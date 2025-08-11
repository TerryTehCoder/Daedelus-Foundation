/datum/self_destruct_config
    // This datum holds the default configuration for self-destruct milestones and profiles.
    // It can be extended or overridden to provide different self-destruct presets.
	// We validate that only one time type is set (relative or absolute), and if both are, we force absolute.

    var/list/default_milestones = list(
        new /datum/self_destruct_milestone(list(SD_EFFECT_LIGHTS_RED), relative_percentage = 1.0), // Lights red at start
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_5), relative_percentage = 0.8), // Alarm 5 at 80%
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_4), relative_percentage = 0.6), // Alarm 4 at 60%
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_3), relative_percentage = 0.4), // Alarm 3 at 40%
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_2), relative_percentage = 0.2), // Alarm 2 at 20%
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_1), relative_percentage = 0.05), // Alarm 1 at 5%
        new /datum/self_destruct_milestone(list(SD_EFFECT_FINAL_DESTRUCTION), absolute_time_offset = 0) // Final destruction at 0s
    )

    var/list/default_profiles = list(
        /datum/self_destruct_profile/self_destruct_light_profile,
        /datum/self_destruct_profile/self_destruct_mechanical_profile,
        /datum/self_destruct_profile/self_destruct_sound_profile,
        /datum/self_destruct_profile/self_destruct_explosion_profile
    )

/*
// Example of a custom self-destruct configuration:
/datum/self_destruct_config/my_custom_preset
    default_milestones = list(
        new /datum/self_destruct_milestone(list(SD_EFFECT_LIGHTS_RED, SD_EFFECT_INTENSE_ALARM), relative_percentage = 1.0),
        new /datum/self_destruct_milestone(list(SD_EFFECT_HULL_BREACH), absolute_time_offset = 120),
        new /datum/self_destruct_milestone(list(SD_EFFECT_FINAL_DESTRUCTION), absolute_time_offset = 0)
    )
    default_profiles = list(
        /datum/self_destruct_light_profile,
        /datum/self_destruct_sound_profile // Only sound and light profiles
    )

// You should /probably/ include some type of Final Destruction event in a self_destruct sequence..we won't handhold though.
*/

/datum/self_destruct_config/proc/get_default_milestones()
    return default_milestones

/datum/self_destruct_config/proc/get_default_profiles()
    return default_profiles
