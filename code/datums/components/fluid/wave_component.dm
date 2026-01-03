/**
 * Wave Component - Procedural wave generation for fluid surfaces
 * Uses mathematical transformations instead of sprites because I couldn't be
 * bothered to make them.
 */

/datum/component/wave
	// Wave parameters
	var/wave_amplitude = 0.8		// Max wave height in pixels
	var/wave_frequency = 0.05		// Wave density (lower = longer waves)
	var/wave_phase = 0				// Current position in wave cycle
	var/wave_speed = 0.02			// Animation speed
	var/wave_direction = NORTH		// Primary wave direction
	var/wave_steepness = 0.3		// How steep the waves are (0-1)

	// Whitecap parameters
	var/whitecap_threshold = 0.7	// Wave height threshold for whitecaps (0-1)
	var/whitecap_intensity = 0		// Current whitecap coverage (0-1)
	var/whitecap_decay = 0.95		// How quickly whitecaps fade each tick

	// Performance optimization
	var/last_update_time = 0
	var/update_interval = 2			// Ticks between updates

	// Wave propagation control
	var/propagation_depth = 0		// Current propagation depth (0 = original wave)

	// Chunk tracking for spatial partitioning
	var/wave_chunk_x = 0			// X coordinate of wave chunk for spatial partitioning
	var/wave_chunk_y = 0			// Y coordinate of wave chunk for spatial partitioning

	// Particle references (new system)
	var/obj/effect/abstract/particle_holder/wave_effect = null
	var/obj/effect/abstract/particle_holder/whitecap_effect = null
	var/obj/effect/abstract/particle_holder/wave_crest_effect = null

	// Old transformation references (deprecated, kept for backward compatibility)
	var/image/wave_overlay = null
	var/image/whitecap_overlay = null

/datum/component/wave/proc/update_particle_whitecaps(wave_height)
	// Calculate whitecap intensity based on wave height and momentum
	var/datum/component/fluid/fluid_comp = parent.GetComponent(/datum/component/fluid)
	if (!fluid_comp) return

	var/momentum_magnitude = sqrt(fluid_comp.momentum_x^2 + fluid_comp.momentum_y^2)

	// Whitecaps appear at wave crests with sufficient momentum
	var/new_whitecap_intensity = 0
	if (wave_height > whitecap_threshold * wave_amplitude && momentum_magnitude > 0.5)
		new_whitecap_intensity = clamp((wave_height - whitecap_threshold) * 2, 0, 1)
		new_whitecap_intensity = clamp(momentum_magnitude, 0, 1)

	// Apply decay to existing whitecaps
	whitecap_intensity = max(new_whitecap_intensity, whitecap_intensity * whitecap_decay)

	// Create/update whitecap particle effect
	if (whitecap_intensity > 0.1)
		create_whitecap_particle_effect()
	else if (whitecap_effect)
		qdel(whitecap_effect)
		whitecap_effect = null

	// Remove whitecap effect if intensity is too low
	qdel(whitecap_effect)
	whitecap_effect = null


/datum/component/wave/Initialize(list/args = null)
	. = ..()
	// Set parameters from initialization args if provided
	if(args)
		if("wave_amplitude" in args)
			wave_amplitude = args["wave_amplitude"]
		if("wave_frequency" in args)
			wave_frequency = args["wave_frequency"]
		if("wave_direction" in args)
			wave_direction = args["wave_direction"]
		if("wave_speed" in args)
			wave_speed = args["wave_speed"]
		if("wave_steepness" in args)
			wave_steepness = args["wave_steepness"]

	// Initialize wave phase based on position for natural variation
	var/turf/T = get_turf(parent)
	if (T && T.x && T.y)
		wave_phase = (T.x + T.y * 100) % 360
	else
		wave_phase = 0

	// Create particle-based wave effect
	create_wave_particle_effect()

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("WaveComponent initialized on [parent] with amplitude [wave_amplitude]"))

/datum/component/wave/proc/create_wave_particle_effect()
	// Clean up any existing wave effect
	if (wave_effect)
		qdel(wave_effect)

	// Create new wave particle effect
	wave_effect = new /obj/effect/abstract/particle_holder/wave_effect(parent, list(
		"wave_amplitude" = wave_amplitude,
		"wave_frequency" = wave_frequency,
		"wave_direction" = wave_direction,
		"wave_speed" = wave_speed
	))

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("WaveComponent [parent]: Created particle-based wave effect"))

/datum/component/wave/Destroy()
	// Clean up particle effects
	if (wave_effect)
		qdel(wave_effect)
		wave_effect = null

	if (whitecap_effect)
		qdel(whitecap_effect)
		whitecap_effect = null

	if (wave_crest_effect)
		qdel(wave_crest_effect)
		wave_crest_effect = null

	. = ..()

/datum/component/wave/proc/UpdateWaves()
	var/current_time = world.time

	if (current_time - last_update_time < update_interval)
		return

	last_update_time = current_time

	// Calculate wave height using multiple sine waves for natural look
	var/turf/T = get_turf(parent)
	var/x_pos = T ? T.x : 0
	var/base_wave = wave_amplitude * sin(wave_frequency * x_pos + wave_phase + current_time * wave_speed)
	var/secondary_wave = wave_amplitude * 0.4 * sin(wave_frequency * 1.3 * x_pos + wave_phase * 0.7 + current_time * wave_speed * 1.1)
	var/wave_height = base_wave + secondary_wave

	// Update particle-based wave effects
	update_particle_waves(wave_height)

	// Update whitecaps using particles
	update_particle_whitecaps(wave_height)

	// Propagate waves to adjacent turfs
	propagate_waves()

	// Handle obstacles
	handle_obstacles()

/datum/component/wave/proc/update_particle_waves(wave_height)
	// Ensure wave effect exists
	if (!wave_effect)
		create_wave_particle_effect()
		return

	// Update wave phase for animation
	wave_phase += wave_speed
	if (wave_phase > 360)
		wave_phase -= 360

	// Create wave crests at high wave points
	if (wave_height > 0.8 && prob(15))
		create_wave_crest_effect()

/datum/component/wave/proc/create_whitecap_particle_effect()
	// Clean up existing whitecap effect
	if (whitecap_effect)
		qdel(whitecap_effect)

	// Create new whitecap particle effect
	whitecap_effect = new /obj/effect/abstract/particle_holder/whitecap_effect(parent)

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("WaveComponent [parent]: Created whitecap particle effect"))

/datum/component/wave/proc/create_wave_crest_effect()
	// Clean up existing wave crest effect
	if (wave_crest_effect)
		qdel(wave_crest_effect)

	// Create new wave crest particle effect
	wave_crest_effect = new /obj/effect/abstract/particle_holder/wave_crest_effect(parent)

	// Schedule cleanup
	spawn(6)
		if (!QDELETED(src) && wave_crest_effect)
			qdel(wave_crest_effect)
			wave_crest_effect = null

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("WaveComponent [parent]: Created wave crest particle effect"))

/datum/component/wave/proc/propagate_waves()
	var/datum/component/fluid/fluid_comp = parent.GetComponent(/datum/component/fluid)
	if (!fluid_comp || fluid_comp.fluid_amount < FLUID_DEEP) return

	// Check propagation depth limit to prevent exponential wave creation
	if (propagation_depth >= MAX_WAVE_PROPAGATION_DEPTH)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("WaveComponent [parent]: Propagation depth limit reached ([propagation_depth]/[MAX_WAVE_PROPAGATION_DEPTH])"))
		return

	// Propagate wave energy to adjacent water turfs
	for(var/direction in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		var/adjacent_turf = get_step(parent, direction)
		if (can_propagate_to(adjacent_turf))
			propagate_wave_energy(adjacent_turf, direction)

/datum/component/wave/proc/can_propagate_to(turf/target)
	if (!target || QDELETED(target)) return FALSE
	if (target.density > 0) return FALSE  // Can't propagate through walls

	var/datum/component/fluid/target_fluid = target.GetComponent(/datum/component/fluid)
	if (!target_fluid || target_fluid.fluid_amount < FLUID_SHALLOW) return FALSE

	return TRUE

/datum/component/wave/proc/propagate_wave_energy(turf/target, direction)
	var/datum/component/wave/target_wave = target.GetComponent(/datum/component/wave)
	if (!target_wave)
		target_wave = target.AddComponent(/datum/component/wave)
		target_wave.wave_direction = direction
		target_wave.wave_amplitude = wave_amplitude * 0.8  // Slight energy loss
		target_wave.propagation_depth = propagation_depth + 1  // Increment propagation depth

	// Transfer some wave energy
	var/energy_transfer = wave_amplitude * 0.1
	target_wave.wave_amplitude = min(target_wave.wave_amplitude + energy_transfer, wave_amplitude)
	wave_amplitude *= 0.98  // Small energy loss during propagation

/datum/component/wave/proc/handle_obstacles()
	// Check propagation depth limit to prevent exponential wave creation
	if (propagation_depth >= MAX_WAVE_PROPAGATION_DEPTH)
		return

	// Check for obstacles in adjacent turfs
	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		var/turf/adjacent_turf = get_step(parent, direction)
		if (adjacent_turf && adjacent_turf.density > 0)
			handle_wave_reflection(adjacent_turf, direction)

/datum/component/wave/proc/handle_wave_reflection(atom/obstacle, direction)
	// Calculate reflection angle
	var/reflection_angle = calculate_reflection_angle(wave_direction, direction)

	// Check if we already have a reflected wave component to prevent unbounded loops
	var/existing_reflected_wave = null
	var/components = parent.GetComponent(/datum/component/wave)
	for(var/datum/component/wave/wave_comp in components)
		if (wave_comp != src && wave_comp.propagation_depth > propagation_depth)
			existing_reflected_wave = wave_comp
			break

	// Create reflected wave component only if we don't already have one
	var/datum/component/wave/reflected_wave = existing_reflected_wave
	if (!reflected_wave)
		reflected_wave = parent.AddComponent(/datum/component/wave)
		reflected_wave.wave_direction = reflection_angle
		reflected_wave.wave_amplitude = wave_amplitude * 0.6  // 40% energy loss
		reflected_wave.wave_phase = wave_phase + 180         // Opposite phase
		reflected_wave.propagation_depth = propagation_depth + 1  // Increment propagation depth
	else
		// Update existing reflected wave instead of creating a new one
		reflected_wave.wave_amplitude = max(reflected_wave.wave_amplitude, wave_amplitude * 0.6)
		reflected_wave.wave_direction = reflection_angle
		reflected_wave.wave_phase = wave_phase + 180

	// Create whitecaps at impact point
	create_impact_whitecaps(obstacle)

	// Reduce main wave amplitude
	wave_amplitude *= 0.7

/datum/component/wave/proc/create_impact_whitecaps(atom/obstacle)
	// Create intense whitecaps at collision point
	whitecap_intensity = 1.0

	// Create splash particles if needed
	if (prob(30))
		create_splash_effect(obstacle)

/datum/component/wave/proc/create_splash_effect(atom/obstacle)
	// Create splash particle effect using the particle holder system
	var/obj/effect/abstract/particle_holder/splash_effect = new(obstacle)
	splash_effect.particles = new /particles/splash()
	splash_effect.particles.count = 15
	splash_effect.particles.spawning = 0
	splash_effect.particles.lifespan = 0.8 SECONDS
	splash_effect.particles.fade = 0.3 SECONDS
	splash_effect.particles.color = "#E0F7FA"
	splash_effect.particles.position = generator(GEN_CIRCLE, 1, 1, NORMAL_RAND)
	splash_effect.particles.scale = generator(GEN_VECTOR, list(1.2,1.2), list(1.8,1.8), NORMAL_RAND)
	splash_effect.particles.velocity = generator(GEN_VECTOR, list(-1.5, -2.0), list(1.5, -1.0), NORMAL_RAND)
	splash_effect.particles.gravity = list(0, 0.5)

	// Schedule cleanup
	spawn(10)
		if (!QDELETED(splash_effect))
			qdel(splash_effect)

// Helper functions
/datum/component/wave/proc/calculate_wave_slope()
	// Calculate slope by comparing with adjacent turfs
	var/north_wave = 0
	var/south_wave = 0
	var/east_wave = 0
	var/west_wave = 0

	var/turf/north_turf = get_step(parent, NORTH)
	var/turf/south_turf = get_step(parent, SOUTH)
	var/turf/east_turf = get_step(parent, EAST)
	var/turf/west_turf = get_step(parent, WEST)

	if (north_turf)
		var/datum/component/wave/north_wave_comp = north_turf.GetComponent(/datum/component/wave)
		if (north_wave_comp)
			north_wave = north_wave_comp.generate_wave_height(north_turf.x, north_turf.y, world.time)
	if (south_turf)
		var/datum/component/wave/south_wave_comp = south_turf.GetComponent(/datum/component/wave)
		if (south_wave_comp)
			south_wave = south_wave_comp.generate_wave_height(south_turf.x, south_turf.y, world.time)
	if (east_turf)
		var/datum/component/wave/east_wave_comp = east_turf.GetComponent(/datum/component/wave)
		if (east_wave_comp)
			east_wave = east_wave_comp.generate_wave_height(east_turf.x, east_turf.y, world.time)
	if (west_turf)
		var/datum/component/wave/west_wave_comp = west_turf.GetComponent(/datum/component/wave)
		if (west_wave_comp)
			west_wave = west_wave_comp.generate_wave_height(west_turf.x, west_turf.y, world.time)

	// Calculate slope (north-south vs east-west difference)
	var/ns_slope = (north_wave - south_wave) * 0.5
	var/ew_slope = (east_wave - west_wave) * 0.5

	// Return combined slope for rotation (using standard arctan)
	if (ns_slope != 0)
		return arctan(ew_slope / ns_slope) * 0.5  // Reduced intensity
	else
		return 0

/datum/component/wave/proc/generate_wave_height(x, y, time)
	var/base_wave = wave_amplitude * sin(wave_frequency * x + wave_phase + time * wave_speed)
	var/secondary_wave = wave_amplitude * 0.4 * sin(wave_frequency * 1.3 * x + wave_phase * 0.7 + time * wave_speed * 1.1)
	return base_wave + secondary_wave

/datum/component/wave/proc/adjust_color_for_waves(base_color, wave_height)
	// Convert base color to HSV for easier manipulation
	var/list/hsv = rgb2hsv(base_color)

	// Adjust based on wave height
	var/brightness_adjust = 0.1 * sin(wave_height * 2)
	hsv[3] = clamp(hsv[3] + brightness_adjust, 0, 1)  // Value channel

	// Add slight blue shift for deeper waves
	if (wave_height > 0.5)
		hsv[1] = min(hsv[1] + 0.05, 1)  // Increase saturation

	return hsv2rgb(hsv)

/datum/component/wave/proc/calculate_reflection_angle(wave_dir, obstacle_dir)
	// Proper wave reflection calculation based on angle of incidence
	// Uses vector math to calculate reflection relative to obstacle surface normal

	// Convert directions to vectors for proper physics calculation
	var/wave_vector = get_direction_vector(wave_dir)
	var/obstacle_normal = get_direction_vector(obstacle_dir)

	// Calculate reflection using vector math: R = D - 2(D·N)N
	// Where D is the incident direction, N is the surface normal, and R is the reflected direction
	var/dot_product = wave_vector[1] * obstacle_normal[1] + wave_vector[2] * obstacle_normal[2]
	var/reflection_vector = list(
		wave_vector[1] - 2 * dot_product * obstacle_normal[1],
		wave_vector[2] - 2 * dot_product * obstacle_normal[2]
	)

	// Convert reflection vector back to direction
	return vector_to_direction(reflection_vector)

/datum/component/wave/proc/get_direction_vector(direction)
	// Convert BYOND direction constants to 2D vectors
	var/vector_map = list(
		NORTH = list(0, -1),
		SOUTH = list(0, 1),
		EAST = list(1, 0),
		WEST = list(-1, 0),
		NORTHEAST = list(1, -1),
		NORTHWEST = list(-1, -1),
		SOUTHEAST = list(1, 1),
		SOUTHWEST = list(-1, 1)
	)
	return vector_map[direction] || list(0, -1)  // Default to NORTH if unknown
/datum/component/wave/proc/vector_to_direction(vector)
	// Convert 2D vector back to BYOND direction constant
	var/x = vector[1]
	var/y = vector[2]

	// Normalize and round to nearest direction
	if (abs(x) > abs(y))
		if (x > 0) return EAST
		else return WEST
	else
		if (y > 0) return SOUTH
		else return NORTH

/datum/component/wave/proc/update_wave_chunks()
	var/turf/T = get_turf(parent)
	if (T)
		wave_chunk_x = floor(T.x / WAVE_CHUNK_SIZE)
		wave_chunk_y = floor(T.y / WAVE_CHUNK_SIZE)
	else
		wave_chunk_x = 0
		wave_chunk_y = 0
