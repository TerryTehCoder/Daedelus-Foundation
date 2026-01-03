/**
 * Wave Particle Holder System
 * Manages particle-based wave effects for ocean turfs
 */

/obj/effect/abstract/particle_holder/wave_effect
	name = "ocean waves"
	layer = 1.0
	plane = GAME_PLANE

	// Wave parameters
	var/wave_amplitude = 0.8
	var/wave_frequency = 0.05
	var/wave_phase = 0
	var/wave_direction = NORTH
	var/wave_speed = 0.02
	var/whitecap_effect = null
	var/wave_animation_timer

/obj/effect/abstract/particle_holder/wave_effect/New(atom/loc, list/args = null)
	. = ..(loc, /particles/wave)

	// Set parameters from args if provided
	if(args)
		if("wave_amplitude" in args)
			wave_amplitude = args["wave_amplitude"]
		if("wave_frequency" in args)
			wave_frequency = args["wave_frequency"]
		if("wave_direction" in args)
			wave_direction = args["wave_direction"]
		if("wave_speed" in args)
			wave_speed = args["wave_speed"]

	// Initialize wave phase based on position for natural variation
	wave_phase = (loc.x + loc.y * 100) % 360

	// Start continuous wave animation using timer
	start_wave_animation()

/obj/effect/abstract/particle_holder/wave_effect/proc/start_wave_animation()
	// Clear any existing timer first
	if (wave_animation_timer)
		deltimer(wave_animation_timer)

	// Start continuous animation timer
	wave_animation_timer = addtimer(CALLBACK(src, PROC_REF(update_wave_animation)), 1, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/effect/abstract/particle_holder/wave_effect/proc/update_wave_animation()
	// Update wave phase
	wave_phase += wave_speed
	if (wave_phase > 360)
		wave_phase -= 360

	// Calculate current wave height
	var/wave_height = wave_amplitude * sin(wave_frequency * loc.x + wave_phase)

	// Update particle velocities based on wave motion
	update_particle_velocities(wave_height)

	// Create whitecaps at wave crests
	if (wave_height > 0.6 && prob(25))  // 25% chance at wave crests
		create_whitecaps()

	// Clean up old whitecaps
	var/obj/effect/abstract/particle_holder/whitecap_effect/whitecap_check = whitecap_effect
	if (whitecap_check && (QDELETED(whitecap_check) || !whitecap_check.particles))
		whitecap_effect = null

	// Schedule next update (continuous loop)
	if (!QDELETED(src))
		wave_animation_timer = addtimer(CALLBACK(src, PROC_REF(update_wave_animation)), 1, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/effect/abstract/particle_holder/wave_effect/proc/update_particle_velocities(wave_height)
	// Calculate base velocity from wave direction and height
	var/base_velocity_x = 0
	var/base_velocity_y = wave_height * 0.08

	// Apply wave direction
	switch(wave_direction)
		if (NORTH)
			base_velocity_y = -abs(wave_height * 0.08)
		if (SOUTH)
			base_velocity_y = abs(wave_height * 0.08)
		if (EAST)
			base_velocity_x = abs(wave_height * 0.08)
		if (WEST)
			base_velocity_x = -abs(wave_height * 0.08)
		if (NORTHEAST)
			base_velocity_x = abs(wave_height * 0.06)
			base_velocity_y = -abs(wave_height * 0.06)
		if (NORTHWEST)
			base_velocity_x = -abs(wave_height * 0.06)
			base_velocity_y = -abs(wave_height * 0.06)
		if (SOUTHEAST)
			base_velocity_x = abs(wave_height * 0.06)
			base_velocity_y = abs(wave_height * 0.06)
		if (SOUTHWEST)
			base_velocity_x = -abs(wave_height * 0.06)
			base_velocity_y = abs(wave_height * 0.06)

	// Apply wave motion to particles with some randomness
	particles.velocity = generator(GEN_VECTOR,
		list(base_velocity_x - 0.2, base_velocity_y - 0.1),
		list(base_velocity_x + 0.2, base_velocity_y + 0.1),
		NORMAL_RAND
	)
	// Create new whitecap effect
	var/obj/effect/abstract/particle_holder/whitecap_effect/typed_whitecap = new /obj/effect/abstract/particle_holder/whitecap_effect(loc)
	if(typed_whitecap)
		typed_whitecap.wave_direction = wave_direction
		typed_whitecap.update_whitecap_velocities()
	whitecap_effect = typed_whitecap

	// Adjust particle positions to create wave shape
	// Replace GEN_WAVE with standard GEN_BOX for wave-like distribution
	particles.position = generator(GEN_BOX,
		list(-12, -12, 0),
		list(12, 12, 0),
		NORMAL_RAND
	)

	// Adjust particle scale based on wave height
	var/base_scale = 0.8 + abs(wave_height) * 0.6
	particles.scale = generator(GEN_VECTOR,
		list(base_scale, base_scale),
		list(base_scale * 1.2, base_scale * 1.2),
		NORMAL_RAND
	)

/obj/effect/abstract/particle_holder/wave_effect/proc/create_whitecaps()
	// Clean up existing whitecaps first
	if (whitecap_effect)
		qdel(whitecap_effect)

	// Create new whitecap effect
	whitecap_effect = new /obj/effect/abstract/particle_holder/whitecap_effect(loc)

	// Schedule whitecap cleanup
	var/obj/effect/abstract/particle_holder/whitecap_effect/this_whitecap = whitecap_effect
	spawn(8)
		if (!QDELETED(src) && !QDELETED(this_whitecap))
			if(whitecap_effect == this_whitecap)
				whitecap_effect = null
			qdel(this_whitecap)

/obj/effect/abstract/particle_holder/wave_effect/Destroy()
	// Clean up animation timer
	if (wave_animation_timer)
		deltimer(wave_animation_timer)
		wave_animation_timer = null

	// Clean up whitecap effect
	if (whitecap_effect)
		qdel(whitecap_effect)
		whitecap_effect = null
	. = ..()

/obj/effect/abstract/particle_holder/whitecap_effect
	name = "wave whitecaps"
	layer = 1.1  // Above waves
	plane = GAME_PLANE

	var/wave_direction = NORTH

/obj/effect/abstract/particle_holder/whitecap_effect/New(atom/loc)
	. = ..(loc, /particles/whitecap)

	// Position whitecaps at wave crests
	particles.position = generator(GEN_CIRCLE, 1.5, 1.5, NORMAL_RAND)

	// Add some directional velocity based on wave direction
	update_whitecap_velocities()

/obj/effect/abstract/particle_holder/whitecap_effect/proc/update_whitecap_velocities()
	var/velocity_x = 0
	var/velocity_y = 0

	switch(wave_direction)
		if (NORTH)
			velocity_y = -0.3
		if (SOUTH)
			velocity_y = 0.3
		if (EAST)
			velocity_x = 0.3
		if (WEST)
			velocity_x = -0.3

		if (NORTHEAST)
			velocity_x = 0.2
			velocity_y = -0.2
		if (NORTHWEST)
			velocity_x = -0.2
			velocity_y = -0.2
		if (SOUTHEAST)
			velocity_x = 0.2
			velocity_y = 0.2
		if (SOUTHWEST)
			velocity_x = -0.2
			velocity_y = 0.2

	particles.velocity = generator(GEN_VECTOR,
		list(velocity_x - 0.2, velocity_y - 0.1),
		list(velocity_x + 0.2, velocity_y + 0.1),
		NORMAL_RAND
	)

/obj/effect/abstract/particle_holder/wave_crest_effect
	name = "wave crests"
	layer = 1.2  // Above whitecaps
	plane = GAME_PLANE

/obj/effect/abstract/particle_holder/wave_crest_effect/New(atom/loc)
	. = ..(loc, /particles/wave_crest)

	// Position wave crests in a line
	particles.position = generator(GEN_VECTOR,
		list(-4, 0, 0),
		list(4, 0, 0),
		UNIFORM_RAND
	)

	// Schedule cleanup
	spawn(6)
		if (!QDELETED(src))
			qdel(src)
