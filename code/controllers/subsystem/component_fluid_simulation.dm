#define SS_PROCESSES_SPREADING (1<<0)
#define SS_PROCESSES_EFFECTS (1<<1)

SUBSYSTEM_DEF(component_fluid_simulation)
	name = "Component Fluid Simulation"
	wait = 0 // Will be autoset based on specific fluid type needs
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
	RegisterSignal(src, COMSIG_BREACH_CREATED, .proc/onBreachCreated)
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, .proc/onBreachRepaired)
	RegisterSignal(src, COMSIG_FLUID_COMPONENT_DIRTY, .proc/onFluidComponentDirty)

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
		fluid_comp = location.AddComponent(/datum/component/fluid, .args = list(fluid_type = simulated_fluid_type))
	else if (fluid_comp.fluid_type != simulated_fluid_type)
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
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, T)
	// Mark turf as dirty to ensure lateral diffusion is re-evaluated
	onFluidComponentDirty(null, T)

/datum/controller/subsystem/component_fluid_simulation/proc/remove_active_fluid_turf(turf/T)
	var/list/bucket = turf_to_bucket_map[T]
	if (bucket)
		bucket -= T
		turf_to_bucket_map -= T
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, T)

/datum/controller/subsystem/component_fluid_simulation/fire(resumed)
	if(currently_simulating)
		return

	currently_simulating = TRUE
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time

	var/list/current_simulation_bucket = simulation_carousel[simulation_bucket_index]
	var/list/turfs_to_process_in_bucket = current_simulation_bucket.Copy() // Iterate over a copy to allow modification of original bucket
	var/list/turfs_to_process_dirty = dirty_turfs.Copy() // Process dirty turfs separately
	dirty_turfs.Cut() // Clear dirty turfs for next tick

	for(var/turf/T in turfs_to_process_in_bucket)
		if (QDELETED(T))
			remove_active_fluid_turf(T)
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_DELETING || fluid_comp.fluid_type != simulated_fluid_type)
			remove_active_fluid_turf(T)
			continue

		// --- Fluid Spreading and Equalization ---
		// This is a simplified model. A more complex one would involve pressure and height.
		// For now, we'll simulate basic equalization and downward flow.

		// Downward flow
		var/turf/turf_below = GetBelow(T)
		if (turf_below && T.CanFluidPass(DOWN))
			var/datum/component/fluid/fluid_comp_below = turf_below.GetComponent(/datum/component/fluid)
			if (!fluid_comp_below)
				fluid_comp_below = turf_below.AddComponent(/datum/component/fluid, .args = list(fluid_type = simulated_fluid_type))
			else if (fluid_comp_below.fluid_type != simulated_fluid_type)
				// Cannot transfer to a turf with a different fluid type
				turf_below = null // Prevent further processing for this direction

			if (fluid_comp_below)
				var/viscosity_multiplier = 1 / fluid_comp.fluid_type.viscosity // Higher viscosity = lower multiplier
				var/transfer_amount = min(fluid_comp.fluid_amount * 0.1 * viscosity_multiplier, (FLUID_MAX_DEPTH - fluid_comp_below.fluid_amount)) // Transfer 10% or until full below
				if (transfer_amount > 0)
					fluid_comp.removeFluid(transfer_amount)
					fluid_comp_below.addFluid(transfer_amount, fluid_comp.temperature)
					add_active_fluid_turf(turf_below)

		// Lateral equalization (only for dirty turfs or their neighbors)
		if (T in turfs_to_process_dirty || fluid_comp.is_dirty)
			fluid_comp.is_dirty = FALSE // Reset dirty flag
			for(var/direction in GLOB.cardinal)
				var/turf/neighbor_turf = get_step(T, direction)
				if (!neighbor_turf || !T.CanFluidPass(direction))
					continue

				var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
				if (!neighbor_fluid_comp)
					neighbor_fluid_comp = neighbor_turf.AddComponent(/datum/component/fluid, .args = list(fluid_type = simulated_fluid_type))
				else if (neighbor_fluid_comp.fluid_type != simulated_fluid_type)
					// Cannot transfer to a turf with a different fluid type
					continue

				if (neighbor_fluid_comp)
					var/diff = fluid_comp.fluid_amount - neighbor_fluid_comp.fluid_amount
					if (diff > FLUID_EVAPORATION_POINT) // Only flow if significant difference
						var/viscosity_multiplier = 1 / fluid_comp.fluid_type.viscosity // Higher viscosity = lower multiplier
						var/transfer_amount = diff * 0.1 * viscosity_multiplier // Transfer 10% of the difference
						fluid_comp.removeFluid(transfer_amount)
						neighbor_fluid_comp.addFluid(transfer_amount, fluid_comp.temperature)
						add_active_fluid_turf(neighbor_turf)
						// Mark neighbor as dirty if fluid was transferred
						onFluidComponentDirty(null, neighbor_turf)

		// --- Fluid Effects (Evaporation, Interactions) ---
		// Evaporation in space
		if (isspaceturf(T))
			fluid_comp.removeFluid(max((FLUID_EVAPORATION_POINT-1), fluid_comp.fluid_amount * 0.05 * delta_time)) // 5% per second

		// Drain fluid if a DrainComponent is present
		var/datum/component/drain/drain_comp = T.GetComponent(/datum/component/drain)
		if (drain_comp)
			drain_comp.drain_fluid(fluid_comp, delta_time)

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

		if (MC_TICK_CHECK)
			break // Break out of the current bucket processing if tick budget is hit

	currently_simulating = FALSE

	simulation_bucket_index++
	if(simulation_bucket_index > num_simulation_buckets)
		simulation_bucket_index = 1

/datum/controller/subsystem/component_fluid_simulation/proc/queue_spread(obj/effect/particle_effect/fluid/node)
	// This method is called by obj/effect/particle_effect/fluid to activate simulation for its turf.
	var/turf/T = get_turf(node)
	if (T)
		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (fluid_comp && fluid_comp.fluid_type == simulated_fluid_type)
			add_active_fluid_turf(T)

/datum/controller/subsystem/component_fluid_simulation/proc/cancel_spread(obj/effect/particle_effect/fluid/node)
	var/turf/T = get_turf(node)
	if (T)
		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (fluid_comp && fluid_comp.fluid_type == simulated_fluid_type)
			remove_active_fluid_turf(T)

/datum/controller/subsystem/component_fluid_simulation/proc/start_processing(obj/effect/particle_effect/fluid/node)
	// Same as queue_spread for component-based system
	queue_spread(node)

/datum/controller/subsystem/component_fluid_simulation/proc/stop_processing(obj/effect/particle_effect/fluid/node)
	// Same as cancel_spread for component-based system
	cancel_spread(node)

/datum/controller/subsystem/component_fluid_simulation/proc/onFluidComponentDirty(datum/component/fluid/fluid_comp, turf/T)
	if (!dirty_turfs[T])
		dirty_turfs += T

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS

// Specific instances of the component-based fluid simulation
FLUID_SUBSYSTEM_DEF(water_simulation)
	name = "Water Fluid Simulation"
	simulated_fluid_type = /datum/fluid/water
	wait = 0 // Let the base subsystem handle the wait, or set a specific one
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS

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
