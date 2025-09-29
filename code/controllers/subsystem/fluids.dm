// Flags indicating what parts of the fluid the subsystem processes.
/// Indicates that a fluid subsystem processes fluid spreading.
#define SS_PROCESSES_SPREADING (1<<0)
/// Indicates that a fluid subsystem processes fluid effects.
#define SS_PROCESSES_EFFECTS (1<<1)

/**
 * # Fluid Subsystem
 *
 * A subsystem that processes the propagation and effects of a particular fluid.
 *
 * Both fluid spread and effect processing are handled through a carousel system.
 * Fluids being spread and fluids being processed are organized into buckets.
 * Each fresh (non-resumed) fire one bucket of each is selected to be processed.
 * These selected buckets are then fully processed.
 * The next fresh fire selects the next bucket in each set for processing.
 * If this would walk off the end of a carousel list we wrap back to the first element.
 * This effectively makes each set a circular list, hence a carousel.
 */
SUBSYSTEM_DEF(fluids)
	name = "Fluid"
	wait = 0 // Will be autoset to whatever makes the most sense given the spread and effect waits.
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_FLUIDS

	// Fluid spread processing:
	/// The amount of time (in deciseconds) before a fluid node is created and when it spreads.
	var/spread_wait = 1 SECONDS
	/// The number of buckets in the spread carousel.
	var/num_spread_buckets
	/// The set of buckets containing fluid nodes to spread.
	var/list/spread_carousel
	/// The index of the spread carousel bucket currently being processed.
	var/spread_bucket_index
	/// The set of turfs that have active fluid components and need processing.
	var/list/active_fluid_turfs = list()

/datum/controller/subsystem/fluids/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_BREACH_CREATED, .proc/onBreachCreated)
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, .proc/onBreachRepaired)

/datum/controller/subsystem/fluids/Destroy()
	UnregisterSignal(src, COMSIG_BREACH_CREATED)
	UnregisterSignal(src, COMSIG_BREACH_REPAIRED)
	. = ..()

/datum/controller/subsystem/fluids/proc/onBreachCreated(datum/component/breach/breach_comp, turf/location, flow_rate)
	var/datum/component/fluid/fluid_comp = location.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = location.AddComponent(/datum/component/fluid)
	if (fluid_comp)
		fluid_comp.addFluid(flow_rate, T20C) // Add initial fluid from breach
		add_active_fluid_turf(location)

/datum/controller/subsystem/fluids/proc/onBreachRepaired(datum/component/breach/breach_comp, turf/location)
	// When a breach is repaired, the fluid flow from that source stops.
	// The existing fluid will still be processed until it evaporates or flows away.
	return

/datum/controller/subsystem/fluids/proc/add_active_fluid_turf(turf/T)
	if (!active_fluid_turfs[T])
		active_fluid_turfs[T] = TRUE
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, T)

/datum/controller/subsystem/fluids/proc/remove_active_fluid_turf(turf/T)
	if (active_fluid_turfs[T])
		active_fluid_turfs -= T
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, T)

/datum/controller/subsystem/fluids/fire(resumed)
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time

	var/list/turfs_to_process = active_fluid_turfs.Copy()
	for(var/turf/T in turfs_to_process)
		if (QDELETED(T))
			remove_active_fluid_turf(T)
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_DELETING)
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
				fluid_comp_below = turf_below.AddComponent(/datum/component/fluid)

			if (fluid_comp_below)
				var/transfer_amount = min(fluid_comp.fluid_amount * 0.1, (FLUID_MAX_DEPTH - fluid_comp_below.fluid_amount)) // Transfer 10% or until full below
				if (transfer_amount > 0)
					fluid_comp.removeFluid(transfer_amount)
					fluid_comp_below.addFluid(transfer_amount, fluid_comp.temperature)
					add_active_fluid_turf(turf_below)

		// Lateral equalization
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor_turf = get_step(T, direction)
			if (!neighbor_turf || !T.CanFluidPass(direction))
				continue

			var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
			if (!neighbor_fluid_comp)
				neighbor_fluid_comp = neighbor_turf.AddComponent(/datum/component/fluid)

			if (neighbor_fluid_comp)
				var/diff = fluid_comp.fluid_amount - neighbor_fluid_comp.fluid_amount
				if (diff > FLUID_EVAPORATION_POINT) // Only flow if significant difference
					var/transfer_amount = diff * 0.1 // Transfer 10% of the difference
					fluid_comp.removeFluid(transfer_amount)
					neighbor_fluid_comp.addFluid(transfer_amount, fluid_comp.temperature)
					add_active_fluid_turf(neighbor_turf)

		// --- Fluid Effects (Evaporation, Interactions) ---
		// Evaporation in space
		if (isspaceturf(T))
			fluid_comp.removeFluid(max((FLUID_EVAPORATION_POINT-1), fluid_comp.fluid_amount * 0.05 * delta_time)) // 5% per second

		// If fluid is still active, ensure it's in the active list
		if (fluid_comp.fluid_amount > FLUID_DELETING)
			add_active_fluid_turf(T)
		else
			remove_active_fluid_turf(T)

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fluids/proc/queue_spread(obj/effect/particle_effect/fluid/node)
	// This method is no longer directly used for spreading logic,
	// as fluid spread is now handled by the subsystem iterating over turfs.
	// However, we might still use it to mark a turf as "active" for processing.
	var/turf/T = get_turf(node)
	if (T)
		add_active_fluid_turf(T)

/datum/controller/subsystem/fluids/proc/cancel_spread(obj/effect/particle_effect/fluid/node)
	// This method is no longer directly used.
	return

/datum/controller/subsystem/fluids/proc/start_processing(obj/effect/particle_effect/fluid/node)
	// This method is no longer directly used for effect processing logic.
	// Effects are handled by the subsystem iterating over turfs.
	var/turf/T = get_turf(node)
	if (T)
		add_active_fluid_turf(T)

/datum/controller/subsystem/fluids/proc/stop_processing(obj/effect/particle_effect/fluid/node)
	// This method is no longer directly used.
	return

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS


// Subtypes:

/// The subsystem responsible for processing smoke propagation and effects.
FLUID_SUBSYSTEM_DEF(smoke)
	name = "Smoke"
	spread_wait = 0.1 SECONDS

/// The subsystem responsible for processing foam propagation and effects.
FLUID_SUBSYSTEM_DEF(foam)
	name = "Foam"
	wait = 0.1 SECONDS // Makes effect bubbling work with foam.
	spread_wait = 0.2 SECONDS
