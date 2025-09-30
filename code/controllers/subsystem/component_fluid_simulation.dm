#define SS_PROCESSES_SPREADING (1<<0)
#define SS_PROCESSES_EFFECTS (1<<1)

SUBSYSTEM_DEF(component_fluid_simulation)
	name = "Component Fluid Simulation"
	wait = 10
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS

	/// A static map to retrieve ComponentFluidSimulationSubsystem instances by their simulated_fluid_type.
	var/static/list/all_fluid_simulations = list()

	/// A static, global list of all turfs with any active fluid, managed by all simulation subsystems.
	var/static/list/global_active_fluid_turfs = list()

	/// The type of fluid this subsystem is responsible for simulating.
	var/datum/fluid/simulated_fluid_type

	// Carousel system for distributing processing
	/// The number of buckets in the simulation carousel.
	var/num_simulation_buckets
	/// The set of buckets containing turfs to simulate.
	var/list/simulation_carousel
	/// The index of the simulation carousel bucket currently being processed.
	var/simulation_bucket_index
	/// Whether the simulation carousel is currently being processed.
	var/currently_simulating

	/// A map to quickly find which bucket a turf belongs to.
	var/list/turf_to_bucket_map = list()

	/// A dedicated list of turfs with active FluidSourceComponents to ensure they are always processed.
	var/list/active_fluid_sources = list()

/datum/controller/subsystem/component_fluid_simulation/Initialize()
	. = ..()
	if (!simulated_fluid_type) // This is an abstract base type, DO NOT LET THIS RUN.
		return
	if (!global_active_fluid_turfs)
		global_active_fluid_turfs = list()
	initialize_simulation_carousel()
	RegisterSignal(src, COMSIG_BREACH_CREATED, PROC_REF(onBreachCreated))
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, PROC_REF(onBreachRepaired))
	RegisterSignal(SSdcs, COMSIG_GLOB_FLUID_COMPONENT_DIRTY, PROC_REF(onFluidComponentDirty))

	if (simulated_fluid_type)
		all_fluid_simulations[simulated_fluid_type] = src
	SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_READY, src) // Signal that this simulation subsystem is ready

/datum/controller/subsystem/component_fluid_simulation/Destroy()
	UnregisterSignal(src, COMSIG_BREACH_CREATED)
	UnregisterSignal(src, COMSIG_BREACH_REPAIRED)
	UnregisterSignal(SSdcs, COMSIG_GLOB_FLUID_COMPONENT_DIRTY)
	if (simulated_fluid_type && all_fluid_simulations[simulated_fluid_type] == src)
		all_fluid_simulations -= simulated_fluid_type
	qdel(simulation_carousel)
	qdel(turf_to_bucket_map)
	. = ..()

/datum/controller/subsystem/component_fluid_simulation/proc/initialize_simulation_carousel()
	// We'll use a fixed number of buckets for now, e.g., 10, to distribute the load.
	// This can be made dynamic based on `wait` or other factors if needed.
	num_simulation_buckets = 10
	message_admins(span_notice("ComponentFluidSimulation: Initializing carousel with [num_simulation_buckets] buckets."))
	simulation_carousel = list(num_simulation_buckets)
	for(var/i in 1 to num_simulation_buckets)
		simulation_carousel[i] = list()
		message_admins(span_notice("ComponentFluidSimulation: Bucket [i] initialized as [simulation_carousel[i]]."))
	simulation_bucket_index = 1

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachCreated(datum/component/breach/breach_comp, turf/location, flow_rate)
	if (!simulated_fluid_type)
		return

	var/datum/component/fluid/fluid_comp = location.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = location.AddComponent(/datum/component/fluid, fluid_type_instance = new simulated_fluid_type)
	else if (fluid_comp.fluid_type_instance.type != simulated_fluid_type)
		// If a different fluid type is already present, we don't mix or override it from a breach.
		return

	if (fluid_comp)
		fluid_comp.addFluid(flow_rate, T20C) // Add initial fluid from breach
		add_active_fluid_turf(location)

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachRepaired(datum/component/breach/breach_comp, turf/location)
	// When a breach is repaired, the fluid flow from that source stops.
	// The existing fluid will still be processed until it evaporates or flows away.
	return

/datum/controller/subsystem/component_fluid_simulation/proc/add_active_fluid_turf(turf/T)
	if (!turf_to_bucket_map[T]) // Check if turf is already active
		message_admins(span_notice("ComponentFluidSimulation: add_active_fluid_turf called for [T]. num_simulation_buckets: [num_simulation_buckets]."))
		var/bucket_index = rand(1, num_simulation_buckets)
		message_admins(span_notice("ComponentFluidSimulation: Before adding T. Bucket index: [bucket_index]. Target bucket: [simulation_carousel[bucket_index]]. Turf: [T]."))

		// Ensure the target bucket is a list before adding.
		if (!istype(simulation_carousel[bucket_index], /list))
			message_admins(span_warning("ComponentFluidSimulation: Bucket [bucket_index] is not a list! Re-initializing."))
			simulation_carousel[bucket_index] = list()

		var/list/temp_bucket = simulation_carousel[bucket_index]
		temp_bucket.Add(T)
		turf_to_bucket_map[T] = bucket_index // Store the bucket index, not the list reference
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Added turf [T] to active list (bucket [bucket_index])"))
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): DEBUG: add_active_fluid_turf called for [T]. Bucket: [bucket_index]. Total active turfs: [LAZYLEN(turf_to_bucket_map)]"))

		// Mark turf as dirty to ensure lateral diffusion is re-evaluated
		onFluidComponentDirty(null, T)

		global_active_fluid_turfs[T] = TRUE
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, T)

		if (QDELETED(src))
			return

/datum/controller/subsystem/component_fluid_simulation/proc/remove_active_fluid_turf(turf/T)
	var/bucket_index = turf_to_bucket_map[T]
	if (isnum(bucket_index)) // Check if a bucket index was stored
		var/list/bucket = simulation_carousel[bucket_index]
		if (bucket)
			bucket -= T
		turf_to_bucket_map -= T
		global_active_fluid_turfs -= T
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Removed turf [T] from active list"))

		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, T)

/datum/controller/subsystem/component_fluid_simulation/fire(resumed)
	if (!simulated_fluid_type) // This is an abstract base type, do not run.
		return
	if(currently_simulating)
		return

	currently_simulating = TRUE
	// We're essentially mimicking a Try Finally block.
	_process_simulation_logic()
	currently_simulating = FALSE

	// Always advance the carousel, even if the simulation logic was cut short by MC_TICK_CHECK
	simulation_bucket_index++
	if(simulation_bucket_index > num_simulation_buckets)
		simulation_bucket_index = 1
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Finished processing. Next bucket: [simulation_bucket_index]"))

/datum/controller/subsystem/component_fluid_simulation/proc/_process_simulation_logic()
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): fire() called. Processing bucket [simulation_bucket_index]"))

	var/list/current_simulation_bucket = simulation_carousel[simulation_bucket_index]
	var/list/turfs_to_process_in_bucket = current_simulation_bucket.Copy()
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing [turfs_to_process_in_bucket.len] turfs in bucket [simulation_bucket_index]."))

	for(var/turf/T in turfs_to_process_in_bucket)
		var/datum/component/fluid/fluid_comp = process_turf_validation(T)
		if (!fluid_comp)
			continue

		process_downward_flow(T, fluid_comp)
		process_lateral_spreading(T, fluid_comp)
		process_turf_effects(T, fluid_comp, delta_time)

		if (MC_TICK_CHECK)
			return // We use return to exit early, the wrapper will handle the flag

	process_fluid_sources(delta_time)

/datum/controller/subsystem/component_fluid_simulation/proc/process_turf_validation(turf/T)
	if (QDELETED(T))
		remove_active_fluid_turf(T)
		return null

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_DELETING || fluid_comp.fluid_type_instance.type != simulated_fluid_type)
		remove_active_fluid_turf(T)
		return null

	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing turf [T] (fluid amount: [fluid_comp.fluid_amount])"))
	return fluid_comp

/datum/controller/subsystem/component_fluid_simulation/proc/process_downward_flow(turf/T, datum/component/fluid/fluid_comp)
	var/turf/turf_below = GetBelow(T)
	if (turf_below && T.CanFluidPass(DOWN))
		var/datum/component/fluid/fluid_comp_below = turf_below.GetComponent(/datum/component/fluid)
		if (!fluid_comp_below)
			fluid_comp_below = turf_below.AddComponent(/datum/component/fluid, fluid_type_instance = new simulated_fluid_type)
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Added FluidComponent to turf below [turf_below]"))
		else if (fluid_comp_below.fluid_type_instance.type != simulated_fluid_type)
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Cannot transfer fluid to turf below [turf_below] due to different fluid type."))
			return

		var/datum/fluid/temp_fluid_viscosity_down = new fluid_comp.fluid_type_instance.type
		var/viscosity_multiplier = 1 / temp_fluid_viscosity_down.viscosity
		qdel(temp_fluid_viscosity_down)
		var/transfer_amount = min(fluid_comp.fluid_amount * 0.1 * viscosity_multiplier, (FLUID_MAX_DEPTH - fluid_comp_below.fluid_amount))
		if (transfer_amount > 0)
			fluid_comp.removeFluid(transfer_amount)
			fluid_comp_below.addFluid(transfer_amount, fluid_comp.temperature)
			add_active_fluid_turf(turf_below)
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Transferred [transfer_amount] fluid from [T] to [turf_below] (downward flow)"))

/datum/controller/subsystem/component_fluid_simulation/proc/process_lateral_spreading(turf/T, datum/component/fluid/fluid_comp)
	if (!fluid_comp.is_dirty)
		return

	fluid_comp.is_dirty = FALSE // Reset dirty flag for the origin turf

	var/list/equalizing_turfs = list(T)
	var/list/turfs_to_check = list(T)
	var/list/checked_turfs = list(T)

	// Discover all connected turfs with the same fluid type
	while (turfs_to_check.len)
		var/turf/current_turf = turfs_to_check[1]
		turfs_to_check.Remove(current_turf)

		for (var/direction in GLOB.cardinals)
			var/turf/neighbor_turf = get_step(current_turf, direction)
			if (!neighbor_turf || !current_turf.CanFluidPass(direction) || (neighbor_turf in checked_turfs))
				continue

			checked_turfs[neighbor_turf] = TRUE
			var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
			if (!neighbor_fluid_comp)
				neighbor_fluid_comp = neighbor_turf.AddComponent(/datum/component/fluid, fluid_type_instance = new simulated_fluid_type)

			if (neighbor_fluid_comp.fluid_type_instance.type == simulated_fluid_type)
				equalizing_turfs += neighbor_turf
				turfs_to_check += neighbor_turf

	if (equalizing_turfs.len <= 1)
		return

	// Calculate the average fluid level for the group
	var/total_fluid = 0
	for (var/turf/turf_in_group in equalizing_turfs)
		var/datum/component/fluid/comp_in_group = turf_in_group.GetComponent(/datum/component/fluid)
		total_fluid += comp_in_group.fluid_amount

	var/average_fluid = total_fluid / equalizing_turfs.len

	// Apply the average to all turfs in the group
	for (var/turf/turf_to_set in equalizing_turfs)
		var/datum/component/fluid/comp_to_set = turf_to_set.GetComponent(/datum/component/fluid)
		var/datum/fluid/temp_fluid_viscosity = new comp_to_set.fluid_type_instance.type
		var/viscosity_multiplier = 1 / temp_fluid_viscosity.viscosity
		qdel(temp_fluid_viscosity)

		var/amount_to_set = lerp(comp_to_set.fluid_amount, average_fluid, 0.5 * viscosity_multiplier) // Adjust rate of equalization
		var/diff = amount_to_set - comp_to_set.fluid_amount

		if (diff > 0)
			comp_to_set.addFluid(diff, comp_to_set.temperature) // Temperature mixing can be improved later
		else
			comp_to_set.removeFluid(-diff)

		add_active_fluid_turf(turf_to_set)
		onFluidComponentDirty(null, turf_to_set) // Mark neighbors as dirty for the next tick

/datum/controller/subsystem/component_fluid_simulation/proc/process_turf_effects(turf/T, datum/component/fluid/fluid_comp, delta_time)
	// Evaporation in space
	if (isspaceturf(T))
		fluid_comp.removeFluid(max((FLUID_EVAPORATION_POINT-1), fluid_comp.fluid_amount * 0.05 * delta_time)) // 5% per second
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Evaporating fluid on space turf [T]"))

	// Drain fluid if a DrainComponent is present
	var/datum/component/drain/drain_comp = T.GetComponent(/datum/component/drain)
	if (drain_comp)
		drain_comp.drain_fluid(fluid_comp, delta_time)
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Draining fluid on turf [T]"))

	// Update active turf status
	if (fluid_comp.fluid_amount <= FLUID_DELETING)
		remove_active_fluid_turf(T)

/datum/controller/subsystem/component_fluid_simulation/proc/process_fluid_sources(delta_time)
	// Process all fluid sources from the dedicated list to ensure they are always active.
	for(var/turf/T_source in active_fluid_sources)
		var/datum/component/fluid_source/source_comp = T_source.GetComponent(/datum/component/fluid_source)
		if (source_comp && source_comp.is_active && source_comp.generated_fluid_type == simulated_fluid_type)
			source_comp.ProcessSource(delta_time)
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing FluidSourceComponent on turf [T_source]"))


/datum/controller/subsystem/component_fluid_simulation/proc/onFluidComponentDirty(datum/component/fluid/fluid_comp, turf/T)
	add_active_fluid_turf(T)
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): DEBUG: onFluidComponentDirty called for [T]. Adding to active turfs."))

/datum/controller/subsystem/component_fluid_simulation/proc/get_fluid_simulation_subsystem(datum/fluid/fluid_type_to_find)
	return all_fluid_simulations[fluid_type_to_find]

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS

// Specific instances of the component-based fluid simulation
COMPONENT_FLUID_SUBSYSTEM_DEF(water_simulation)
	name = "Water Fluid Simulation"
	simulated_fluid_type = /datum/fluid/water
	wait = 10
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

// Add other fluid simulations here as needed, e.g.:
/*
FLUID_SUBSYSTEM_DEF(lava_simulation)
	name = "Lava Fluid Simulation"
	simulated_fluid_type = /datum/fluid/lava
	wait = 0
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS
*/
