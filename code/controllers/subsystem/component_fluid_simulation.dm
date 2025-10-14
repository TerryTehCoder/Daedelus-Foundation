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

	/// A static, global list of all turfs with any active fluid. Other subsystems may reference this.
	var/static/list/global_active_fluid_turfs = list()
	/// The queue of turfs whose fluid levels have changed and need to be processed.
	var/static/list/dirty_turfs_queue = list()
	/// An associative list for fast checking of whether a turf is already in the dirty queue.
	var/static/list/is_dirty_turf = list()

	/// The maximum number of turfs to process in a single simulation tick.
	var/turfs_to_process_per_tick = 200

	/// Whether the simulation is currently processing.
	var/currently_simulating
	/// A counter to occasionally run expensive pressure calculations.
	var/pressure_calculation_tick = 0

	/// A dedicated list of turfs with active FluidSourceComponents to ensure they are always processed.
	var/list/active_fluid_sources = list()


/datum/controller/subsystem/component_fluid_simulation/Initialize()
	. = ..()
	if (!global_active_fluid_turfs)
		global_active_fluid_turfs = list()
	RegisterSignal(src, COMSIG_BREACH_CREATED, PROC_REF(onBreachCreated))
	RegisterSignal(src, COMSIG_BREACH_REPAIRED, PROC_REF(onBreachRepaired))
	SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_READY, src) // Signal that this simulation subsystem is ready

/datum/controller/subsystem/component_fluid_simulation/Destroy()
	UnregisterSignal(src, COMSIG_BREACH_CREATED)
	UnregisterSignal(src, COMSIG_BREACH_REPAIRED)
	. = ..()

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachCreated(datum/component/breach/breach_comp, turf/location, flow_rate)
	var/datum/component/fluid/fluid_comp = location.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = location.AddComponent(/datum/component/fluid)

	if (fluid_comp)
		fluid_comp.reagents.add_reagent(/datum/reagent/water, flow_rate) // Breaches create water by default for now
		add_dirty_turf(location)

/datum/controller/subsystem/component_fluid_simulation/proc/onBreachRepaired(datum/component/breach/breach_comp, turf/location)
	// When a breach is repaired, the fluid flow from that source stops.
	// The existing fluid will still be processed until it evaporates or flows away.
	return

/datum/controller/subsystem/component_fluid_simulation/proc/add_dirty_turf(turf/T)
	if(!is_dirty_turf[T])
		is_dirty_turf[T] = TRUE
		dirty_turfs_queue.Add(T)

		// Also manage the global list for any other systems that might rely on it.
		if (!global_active_fluid_turfs[T])
			global_active_fluid_turfs[T] = TRUE
			SEND_SIGNAL(src, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, T)
			if (QDELETED(src))
				return

/datum/controller/subsystem/component_fluid_simulation/proc/remove_active_fluid_turf(turf/T)
	if (global_active_fluid_turfs[T])
		global_active_fluid_turfs -= T
		is_dirty_turf -= T // Ensure it's marked as not dirty if it's being forcefully removed.
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

/datum/controller/subsystem/component_fluid_simulation/proc/_process_simulation_logic()
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("ComponentFluidSimulation: fire() called."))

	pressure_calculation_tick++
	if(pressure_calculation_tick > 10) // Run every 10 ticks of this subsystem
		_process_pressure_calculation()
		pressure_calculation_tick = 0

	// Process fluid sources first to ensure they always generate fluid.
	process_fluid_sources(delta_time)


	// Process a chunk of turfs from the dirty queue.
	var/turfs_processed = 0
	while(turfs_processed < turfs_to_process_per_tick && dirty_turfs_queue.len)
		var/turf/T = dirty_turfs_queue[1]
		dirty_turfs_queue.Cut(1, 2) // Efficiently remove the first element
		is_dirty_turf -= T // Mark as clean now that we are processing it.

		var/datum/component/fluid/fluid_comp = process_turf_validation(T)
		if (!fluid_comp)
			continue

		process_lateral_spreading(T, fluid_comp)
		process_downward_flow(T, fluid_comp)
		process_turf_effects(T, fluid_comp, delta_time)

		turfs_processed++
		if (MC_TICK_CHECK)
			return

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
			var/datum/reagents/transfer_reagents = new()
			var/fraction = min(1, transfer_amount / fluid_comp.getFluidAmount())
			for(var/datum/reagent/R in fluid_comp.reagents.reagent_list)
				transfer_reagents.add_reagent(R.type, R.volume * fraction)

			fluid_comp_below.addFluid(transfer_amount, fluid_comp.getTemperature(), 0, 0, transfer_reagents, fluid_comp.reagent_color_overrides)
			fluid_comp.removeFluid(transfer_amount)
			qdel(transfer_reagents)
			add_dirty_turf(turf_below)
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("ComponentFluidSimulation: Transferred [transfer_amount] fluid from [T] to [turf_below] (downward flow)"))

/datum/controller/subsystem/component_fluid_simulation/proc/process_lateral_spreading(turf/T, datum/component/fluid/fluid_comp)
	var/list/potential_transfers = list()
	var/total_outflow = 0

	// Step 1: Calculate Potential Flow for All Neighbors
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
		var/pressure_factor = 1 + (fluid_comp.pressure / FLUID_MAX_DEPTH)

		// Directional factor: diagonal flow is slower
		var/spread_factor = (direction in GLOB.cardinals) ? 1 : (1 / sqrt(2))

		// Momentum factor: fluid prefers to flow in its current direction
		var/dir_x = (direction & 3) - 2 // EAST=1, WEST=-1, other=0
		var/dir_y = (direction & 12) / 4 - 2 // NORTH=1, SOUTH=-1, other=0
		var/momentum_factor = 1 + (fluid_comp.momentum_x * dir_x + fluid_comp.momentum_y * dir_y)
		momentum_factor = max(0.1, momentum_factor) // Ensure momentum doesn't completely stop the flow

		// We calculate two types of flow potential and use the greater of the two.
		// 1. Equalization: How much fluid to share to level out the pool. This can be zero if the turf is at/below the average.
		var/outflow_potential_equalization = (fluid_comp.getFluidAmount() - fluid_comp.body_average_amount) * FLUID_EQUALIZATION_FACTOR

		// 2. Spreading: A baseline outward pressure to ensure fluid always tries to expand into empty space.
		var/outflow_potential_spread = fluid_comp.getFluidAmount() * FLUID_SPREAD_FACTOR

		// The actual potential is the greater of the two. This ensures equalization happens when needed, but spreading never completely stops.
		var/outflow_potential = max(outflow_potential_equalization, outflow_potential_spread)

		// Sources are a special case and should always be able to push fluid out aggressively.
		var/datum/component/fluid_source/source_comp = T.GetComponent(/datum/component/fluid_source)
		if (source_comp && source_comp.is_active)
			outflow_potential = max(outflow_potential, fluid_comp.getFluidAmount() * FLUID_EQUALIZATION_FACTOR)

		if (outflow_potential <= 0)
			continue

		var/flow_rate_multiplier = pressure_factor // Increased flow rate based on pressure
		var/base_transfer_amount = outflow_potential * flow_rate_multiplier
		var/transfer_amount = min(fluid_diff, base_transfer_amount) * viscosity_multiplier * spread_factor * momentum_factor

		if (transfer_amount > 0)
			potential_transfers[neighbor_turf] = transfer_amount
			total_outflow += transfer_amount

	if (total_outflow < 0.001) // Minimum transfer threshold
		return

	// Step 2: Sum and Cap the Total Outflow
	var/scaling_factor = 1
	var/max_outflow = fluid_comp.getFluidAmount()
	if (total_outflow > max_outflow)
		scaling_factor = max_outflow / total_outflow

	// Step 3: Execute All Transfers
	var/total_fluid_removed = 0
	for (var/turf/neighbor_turf in potential_transfers)
		var/transfer_amount = potential_transfers[neighbor_turf] * scaling_factor
		if (transfer_amount <= 0)
			continue

		var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
		var/datum/reagents/transfer_reagents = new()
		var/fraction = min(1, transfer_amount / fluid_comp.getFluidAmount())
		for(var/datum/reagent/R in fluid_comp.reagents.reagent_list)
			transfer_reagents.add_reagent(R.type, R.volume * fraction)

		neighbor_fluid_comp.addFluid(transfer_amount, fluid_comp.getTemperature(), fluid_comp.momentum_x, fluid_comp.momentum_y, transfer_reagents, fluid_comp.reagent_color_overrides)
		qdel(transfer_reagents)
		add_dirty_turf(neighbor_turf)
		total_fluid_removed += transfer_amount

	fluid_comp.removeFluid(total_fluid_removed)

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

/datum/controller/subsystem/component_fluid_simulation/proc/_process_pressure_calculation()
	var/list/processed_turfs = list()

	for(var/turf/T in global_active_fluid_turfs)
		if(T in processed_turfs)
			continue

		var/list/fluid_body = list()
		var/list/queue = list(T)
		processed_turfs[T] = TRUE
		var/total_fluid = 0
		var/total_density = 0

		while(queue.len > 0)
			var/turf/current_turf = queue[1]
			queue.Remove(current_turf)
			fluid_body += current_turf

			var/datum/component/fluid/fluid_comp = current_turf.GetComponent(/datum/component/fluid)
			if(fluid_comp)
				var/fluid_amount = fluid_comp.getFluidAmount()
				total_fluid += fluid_amount
				total_density += fluid_comp.get_density() * fluid_amount

			for(var/direction in GLOB.alldirs)
				var/turf/neighbor_turf = get_step(current_turf, direction)
				if(neighbor_turf && !(neighbor_turf in processed_turfs))
					var/datum/component/fluid/neighbor_fluid_comp = neighbor_turf.GetComponent(/datum/component/fluid)
					if(neighbor_fluid_comp && neighbor_fluid_comp.getFluidAmount() > FLUID_EVAPORATION_POINT)
						processed_turfs[neighbor_turf] = TRUE
						queue += neighbor_turf

		// Now we have the whole fluid body and the total fluid amount.
		var/pressure = 0
		var/average_fluid_amount = 0
		if(fluid_body.len > 0 && total_fluid > 0)
			// We model pressure by P = pgh (density * gravity * height)
			var/average_density = total_density / total_fluid
			average_fluid_amount = total_fluid / fluid_body.len
			pressure = (average_density * FLUID_GRAVITY * average_fluid_amount) / FLUID_PRESSURE_NORMALIZATION

		for(var/turf/body_turf in fluid_body)
			var/datum/component/fluid/body_fluid_comp = body_turf.GetComponent(/datum/component/fluid)
			if(body_fluid_comp)
				body_fluid_comp.pressure = pressure
				body_fluid_comp.body_average_amount = average_fluid_amount

		if(MC_TICK_CHECK)
			return

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
