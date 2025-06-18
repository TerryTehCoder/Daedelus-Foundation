//My attempt at porting the Bay12 flaregun.

/obj/item/gun/ballistic/flare
	name = "flare launcher"
	desc = "A single shot polymer flare launcher, the XI-54 \"Sirius\" is a reliable way to launch flares away from yourself."
	icon = 'icons/obj/guns/ballistic.dmi'
	icon_state = "flaregun"
	inhand_icon_state = "flaregun"
	fire_sound = 'sound/weapons/flaregunlaunch.ogg'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = null

	casing_ejector = FALSE

/obj/item/ammo_casing/flaregun
	name = "flaregun casing"
	desc = "A spent casing from a flaregun."
	icon = 'icons/obj/guns/ballistic.dmi'
	icon_state = "flaregun"
	caliber = "flare"
	projectile_type = /obj/item/flashlight/flare
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/plastic=5)

/obj/item/gun/ballistic/flare/Initialize(mapload)
	. = ..()
	if(!chambered)
		chambered = new /obj/item/ammo_casing/flaregun(src)

/obj/item/gun/ballistic/flare/examine(mob/user, distance)
	. = ..()
	if(distance <= 2 && chambered)
		to_chat(user, "\A [chambered] is chambered.")

/obj/item/gun/ballistic/flare/can_fire()
	if(!chambered)
		return FALSE // Cannot fire a projectile if no chambered item.

	if(!istype(chambered, /obj/item/ammo_casing/flaregun))
		// This is the "wrong ammo type" scenario. Explode.
		var/mob/living/carbon/C = loc
		if(istype(C))
			C.visible_message(span_danger("[src] explodes in [C]'s hands!"), span_danger("[src] explodes in your face!"))
			for(var/zone in list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
				C.apply_damage(rand(10,20), def_zone=zone)
		else
			visible_message(span_danger("[src] explodes!"))
		explosion(get_turf(src), -1, -1, 1)
		qdel(src)
		return FALSE // Cannot fire if it explodes.

	// If it's the correct casing, then it can fire.
	return ..() // Call parent's can_fire (which returns TRUE by default for gun)

/obj/item/gun/ballistic/flare/try_fire_gun(atom/target, mob/living/user, flag, params, bonus_spread = 0, target_zone = null)
	. = ..(target, user, flag, params, bonus_spread, target_zone) // Call parent's try_fire_gun to create and launch the projectile

	if(.) // If parent's try_fire_gun successfully launched a projectile
		var/obj/projectile/P = . // The return value of try_fire_gun is the projectile
		if(istype(P, /obj/item/flashlight/flare)) // If the launched projectile is a flare
			var/obj/item/flashlight/flare/launched_flare = P
			launched_flare.on = TRUE
			launched_flare.update_brightness()
			START_PROCESSING(SSobj, launched_flare) // Ensure it starts processing for fuel consumption
	return .

/// Rescue Flare Launching Verb + Logic

/obj/item/gun/ballistic/flare/verb/launch_rescue_flare()
	set name = "Launch Rescue Flare"
	set category = "Object"
	set src in usr

	if(!usr.canUseTopic(src, USE_CLOSE|USE_DEXTERITY|USE_NEED_HANDS))
		return

	if(!chambered)
		to_chat(usr, span_warning("[src] is empty!"))
		return

	var/obj/item/ammo_casing/flaregun/C = chambered
	if(!istype(C) || !istype(C.loaded_projectile, /obj/item/flashlight/flare))
		to_chat(usr, span_warning("Only flares can be launched this way!"))
		return

	var/obj/item/flashlight/flare/F = C.loaded_projectile
	chambered = null // Consume the casing
	update_icon()

	to_chat(usr, span_notice("You launch a flare vertically hoping to catch someones attention!"))
	var/turf/start_turf = get_turf(src)
	var/obj/projectile/flare_signal/P = new /obj/projectile/flare_signal(start_turf)
	P.firer = usr
	P.starting = start_turf
	P.original_z = start_turf.z
	P.name = "rescue flare signal"
	P.desc = "A flare launched high into the sky to signal for rescue."
	P.start_vertical_launch()
	qdel(F) // Delete the original flare item

	to_chat(usr, span_notice("The flare shoots up into the sky, but you wonder if anyone will see it..."))
	var/prob_passed = prob(5) // 5% chance to auto-approve. I'm not going to lie to you, your chances of getting out of here alive are slim...
	new /datum/ert_dispatch_request(usr, prob_passed)

/datum/ert_dispatch_request
	var/mob/living/carbon/human/requester = null
	var/timer_id = null
	var/approved = FALSE // True if manually approved, or auto-approved
	var/denied = FALSE // True if manually denied
	var/prob_passed = FALSE //Stores probability result for admin message ternary ("Auto-approves/denies in..")
	var/dispatch_delay = 2 MINUTES // Delay for admin approval/denial

/datum/ert_dispatch_request/proc/Initialize(mob/living/carbon/human/user, prob_result)
	requester = user
	prob_passed = prob_result

	var/status_message = prob_passed ? "MTF dispatch pending. Auto-approves" : "Probability check failed. Auto-denies"
	// Always show both approve and deny links
	var/links = "<a href='?_src_=holder;[REF(src)];approve=1'>APPROVE</a> | <a href='?_src_=holder;[REF(src)];deny=1'>DENY</a>"

	message_admins("Flaregun signal detected from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)]. [status_message] in [DisplayTimeText(dispatch_delay)]. [links]")
	timer_id = addtimer(CALLBACK(src, PROC_REF(auto_finalize)), dispatch_delay, TIMER_UNIQUE)

/datum/ert_dispatch_request/proc/auto_approve() // This proc is no longer called by timer, only by manual approval
	if(!approved)
		approved = TRUE
		message_admins("MTF dispatch for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)] has been automatically approved.")
		dispatch_ert()
	qdel(src)

/datum/ert_dispatch_request/proc/auto_finalize() // New proc for timer callback
	if(!approved && !denied) // Only finalize if no manual action was taken
		if(prob_passed)
			approved = TRUE
			message_admins("MTF dispatch for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)] has been automatically approved.")
			dispatch_ert()
		else
			denied = TRUE
			message_admins("MTF dispatch for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)] has been automatically denied (override window expired).")
	qdel(src)

/datum/ert_dispatch_request/Topic(href, href_list)
	if(href_list["approve"])
		if(!approved && !denied) // Only approve if not already approved or denied
			approved = TRUE
			message_admins("[ADMIN_LOOKUPFLW(usr)] manually approved MTF dispatch for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)].")
			dispatch_ert()
		else
			to_chat(usr, span_warning("This MTF dispatch has already been [approved ? "approved" : "denied"]."))
		deltimer(timer_id)
		qdel(src)
		return TRUE
	if(href_list["deny"])
		if(!approved && !denied) // Only deny if not already approved or denied
			denied = TRUE
			message_admins("[ADMIN_LOOKUPFLW(usr)] manually denied MTF dispatch for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)].")
		else
			to_chat(usr, span_warning("This MTF dispatch has already been [approved ? "approved" : "denied"]."))
		deltimer(timer_id)
		qdel(src)
		return TRUE
	return ..()

/datum/ert_dispatch_request/proc/dispatch_ert()
	message_admins("Calling makeEmergencyresponseteam for flaregun signal from [ADMIN_LOOKUPFLW(requester)] at [ADMIN_VERBOSEJMP(requester.loc)].")
	var/datum/admins/admin_datum = GLOB.admins.len ? GLOB.admins[1] : null // Get the first admin datum, or null if none
	if(admin_datum)
		admin_datum.makeEmergencyresponseteam()
	else
		message_admins("Error: No active admin datum found to dispatch MTF. MTF dispatch failed.")


/obj/projectile/flare_signal
	name = "flare signal"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare"
	var/original_z = 0
	var/max_z_levels = 10 // How many Z-levels to ascend
	var/current_z_level_ascended = 0
	var/movement_delay = 1 SECONDS // Delay between Z-level ascensions
	var/linger_delay = 7 SECONDS // How long the flare lingers at max height
	var/linger_timer_started = FALSE
	var/next_move_time = 0

	// New lighting properties for ignition
	light_outer_range = 7
	light_power = 0.3
	light_color = LIGHT_COLOR_FLARE
	light_system = OVERLAY_LIGHT
	var/on = FALSE // To control light state
	var/lifetime = 0 // Total duration the flare stays lit

/obj/projectile/flare_signal/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	on = TRUE // Turn on the light
	set_light_on(TRUE)
	lifetime = rand(1600, 2000) // Set initial lifetime, similar to original flare fuel

/obj/projectile/flare_signal/Destroy()
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE) // Ensure light is off when destroyed
	. = ..()

/obj/projectile/flare_signal/process(delta_time)
	lifetime = max(lifetime - delta_time, 0) // Consume lifetime
	if(lifetime <= 0)
		set_light_on(FALSE) // Turn off light
		return PROCESS_KILL // Stop processing and qdel

	if(current_z_level_ascended >= max_z_levels)
		// Reached max height, now linger
		if(!linger_timer_started)
			linger_timer_started = TRUE
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), linger_delay, TIMER_UNIQUE)
		return // Stop further movement processing

	if(world.time >= next_move_time)
		next_move_time = world.time + movement_delay
		current_z_level_ascended++
		var/turf/next_turf = locate(src.x, src.y, src.z + 1)
		if(next_turf)
			forceMove(next_turf)
		else
			// If there's no turf above, start lingering immediately
			if(!linger_timer_started)
				linger_timer_started = TRUE
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), linger_delay, TIMER_UNIQUE)
			return

/obj/projectile/flare_signal/proc/start_vertical_launch()
	next_move_time = world.time + movement_delay // Set initial delay
