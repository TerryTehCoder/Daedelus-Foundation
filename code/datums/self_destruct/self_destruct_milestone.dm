/datum/self_destruct_milestone
    var/list/effect_types // List of SD_EFFECT_ defines or custom event types
    var/relative_time_percentage // Percentage of total countdown time (e.g., 0.5 for halfway)
    var/absolute_time_offset // Offset from the end of the countdown (e.g., 60 for 60 seconds before detonation)
    var/trigger_time = -1 // The calculated absolute time (in seconds) when this milestone should trigger

/datum/self_destruct_milestone/New(effects, relative_percentage = null, absolute_offset = null)
    if(istype(effects, /list))
        src.effect_types = effects
    else
        src.effect_types = list(effects)
    if(relative_percentage != null && absolute_offset != null)
        log_game("Self-destruct Milestone Warning: Both relative_percentage and absolute_time_offset provided for milestone. Prioritizing absolute_time_offset.")
        src.absolute_time_offset = absolute_offset
        src.relative_time_percentage = null // Ensure only one is active
    else if(relative_percentage != null)
        src.relative_time_percentage = relative_percentage
    else if(absolute_offset != null)
        src.absolute_time_offset = absolute_offset

/datum/self_destruct_milestone/proc/sort_by_trigger_time(datum/self_destruct_milestone/M1, datum/self_destruct_milestone/M2)
	return M1.trigger_time - M2.trigger_time
