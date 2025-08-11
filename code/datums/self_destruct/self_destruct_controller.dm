/* A more modular self-destruct framework.
// TLDR:
// - Profile Datum handles effects, make a new one for new effects, or modify existing.
// - code/__DEFINES/self_destruct.dm defines SD_EFFECT_ constants
// - Config datum says what/when milestones should occur. (Relative || Absolute)
// - Instantiate controller datum in bomb, with config datum as arg.
// * You can find more documentation in the comments of each file themselves *
*/

/datum/self_destruct_controller
	var/time_remaining = 0 // In seconds
	var/timing = FALSE
	var/list/subscribers = list() // List of datums/objects that subscribe to events

	var/list/defined_milestones = list() // List of /datum/self_destruct_milestone
	var/list/active_milestones = list() // List of actual times (seconds) for the current countdown
	var/atom/parent_atom // Reference to the atom that owns this controller

/datum/self_destruct_controller/New(datum/self_destruct_config/initial_config = null, atom/new_parent_atom = null)
	. = ..()
	parent_atom = new_parent_atom
	// Default milestones (can be overridden by specific profiles)
	// These are defined as relative/absolute offsets, not hardcoded times.
	var/datum/self_destruct_config/config = initial_config || new /datum/self_destruct_config()
	defined_milestones = config.get_default_milestones()
	for(var/profile_type in config.get_default_profiles())
		subscribe(new profile_type())

/datum/self_destruct_controller/proc/generate_milestones(total_time)
	active_milestones = list()
	for(var/datum/self_destruct_milestone/M in defined_milestones)
		var/calculated_time = -1
		if(M.absolute_time_offset != null)
			calculated_time = M.absolute_time_offset
		else if(M.relative_time_percentage != null)
			calculated_time = round(total_time * M.relative_time_percentage)

		if(calculated_time >= 0 && calculated_time <= total_time) // Only add if within the countdown range
			active_milestones[calculated_time] = M // Store the milestone datum at its calculated time

	// Ensure the final event is always at 0
	if(!active_milestones[0])
		active_milestones[0] = new /datum/self_destruct_milestone(SD_EFFECT_FINAL_DESTRUCTION, absolute_offset = 0)

	// Log for debugging
	log_game("Self-destruct: Generated milestones for total time [total_time]:")
	for(var/time in active_milestones)
		var/datum/self_destruct_milestone/M = active_milestones[time]
		for(var/effect_type in M.effect_types)
			log_game("Self-destruct: Time: [time], Effect: [effect_type], Relative: [M.relative_time_percentage], Absolute: [M.absolute_time_offset]")

/datum/self_destruct_controller/proc/start_countdown(initial_time)
	if(timing)
		return FALSE // Already timing
	time_remaining = initial_time
	timing = TRUE
	generate_milestones(initial_time) // Generate milestones based on initial time
	start_processing(src)
	broadcast_event(SD_EVENT_START, time_remaining)
	message_admins(span_adminnotice("Self-destruct: Countdown started with initial time [initial_time]"))
	return TRUE

/datum/self_destruct_controller/proc/subscribe(datum/subscriber)
	if(!subscriber || !istype(subscriber))
		return FALSE
	if(!(subscriber in subscribers))
		subscribers += subscriber
		return TRUE
	return FALSE

/datum/self_destruct_controller/proc/unsubscribe(datum/subscriber)
	if(!subscriber || !istype(subscriber))
		return FALSE
	if(subscriber in subscribers)
		subscribers -= subscriber
		return TRUE
	return FALSE

/datum/self_destruct_controller/proc/pause_countdown()
	if(!timing)
		return FALSE
	timing = FALSE
	stop_processing(src)
	broadcast_event(SD_EVENT_PAUSE, time_remaining)
	return TRUE

/datum/self_destruct_controller/proc/resume_countdown()
	if(timing)
		return FALSE
	timing = TRUE
	start_processing(src)
	broadcast_event(SD_EVENT_RESUME, time_remaining)
	return TRUE

/datum/self_destruct_controller/proc/cancel_countdown()
	if(!timing && time_remaining <= 0)
		return FALSE // Not timing or already finished
	timing = FALSE
	time_remaining = 0
	stop_processing(src)
	broadcast_event(SD_EVENT_CANCEL)
	return TRUE

/datum/self_destruct_controller/proc/trigger_now()
	if(!timing)
		return FALSE
	time_remaining = 0
	process() // Force immediate processing to trigger final event
	message_admins(span_adminnotice("Self-destruct: Triggering immediate destruction."))
	return TRUE

/datum/self_destruct_controller/proc/get_time_left()
	return time_remaining

/datum/self_destruct_controller/process(delta_time)
	message_admins(span_adminnotice("Self-destruct Controller: process(delta_time) called. Delta: [delta_time]. Time remaining: [time_remaining]. Timing: [timing]."))
	if(!timing)
		return PROCESS_STOP

	if(time_remaining <= 0)
		timing = FALSE
		stop_processing(src)
		broadcast_event(SD_EFFECT_FINAL_DESTRUCTION, parent_atom) // Explicitly broadcast this effect, passing the parent atom
		broadcast_event(SD_EVENT_FINAL)
		message_admins(span_adminnotice("Self-destruct: Final event triggered. Time remaining: [time_remaining]."))
		return PROCESS_STOP

	// Check for milestones before decrementing time
	message_admins(span_adminnotice("Self-destruct Controller: Checking milestones for time [time_remaining]. Active milestones count: [active_milestones.len]. Milestone at current time: [active_milestones[time_remaining] ? "YES" : "NO"]."))
	if(active_milestones[time_remaining])
		var/datum/self_destruct_milestone/M = active_milestones[time_remaining]
		for(var/effect_type in M.effect_types)
			broadcast_event(effect_type, time_remaining) // Pass each effect type
			message_admins(span_adminnotice("Self-destruct: Milestone triggered at [time_remaining] seconds for effect type [effect_type]."))

	time_remaining -= delta_time / 10 // Decrement time after milestone check, using delta_time (converted from deciseconds to seconds)
	message_admins(span_adminnotice("Self-destruct Controller: Time remaining after decrement: [time_remaining]."))
	broadcast_event(SD_EVENT_TICK, time_remaining)
	message_admins(span_adminnotice("Self-destruct: Tick - [time_remaining] seconds remaining."))

	return PROCESS_CONTINUE

/datum/self_destruct_controller/proc/start_processing(datum/process_datum)
	if(!process_datum) return
	if(!(process_datum in SSprocessing.processing))
		SSprocessing.processing += process_datum
		message_admins(span_adminnotice("Self-destruct Controller: Added [process_datum] to SSprocessing.processing. Current count: [SSprocessing.processing.len]"))
	else
		message_admins(span_adminnotice("Self-destruct Controller: [process_datum] already in SSprocessing.processing."))

/datum/self_destruct_controller/proc/stop_processing(datum/process_datum)
	if(!process_datum) return
	if(process_datum in SSprocessing.processing)
		SSprocessing.processing -= process_datum
		message_admins(span_adminnotice("Self-destruct Controller: Removed [process_datum] from SSprocessing.processing. Current count: [SSprocessing.processing.len]"))
	else
		message_admins(span_adminnotice("Self-destruct Controller: [process_datum] not in SSprocessing.processing."))

/datum/self_destruct_controller/proc/broadcast_event(event_type, data = null)
	var/list/subscribers_copy = subscribers.Copy() // Iterate over a copy to safely modify the original list
	for(var/datum/subscriber in subscribers_copy)
		if(QDELING(subscriber))
			subscribers -= subscriber // Remove from original list
			continue
		var/datum/self_destruct_profile/P = subscriber
		P.handle_event(event_type, data)
