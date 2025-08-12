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
	var/countdown_timer // Manages the countdown ticks (stores timer ID)
	var/instance_id // Unique identifier for this instance

	var/list/defined_milestones = list() // List of /datum/self_destruct_milestone
	var/list/active_milestones = list() // List of /datum/self_destruct_milestone objects, sorted by trigger_time
	var/atom/parent_atom // Reference to the atom that owns this controller

/datum/self_destruct_controller/New(datum/self_destruct_config/initial_config = null, atom/new_parent_atom = null)
	. = ..()
	instance_id = rand() // Assign a unique ID to this instance
	parent_atom = new_parent_atom
	message_admins(span_adminnotice("Self-destruct Controller: New() called. Instance: [src] (ID: [instance_id]). Parent: [parent_atom]."))
	// Default milestones (can be overridden by specific profiles)
	// These are defined as relative/absolute offsets, not hardcoded times.
	var/datum/self_destruct_config/config = initial_config || new /datum/self_destruct_config()
	defined_milestones = config.get_default_milestones()
	message_admins(span_adminnotice("Self-destruct Controller: New() - defined_milestones populated. Count: [defined_milestones.len]. Contents: [defined_milestones]."))
	for(var/profile_type in config.get_default_profiles())
		// Pass the controller instance to the profile so it can register signals
		new profile_type(src)

/datum/self_destruct_controller/proc/generate_milestones(total_time)
	message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): generate_milestones() called. Total time: [total_time]."))
	active_milestones = list()
	for(var/datum/self_destruct_milestone/M in defined_milestones)
		var/calculated_time = -1
		if(M.absolute_time_offset != null)
			calculated_time = total_time - M.absolute_time_offset
			message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Milestone '[M]' (Absolute: [M.absolute_time_offset]) calculated time: [calculated_time]."))
		else if(M.relative_time_percentage != null)
			calculated_time = round(total_time * M.relative_time_percentage)
			message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Milestone '[M]' (Relative: [M.relative_time_percentage]) calculated time: [calculated_time]."))

		message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Milestone '[M]' (Relative: [M.relative_time_percentage], Absolute: [M.absolute_time_offset]) calculated time: [calculated_time]."))
		if(calculated_time >= 0 && calculated_time <= total_time) // Only add if within the countdown range
			M.trigger_time = floor(calculated_time) // Assign the calculated time to the milestone's trigger_time
			active_milestones += M // Add the milestone datum to the list
			message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Added milestone '[M]' at calculated time [M.trigger_time]. Condition: ([calculated_time] >= 0 && [calculated_time] <= [total_time]) was TRUE."))
		else
			message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Did NOT add milestone '[M]' at time [calculated_time] (out of range). Condition: ([calculated_time] >= 0 && [calculated_time] <= [total_time]) was FALSE. Calculated: [calculated_time], Total: [total_time]. ([calculated_time] >= 0: [calculated_time >= 0]), ([calculated_time] <= [total_time]: [calculated_time <= total_time])."))

	// Ensure the final event is always at 0
	var/datum/self_destruct_milestone/final_milestone = new /datum/self_destruct_milestone(SD_EFFECT_FINAL_DESTRUCTION, absolute_offset = 0)
	final_milestone.trigger_time = 0
	var/found_final = FALSE
	for(var/datum/self_destruct_milestone/M in active_milestones)
		if(M.trigger_time == 0)
			found_final = TRUE
			break
	if(!found_final)
		active_milestones += final_milestone
		message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): Added final destruction milestone at time 0."))

	// Sort milestones by trigger_time in ascending order
	sortTim(active_milestones, TYPE_PROC_REF(/datum/self_destruct_milestone, sort_by_trigger_time))

	// Log for debugging
	log_game("Self-destruct: Generated milestones for total time [total_time]:")
	for(var/datum/self_destruct_milestone/M in active_milestones)
		for(var/effect_type in M.effect_types)
			log_game("Self-destruct: Time: [M.trigger_time], Effect: [effect_type], Relative: [M.relative_time_percentage], Absolute: [M.absolute_time_offset]")
	message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id]): generate_milestones() completed. Active milestones count: [active_milestones.len]. Active milestones: [active_milestones]."))

/datum/self_destruct_controller/proc/start_countdown(initial_time)
	message_admins(span_adminnotice("Self-destruct Controller: start_countdown([initial_time]) called. Initial time: [initial_time]."))
	if(timing) // Sanity check: if already timing, something is wrong
		message_admins(span_adminnotice("Self-destruct Controller: start_countdown - Already timing! Aborting start to prevent duplicate timers. Current time remaining: [time_remaining]."))
		return FALSE

	if(countdown_timer) // Explicitly stop any existing timer
		deltimer(countdown_timer)
		countdown_timer = null
		message_admins(span_adminnotice("Self-destruct Controller: start_countdown - Stopped existing timer before starting a new one."))

	time_remaining = initial_time
	timing = TRUE
	message_admins(span_adminnotice("Self-destruct Controller: timing set to TRUE. Time remaining: [time_remaining]."))
	generate_milestones(initial_time) // Generate milestones based on initial time

	countdown_timer = null // Sanity check: Ensure timer is null before attempting to create a new one
	if(!countdown_timer) // Defensive check: ensure no timer is active before creating a new one
		countdown_timer = addtimer(CALLBACK(src, PROC_REF(tick_countdown)), 10, TIMER_LOOP | TIMER_STOPPABLE) // 10 deciseconds = 1 second
		if(countdown_timer)
			message_admins(span_adminnotice("Self-destruct Controller: Started internal countdown timer. Timer ID: [countdown_timer]."))
		else
			message_admins(span_adminnotice("Self-destruct Controller: FAILED to start internal countdown timer."))
	else
		message_admins(span_adminnotice("Self-destruct Controller: start_countdown - Timer already active, not starting a new one."))

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
	if(timing) // Sanity check: if already timing, something is wrong
		message_admins(span_adminnotice("Self-destruct Controller: resume_countdown - Already timing! Aborting resume. Current time remaining: [time_remaining]."))
		return FALSE

	if(countdown_timer) // Explicitly stop any existing timer
		deltimer(countdown_timer)
		countdown_timer = null
		message_admins(span_adminnotice("Self-destruct Controller: resume_countdown - Stopped existing timer before resuming."))

	timing = TRUE
	countdown_timer = null // Sanity check: Ensure timer is null before attempting to create a new one
	if(!countdown_timer) // Defensive check: ensure no timer is active before creating a new one
		countdown_timer = addtimer(CALLBACK(src, PROC_REF(tick_countdown)), 10, TIMER_LOOP | TIMER_STOPPABLE) // 10 deciseconds = 1 second
		message_admins(span_adminnotice("Self-destruct Controller: Resumed internal countdown timer."))
	else
		message_admins(span_adminnotice("Self-destruct Controller: resume_countdown - Timer already active, not starting a new one."))
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
	// Sanity check: If not timing and time is 0 or less, this timer should have stopped.
	// This prevents continuous execution from a lingering timer after countdown completion/cancellation.
	if(!timing && time_remaining <= 0)
		return

	message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): Time remaining BEFORE processing: [time_remaining] (Type: [isnum(time_remaining) ? "Number" : "Other"])."))

	// Ensure time_remaining is a strict integer for consistent lookup
	time_remaining = floor(time_remaining)

	// Check if time has reached 0 or gone below.
	// This check must happen BEFORE decrementing to ensure the final event triggers at 0 and only once.
	if(time_remaining <= 0)
		if(timing) // Only trigger final signal if it was actively timing
			timing = FALSE
			if(countdown_timer)
				deltimer(countdown_timer)
				countdown_timer = null
				message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): Stopped internal countdown timer."))
			SEND_SIGNAL(src, SD_SIGNAL_FINAL, parent_atom)
			message_admins(span_adminnotice("Self-destruct (ID: [instance_id], Ref: [src]): Countdown finished. Time remaining: [time_remaining]."))
		return // Exit to prevent further processing or negative numbers

	// Decrement time by 1 second
	time_remaining = time_remaining - 1
	message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): Time remaining AFTER decrement: [time_remaining] (Type: [isnum(time_remaining) ? "Number" : "Other"])."))

	// Check for milestones at the new time_remaining
	message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): Checking milestones for time [time_remaining]. Active milestones count: [active_milestones.len]."))
	// Iterate through active milestones and trigger those whose trigger_time is less than or equal to current time_remaining
	// Process in reverse to safely remove elements while iterating
	for(var/i = active_milestones.len, i >= 1, i--)
		var/datum/self_destruct_milestone/M = active_milestones[i]
		if(M.trigger_time == time_remaining) // Trigger when the milestone's time is exactly the current time_remaining
			message_admins(span_adminnotice("Self-destruct Controller (ID: [instance_id], Ref: [src]): Found milestone '[M]' at [M.trigger_time] seconds. Effects: [M.effect_types]."))
			for(var/effect_type in M.effect_types)
				SEND_SIGNAL(src, SD_SIGNAL_MILESTONE, effect_type, time_remaining) // Pass each effect type
				message_admins(span_adminnotice("Self-destruct (ID: [instance_id], Ref: [src]): SENT SD_SIGNAL_MILESTONE for effect type [effect_type] at [time_remaining] seconds."))
			active_milestones.Remove(M) // Remove triggered milestone
		// The list is sorted, so we iterate through all of them to find exact matches.

	SEND_SIGNAL(src, SD_SIGNAL_TICK, time_remaining)
	message_admins(span_adminnotice("Self-destruct (ID: [instance_id], Ref: [src]): Tick - [time_remaining] seconds remaining."))
