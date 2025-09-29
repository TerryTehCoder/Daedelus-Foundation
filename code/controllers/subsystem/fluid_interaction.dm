SUBSYSTEM_DEF(fluid_interaction)
	name = "Fluid Interaction"
	wait = 1 SECONDS // Process interactions every second
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	priority = FIRE_PRIORITY_FLUIDS + 1 // Run after fluid simulation

	var/list/active_fluid_interactions = list() // List of turfs with active fluid for interaction
	var/datum/controller/subsystem/component_fluid_simulation/water_simulation_subsystem // Reference to the water simulation subsystem
	var/datum/controller/subsystem/component_fluid_simulation/smoke_simulation_subsystem // Reference to the smoke simulation subsystem
	var/datum/controller/subsystem/component_fluid_simulation/foam_simulation_subsystem // Reference to the foam simulation subsystem

/datum/controller/subsystem/fluid_interaction/Initialize()
	. = ..()
	// Retrieve the fluid simulation subsystem instances
	water_simulation_subsystem = SScomponent_fluid_simulation.all_fluid_simulations[/datum/fluid/water]
	smoke_simulation_subsystem = SScomponent_fluid_simulation.all_fluid_simulations[/datum/fluid/smoke]
	foam_simulation_subsystem = SScomponent_fluid_simulation.all_fluid_simulations[/datum/fluid/foam]

	// Register to signals from specific component-based fluid simulation subsystems
	if (water_simulation_subsystem)
		RegisterSignal(water_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, PROC_REF(onFluidTurfActive))
		RegisterSignal(water_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, PROC_REF(onFluidTurfInactive))
	// You Could add registrations for other fluid types as needed, e.g.:
	// RegisterSignal(lava_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_ACTIVE, PROC_REF(onFluidTurfActive))
	// RegisterSignal(lava_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_INACTIVE, PROC_REF(onFluidTurfInactive))
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(onGlobalExplosion))

/datum/controller/subsystem/fluid_interaction/Destroy()
	if (water_simulation_subsystem)
		UnregisterSignal(water_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_ACTIVE)
		UnregisterSignal(water_simulation_subsystem, COMSIG_FLUID_SIMULATION_TURF_INACTIVE)
	// Unregister for other fluid types as needed
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/datum/controller/subsystem/fluid_interaction/proc/onFluidTurfActive(datum/controller/subsystem/fluids/source_subsystem, turf/T)
	if (!active_fluid_interactions[T])
		active_fluid_interactions[T] = TRUE
		message_admins(span_notice("FluidInteraction: Turf [T] marked as active for fluid interaction."))

/datum/controller/subsystem/fluid_interaction/proc/onFluidTurfInactive(datum/controller/subsystem/fluids/source_subsystem, turf/T)
	if (active_fluid_interactions[T])
		active_fluid_interactions -= T
		message_admins(span_notice("FluidInteraction: Turf [T] marked as inactive for fluid interaction."))

/datum/controller/subsystem/fluid_interaction/fire(resumed)
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	message_admins(span_notice("FluidInteraction: fire() called. Active fluid interactions: [active_fluid_interactions.len]"))

	for(var/turf/T in active_fluid_interactions)
		if (QDELETED(T))
			active_fluid_interactions -= T
			message_admins(span_notice("FluidInteraction: Removed QDELETED turf [T] from active_fluid_interactions."))
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_EVAPORATION_POINT)
			active_fluid_interactions -= T
			continue

		// Handle pushing of movable atoms
		if (fluid_comp.fluid_amount > FLUID_PUSH_THRESHOLD)
			for(var/atom/movable/AM in T.contents)
				if (AM.is_fluid_pushable(fluid_comp.fluid_amount))
					// Work around for fetching viscosity/density
					var/datum/fluid/temp_fluid = new fluid_comp.fluid_type_instance.type
					var/viscosity_resistance = temp_fluid.viscosity // Higher viscosity means more resistance
					var/density_factor = temp_fluid.density / AM.float_density // Denser fluid pushes lighter objects more effectively
					qdel(temp_fluid) // Clean up the temporary instance

					// Simplified push: random direction, influenced by viscosity and density
					var/push_strength = 1 / viscosity_resistance * density_factor // Adjust as needed
					if (push_strength > 0.1) // Only push if strength is significant
						step(AM, pick(GLOB.cardinals), round(push_strength))

		// Handle buoyancy for movable atoms
		for(var/atom/movable/AM in T.contents)
			// Buoyancy: if object's float_density is less than fluid's density * threshold, it floats (moves up)
			var/datum/fluid/temp_fluid_buoyancy = new fluid_comp.fluid_type_instance.type
			if (AM.float_density < temp_fluid_buoyancy.density * FLUID_BUOYANCY_THRESHOLD)
				qdel(temp_fluid_buoyancy)
				var/turf/turf_above = get_step(get_turf(AM), UP)
				if (turf_above && !turf_above.density) // Check if turf above exists and is not dense/blocking
					step(AM, UP)

		// Trigger water_act on mobs (handled by MovableFluidInteractionComponent now)
		for(var/atom/movable/A in T.contents)
			var/datum/component/movable_fluid_interaction/movable_fluid_comp = A.GetComponent(/datum/component/movable_fluid_interaction)
			if (movable_fluid_comp)
				movable_fluid_comp.onProcess(movable_fluid_comp, delta_time) // Manually call process for immediate interaction

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fluid_interaction/proc/onGlobalExplosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range, explosion_cause, explosion_index)
	SIGNAL_HANDLER

	// Iterate through turfs affected by the explosion
	for (var/turf/T in range(max(devastation_range, heavy_impact_range, light_impact_range), epicenter))
		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_SHALLOW)
			continue

		// Apply amplified knockback to movable atoms in fluid
		for (var/atom/movable/AM in T.contents)
			if (AM.is_fluid_pushable(fluid_comp.fluid_amount))
				// Calculate a directional force away from the epicenter
				var/direction = get_dir(epicenter, AM)

				// Amplify the knockback force based on fluid presence
				var/knockback_force = FLUID_EXPLOSION_KNOCKBACK_MULTIPLIER // Base multiplier
				if (fluid_comp.fluid_amount > FLUID_OVER_MOB_HEAD)
					knockback_force *= 1.5 // Further amplification for deep water

				// Incorporate fluid density and viscosity into knockback
				var/datum/fluid/temp_fluid = new fluid_comp.fluid_type_instance.type
				var/fluid_density = temp_fluid.density
				var/fluid_viscosity = temp_fluid.viscosity
				del(temp_fluid) // Clean up the temporary instance

				// Denser fluids might transfer more force, higher viscosity might dampen it
				knockback_force *= (fluid_density / 1000) // Normalize density (e.g., water = 1)
				knockback_force /= fluid_viscosity // Higher viscosity reduces knockback

				// Apply the force (this is a simplified push, a more robust physics system would be better)
				step(AM, direction, knockback_force) // Assuming step can take a force/distance
