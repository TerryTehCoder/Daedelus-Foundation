#define SS_PROCESSES_SPREADING (1<<0)
#define SS_PROCESSES_EFFECTS (1<<1)

SUBSYSTEM_DEF(component_fluid_simulation)
	name = "Component Fluid Simulation"
	wait = 1 // Set to 1 decisecond to ensure delta_time is positive and simulation runs every tick.
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS

	/// A static map to retrieve ComponentFluidSimulationSubsystem instances by their simulated_fluid_type.
	var/static/list/all_fluid_simulations = list()

	/// The type of fluid this subsystem is responsible for simulating.
	var/datum/fluid/simulated_fluid_type

	/// The set of turfs that have active fluid components of `simulated_fluid_type` and need processing.
	var/list/active_fluid_turfs = list() // This will now be a map for quick lookup

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

	/// A list of turfs that have had their fluid components modified and need re-evaluation for lateral diffusion.
	var/list/dirty_turfs = list()

/datum/controller/subsystem/component_fluid_simulation/Initialize()
	. = ..()
	initialize_simulation_carousel()
	RegisterSignal(src, COMSIG_BREACH_CREATED, PROC_REF(onBreachCreated))
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, PROC_REF(onBreachRepaired))
	RegisterSignal(src, COMSIG_FLUID_COMPONENT_DIRTY, PROC_REF(onFluidComponentDirty))

	if (simulated_fluid_type)
		all_fluid_simulations[simulated_fluid_type] = src

/datum/controller/subsystem/component_fluid_simulation/Destroy()
	UnregisterSignal(src, COMSIG_BREACH_CREATED)
	UnregisterSignal(src, COMSIG_BREACH_REPAIRED)
	UnregisterSignal(src, COMSIG_FLUID_COMPONENT_DIRTY)
	if (simulated_fluid_type && all_fluid_simulations[simulated_fluid_type] == src)
		all_fluid_simulations -= simulated_fluid_type
	qdel(simulation_carousel)
	qdel(turf_to_bucket_map)
	qdel(dirty_turfs)
	. = ..()

/datum/controller/subsystem/component_fluid_simulation/proc/initialize_simulation_carousel()
	// We'll use a fixed number of buckets for now, e.g., 10, to distribute the load.
	// This can be made dynamic based on `wait` or other factors if needed.
	num_simulation_buckets = 10
	simulation_carousel = list(num_simulation_buckets)
	for(var/i in 1 to num_simulation_buckets)
		simulation_carousel[i] = list()
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
		var/bucket_index = rand(1, num_simulation_buckets)
		simulation_carousel[bucket_index] += T
		turf_to_bucket_map[T] = simulation_carousel[bucket_index] // Store reference to its bucket
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Added turf [T] to active list (bucket [bucket_index])"))
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): DEBUG: add_active_fluid_turf called for [T]. Bucket: [bucket_index]. Total active turfs: [LAZYLEN(turf_to_bucket_map)]"))


		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, T)
	// Mark turf as dirty to ensure lateral diffusion is re-evaluated
	onFluidComponentDirty(null, T)

/datum/controller/subsystem/component_fluid_simulation/proc/remove_active_fluid_turf(turf/T)
	var/list/bucket = turf_to_bucket_map[T]
	if (bucket)
		bucket -= T
		turf_to_bucket_map -= T
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Removed turf [T] from active list"))

		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, T)

/datum/controller/subsystem/component_fluid_simulation/fire(resumed)
	if(currently_simulating)
		return

	currently_simulating = TRUE
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): fire() called. Processing bucket [simulation_bucket_index]"))

	var/list/current_simulation_bucket = simulation_carousel[simulation_bucket_index]
	var/list/turfs_to_process_in_bucket = current_simulation_bucket.Copy() // Iterate over a copy to allow modification of original bucket
	var/list/turfs_to_process_dirty = dirty_turfs.Copy() // Process dirty turfs separately
	dirty_turfs.Cut() // Clear dirty turfs for next tick
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing [turfs_to_process_in_bucket.len] turfs in bucket [simulation_bucket_index] and [turfs_to_process_dirty.len] dirty turfs."))

	for(var/turf/T in turfs_to_process_in_bucket)
		if (QDELETED(T))
			remove_active_fluid_turf(T)
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_DELETING || fluid_comp.fluid_type_instance.type != simulated_fluid_type)
			remove_active_fluid_turf(T)
			continue

		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing turf [T] (fluid amount: [fluid_comp.fluid_amount])"))

		// --- Fluid Spreading and Equalization ---
		// This is a simplified model. A more complex one would involve pressure and height.
		// For now, we'll simulate basic equalization and downward flow.

		// Downward flow
		var/turf/turf_below = GetBelow(T)
		if (turf_below && T.CanFluidPass(DOWN))
			var/datum/component/fluid/fluid_comp_below = turf_below.GetComponent(/datum/component/fluid)
			if (!fluid_comp_below)
				fluid_comp_below = turf_below.AddComponent(/datum/component/fluid, fluid_type_instance = new simulated_fluid_type)
				message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Added FluidComponent to turf below [turf_below]"))
			else if (fluid_comp_below.fluid_type_instance.type != simulated_fluid_type)
				// Cannot transfer to a turf with a different fluid type
				message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Cannot transfer fluid to turf below [turf_below] due to different fluid type."))
				turf_below = null // Prevent further processing for this direction

			if (fluid_comp_below)
				var/datum/fluid/temp_fluid_viscosity_down = new fluid_comp.fluid_type_instance.type
				var/viscosity_multiplier = 1 / temp_fluid_viscosity_down.viscosity // Higher viscosity = lower multiplier
				qdel(temp_fluid_viscosity_down)
				var/transfer_amount = min(fluid_comp.fluid_amount * 0.1 * viscosity_multiplier, (FLUID_MAX_DEPTH - fluid_comp_below.fluid_amount)) // Transfer 10% or until full below
				if (transfer_amount > 0)
					fluid_comp.removeFluid(transfer_amount)
					fluid_comp_below.addFluid(transfer_amount, fluid_comp.temperature)
					add_active_fluid_turf(turf_below)
					message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Transferred [transfer_amount] fluid from [T] to [turf_below] (downward flow)"))

		// Lateral equalization (only for dirty turfs or their neighbors)
		if (T in turfs_to_process_dirty || fluid_comp.is_dirty)
			fluid_comp.is_dirty = FALSE // Reset dirty flag
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing lateral diffusion for dirty turf [T]"))
			for(var/direction in GLOB.cardinals)
				var/turf/neighbor_turf = get_step(T, direction)
				if (!neighbor_turf || !T.CanFluidPass(direction)) // Call the new proc
					continue

				var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
				if (!neighbor_fluid_comp)
					neighbor_fluid_comp = neighbor_turf.AddComponent(/datum/component/fluid, fluid_type_instance = new simulated_fluid_type)
					message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Added FluidComponent to neighbor turf [neighbor_turf]"))
				else if (neighbor_fluid_comp.fluid_type_instance.type != simulated_fluid_type)
					// Cannot transfer to a turf with a different fluid type
					message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Cannot transfer fluid to neighbor [neighbor_turf] due to different fluid type."))
					continue

				if (neighbor_fluid_comp)
					var/diff = fluid_comp.fluid_amount - neighbor_fluid_comp.fluid_amount
					if (diff > FLUID_EVAPORATION_POINT) // Only flow if significant difference
						message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): DEBUG: Lateral flow condition met for [T] to [neighbor_turf]. Diff: [diff]"))
						var/datum/fluid/temp_fluid_viscosity_lateral = new fluid_comp.fluid_type_instance.type
						var/viscosity_multiplier = 1 / temp_fluid_viscosity_lateral.viscosity
						qdel(temp_fluid_viscosity_lateral)
						var/transfer_amount = diff * 0.1 * viscosity_multiplier // Transfer 10% of the difference
						fluid_comp.removeFluid(transfer_amount)
						neighbor_fluid_comp.addFluid(transfer_amount, fluid_comp.temperature)
						add_active_fluid_turf(neighbor_turf)
						// Mark neighbor as dirty if fluid was transferred
						onFluidComponentDirty(null, neighbor_turf)
						message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Transferred [transfer_amount] fluid from [T] to [neighbor_turf] (lateral flow)"))

		// --- Fluid Effects (Evaporation, Interactions) ---
		// Evaporation in space
		if (isspaceturf(T))
			fluid_comp.removeFluid(max((FLUID_EVAPORATION_POINT-1), fluid_comp.fluid_amount * 0.05 * delta_time)) // 5% per second
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Evaporating fluid on space turf [T]"))

		// Drain fluid if a DrainComponent is present
		var/datum/component/drain/drain_comp = T.GetComponent(/datum/component/drain)
		if (drain_comp)
			drain_comp.drain_fluid(fluid_comp, delta_time)
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Draining fluid on turf [T]"))

		// If fluid is still active, ensure it's in the active list
		if (fluid_comp.fluid_amount > FLUID_DELETING)
			add_active_fluid_turf(T)
		else
			remove_active_fluid_turf(T)

		// Process FluidSourceComponents on this turf
		var/datum/component/fluid_source/fluid_source_comp = T.GetComponent(/datum/component/fluid_source)
		if (fluid_source_comp && fluid_source_comp.is_active && fluid_source_comp.generated_fluid_type == simulated_fluid_type)
			fluid_source_comp.ProcessSource(delta_time)
			add_active_fluid_turf(T) // Ensure turf remains active if it has an active source
			message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Processing FluidSourceComponent on turf [T]"))

		if (MC_TICK_CHECK)
			break // Break out of the current bucket processing if tick budget is hit

	currently_simulating = FALSE

	simulation_bucket_index++
	if(simulation_bucket_index > num_simulation_buckets)
		simulation_bucket_index = 1
	message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): Finished processing bucket. Next bucket: [simulation_bucket_index]"))


/datum/controller/subsystem/component_fluid_simulation/proc/onFluidComponentDirty(datum/component/fluid/fluid_comp, turf/T)
	if (!dirty_turfs[T])
		dirty_turfs += T
		message_admins(span_notice("ComponentFluidSimulation ([simulated_fluid_type]): DEBUG: onFluidComponentDirty called for [T]. Total dirty turfs: [LAZYLEN(dirty_turfs)]"))

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS

// Specific instances of the component-based fluid simulation
COMPONENT_FLUID_SUBSYSTEM_DEF(water_simulation)
	name = "Water Fluid Simulation"
	simulated_fluid_type = /datum/fluid/water
	wait = 1
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
