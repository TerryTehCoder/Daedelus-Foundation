/datum/mind
    var/datum/persistent_player_data/persistent_data

/datum/mind/proc/initialize_persistent_data()
    if(!ckey)
        return

    persistent_data = SSpersistent_progression.get_player_data(ckey)
    if(persistent_data)
        // Update last login
        persistent_data.last_login = world.time

        // Notify player of their current status
        if(current && current.client)
            var/datum/persistent_class/class = SSpersistent_progression.get_class(persistent_data.current_class_id)
            var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(persistent_data.current_faction_id)

            to_chat(current, span_notice("Welcome back! You are a [class ? class.class_name : "Unknown"] in the [faction ? faction.faction_name : "Unknown"] faction."))
            to_chat(current, span_notice("Current Rank: [persistent_data.current_rank_name] (Level [persistent_data.current_rank])"))
            to_chat(current, span_notice("Total Experience: [persistent_data.total_experience]"))

            if(class)
                var/progress = persistent_data.get_progress_to_next_rank()
                var/exp_needed = persistent_data.get_experience_needed_for_next_rank()
                if(exp_needed > 0)
                    to_chat(current, span_notice("Progress to next rank: [progress]% ([exp_needed] exp needed)"))

/datum/mind/proc/award_experience(amount, source, reason)
    if(!persistent_data || !ckey)
        return 0

    return SSpersistent_progression.award_experience(ckey, source, amount, reason)

/datum/mind/proc/change_class(new_class_id)
    if(!persistent_data || !ckey)
        return FALSE

    var/datum/persistent_class/new_class = SSpersistent_progression.get_class(new_class_id)
    if(!new_class)
        return FALSE

    // Check if player's faction allows this class
    var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(persistent_data.current_faction_id)
    if(faction && !(new_class_id in faction.faction_classes))
        return FALSE

    persistent_data.current_class_id = new_class_id
    persistent_data.current_rank = 0
    persistent_data.current_rank_name = new_class.get_rank_name(0)

    SSpersistent_progression.save_player_data(ckey)

    if(current && current.client)
        to_chat(current, span_notice("You have changed your class to [new_class.class_name]!"))
        to_chat(current, span_notice("Your rank has been reset to [persistent_data.current_rank_name]."))

    return TRUE

/datum/mind/proc/change_faction(new_faction_id)
    if(!persistent_data || !ckey)
        return FALSE

    var/datum/persistent_faction/new_faction = SSpersistent_progression.get_faction(new_faction_id)
    if(!new_faction)
        return FALSE

    // Check if the new faction allows the player's current class
    if(!(persistent_data.current_class_id in new_faction.faction_classes))
        return FALSE

    persistent_data.current_faction_id = new_faction_id

    SSpersistent_progression.save_player_data(ckey)

    if(current && current.client)
        to_chat(current, span_notice("You have changed your faction to [new_faction.faction_name]!"))

    return TRUE

/datum/mind/proc/get_current_class()
    if(!persistent_data)
        return null

    return SSpersistent_progression.get_class(persistent_data.current_class_id)

/datum/mind/proc/get_current_faction()
    if(!persistent_data)
        return null

    return SSpersistent_progression.get_faction(persistent_data.current_faction_id)

/datum/mind/proc/get_rank_progress()
    if(!persistent_data)
        return list("progress" = 0, "exp_needed" = 0, "current_rank" = 0, "rank_name" = "Unknown")

    var/datum/persistent_class/class = get_current_class()
    if(!class)
        return list("progress" = 0, "exp_needed" = 0, "current_rank" = 0, "rank_name" = "Unknown")

    var/progress = persistent_data.get_progress_to_next_rank()
    var/exp_needed = persistent_data.get_experience_needed_for_next_rank()

    return list(
        "progress" = progress,
        "exp_needed" = exp_needed,
        "current_rank" = persistent_data.current_rank,
        "rank_name" = persistent_data.current_rank_name
    )

/datum/mind/proc/unlock_item(item_id)
    if(!persistent_data)
        return FALSE

    var/unlocked = persistent_data.unlock_item(item_id)
    if(unlocked && current && current.client)
        to_chat(current, span_notice("You have unlocked a new item: [item_id]!"))

    return unlocked

/datum/mind/proc/unlock_title(title_id)
    if(!persistent_data)
        return FALSE

    var/unlocked = persistent_data.unlock_title(title_id)
    if(unlocked && current && current.client)
        to_chat(current, span_notice("You have unlocked a new title: [title_id]!"))

    return unlocked

/datum/mind/proc/add_achievement(achievement_id)
    if(!persistent_data)
        return FALSE

    var/achieved = persistent_data.add_achievement(achievement_id)
    if(achieved && current && current.client)
        to_chat(current, span_notice("Achievement unlocked: [achievement_id]!"))

    return achieved

// Hook into mind transfer
/datum/mind/proc/transfer_to(mob/new_character, force_key_move = FALSE)
    . = ..()

    if(new_character && new_character.client)
        initialize_persistent_data()

        // Start performance tracking
        if(istype(new_character, /mob/living/carbon/human))
            var/datum/performance_tracker/tracker = new /datum/performance_tracker(new_character)
            SSpersistent_progression.active_trackers[ckey] = tracker

// Hook into mind removal
/datum/mind/proc/remove_from_mob()
    // Save persistent data before removal
    if(persistent_data && ckey)
        SSpersistent_progression.save_player_data(ckey)

        // Stop performance tracking
        SSpersistent_progression.active_trackers -= ckey

    . = ..()
