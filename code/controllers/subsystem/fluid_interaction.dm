SUBSYSTEM_DEF(fluid_interaction)
	name = "Fluid Interaction"
	wait = 3 SECONDS // Process interactions every 3 seconds
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
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidInteraction: fire() called. Active fluid interactions: [active_turfs.len]"))

	for(var/turf/T in active_turfs)
		if (QDELETED(T))
			continue

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_EVAPORATION_POINT)
			continue

		// Process wave momentum transfer
		process_wave_momentum(fluid_comp)

		// Handle pushing of movable atoms
		if (fluid_comp.fluid_amount > FLUID_PUSH_THRESHOLD)
			for(var/atom/movable/AM in T.contents)
				if (AM.anchored || AM.layer == WALL_OBJ_LAYER)
					continue
				if (AM.is_fluid_pushable(fluid_comp.fluid_amount))
					// Weak, infrequent ambient push
					var/viscosity_resistance = fluid_comp.get_viscosity()

					if(!viscosity_resistance || !AM.float_density)
						continue
					var/density_factor = fluid_comp.get_density() / AM.float_density

					var/push_strength = (density_factor / viscosity_resistance) / 2 // Weak push
					if (push_strength > 0.1)
						var/push_dir = 0
						var/abs_mom_x = abs(fluid_comp.momentum_x)
						var/abs_mom_y = abs(fluid_comp.momentum_y)

						if(abs_mom_x > 0.1 || abs_mom_y > 0.1) // Only push if there's significant momentum
							if (abs_mom_x > abs_mom_y)
								push_dir = (fluid_comp.momentum_x > 0) ? EAST : WEST
							else
								push_dir = (fluid_comp.momentum_y > 0) ? NORTH : SOUTH

						if(push_dir)
							step(AM, push_dir, round(push_strength))

		// Handle buoyancy for movable atoms
		for(var/atom/movable/AM in T.contents)
			// Buoyancy: if object's float_density is less than fluid's density * threshold, it floats (moves up)
			if (AM.float_density < fluid_comp.get_density() * FLUID_BUOYANCY_THRESHOLD)
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

/datum/controller/subsystem/fluid_interaction/proc/process_wave_momentum(datum/component/fluid/fluid_comp)
	// Get wave component if it exists
	var/datum/component/wave/wave_comp = fluid_comp.parent.GetComponent(/datum/component/wave)
	if (!wave_comp) return

	// Transfer wave momentum to fluid momentum
	var/wave_momentum_x = 0
	var/wave_momentum_y = 0

	// Calculate momentum based on wave direction and amplitude
	var/turf/parent_turf = fluid_comp.parent
	if (!istype(parent_turf))
		return
	var/wave_height = wave_comp.generate_wave_height(parent_turf.x, parent_turf.y, world.time)
	var/momentum_factor = abs(wave_height) * 0.1 // Convert wave height to momentum

	// Apply momentum in wave direction
	switch(wave_comp.wave_direction)
		if (NORTH) wave_momentum_y = -momentum_factor
		if (SOUTH) wave_momentum_y = momentum_factor
		if (EAST) wave_momentum_x = momentum_factor
		if (WEST) wave_momentum_x = -momentum_factor
		if (NORTHEAST)
			wave_momentum_x = momentum_factor * 0.7
			wave_momentum_y = -momentum_factor * 0.7
		if (NORTHWEST)
			wave_momentum_x = -momentum_factor * 0.7
			wave_momentum_y = -momentum_factor * 0.7
		if (SOUTHEAST)
			wave_momentum_x = momentum_factor * 0.7
			wave_momentum_y = momentum_factor * 0.7
		if (SOUTHWEST)
			wave_momentum_x = -momentum_factor * 0.7
			wave_momentum_y = momentum_factor * 0.7

	// Add wave momentum to fluid momentum
	fluid_comp.momentum_x += wave_momentum_x
	fluid_comp.momentum_y += wave_momentum_y

	// Apply momentum decay
	fluid_comp.momentum_x *= (1 - fluid_comp.momentum_decay)
	fluid_comp.momentum_y *= (1 - fluid_comp.momentum_decay)

	// Transfer momentum to adjacent turfs (wave propagation)
	transfer_wave_momentum_to_adjacent(fluid_comp, wave_comp)

/datum/controller/subsystem/fluid_interaction/proc/transfer_wave_momentum_to_adjacent(datum/component/fluid/fluid_comp, datum/component/wave/wave_comp)
	var/momentum_to_transfer_x = fluid_comp.momentum_x * 0.3 // Transfer 30% of momentum
	var/momentum_to_transfer_y = fluid_comp.momentum_y * 0.3

	// Transfer momentum to adjacent fluid turfs
	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		var/turf/adjacent_turf = get_step(fluid_comp.parent, direction)
		if (adjacent_turf)
			var/datum/component/fluid/adjacent_fluid = adjacent_turf.GetComponent(/datum/component/fluid)
			if (adjacent_fluid && adjacent_fluid.fluid_amount >= FLUID_SHALLOW)
				// Calculate direction-based transfer
				var/transfer_factor = 0
				switch(direction)
					if (NORTH) transfer_factor = -momentum_to_transfer_y
					if (SOUTH) transfer_factor = momentum_to_transfer_y
					if (EAST) transfer_factor = momentum_to_transfer_x
					if (WEST) transfer_factor = -momentum_to_transfer_x


				// Apply momentum transfer
				if (direction == NORTH || direction == SOUTH)
					adjacent_fluid.momentum_y += transfer_factor
				else
					adjacent_fluid.momentum_x += transfer_factor

				// Reduce our own momentum
				if (direction == NORTH || direction == SOUTH)
					fluid_comp.momentum_y -= transfer_factor * 0.5 // Only reduce half to prevent complete loss
				else
					fluid_comp.momentum_x -= transfer_factor * 0.5

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
				var/fluid_density = fluid_comp.get_density()
				var/fluid_viscosity = fluid_comp.get_viscosity()

				// Denser fluids might transfer more force, higher viscosity might dampen it
				knockback_force *= (fluid_density / 1000) // Normalize density (e.g., water = 1)
				if(fluid_viscosity > 0)
					knockback_force /= fluid_viscosity // Higher viscosity reduces knockback

				// Apply the force (this is a simplified push, a more robust physics system would be better)
				step(AM, direction, knockback_force)
