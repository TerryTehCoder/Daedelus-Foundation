/datum/self_destruct_profile/self_destruct_mechanical_profile
    var/list/original_light_colors
    var/list/original_area_lighting_states // Stores original area lighting states for reversion

/datum/self_destruct_profile/self_destruct_mechanical_profile/New()
    . = ..()
    original_light_colors = list()
    original_area_lighting_states = list()

/datum/self_destruct_profile/self_destruct_mechanical_profile/handle_event(event_type, data = null)
    message_admins(span_adminnotice("Self-destruct Mechanical Profile: Handling event [event_type] with data [data]."))
    switch(event_type)
        if(SD_EVENT_START)
            for(var/mob/living/silicon/ai/A in GLOB.ai_list)
                to_chat(A, span_bolddanger("WARNING: Site-Wide Self-Destruct sequence initiated!"))
        if(SD_EVENT_TICK)
            // No specific action on every tick
        if(SD_EVENT_PAUSE, SD_EVENT_CANCEL)
            log_game("Self-destruct: Reverting mechanical effects.")
            message_admins(span_adminnotice("Self-destruct Mechanical Profile: SD_EVENT_PAUSE/CANCEL - Reverting mechanical effects."))
            // Revert red lights
            for(var/obj/machinery/light/L in original_light_colors) // Iterate through light objects directly
                if(istype(L) && !QDELETED(L)) // Check if the light object still exists
                    L.bulb_colour = original_light_colors[L]
                    L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)
            original_light_colors = list() // Clear the list

        if(SD_EVENT_RESUME)
            log_game("Self-destruct: Resuming mechanical effects.")
            message_admins(span_adminnotice("Self-destruct Mechanical Profile: SD_EVENT_RESUME - Resuming mechanical effects."))
            // Re-apply red lights (if they were active before pause)
            for(var/obj/machinery/light/L in original_light_colors)
                if(istype(L) && !QDELETED(L))
                    L.bulb_colour = "#FF0000" // Re-apply red
                    L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)


        if(SD_EFFECT_FINAL_DESTRUCTION)
            // Implement final destruction sequence (e.g., explosion)
            log_game("Self-destruct: Initiating final destruction sequence.")
            message_admins(span_adminnotice("Self-destruct Mechanical Profile: SD_EFFECT_FINAL_DESTRUCTION - Initiating final destruction sequence."))
        // Add more effect types here
