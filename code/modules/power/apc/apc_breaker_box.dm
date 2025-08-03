/obj/machinery/power/apc/breaker_box
	name = "breaker box"
	desc = "A sturdy metal box containing electrical breakers and an area power controller."

	icon = 'icons/obj/breaker_box.dmi' // This will be created later
	icon_state = "breaker_good" // Default good state

	req_access = null // No ID access required to open the cover
	opened = APC_COVER_CLOSED // Starts closed
	coverlocked = TRUE // Starts locked

	// Override ui_interact to only allow access to the APC menu if the cover is open
/obj/machinery/power/apc/breaker_box/ui_interact(mob/user, datum/tgui/ui)
	if(!opened)
		to_chat(user, span_warning("You need to open the breaker box first!"))
		return
	. = ..()

	// Override attack_hand_secondary to handle alt-click for opening/closing the cover
/obj/machinery/power/apc/breaker_box/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, USE_CLOSE|USE_SILICON_REACH) || !isturf(loc))
		return
	if(!ishuman(user))
		return

	if(coverlocked)
		to_chat(user, span_warning("The breaker box is locked!"))
		return

	opened = !opened
	update_appearance()
	if(opened)
		to_chat(user, span_notice("You open the breaker box."))
	else
		to_chat(user, span_notice("You close the breaker box."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// Override update_icon_state and update_overlays for breaker box specific sprites and lights
/obj/machinery/power/apc/breaker_box/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "breaker_damaged"
	else if(machine_stat & MAINT)
		icon_state = "breaker_maint"
	else if(obj_flags & EMAGGED)
		icon_state = "breaker_emag"
	else if(panel_open)
		icon_state = "breaker_wires"
	else if(opened)
		icon_state = "breaker1-nocover" // Assuming this is the open state without cover
	else
		icon_state = "breaker_good" // Default closed state
	return ..()

	update_overlays()
	. = ..()
	if((machine_stat & (BROKEN|MAINT)) || update_state)
		return

	// Add overlay for lock status light
	. += mutable_appearance(icon, "breaker_frame") // Base frame
	. += mutable_appearance(icon, "breaker[locked ? 1 : 2]") // Breaker state (locked/unlocked)
	. += emissive_appearance(icon, "breaker[locked ? 1 : 2]", alpha = 90) // Emissive for light
