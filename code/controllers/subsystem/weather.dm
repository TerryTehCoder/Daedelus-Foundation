#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

SUBSYSTEM_DEF(weather)
	name = "Weather"
	init_order = INIT_ORDER_WEATHER // Mostly to avoid SSmapping info issues
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	var/list/processing = list()
	var/list/eligible_zlevels = list()
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming
	var/list/relevant_z_levels_for_coverage = list() // Used to determine which Z-levels are eligible for weather coverage and effects.

	///Referencing the current weather profile the profile system has suggested.
	var/datum/weather/profile/current_profile

	//Referencing other necessary weather systems
	var/datum/weather/chunking/weather_chunking = new
	var/datum/weather/weather_coverage/weather_coverage_handler = new
	var/next_flavor_smell_time = 0
	var/flavor_smell_interval_min = 6000 // 10 minutes in deciseconds
	var/flavor_smell_interval_max = 18000 // 30 minutes in deciseconds
	/// Flag to track initial weather coverage calculation, we won't start processing until we have all the turf coverage info.
	var/initial_coverage_processing_complete = FALSE
	/// Flag to indicate that the subsystem is currently baking a new weather cache.
	var/is_baking = FALSE

	/// Dynamic batch size for initial turf coverage processing.
	var/dynamic_turf_batch_size = 1500
	var/batch_processing_target_tick_usage = 5 // Target tick usage in deciseconds
	var/min_batch_size = 1500
	var/max_batch_size = 5000
	// PID controller variables - We're essentially doing calculus to optimize the batch size based on tick changes...
	// Basically.. if you have a higher quality oven, you can cook more turf columns at once.. so, not my computer.
	var/pid_proportional_gain = 0.1
	var/pid_integral_gain = 0.01
	var/pid_derivative_gain = 0.05
	var/pid_previous_error = 0
	var/pid_integral = 0

/datum/controller/subsystem/weather/fire()

	//Simulated threading setup for batch processing.
	var/static/mob_batch_index = 1
	var/static/obj_batch_index = 1
	/// Batch size for mob/obj processing
	var/batch_size = 10

	// Process initial weather coverage in batches
	if(is_baking || !initial_coverage_processing_complete)
		if(!weather_coverage_handler.process_next_turf_batch(dynamic_turf_batch_size))
			if(is_baking)
				FinishBaking()
			else
				initial_coverage_processing_complete = TRUE
				weather_coverage_handler.finalize_exposed_turf_registration()
				return

		// Adjust batch size based on world's tick usage using our PID controller, unless a custom batch size is being used for a manual bake.
		if(!is_baking || (is_baking && !initial_coverage_processing_complete))
			var/error = batch_processing_target_tick_usage - world.tick_usage
			pid_integral += error
			var/derivative = error - pid_previous_error
			var/output = pid_proportional_gain * error + pid_integral_gain * pid_integral + pid_derivative_gain * derivative
			pid_previous_error = error

			dynamic_turf_batch_size = clamp(dynamic_turf_batch_size + output, min_batch_size, max_batch_size)

			if(SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
				message_admins(span_adminnotice("Weather Subsystem Debug: Tick usage ([world.tick_usage]), Error ([error]), PID Output ([output]), New Batch Size ([dynamic_turf_batch_size])"))

		if(!is_baking)
			return // Do not proceed with other weather processing until initial coverage is complete
		else
			return // Also return if we are baking

	// Play flavor smells occasionally
	if(world.time >= next_flavor_smell_time && current_profile)
		var/list/all_smells = list()
		if(current_profile.flavor_smells_long && current_profile.flavor_smells_long.len)
			all_smells += current_profile.flavor_smells_long
		if(current_profile.flavor_smells_short && current_profile.flavor_smells_short.len)
			all_smells += current_profile.flavor_smells_short

		if(all_smells.len)
			// Set the next time for a smell opportunity
			next_flavor_smell_time = world.time + rand(flavor_smell_interval_min, flavor_smell_interval_max)

			// Getting all outdoor mobs for flavor smells using the chunking system
			var/list/all_exposed_turf_chunk_keys = weather_chunking.get_all_turf_chunk_keys()
			var/list/outdoor_mobs_for_smells = weather_chunking.get_mobs_in_chunks(all_exposed_turf_chunk_keys)

			// Broadcast to outdoor players with a per-player chance
			for(var/mob/player as anything in outdoor_mobs_for_smells)
				// 20% chance for a player to receive a smell message
				if(prob(20)) // TD: Make this probability configurable in weather_profiles or SSweather vars.
					var/smell_message_raw = pick(all_smells)
					var/smell_message_formatted = ""

					if(smell_message_raw in current_profile.flavor_smells_long)
						smell_message_formatted = smell_message_raw // Long message is used directly
					else
						smell_message_formatted = "You catch the scent of [smell_message_raw] in the air." // Short message is formatted

					to_chat(player, span_notice(smell_message_formatted))


	// process active weather
	for(var/datum/weather/current_storm in processing)
		if(!current_storm || current_storm.aesthetic || current_storm.stage != MAIN_STAGE)
			continue

		// Manage mob signal registration and unregistration based on storm presence.
		// Get Candidate Lists for the current storm
		var/list/mob_canidates = weather_chunking.get_mobs_in_chunks_around_storm(current_storm)
		var/list/object_canidates = weather_chunking.get_objects_in_chunks_around_storm(current_storm)

		// Get actual lists for storage (Mobs, Obj) for the current storm
		var/list/mobs_to_affect = list()
		var/list/objects_to_affect = list()

		// Register movement signal for all mobs in range, so check_mob_ambient_sound is called on movement.
		for(var/mob/M in mob_canidates)
			if(M && M.client)
				RegisterSignal(M, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/weather, handle_mob_moved))
		// Unregister signals for mobs that left the storm's area.
		// Iterate over a copy of mobs_with_ambient_sound to safely remove elements during iteration.
		var/list/mobs_to_check_for_exit = current_storm.mobs_with_ambient_sound.Copy()
		for(var/mob/M in mobs_to_check_for_exit)
			if(!M || !M.client || !(M.z in current_storm.impacted_z_levels)) // Mob might have been deleted, logged out, or left the storm's Z-level
				current_storm.mobs_with_ambient_sound -= M
				SEND_SOUND(M, sound(null, channel = current_storm.sound_channel)) // Stop sound
				UnregisterSignal(M, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/weather, handle_mob_moved))

		// Determining the mobs/objs lists here and flagging them appropriately.
		for(var/mob/living/M in mob_canidates)
			if(!M || !M.needs_weather_update)
				continue
			mobs_to_affect += M
			M.needs_weather_update = FALSE

		for(var/obj/O in object_canidates)
			if(!O || !O.needs_weather_update) // Added null check for O
				continue
			objects_to_affect += O
			O.needs_weather_update = FALSE

		// We've populated our mobs and objects filtered lists, lets slice them now into batches.
		// Reset batch index if it exceeds the list length
		var/list/mob_slice
		if(!mobs_to_affect || !mobs_to_affect.len) // Add check for empty or null list
			mob_batch_index = 1 // Reset for next cycle even if empty
			mob_slice = list() // Ensure mob_slice is an empty list
		else
			if(mob_batch_index > mobs_to_affect.len)
				mob_batch_index = 1
			mob_slice = mobs_to_affect.Copy(mob_batch_index, mob_batch_index + batch_size)

		var/list/obj_slice
		if(!objects_to_affect || !objects_to_affect.len) // Add check for empty or null list
			obj_batch_index = 1 // Reset for next cycle even if empty
			obj_slice = list() // Ensure obj_slice is an empty list
		else
			if(obj_batch_index > objects_to_affect.len)
				obj_batch_index = 1
			obj_slice = objects_to_affect.Copy(obj_batch_index, obj_batch_index + batch_size)

		// Increment batch indices for the next tick
		mob_batch_index += batch_size
		obj_batch_index += batch_size

		// Ticking weather effects and applying them if ready.
		if(current_storm.weather_effects) // Ensure weather_effects list is not null
			for(var/datum/weather/effect/E in current_storm.weather_effects)
				if(!E) // Added null check for E
					continue

				if(world.time % E.tick_interval == 0)
					var/effect_ready = E.tick() // Returns TRUE if cooldown is met and resets it, otherwise lowers cooldown.

					if(effect_ready)
						// Global effects, once per weather effect.
						if(E.type in E.global_effect_types)
							E.apply_global_effect()

						// Applying to Mobs
						if(E.affects_mobs && mob_slice)
							E.apply_to_mobs(mob_slice)

						// Applying to Objects
						if(E.affects_objects && obj_slice)
							E.apply_to_objects(obj_slice)


	// Start random weather on relevant levels, grouping Z-levels by their weather traits and contiguity.
	var/list/all_weather_traits = list()
	for(var/V in subtypesof(/datum/weather/weather_types))
		var/datum/weather/weather_types/W = V
		all_weather_traits |= initial(W.target_trait) // Collect all unique target traits

	for(var/trait in all_weather_traits)
		var/list/z_levels_with_trait = SSmapping.levels_by_trait(trait)

		if(!z_levels_with_trait || !z_levels_with_trait.len)
			continue

		// Sort Z-levels to identify contiguous groups - SURELY there is a better way to sort lists numerically...
		z_levels_with_trait = sort_list(z_levels_with_trait, GLOBAL_PROC_REF(cmp_numeric_asc))

		var/list/contiguous_z_groups = list()
		var/list/current_group = list()

		for(var/i = 1 to z_levels_with_trait.len)
			var/current_z = z_levels_with_trait[i]
			if(!current_group.len || current_z == current_group[current_group.len] + 1)
				current_group += current_z
			else
				contiguous_z_groups.Add(list(current_group))
				current_group = list(current_z)
		if(current_group.len)
			contiguous_z_groups.Add(list(current_group))

		// Had a lot of trouble with non-indexed iterations on these loops, so I'm falling back to what works.
		for(var/i = 1, i <= contiguous_z_groups.len, i++)
			var/list/z_group = contiguous_z_groups[i]
			if(SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
				message_admins(span_adminnotice("Weather Subsystem Debug: Entered z_group loop for trait: [trait] and z_group: [z_group.Join(", ")]"))
				message_admins(span_adminnotice("Weather Subsystem: Processing Z-group: [z_group.Join(", ")] for trait: [trait]"))

			// Check if this group is already processing a storm or is scheduled for one
			// We assume a group is eligible, until something tells us otherwise. (Timers, etc)
			var/group_eligible = TRUE
			for(var/j = 1, j <= z_group.len, j++)
				var/z_level = z_group[j]
				if(SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
					message_admins(span_adminnotice("Weather Subsystem Debug: After z_level check for trait: [trait], z_group: [z_group.Join(", ")]. group_eligible: [group_eligible]. next_hit_by_zlevel: [next_hit_by_zlevel.len ? next_hit_by_zlevel.Join(", ") : "None"]."))
				if(next_hit_by_zlevel["[z_level]"]) // If a timer exists, it's not eligible yet
					group_eligible = FALSE
					break
			if(!group_eligible)
				if (SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
					message_admins(span_adminnotice("Weather Subsystem: Z-group [z_group.Join(", ")] not eligible for new storm because a timer exists for one or more levels. Current timers: [next_hit_by_zlevel.len ? next_hit_by_zlevel.Join(", ") : "None"]."))
				continue

			var/list/possible_weather_types_for_trait = list()
			for(var/V in subtypesof(/datum/weather/weather_types))
				var/datum/weather/W = V
				var/probability = initial(W.probability)
				var/weather_target_trait = initial(W.target_trait)

				if(weather_target_trait != trait) // Only consider weather types for the current trait
					continue

				// Apply map-specific probability overrides
				var/datum/map_config/current_map_config = SSmapping.config
				var/overrides = current_map_config.weather_overrides[V]
				if(overrides && ("probability" in overrides))
					probability = overrides["probability"]

				// Filter by allowed_storms in the current profile
				if(current_profile && current_profile.allowed_storms && current_profile.allowed_storms.len)
					if(!(W.type in current_profile.allowed_storms))
						continue

				if(probability)
					possible_weather_types_for_trait[W] = probability

			if (SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
				message_admins(span_adminnotice("Weather Subsystem: Possible weather types for trait [trait] on Z-levels [z_group.Join(", ")]: [possible_weather_types_for_trait.len] types found."))
			if(possible_weather_types_for_trait.len)
				var/datum/weather/our_event_type = pick_weight(possible_weather_types_for_trait)
				if (SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
					message_admins(span_adminnotice("Weather Subsystem: Picked unified storm: [initial(our_event_type.name)] for Z-levels: [z_group.Join(", ")] (Trait: [trait])"))
					message_admins(span_adminnotice("Weather Subsystem: Attempting to run weather: [initial(our_event_type.name)] on Z-levels: [z_group.Join(", ")]"))
				run_weather(our_event_type, z_group)

				// Schedule the next unified weather event for these Z-levels
				var/randTime = rand(3000, 6000)
				var/next_storm_time = world.time + randTime + initial(our_event_type.weather_duration_upper)
				for(var/z_level in z_group)
					next_hit_by_zlevel["[z_level]"] = addtimer(CALLBACK(src, PROC_REF(make_eligible_unified), z_group, possible_weather_types_for_trait), next_storm_time - world.time, TIMER_UNIQUE|TIMER_STOPPABLE)
			else
				message_admins(span_adminnotice("Weather Subsystem: No eligible unified weather types found for trait: [trait] on Z-levels: [z_group.Join(", ")]"))

/datum/controller/subsystem/weather/Initialize(start_timeofday)
	log_world("Weather Subsystem: Initialize called.")

	weather_chunking.Initialize()

	// Select a random weather profile for the round
	var/list/all_profiles = list()
	for(var/V in subtypesof(/datum/weather/profile))
		all_profiles += V
	if(all_profiles.len)
		message_admins(span_adminnotice("Weather Subsystem: Found [all_profiles.len] weather profiles."))
		var/profile_type = pick(all_profiles)
		current_profile = new profile_type()
		if(current_profile) // Defensive check
			var/formatted_effects = "None"
			if(current_profile.allowed_weather_effects && current_profile.allowed_weather_effects.len)
				var/list/effect_names = list()
				for(var/effect_type in current_profile.allowed_weather_effects)
					var/datum/weather/effect/temp_effect = new effect_type()
					effect_names += temp_effect.name
					qdel(temp_effect) // Clean up the temporary instance
				formatted_effects = effect_names.Join(", ")
			message_admins(span_adminnotice("Weather Subsystem: Picked weather profile: [current_profile.name] (Allowed Effects: [formatted_effects])"))
			current_profile.apply_environment_settings() // Apply environment settings from the selected profile
		else
			message_admins(span_adminnotice("Weather Subsystem: No valid weather profile found! Defaulting to no profile."))

	// Populate eligible_zlevels based on weather types and map traits
	// This block is kept for future random weather generation, but initial coverage will use a direct approach.
	for(var/V in subtypesof(/datum/weather/weather_types))
		var/datum/weather/W = V
		var/probability = initial(W.probability)

		// Applying map-specific probability overrides first
		var/datum/map_config/current_map_config = SSmapping.config
		var/overrides = current_map_config.weather_overrides[V]
		if(overrides && ("probability" in overrides))
			probability = overrides["probability"]

		var/target_trait = initial(W.target_trait)

		// Filter by allowed_storms in the current profile
		if(current_profile && current_profile.allowed_storms && current_profile.allowed_storms.len)
			if(!(W.type in current_profile.allowed_storms))
				continue // Skip if this weather type is not allowed by the profile

		// any weather with a probability set may occur at random
		if (probability)
			for(var/z in SSmapping.levels_by_trait(target_trait))
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][W] = probability

	SSweather.relevant_z_levels_for_coverage = list()
	var/datum/map_config/current_map_config = SSmapping.config
	if(current_map_config.weather_coverage_traits && current_map_config.weather_coverage_traits.len)
		for(var/trait in current_map_config.weather_coverage_traits)
			var/list/z_levels_from_trait = SSmapping.levels_by_trait(trait)
			if(z_levels_from_trait && z_levels_from_trait.len)
				for(var/z_level in z_levels_from_trait)
					SSweather.relevant_z_levels_for_coverage += text2num(z_level)
	else
		// Fallback to ZTRAIT_PLANETARY_ENVIRONMENT if no specific traits are configured
		var/list/planetary_z_levels = SSmapping.levels_by_trait(ZTRAIT_PLANETARY_ENVIRONMENT)
		if(planetary_z_levels && planetary_z_levels.len)
			for(var/z_level in planetary_z_levels) {
				SSweather.relevant_z_levels_for_coverage += text2num(z_level)
			}

	// Attempt to load from cache
	var/cache_loaded = TryLoadWeatherCache()
	if(cache_loaded)
		initial_coverage_processing_complete = TRUE
		weather_coverage_handler.finalize_exposed_turf_registration()
	else
		// If cache loading fails, proceed with normal initialization
		weather_coverage_handler.Initialize(start_timeofday, relevant_z_levels_for_coverage)
		// Auto-bake a new cache in the background for the next round
		spawn(0)
			BakeWeatherCoverage()

	var/list/exposed_turfs = weather_chunking.get_turfs_in_chunks(weather_chunking.get_all_turf_chunk_keys())
	for(var/turf/T in exposed_turfs)
		if(!T || !T.z || !(T.z in relevant_z_levels_for_coverage)) //Erroneous? Maybe. Probably best to be safe though.
			continue
		else
			RegisterSignal(T, COMSIG_TURF_CREATED, PROC_REF(handle_turf_created))
			RegisterSignal(T, COMSIG_TURF_DESTROYED, PROC_REF(handle_turf_destroyed))

	return ..()

/datum/controller/subsystem/weather/proc/TryLoadWeatherCache()
	var/datum/map_config/current_map_config = SSmapping.config
	if(!current_map_config || !current_map_config.map_name || !current_map_config.map_file)
		return FALSE

	var/cache_dir = "data/weather_cache/[current_map_config.map_name]"
	var/cache_file_path = "[cache_dir]/weather.json"
	if(!fexists(cache_file_path))
		message_admins(span_adminnotice("Weather Subsystem: No weather cache found for map '[current_map_config.map_name]'."))
		return FALSE

	var/map_file_path = "_maps/map_files/[current_map_config.map_name]/[current_map_config.map_file]"
	if(!fexists(map_file_path))
		message_admins(span_adminnotice("Weather Subsystem: Could not find map file '[map_file_path]' to validate cache."))
		return FALSE

	var/current_map_hash = md5filepath(map_file_path)
	if(!current_map_hash)
		message_admins(span_adminnotice("Weather Subsystem: Could not calculate hash for current map file."))
		return FALSE

	var/json_data = file2text(cache_file_path)
	if(!json_data)
		message_admins(span_adminnotice("Weather Subsystem: Could not read cache file '[cache_file_path]'."))
		return FALSE

	var/list/cache_data = json_decode(json_data)
	if(!cache_data || !cache_data["map_hash"] || !cache_data["exposed_turfs_by_z"])
		message_admins(span_adminnotice("Weather Subsystem: Cache file '[cache_file_path]' is corrupted or invalid."))
		return FALSE

	if(cache_data["map_hash"] != current_map_hash)
		message_admins(span_adminnotice("Weather Subsystem: Weather cache for map '[current_map_config.map_name]' is stale. Hash mismatch."))
		return FALSE

	message_admins(span_adminnotice("Weather Subsystem: Loading weather coverage from cache for map '[current_map_config.map_name]'."))
	var/list/exposed_turfs_by_z = cache_data["exposed_turfs_by_z"]

	if(!exposed_turfs_by_z || !exposed_turfs_by_z.len)
		return TRUE // Nothing to load

	for(var/z_key in exposed_turfs_by_z)
		var/z = text2num(z_key)
		var/list/turfs_on_z = exposed_turfs_by_z[z_key]
		for(var/list/coords in turfs_on_z)
			var/turf/T = locate(coords[1], coords[2], z)
			if(T)
				T.cover_cache = FALSE
				SSweather.weather_chunking.register_exposed_turf(T)
				T.needs_weather_update = TRUE
	return TRUE

/datum/controller/subsystem/weather/proc/update_z_level(datum/space_level/level)
	var/z = level.z_value
	var/list/possible_weather_for_z = list()

	// Determine relevant traits for this Z-level
	var/list/z_level_traits = level.traits
	if(!z_level_traits || !z_level_traits.len)
		return // No traits, no weather eligibility

	for(var/V in subtypesof(/datum/weather/weather_types))
		var/datum/weather/W = V
		var/probability = initial(W.probability)
		var/target_trait = initial(W.target_trait)

		// Check if this weather type's target trait matches any trait of the current Z-level
		if(!(target_trait in z_level_traits))
			continue

		// Apply map-specific probability overrides
		var/datum/map_config/current_map_config = SSmapping.config
		var/overrides = current_map_config.weather_overrides[V]
		if(overrides && ("probability" in overrides))
			probability = overrides["probability"]

		// Filter by allowed_storms in the current profile
		if(current_profile && current_profile.allowed_storms && current_profile.allowed_storms.len)
			if(!(W.type in current_profile.allowed_storms))
				continue

		if(probability)
			possible_weather_for_z[W] = probability

	// Update eligible_zlevels for this Z-level
	eligible_zlevels["[z]"] = possible_weather_for_z

	// Clear any existing timer for this Z-level, making it immediately eligible for a new storm
	if(next_hit_by_zlevel["[z]"])
		next_hit_by_zlevel["[z]"] = null

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels_param, skip_telegraph)
	message_admins(span_adminnotice("Weather Subsystem: run_weather called with initial weather_datum_type: [weather_datum_type] and z_levels_param: [z_levels_param]"))
	var/list/actual_z_levels = z_levels_param // Declare a typed local variable to ensure correct type inference

	if (istext(weather_datum_type))
		message_admins(span_adminnotice("Weather Subsystem: Attempting to convert text path '[weather_datum_type]' to type."))
		for (var/V in subtypesof(/datum/weather/weather_types))
			var/datum/weather/W_temp = V // Use a temporary variable to avoid confusion with the outer W
			if (W_temp.type == weather_datum_type)
				weather_datum_type = V
				message_admins(span_adminnotice("Weather Subsystem: Successfully converted to type: [weather_datum_type]"))
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	message_admins(span_adminnotice("Weather Subsystem: weather_datum_type after conversion attempt: [weather_datum_type] (ispath: [ispath(weather_datum_type, /datum/weather)])"))

	if (isnull(actual_z_levels))
		actual_z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
		if (isnull(actual_z_levels))
			actual_z_levels = list()
	else if (isnum(actual_z_levels))
		actual_z_levels = list(actual_z_levels)
	else if (!islist(actual_z_levels))
		CRASH("run_weather called with invalid z_levels: [actual_z_levels || "null"]")

	if(weather_coverage_handler.debug_verbose_coverage_messages)
		message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Actual Z-levels for storm: [actual_z_levels.Join(", ")]"))

	var/turf/storm_center_turf
	if(actual_z_levels.len)
		// Sort actual_z_levels in descending order to prioritize higher Z-levels
		var/list/sorted_z_levels = list()
		for(var/z_level in actual_z_levels)
			var/inserted = FALSE
			for(var/i = 1, i <= sorted_z_levels.len, i++)
				if(z_level > sorted_z_levels[i])
					sorted_z_levels.Insert(i, z_level)
					inserted = TRUE
					break
			if(!inserted)
				sorted_z_levels += z_level

		if(weather_coverage_handler.debug_verbose_coverage_messages)
			message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Sorted Z-levels for center turf selection: [sorted_z_levels.Join(", ")]"))

		// Find a suitable center turf on the highest impacted z-level first.
		for(var/z_level in sorted_z_levels)
			var/list/candidate_turfs = list()
			// Iterate all turfs to find suitable ones on the current z_level
			var/list/z_chunk_keys = weather_chunking.get_all_turf_chunk_keys_on_z(z_level)
			if(weather_coverage_handler.debug_verbose_coverage_messages)
				message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Z-level [z_level]: Retrieved [z_chunk_keys.len] chunk keys."))

			if(z_chunk_keys && z_chunk_keys.len)
				candidate_turfs = weather_chunking.get_turfs_in_chunks(z_chunk_keys)
				if(weather_coverage_handler.debug_verbose_coverage_messages)
					message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Z-level [z_level]: Found [candidate_turfs.len] candidate turfs from chunks."))

			if(candidate_turfs && candidate_turfs.len)
				storm_center_turf = pick(candidate_turfs) // Pick a random suitable turf from the highest Z-level
				if(weather_coverage_handler.debug_verbose_coverage_messages)
					message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Selected storm_center_turf: [storm_center_turf.loc] on Z-level [z_level]."))
				break // Found a center, no need to check lower z-levels
			else if (weather_coverage_handler.debug_verbose_coverage_messages)
				message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Z-level [z_level]: No candidate turfs found for storm center."))

	if(weather_coverage_handler.debug_verbose_coverage_messages)
		if(storm_center_turf)
			message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - Final storm_center_turf: [storm_center_turf.loc]"))
		else
			message_admins(span_adminnotice("Weather Subsystem Debug: run_weather - No storm_center_turf selected (it is null)."))

	//A storm is Born!
	var/datum/weather/W = new weather_datum_type(actual_z_levels, storm_center_turf)

	if(weather_coverage_handler.debug_verbose_coverage_messages)
		message_admins(span_adminnotice("Weather Subsystem Debug: New storm '[W.name]' created with radius_in_chunks: [W.radius_in_chunks]."))

	W.telegraph(skip_telegraph)

/datum/controller/subsystem/weather/proc/make_eligible(z, possible_weather)
	eligible_zlevels[z] = possible_weather
	next_hit_by_zlevel["[z]"] = null

/datum/controller/subsystem/weather/proc/make_eligible_unified(list/z_levels, list/possible_weather)
	message_admins(span_adminnotice("Weather Subsystem: make_eligible_unified called for Z-levels: [z_levels.Join(", ")]"))
	for(var/z in z_levels)
		eligible_zlevels["[z]"] = possible_weather // Re-add eligibility for each Z-level in the group
		if(next_hit_by_zlevel["[z]"])
			message_admins(span_adminnotice("Weather Subsystem: Clearing next_hit_by_zlevel for Z-level: [z]. Was: [next_hit_by_zlevel["[z]"]]"))
		next_hit_by_zlevel["[z]"] = null // Clear the timer
		message_admins(span_adminnotice("Weather Subsystem: next_hit_by_zlevel for Z-level [z] is now: [next_hit_by_zlevel["[z]"] || "null"]"))

/datum/controller/subsystem/weather/proc/handle_turf_created(turf/T)
	weather_coverage_handler.on_turf_created(T)

/datum/controller/subsystem/weather/proc/handle_turf_destroyed(turf/T)
	weather_coverage_handler.on_turf_destroyed(T)

///Bakes the weather coverage info for the current map into a cached file at data/weather_cache/[map_name]/weather.json
/datum/controller/subsystem/weather/proc/BakeWeatherCoverage(custom_batch_size)
	if(is_baking)
		message_admins(span_adminnotice("Weather Subsystem: Already baking weather coverage."))
		return FALSE

	if(custom_batch_size)
		dynamic_turf_batch_size = custom_batch_size
		message_admins(span_adminnotice("Weather Subsystem: Starting weather coverage baking with custom batch size: [custom_batch_size]..."))
	else
		message_admins(span_adminnotice("Weather Subsystem: Starting weather coverage baking with dynamic batch sizing..."))

	is_baking = TRUE
	return TRUE

/datum/controller/subsystem/weather/proc/FinishBaking()
	message_admins(span_adminnotice("Weather Subsystem: Finishing weather coverage baking..."))
	is_baking = FALSE

	var/datum/map_config/current_map_config = SSmapping.config
	if(!current_map_config || !current_map_config.map_file)
		message_admins(span_adminnotice("Weather Subsystem: Baking failed. Map file not specified in map config."))
		return FALSE

	var/map_file_path = "_maps/map_files/[current_map_config.map_name]/[current_map_config.map_file]"
	if(!fexists(map_file_path))
		message_admins(span_adminnotice("Weather Subsystem: Baking failed. Map file not found at '[map_file_path]'."))
		is_baking = FALSE
		return FALSE

	var/map_hash = md5filepath(map_file_path)
	if(!map_hash)
		message_admins(span_adminnotice("Weather Subsystem: Baking failed. Could not calculate MD5 hash of map file."))
		is_baking = FALSE
		return FALSE

	var/list/exposed_turfs_by_z = list()
	var/list/exposed_turfs = weather_chunking.get_turfs_in_chunks(weather_chunking.get_all_turf_chunk_keys())
	for(var/turf/T in exposed_turfs)
		var/z_key = "[T.z]"
		if(!exposed_turfs_by_z[z_key])
			exposed_turfs_by_z[z_key] = list()
		exposed_turfs_by_z[z_key] += list(list(T.x, T.y))

	var/list/cache_data = list("map_hash" = map_hash, "exposed_turfs_by_z" = exposed_turfs_by_z)
	var/json_data = json_encode(cache_data)

	var/cache_dir = "data/weather_cache/[current_map_config.map_name]"
	if(!fexists(cache_dir))
		fcopy("[]", "[cache_dir]/dummy.json")
		fdel("[cache_dir]/dummy.json")

	var/cache_file_path = "[cache_dir]/weather.json"
	if(fexists(cache_file_path) && !fdel(cache_file_path))
		message_admins(span_adminnotice("Weather Subsystem: Could not delete existing cache file at '[cache_file_path]'."))
		is_baking = FALSE
		return FALSE

	if(!text2file(json_data, cache_file_path))
		message_admins(span_adminnotice("Weather Subsystem: Baking failed. Could not write to cache file at '[cache_file_path]'."))
		is_baking = FALSE
		return FALSE

	message_admins(span_adminnotice("Weather Subsystem: Baking complete. Saved cache for map '[current_map_config.map_name]' with hash [map_hash]."))
	is_baking = FALSE
	return TRUE

/// Debug Utilities

/client/proc/toggle_weather_verbose_messages()
	set name = "Toggle Weather Verbose Messages"
	set category = "Weather Debugging"
	set desc = "Toggles verbose debug messages for weather subsystem operations."

	if(!check_rights(R_DEBUG))
		return

	if(!SSweather || !SSweather.weather_coverage_handler)
		to_chat(usr, span_warning("Weather subsystem or coverage handler not found."), confidential = TRUE)
		return

	SSweather.weather_coverage_handler.debug_verbose_coverage_messages = !SSweather.weather_coverage_handler.debug_verbose_coverage_messages

	if(SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
		to_chat(usr, span_notice("Weather verbose debug messages ENABLED."), confidential = TRUE)
		log_admin("[key_name(usr)] enabled weather verbose debug messages.")
		message_admins("[key_name_admin(usr)] enabled weather verbose debug messages.")
	else
		to_chat(usr, span_notice("Weather verbose debug messages DISABLED."), confidential = TRUE)
		log_admin("[key_name(usr)] disabled weather verbose debug messages.")
		message_admins("[key_name_admin(usr)] disabled weather verbose debug messages.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Weather Verbose Messages")

/client/proc/force_weather_event()
	set category = "Weather Debugging"
	set name = "Force Weather Event"
	set desc = "Forces a specific weather event to start on selected Z-levels."

	if(!check_rights(R_DEBUG))
		return

	if(!SSweather || !SSweather.weather_coverage_handler || !SSweather.weather_coverage_handler.debug_verbose_coverage_messages)
		return // Exit if debug verbs are not enabled or weather subsystem/handler not found

	//Selecting Weather Type
	var/list/weather_types = list()
	for(var/V in subtypesof(/datum/weather/weather_types))
		var/datum/weather/W = V
		if(isabstract(W)) // Don't allow abstract types to be picked directly
			continue
		weather_types["[initial(W.name)] ([W.type])"] = W.type // Display name and path, store path

	var/weather_type_path = tgui_input_list(usr, "Select weather event to force:", "Force Weather Event", sort_list(weather_types))
	if(!weather_type_path)
		return

	// (Optionally) Selecting Z-levels
	var/z_levels_input = tgui_input_text(usr, "Enter Z-levels (comma-separated, e.g., '1,2,3') or leave blank for default:", "Force Weather Event", "")
	var/list/z_levels_to_impact = list()
	if(z_levels_input)
		var/list/z_level_strings = splittext(z_levels_input, ",")
		for(var/z_str in z_level_strings)
			var/z_num = text2num(trim(z_str))
			if(isnum(z_num) && z_num >= 1 && z_num <= world.maxz)
				z_levels_to_impact += z_num
			else
				to_chat(usr, span_warning("Invalid Z-level entered: [z_str]. Skipping."))

	// Calling SSweather.run_weather
	if(!SSweather)
		to_chat(usr, span_warning("Weather subsystem not found."), confidential = TRUE)
		return

	if(z_levels_to_impact.len)
		SSweather.run_weather(weather_type_path, z_levels_to_impact)

		message_admins(span_adminnotice("[key_name_admin(usr)] forced weather event '[weather_types[weather_type_path]]' on Z-levels: [z_levels_to_impact.Join(", ")]"))
		log_admin("[key_name(usr)] forced weather event '[weather_types[weather_type_path]]' on Z-levels: [z_levels_to_impact.Join(", ")]")
	else
		message_admins(span_adminnotice("[key_name_admin(usr)] forced weather event '[weather_types[weather_type_path]]' on default Z-levels (based on target trait)."))
		log_admin("[key_name(usr)] forced weather event '[weather_types[weather_type_path]]' on default Z-levels (based on target trait).")

	to_chat(usr, span_notice("Forced weather event: [weather_types[weather_type_path]] initiated."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Force Weather Event")
