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
	var/datum/callback/countdown_timer // Manages the countdown ticks

	var/list/defined_milestones = list() // List of /datum/self_destruct_milestone
	var/list/active_milestones = list() // List of actual times (seconds) for the current countdown
	var/atom/parent_atom // Reference to the atom that owns this controller

/datum/self_destruct_controller/New(datum/self_destruct_config/initial_config = null, atom/new_parent_atom = null)
	. = ..()
	parent_atom = new_parent_atom
	message_admins(span_adminnotice("Self-destruct Controller: New() called. Instance: [src]. Parent: [parent_atom]."))
	// Default milestones (can be overridden by specific profiles)
	// These are defined as relative/absolute offsets, not hardcoded times.
	var/datum/self_destruct_config/config = initial_config || new /datum/self_destruct_config()
	defined_milestones = config.get_default_milestones()
	for(var/profile_type in config.get_default_profiles())
		// Pass the controller instance to the profile so it can register signals
		new profile_type(src)

/datum/self_destruct_controller/proc/generate_milestones(total_time)
	message_admins(span_adminnotice("Self-destruct Controller: generate_milestones() called. Total time: [total_time]."))
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
	message_admins(span_adminnotice("Self-destruct Controller: generate_milestones() completed. Active milestones count: [active_milestones.len]."))

/datum/self_destruct_controller/proc/start_countdown(initial_time)
	message_admins(span_adminnotice("Self-destruct Controller: start_countdown([initial_time]) called."))
	if(timing)
		message_admins(span_adminnotice("Self-destruct Controller: start_countdown - Already timing, returning FALSE."))
		return FALSE // Already timing
	time_remaining = initial_time
	timing = TRUE
	message_admins(span_adminnotice("Self-destruct Controller: timing set to TRUE. Time remaining: [time_remaining]."))
	generate_milestones(initial_time) // Generate milestones based on initial time

	countdown_timer = addtimer(CALLBACK(src, PROC_REF(tick_countdown)), 10, TIMER_LOOP) // 10 deciseconds = 1 second
	message_admins(span_adminnotice("Self-destruct Controller: Started internal countdown timer."))

	SEND_SIGNAL(src, SD_SIGNAL_START, time_remaining)
	message_admins(span_adminnotice("Self-destruct: Countdown started with initial time [initial_time]"))
	return TRUE

/datum/self_destruct_controller/proc/pause_countdown()
	message_admins(span_adminnotice("Self-destruct Controller: pause_countdown() called."))
	if(!timing)
		message_admins(span_adminnotice("Self-destruct Controller: pause_countdown - Not timing, returning FALSE."))
		return FALSE
	timing = FALSE
	if(countdown_timer)
		deltimer(countdown_timer)
		countdown_timer = null
		message_admins(span_adminnotice("Self-destruct Controller: Stopped internal countdown timer."))
	SEND_SIGNAL(src, SD_SIGNAL_PAUSE, time_remaining)
	message_admins(span_adminnotice("Self-destruct Controller: Countdown paused. Time remaining: [time_remaining]."))
	return TRUE

/datum/self_destruct_controller/proc/resume_countdown()
	message_admins(span_adminnotice("Self-destruct Controller: resume_countdown() called."))
	if(timing)
		message_admins(span_adminnotice("Self-destruct Controller: resume_countdown - Already timing, returning FALSE."))
		return FALSE
	timing = TRUE
	countdown_timer = addtimer(CALLBACK(src, PROC_REF(tick_countdown)), 10, TIMER_LOOP) // 10 deciseconds = 1 second
	message_admins(span_adminnotice("Self-destruct Controller: Resumed internal countdown timer."))
	SEND_SIGNAL(src, SD_SIGNAL_RESUME, time_remaining)
	message_admins(span_adminnotice("Self-destruct Controller: Countdown resumed. Time remaining: [time_remaining]."))
	return TRUE

/datum/self_destruct_controller/proc/cancel_countdown()
	message_admins(span_adminnotice("Self-destruct Controller: cancel_countdown() called."))
	if(!timing && time_remaining <= 0)
		message_admins(span_adminnotice("Self-destruct Controller: cancel_countdown - Not timing or already finished, returning FALSE."))
		return FALSE // Not timing or already finished
	timing = FALSE
	time_remaining = 0
	if(countdown_timer)
		deltimer(countdown_timer)
		countdown_timer = null
		message_admins(span_adminnotice("Self-destruct Controller: Stopped internal countdown timer."))
	SEND_SIGNAL(src, SD_SIGNAL_CANCEL)
	message_admins(span_adminnotice("Self-destruct Controller: Countdown cancelled."))
	return TRUE

/datum/self_destruct_controller/proc/trigger_now()
	if(!timing)
		return FALSE
	time_remaining = 0
	tick_countdown() // Force immediate processing to trigger final event
	message_admins(span_adminnotice("Self-destruct: Triggering immediate destruction."))
	return TRUE

/datum/self_destruct_controller/proc/get_time_left()
	return time_remaining

/datum/self_destruct_controller/proc/tick_countdown()
	message_admins(span_adminnotice("Self-destruct Controller: --- Entering tick_countdown(). Time remaining: [time_remaining]. Timing: [timing]."))
	if(!timing)
		message_admins(span_adminnotice("Self-destruct Controller: tick_countdown - Timing is FALSE, stopping timer."))
		if(countdown_timer)
			deltimer(countdown_timer)
			countdown_timer = null
		return

	message_admins(span_adminnotice("Self-destruct Controller: Time remaining BEFORE decrement: [time_remaining]."))

	if(time_remaining <= 0)
		timing = FALSE
		if(countdown_timer)
			deltimer(countdown_timer)
			countdown_timer = null
			message_admins(span_adminnotice("Self-destruct Controller: Stopped internal countdown timer."))
		SEND_SIGNAL(src, SD_SIGNAL_FINAL_DESTRUCTION, parent_atom) // Explicitly broadcast this effect, passing the parent atom
		SEND_SIGNAL(src, SD_SIGNAL_FINAL)
		message_admins(span_adminnotice("Self-destruct: Final event triggered. Time remaining: [time_remaining]."))
		return

	// Check for milestones before decrementing time
	message_admins(span_adminnotice("Self-destruct Controller: Checking milestones for time [time_remaining]. Active milestones count: [active_milestones.len]. Milestone at current time: [active_milestones[time_remaining] ? "YES" : "NO"]."))
	if(active_milestones[time_remaining])
		var/datum/self_destruct_milestone/M = active_milestones[time_remaining]
		for(var/effect_type in M.effect_types)
			SEND_SIGNAL(src, SD_SIGNAL_MILESTONE, effect_type, time_remaining) // Pass each effect type
			message_admins(span_adminnotice("Self-destruct: Milestone triggered at [time_remaining] seconds for effect type [effect_type]."))

	time_remaining -= 1 // Decrement time by 1 second
	message_admins(span_adminnotice("Self-destruct Controller: Time remaining AFTER decrement: [time_remaining]."))
	SEND_SIGNAL(src, SD_SIGNAL_TICK, time_remaining)
	message_admins(span_adminnotice("Self-destruct: Tick - [time_remaining] seconds remaining."))
