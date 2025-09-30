SUBSYSTEM_DEF(fluid_interaction)
	name = "Fluid Interaction"
	wait = 3 SECONDS // Process interactions every second
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	priority = FIRE_PRIORITY_FLUIDS + 1 // Run after fluid simulation

/datum/controller/subsystem/fluid_interaction/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(onGlobalExplosion))

/datum/controller/subsystem/fluid_interaction/Destroy()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/datum/controller/subsystem/fluid_interaction/fire(resumed)
	var/delta_time = wait / (1 SECONDS) // Convert wait to seconds for consistent delta_time
	var/list/active_turfs = SScomponent_fluid_simulation.global_active_fluid_turfs
	message_admins(span_notice("FluidInteraction: fire() called. Active fluid interactions: [active_turfs.len]"))

	for(var/turf/T in active_turfs)
		if (QDELETED(T))
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_EVAPORATION_POINT)
			continue

		// Handle pushing of movable atoms
		if (fluid_comp.fluid_amount > FLUID_PUSH_THRESHOLD)
			for(var/atom/movable/AM in T.contents)
				if (AM.anchored || AM.layer == WALL_OBJ_LAYER)
					continue
				if (AM.is_fluid_pushable(fluid_comp.fluid_amount))
					// Weak, infrequent ambient push
					if(prob(5)) // 5% chance each call
						var/datum/fluid/fluid_properties = fluid_comp.fluid_type_instance
						var/viscosity_resistance = fluid_properties.viscosity
						var/density_factor = fluid_properties.density / AM.float_density

						var/push_strength = (1 / viscosity_resistance * density_factor) / 2 // Weak push
						if (push_strength > 0.1)
							step(AM, pick(GLOB.cardinals), round(push_strength))

		// Handle buoyancy for movable atoms
		for(var/atom/movable/AM in T.contents)
			// Buoyancy: if object's float_density is less than fluid's density * threshold, it floats (moves up)
			var/datum/fluid/fluid_properties_buoyancy = fluid_comp.fluid_type_instance
			if (AM.float_density < fluid_properties_buoyancy.density * FLUID_BUOYANCY_THRESHOLD)
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
				var/datum/fluid/fluid_properties_explosion = fluid_comp.fluid_type_instance
				var/fluid_density = fluid_properties_explosion.density
				var/fluid_viscosity = fluid_properties_explosion.viscosity

				// Denser fluids might transfer more force, higher viscosity might dampen it
				knockback_force *= (fluid_density / 1000) // Normalize density (e.g., water = 1)
				knockback_force /= fluid_viscosity // Higher viscosity reduces knockback

				// Apply the force (this is a simplified push, a more robust physics system would be better)
				step(AM, direction, knockback_force) // Assuming step can take a force/distance
