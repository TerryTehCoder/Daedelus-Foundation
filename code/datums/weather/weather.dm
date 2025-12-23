/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 *
 */

/**
* When adding new weather, consider the following:
* - code\__DEFINES\maps.dm needs to be updated with a ZTRAIT_WEATHERNAME define, so the weather occurs on that Z.
* - code\__DEFINES\traits.dm needs to be updated with a TRAIT_WEATHERNAME_IMMUNE define, so mobs can be immune to it.
*
*/

/client/var/weather_debug_verbs_enabled = FALSE

/// Global counter for unique weather sound channels
GLOBAL_VAR_INIT(next_weather_sound_channel, 10000) // Start at a high number to avoid conflicts with other sounds

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>"
	/// In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 300
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = "<span class='userdanger'>The wind begins to blow ferociously!</span>"
	/// In deciseconds, how long the weather lasts once it begins
	var/weather_duration = 1200
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 1200
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 1500
	/// Looping sound while weather is occuring
	var/weather_sound
	/// Unique channel for ambient weather sounds to allow stopping them
	var/sound_channel
	/// List of mobs currently playing ambient sounds for this weather datum
	var/list/mobs_with_ambient_sound = list()
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null

	/// Displayed once the weather is over
	var/end_message = "<span class='danger'>The wind relents its assault.</span>"
	/// In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 300
	/// Sound that plays while weather is ending
	var/end_sound
	/// Area overlay while weather is ending
	var/end_overlay

	/// The list of z-levels that this weather is actively affecting
	var/list/impacted_z_levels

	/// Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = AREA_PLANE
	/// If the weather has no purpose other than looks
	var/aesthetic = FALSE
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type
	/// If this bit of weather should also draw an overlay that's uneffected by lighting onto the area
	/// Taken from weather_glow.dmi
	var/use_glow = TRUE
	/// List of all overlays to apply to our turfs
	var/list/overlay_cache

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_PLANETARY_ENVIRONMENT

	/// Whether a barometer can predict when the weather will happen
	var/barometer_predictable = FALSE
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0
	/// This causes the weather to only end if forced to
	var/perpetual = FALSE

	/// Mechanical Weather effects applied to this weather_type which are applied to mobs. (Wind Gust, lightning, etc)

	/// Wind direction, passed from weather profile.
	var/wind_direction = null
	/// Override to effect list in each weather type, can also be overriden in the map config.
	var/list/weather_effects = list()
	///The maximum number of weather effects that can be picked for a given storm.
	var/max_effects = 3
	/// The radius of influence for this storm, -1 = entire map
	var/radius_in_chunks = -1
	/// Central turf of a storm's influence. Really only relevant if radius is not -1
	var/center_turf

/datum/weather/storm
	name = "Storm"

/datum/weather/weather_types

/datum/weather/New(z_levels, turf/initial_center_turf)
	..()
	impacted_z_levels = z_levels
	center_turf = initial_center_turf
	sound_channel = GLOB.next_weather_sound_channel++

	/*
	* Applying map-specific overrides to things like descs, probabilities, durations, etc.
	* Can be extended if you'd like to add more overrides, just update the map Json and this code.
	*
	*/

	var/datum/map_config/current_map_config = SSmapping.config
	if(current_map_config && current_map_config.weather_overrides)
		var/overrides = current_map_config.weather_overrides[type]
		if(overrides)
			if("desc" in overrides)
				desc = overrides["desc"]
			if("probability" in overrides)
				probability = overrides["probability"]
			if("telegraph_duration" in overrides)
				telegraph_duration = overrides["telegraph_duration"]
			if("weather_duration_lower" in overrides)
				weather_duration_lower = overrides["weather_duration_lower"]
			if("weather_duration_upper" in overrides)
				weather_duration_upper = overrides["weather_duration_upper"]
			if("end_duration" in overrides)
				end_duration = overrides["end_duration"]
			if("telegraph_message" in overrides)
				telegraph_message = overrides["telegraph_message"]
			if("weather_message" in overrides)
				weather_message = overrides["weather_message"]
			if("end_message" in overrides)
				end_message = overrides["end_message"]
			if("perpetual" in overrides)
				perpetual = overrides["perpetual"]
			if("barometer_predictable" in overrides)
				barometer_predictable = overrides["barometer_predictable"]
			if("aesthetic" in overrides)
				aesthetic = overrides["aesthetic"]



/**
 * Telegraphs the beginning of the weather on the impacted z levels
 *
 * Sends sounds and details to mobs in the area
 * Calculates duration and hit areas, and makes a callback for the actual weather to start
 *
 */
/datum/weather/proc/telegraph(get_to_the_good_part)
	message_admins(span_adminnotice("Weather Datum: [name] entering telegraph stage."))
	if(stage == STARTUP_STAGE)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type))
	stage = STARTUP_STAGE

	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_turf_overlays()

	if(get_to_the_good_part)
		start()
	else
		send_alert(telegraph_message, telegraph_sound)
		addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/**
 * Starts the actual weather and effects from it
 *
 * Updates area overlays and sends sounds and messages to mobs to notify them
 * Begins dealing effects from weather to mobs in the area
 *
 */
/datum/weather/proc/start()
	message_admins(span_adminnotice("Weather Datum: [name] entering start stage."))
	if(stage >= MAIN_STAGE)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type))

	stage = MAIN_STAGE
	update_turf_overlays()

	weather_effects = select_weather_effects()

	//Instantiate the actual effects now
	var/list/instanced_effects = list()
	for(var/effect_type in weather_effects)
		instanced_effects += new effect_type()
	weather_effects = instanced_effects

	if(weather_effects.len)
		var/list/effect_names = list()
		for(var/datum/weather/effect/E in weather_effects)
			effect_names += E.name
		message_admins(span_adminnotice("Weather Datum: [name] generated effects for this storm: [effect_names.Join(", ")]"))

	send_alert(weather_message, weather_sound)
	if(!perpetual)
		addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/**
 * Weather enters the winding down phase, stops effects
 *
 * Updates areas to be in the winding down phase
 * Sends sounds and messages to mobs to notify them
 *
 */
/datum/weather/proc/wind_down()
	message_admins(span_adminnotice("Weather Datum: [name] entering wind_down stage."))
	if(stage >= WIND_DOWN_STAGE)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type))
	stage = WIND_DOWN_STAGE

	update_turf_overlays()

	send_alert(end_message, end_sound)
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/**
 * Fully ends the weather
 *
 * Effects no longer occur and area overlays are removed
 * Removes weather from processing completely
 *
 */
/datum/weather/proc/end()
	message_admins(span_adminnotice("Weather Datum: [name] entering end stage."))
	if(stage == END_STAGE)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type))
	stage = END_STAGE

	SSweather.processing -= src
	update_turf_overlays()

	// Unregister signals and stop ambient sounds for all affected mobs
	for(var/mob/living/M in mobs_with_ambient_sound)
		if(M && M.client)
			UnregisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(handle_mob_moved))
			SEND_SOUND(M, sound(null, channel = sound_channel))
	mobs_with_ambient_sound.Cut() // Clear the list

	// Clean up visual overlays from effects that manage their own
	for(var/datum/weather/effect/E in weather_effects)
		if(E && E.needs_overlay_cleanup)
			E.cleanup_visual_overlays()

/datum/weather/proc/send_alert(alert_msg, alert_sfx)
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			if(!can_get_alert(player))
				continue

			if(telegraph_message)
				to_chat(player, alert_msg)

			if(telegraph_sound)
				SEND_SOUND(player, sound(alert_sfx))

// the checks for if a mob should recieve alerts, returns TRUE if can
/datum/weather/proc/can_get_alert(mob/player)
	var/turf/mob_turf = get_turf(player)
	return !isnull(mob_turf)

/**
 * Returns TRUE if the living mob can be affected by the weather
 *
 */
/datum/weather/proc/can_weather_act(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)
	if(!mob_turf)
		return

	// Check if this turf is covered by weather (turf-based coverage system)
	var/chunk_key = SSweather.weather_chunking.get_turf_chunk_key(mob_turf)
	if(!chunk_key || !SSweather.weather_chunking.turf_chunks[chunk_key])
		return

	// Immunity checks for mob
	if((immunity_type && HAS_TRAIT(mob_to_check, immunity_type)) || HAS_TRAIT(mob_to_check, TRAIT_WEATHER_IMMUNE))
		return

	// Immunity checks for containers (e.g. bags, vehicles)
	var/atom/loc_to_check = mob_to_check.loc
	while(loc_to_check && loc_to_check != mob_turf)
		if((immunity_type && HAS_TRAIT(loc_to_check, immunity_type)) || HAS_TRAIT(loc_to_check, TRAIT_WEATHER_IMMUNE))
			return
		loc_to_check = loc_to_check.loc

	return TRUE


/// Signal handler for mob movement.
/datum/weather/proc/handle_mob_moved(mob/living/M, turf/old_loc, turf/new_loc)
	if(!M || !M.client || !(M.z in impacted_z_levels)) // Only process for mobs on impacted Z-levels
		return
	check_mob_ambient_sound(M)

/// Checks if a mob should be hearing ambient weather sounds and plays/stops them accordingly.
/datum/weather/proc/check_mob_ambient_sound(mob/living/M)
	if(!M || !M.client || !weather_sound) // Only proceed if mob is valid, has a client, and weather_sound is defined
		if(M in mobs_with_ambient_sound)
			SEND_SOUND(M, sound(null, channel = sound_channel))
			mobs_with_ambient_sound -= M
		return

	var/turf/mob_turf = get_turf(M)
	if(!mob_turf || !(mob_turf.z in impacted_z_levels)) // Mob not on an impacted Z-level
		if(M in mobs_with_ambient_sound)
			SEND_SOUND(M, sound(null, channel = sound_channel))
			mobs_with_ambient_sound -= M
		return

	var/should_play_sound = FALSE
	var/volume_to_play = 70 // Default volume

	// Check if the mob is in an area affected by weather and can be affected
	if(can_weather_act(M))
		should_play_sound = TRUE
		var/area/A = get_area(mob_turf)
		if(A && !A.outdoors) // If indoors, dampen the sound
			volume_to_play *= 0.5 // Dampen by 50%

	if(should_play_sound)
		if(!(M in mobs_with_ambient_sound)) // Only start sound if not already playing
			var/sound/S = sound(weather_sound, volume = volume_to_play, channel = sound_channel)
			S.falloff = 0 // No falloff for Z-level wide ambient sounds
			S.repeat = TRUE
			S.frequency = get_rand_frequency()
			SEND_SOUND(M, S)
			mobs_with_ambient_sound += M
	else
		if(M in mobs_with_ambient_sound)
			// Stop the sound if it was playing but shouldn't be now
			SEND_SOUND(M, sound(null, channel = sound_channel))
			mobs_with_ambient_sound -= M

///A hook for weather_types to apply specific effects that can't be captured in these generic effects.
/datum/weather/proc/weather_act(mob/living/L, obj/O)
	// This proc is a placeholder for child weather_types to add their specific effects.
	// Generic weather effects (Wind Gusts, Lightning, Fog, etc) are applied by the SSweather subsystem directly.

/**
 * Updates the overlays on impacted areas
 *
 */
/datum/weather/proc/update_turf_overlays()
	var/list/new_overlay_cache = generate_overlay_cache()

	var/list/chunk_keys = SSweather.weather_chunking.get_impacted_chunk_keys(src)

	for(var/key in chunk_keys)
		var/list/turfs = SSweather.weather_chunking.get_turfs_in_chunks(list(key))
		for(var/turf/T in turfs)
			if(!isturf(T))
				continue

			//Clearing old overlays
			if(length(overlay_cache))
				T.overlays -= overlay_cache

			//Adding new overlays
			if(length(new_overlay_cache))
				T.overlays += new_overlay_cache

	overlay_cache = new_overlay_cache

/// Returns a list of visual offset -> overlays to use
/datum/weather/proc/generate_overlay_cache()
	// We're ending, so no overlays at all
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	var/list/gen_overlay_cache = list()

	// Check if any active effect manages its own overlays. If so, the storm should not apply its generic overlay.
	var/effect_manages_overlay = FALSE
	for(var/datum/weather/effect/E in weather_effects)
		if(E && E.needs_overlay_cleanup)
			effect_manages_overlay = TRUE
			break

	if(effect_manages_overlay)
		return list() // Return empty list if an effect is handling overlays

	if(use_glow)
		var/mutable_appearance/glow_image = mutable_appearance('icons/effects/glow_weather.dmi', weather_state, overlay_layer, ABOVE_LIGHTING_PLANE, 100)
		glow_image.color = weather_color
		gen_overlay_cache += glow_image

	var/mutable_appearance/weather_image = mutable_appearance('icons/effects/weather_effects.dmi', weather_state, overlay_layer, plane = overlay_plane)
	weather_image.color = weather_color
	gen_overlay_cache += weather_image

	return gen_overlay_cache

/**
 * Selects random weather effects from the allowed list at the beginning of the storm.
 */

/datum/weather/proc/select_weather_effects()
	var/list/selected_effects = list()
	var/datum/weather/profile/active_profile = SSweather.current_profile

	if(!active_profile || !active_profile.allowed_weather_effects || !active_profile.allowed_weather_effects.len)
		// If no active profile or no allowed effects, return empty list.
		return selected_effects
	var/num_effects = 3 //Arbitrary, but will be overridden by max_effects if set.
	if(max_effects > 0)
		num_effects = rand(1, max_effects) //If we have a max effects number, use that.
	else
		num_effects = rand(1, 5) //At least 1, at most 5.

	var/list/available_effects = active_profile.allowed_weather_effects.Copy() // Work on a copy to remove selected effects
	var/total_weight = 0

	for(var/effect in available_effects)
		total_weight += available_effects[effect] //Adding each effects weight to the total weight.

	while(num_effects > 0 && total_weight > 0 && available_effects.len > 0) //Continue selecting until we hit the max effects, or no more weight.
		var/random_weight = rand(1, total_weight)
		var/current_weight = 0

		for(var/effect in available_effects)
			current_weight += available_effects[effect]
			if(random_weight <= current_weight)
				selected_effects += effect
				total_weight -= available_effects[effect]
				available_effects.Remove(effect) // Remove from copy
				num_effects--
				break

	var/list/selected_effect_names = list()
	for(var/effect_type in selected_effects)
		var/datum/weather/effect/temp_effect = new effect_type()
		selected_effect_names += temp_effect.name
		qdel(temp_effect) // Clean up the temporary instance

	if(selected_effect_names.len)
		message_admins(span_adminnotice("Weather Datum: [name] selected effects for this storm: [selected_effect_names.Join(", ")]"))
	else
		message_admins(span_adminnotice("Weather Datum: [name] selected no effects for this storm."))

	return selected_effects
