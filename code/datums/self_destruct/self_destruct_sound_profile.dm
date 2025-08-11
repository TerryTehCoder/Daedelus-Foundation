/datum/self_destruct_profile/self_destruct_sound_profile
	var/list/ambient_loops = list(
		'sound/effects/selfdestruct/sirenloop.ogg'
	)
	// List of ambient sound file paths to loop during countdown

/datum/self_destruct_sound_profile/New()
	. = ..()

/datum/self_destruct_profile/self_destruct_sound_profile/handle_event(event_type, data = null)
	message_admins(span_adminnotice("Self-destruct Sound Profile: Handling event [event_type] with data [data]."))
	switch(event_type)
		if(SD_EVENT_START)
			play_ambient_loops()
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EVENT_START - Playing ambient loops."))
		if(SD_EVENT_TICK)
			// No specific action on every tick
		if(SD_EVENT_PAUSE, SD_EVENT_CANCEL)
			stop_ambient_loops()
			stop_alarm_sound() // Ensure alarm sound is stopped on pause/cancel
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EVENT_PAUSE/CANCEL - Stopping all sounds."))
		if(SD_EVENT_RESUME)
			log_game("Self-destruct: Resuming sound effects.")
			play_ambient_loops()
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EVENT_RESUME - Resuming ambient loops."))
		// Handle specific effects directly
		if(SD_EFFECT_FINAL_DESTRUCTION)
			stop_ambient_loops()
			stop_alarm_sound()
			// Play final destruction sound
			sound_to_playing_players('sound/machines/alarm.ogg', 100, FALSE) // Play alarm.ogg for final destruction
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_FINAL_DESTRUCTION - Playing final destruction sound."))
		if(SD_EFFECT_ALARM_5)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_5 - Playing alarm sound 5."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm5Tone.ogg', 50, FALSE, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_4)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_4 - Playing alarm sound 4."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm4Tone.ogg', 60, FALSE, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_3)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_3 - Playing alarm sound 3."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm3Tone.ogg', 70, FALSE, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_2)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_2 - Playing alarm sound 2."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm2Tone.ogg', 80, FALSE, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_1)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_1 - Playing alarm sound 1."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm1Tone.ogg', 90, FALSE, CHANNEL_SELF_DESTRUCT_ALARM)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/play_ambient_loops()
	message_admins(span_adminnotice("Self-destruct Sound Profile: play_ambient_loops() called."))
	if(!ambient_loops || !length(ambient_loops))
		message_admins(span_adminnotice("Self-destruct Sound Profile: No ambient loops defined or list is empty."))
		return // No loops to play

	for(var/sound_path in ambient_loops)
		sound_to_playing_players(sound_path, 30, TRUE, CHANNEL_SELF_DESTRUCT_AMBIENCE)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/stop_ambient_loops()
	// Stop all sounds on the self-destruct ambient channel
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.stop_sound_channel(CHANNEL_SELF_DESTRUCT_AMBIENCE)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/stop_alarm_sound()
	// Stop all sounds on the self-destruct alarm channel
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.stop_sound_channel(CHANNEL_SELF_DESTRUCT_ALARM)
