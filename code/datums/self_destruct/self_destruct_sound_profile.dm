/datum/self_destruct_profile/self_destruct_sound_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/list/ambient_loops = list(
		'sound/effects/selfdestruct/sirenloop.ogg'
	)
	// List of ambient sound file paths to loop during countdown

/datum/self_destruct_profile/self_destruct_sound_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_PAUSE, SD_SIGNAL_CANCEL), PROC_REF(on_stop_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_destruction_signal))
	RegisterSignal(controller, SD_SIGNAL_MILESTONE, PROC_REF(on_milestone_signal))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	play_ambient_loops()
	message_admins(span_adminnotice("Self-destruct Sound Profile: SD_SIGNAL_START - Playing ambient loops."))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_stop_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	stop_ambient_loops()
	stop_alarm_sound() // Ensure alarm sound is stopped on pause/cancel
	message_admins(span_adminnotice("Self-destruct Sound Profile: SD_SIGNAL_PAUSE/CANCEL - Stopping all sounds."))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct: Resuming sound effects.")
	play_ambient_loops()
	message_admins(span_adminnotice("Self-destruct Sound Profile: SD_SIGNAL_RESUME - Resuming ambient loops."))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_final_destruction_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	stop_ambient_loops()
	stop_alarm_sound()
	// Play final destruction sound
	message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play final destruction sound: 'sound/machines/alarm.ogg' at volume 100 on no channel."))
	sound_to_playing_players('sound/machines/alarm.ogg', 100, FALSE) // Play alarm.ogg for final destruction
	message_admins(span_adminnotice("Self-destruct Sound Profile: SD_SIGNAL_FINAL - Playing final destruction sound."))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_milestone_signal(datum/self_destruct_controller/controller_instance, effect_type, data = null)
	SIGNAL_HANDLER
	message_admins(span_adminnotice("Self-destruct Sound Profile: on_milestone_signal received for effect type [effect_type]."))
	// Handle specific effects directly
	switch(effect_type)
		if(SD_EFFECT_ALARM_5)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_5 - Playing alarm sound 5."))
			message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play 'sound/effects/selfdestruct/SelfDestructAlarm5Tone.ogg' at volume 50 on channel CHANNEL_SELF_DESTRUCT_ALARM."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm5Tone.ogg', 25, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_4)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_4 - Playing alarm sound 4."))
			message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play 'sound/effects/selfdestruct/SelfDestructAlarm4Tone.ogg' at volume 60 on channel CHANNEL_SELF_DESTRUCT_ALARM."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm4Tone.ogg', 30, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_3)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_3 - Playing alarm sound 3."))
			message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play 'sound/effects/selfdestruct/SelfDestructAlarm3Tone.ogg' at volume 70 on channel CHANNEL_SELF_DESTRUCT_ALARM."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm3Tone.ogg', 35, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_2)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_2 - Playing alarm sound 2."))
			message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play 'sound/effects/selfdestruct/SelfDestructAlarm2Tone.ogg' at volume 80 on channel CHANNEL_SELF_DESTRUCT_ALARM."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm2Tone.ogg', 40, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_1)
			message_admins(span_adminnotice("Self-destruct Sound Profile: SD_EFFECT_ALARM_1 - Playing alarm sound 1."))
			message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play 'sound/effects/selfdestruct/SelfDestructAlarm1Tone.ogg' at volume 90 on channel CHANNEL_SELF_DESTRUCT_ALARM."))
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm1Tone.ogg', 45, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/play_ambient_loops()
	message_admins(span_adminnotice("Self-destruct Sound Profile: play_ambient_loops() called."))
	if(!ambient_loops || !length(ambient_loops))
		message_admins(span_adminnotice("Self-destruct Sound Profile: No ambient loops defined or list is empty."))
		return // No loops to play

	for(var/sound_path in ambient_loops)
		message_admins(span_adminnotice("Self-destruct Sound Profile: Attempting to play ambient loop '[sound_path]' at volume 30 on channel CHANNEL_SELF_DESTRUCT_AMBIENCE."))
		sound_to_playing_players(sound_path, 30, TRUE, null, CHANNEL_SELF_DESTRUCT_AMBIENCE)

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
