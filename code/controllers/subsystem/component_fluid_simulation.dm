/*
* Component-Based Fluid Simulation Subsystem (As opposed to stuff like Foam/Smoke which are "technically" fluids, but not really)
* Handles fluid dynamics for specific fluid types using components attached to turfs.
*
* Ideas for later;
* More Fluid Interactions with machines/people, not every reagent should autoabsorb into bloodstream (Wading through blood does not absorb all of the blood, for ex.)
*
* Electricity, shorting out machines water touches, being more conductive/damaging (maybe poor for saltwater?). I forget the rule for fluid conductivity,
* all I remember is Wiedemann-Franz.
*/

#define SS_PROCESSES_SPREADING (1<<0)
#define SS_PROCESSES_EFFECTS (1<<1)

/// If TRUE, the fluid simulation will show debug messages to admins.
GLOBAL_VAR_INIT(fluid_debug_enabled, FALSE)

SUBSYSTEM_DEF(component_fluid_simulation)
	name = "Component Fluid Simulation"
	wait = 5
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS

	/// A static, global list of all turfs with any active fluid, managed by all simulation subsystems.
	var/static/list/global_active_fluid_turfs = list()

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
	if (!global_active_fluid_turfs)
		global_active_fluid_turfs = list()
	initialize_simulation_carousel()
	RegisterSignal(src, COMSIG_BREACH_CREATED, PROC_REF(onBreachCreated))
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, PROC_REF(onBreachRepaired))
	SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_READY, src) // Signal that this simulation subsystem is ready

/datum/controller/subsystem/component_fluid_simulation/Destroy()
	UnregisterSignal(src, COMSIG_BREACH_CREATED)
	UnregisterSignal(src, COMSIG_BREACH_REPAIRED)
	qdel(simulation_carousel)
	qdel(turf_to_bucket_map)
	. = ..()

/datum/controller/subsystem/component_fluid_simulation/proc/initialize_simulation_carousel()
	// We'll use a fixed number of buckets for now, e.g., 10, to distribute the load.
	// This can be made dynamic based on `wait` or other factors if needed.
	num_simulation_buckets = 10
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: Initializing carousel with [num_simulation_buckets] buckets."))
	simulation_carousel = list()
	simulation_carousel.len = num_simulation_buckets
	for(var/i in 1 to num_simulation_buckets)
		simulation_carousel[i] = list()
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("ComponentFluidSimulation: Bucket [i] initialized as [simulation_carousel[i]]."))
	simulation_bucket_index = 1

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachCreated(datum/component/breach/breach_comp, turf/location, flow_rate)
	var/datum/component/fluid/fluid_comp = location.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = location.AddComponent(/datum/component/fluid)

	if (fluid_comp)
		fluid_comp.reagents.add_reagent(/datum/reagent/water, flow_rate) // Breaches create water by default for now
		add_active_fluid_turf(location)

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachRepaired(datum/component/breach/breach_comp, turf/location)
	// When a breach is repaired, the fluid flow from that source stops.
	// The existing fluid will still be processed until it evaporates or flows away.
	return

/datum/controller/subsystem/component_fluid_simulation/proc/add_active_fluid_turf(turf/T)
	if (!turf_to_bucket_map[T]) // Check if turf is already active
		var/bucket_index = rand(1, num_simulation_buckets)

		// Ensure the target bucket is a list before adding.
		if (!istype(simulation_carousel[bucket_index], /list))
			simulation_carousel[bucket_index] = list()

		var/list/temp_bucket = simulation_carousel[bucket_index]
		temp_bucket.Add(T)
		turf_to_bucket_map[T] = bucket_index // Store the bucket index, not the list reference

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
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("ComponentFluidSimulation: Removed turf [T] from active list"))

		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, T)

/datum/controller/subsystem/component_fluid_simulation/fire(resumed)
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
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: Finished processing. Next bucket: [simulation_bucket_index]"))

/datum/controller/subsystem/component_fluid_simulation/proc/_process_simulation_logic()
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: fire() called. Processing bucket [simulation_bucket_index]"))

	var/list/current_simulation_bucket = simulation_carousel[simulation_bucket_index]
	var/list/turfs_to_process_in_bucket = current_simulation_bucket.Copy()
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: Processing [turfs_to_process_in_bucket.len] turfs in bucket [simulation_bucket_index]."))

	for(var/turf/T in turfs_to_process_in_bucket)
		var/datum/component/fluid/fluid_comp = process_turf_validation(T)
		if (!fluid_comp)
			continue

		process_lateral_spreading(T, fluid_comp)
		process_downward_flow(T, fluid_comp)
		process_turf_effects(T, fluid_comp, delta_time)

		if (MC_TICK_CHECK)
			return // We use return to exit early, the wrapper will handle the flag

	process_fluid_sources(delta_time)

/datum/controller/subsystem/component_fluid_simulation/proc/process_turf_validation(turf/T)
	if (QDELETED(T))
		remove_active_fluid_turf(T)
		return null

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (!fluid_comp || fluid_comp.getFluidAmount() <= FLUID_DELETING)
		remove_active_fluid_turf(T)
		return null

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: Processing turf [T] (fluid amount: [fluid_comp.fluid_amount])"))
	return fluid_comp

/datum/controller/subsystem/component_fluid_simulation/proc/process_downward_flow(turf/T, datum/component/fluid/fluid_comp)
	var/turf/turf_below = GetBelow(T)
	if (turf_below && T.CanFluidPass(DOWN))
		var/datum/component/fluid/fluid_comp_below = turf_below.GetComponent(/datum/component/fluid)
		if (!fluid_comp_below)
			fluid_comp_below = turf_below.AddComponent(/datum/component/fluid)
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("ComponentFluidSimulation: Added FluidComponent to turf below [turf_below]"))

		var/viscosity_multiplier = 1 / fluid_comp.get_viscosity()
		var/transfer_amount = min(fluid_comp.getFluidAmount() * 0.1 * viscosity_multiplier, (FLUID_MAX_DEPTH - fluid_comp_below.getFluidAmount()))
		if (transfer_amount > 0)
		{
			fluid_comp.reagents.copy_to(fluid_comp_below, transfer_amount)
			fluid_comp.removeFluid(transfer_amount)
			add_active_fluid_turf(turf_below)
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("ComponentFluidSimulation: Transferred [transfer_amount] fluid from [T] to [turf_below] (downward flow)"))
		}

/datum/controller/subsystem/component_fluid_simulation/proc/process_lateral_spreading(turf/T, datum/component/fluid/fluid_comp)
	for (var/direction in GLOB.alldirs)
		var/turf/neighbor_turf = get_step(T, direction)
		if (!neighbor_turf || !T.CanFluidPass(direction) || !neighbor_turf.CanFluidPass(get_dir(neighbor_turf, T)))
			continue

		var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
		if (!neighbor_fluid_comp)
			neighbor_fluid_comp = neighbor_turf.AddComponent(/datum/component/fluid)

		var/fluid_diff = fluid_comp.getFluidAmount() - neighbor_fluid_comp.getFluidAmount()
		if (fluid_diff <= 0)
			continue

		var/viscosity_multiplier = 1 / fluid_comp.get_viscosity()

		// Pressure-Based Flow & Hydrostatic Leveling for deeper fluids

		// Pressure is proportional to the difference in fluid levels (fluid_diff)
		var/pressure_factor = 1 + (fluid_diff / FLUID_MAX_DEPTH)

		// Directional factor: diagonal flow is slower
		var/spread_factor = (direction in GLOB.alldirs) ? 1 : (1 / sqrt(2))

		// Momentum factor: fluid prefers to flow in its current direction
		var/dir_x = (direction & 3) - 2 // EAST=1, WEST=-1, other=0
		var/dir_y = (direction & 12) / 4 - 2 // NORTH=1, SOUTH=-1, other=0
		var/momentum_factor = 1 + (fluid_comp.momentum_x * dir_x + fluid_comp.momentum_y * dir_y)
		momentum_factor = max(0.1, momentum_factor) // Ensure momentum doesn't completely stop the flow

		var/transfer_amount = min(fluid_diff / 2, fluid_comp.getFluidAmount() * 0.5) * viscosity_multiplier * pressure_factor * spread_factor * momentum_factor

		if (transfer_amount > 0.1) // Minimum transfer threshold
		{
			var/datum/reagents/transfer_reagents = new()
			var/fraction = transfer_amount / fluid_comp.getFluidAmount()
			for(var/datum/reagent/R in fluid_comp.reagents.reagent_list)
				transfer_reagents.add_reagent(R.type, R.volume * fraction)

			neighbor_fluid_comp.addFluid(transfer_amount, fluid_comp.getTemperature(), fluid_comp.momentum_x, fluid_comp.momentum_y, transfer_reagents)
			fluid_comp.removeFluid(transfer_amount)
			qdel(transfer_reagents)
			add_active_fluid_turf(neighbor_turf)
			// The neighbor's addFluid will mark it as dirty, continuing the spread
		}

/datum/controller/subsystem/component_fluid_simulation/proc/process_turf_effects(turf/T, datum/component/fluid/fluid_comp, delta_time)

	// Evaporation in space
	if (isspaceturf(T))
		fluid_comp.removeFluid(fluid_comp.getFluidAmount()) // Instant evaporation
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("ComponentFluidSimulation: Evaporating fluid on space turf [T]"))

	// Drain fluid if a DrainComponent is present
	var/datum/component/drain/drain_comp = T.GetComponent(/datum/component/drain)
	if (drain_comp)
		drain_comp.drain_fluid(fluid_comp, delta_time)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("ComponentFluidSimulation: Draining fluid on turf [T]"))

	// Update active turf status
	if (fluid_comp.fluid_amount <= FLUID_DELETING)
		remove_active_fluid_turf(T)

	// Decay momentum
	fluid_comp.momentum_x *= (1 - fluid_comp.momentum_decay)
	fluid_comp.momentum_y *= (1 - fluid_comp.momentum_decay)

/datum/controller/subsystem/component_fluid_simulation/proc/process_fluid_sources(delta_time)
	// Process all fluid sources from the dedicated list to ensure they are always active.
	for(var/turf/T_source in active_fluid_sources)
		var/datum/component/fluid_source/source_comp = T_source.GetComponent(/datum/component/fluid_source)
		if (source_comp && source_comp.is_active)
			source_comp.ProcessSource(delta_time)
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("ComponentFluidSimulation: Processing FluidSourceComponent on turf [T_source]"))

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS
