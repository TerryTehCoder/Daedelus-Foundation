/mob/living/scp096
	name = "????"
	icon = 'icons/SCP/scp-096.dmi'

	icon_state = "scp"
	health = 2000
	maxHealth = 2000

	//Config

	///View probability when idle
	var/idle_view_prob = 20
	///View probability when chasing
	var/chasing_view_prob = 40
	///How long until we can emote again?
	var/emote_cooldown = 40 SECONDS
	///Speed at which we move at
	var/scp096_speed = 1 // Handeled by movespeed modifier usually, but Base.
	///How close we have to be before we can leap at a target
	var/scp096_leap_range = 4
	///Maximium JPS distance. Dont fuck with this unless you know what you're doing.
	var/maxJPSdistance = 240
	///How long 096 holds onto a target for (in deciseconds)
	var/scp096_grab_duration = 50
	///How often 096 slashes a grabbed target (in deciseconds)
	var/scp096_slash_interval = 10
	///Damage per slash
	var/scp096_slash_damage = 50

	//Mechanicial

	///Current Target
	var/mob/living/carbon/human/target
	///Possible targets we can pick from
	var/list/mob/living/carbon/human/targets
	///Individuals who were viewing us
	var/list/datum/weakref/oldViewers

	///Our current AI state
	var/current_state = STATE_096_IDLE
	///Our description to scramblers
	var/scramble_desc
	///Emote Cooldown tracker
	var/emote_cooldown_track = 0
	///096's current pathing path. We store this to avoid calling JPS unnecesarily.
	var/list/current_path
	///Targets previous turf, this is kept in order to avoid calling JPS unnecesarily.
	var/datum/weakref/lastTargetTurf
	///How long 096 is staggered for
	var/stagger_counter
	var/seedarkness  =  1
	var/datum/component/scp096_tackler/scp_tackler // New component for SCP-096's leap

/datum/movespeed_modifier/scp096_enraged_speed
	slowdown = -7 // Very fast (3 deciseconds per tile if base is 10)
	priority = 10 // High priority

//Overide, unsure if buckleable var exists.
/mob/living/scp096/is_buckle_possible(mob/living/target, force, check_loc)
		return FALSE

/mob/living/scp096/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "IC"
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	update_sight()

/mob/living/scp096/verb/stop_screaming()
	set name = "Stop scream"
	set category = "IC"

	target = null
	LAZYCLEARLIST(targets)
	current_state = STATE_096_IDLE
	icon_state = "scp"
	update_icon()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp096_enraged_speed, TRUE)

/mob/living/scp096/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"????", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"096", //Numerical Designation
		SCP_MEMETIC
	)

	SCP.memeticFlags = MINSPECT|MPHOTO|MCAMERA
	SCP.memetic_proc = TYPE_PROC_REF(/mob/living/scp096, trigger)
	SCP.compInit()

	scp_tackler = AddComponent(/datum/component/scp096_tackler)
	scramble_desc = "A pale, emanciated figure. It looks almost human, but its limbs are long and skinny, its face is [span_info("censored with several flashing squares.")]"
	desc = "A pale white figure, with lengthy arms. You slowly scan the creature bottom up, from its skinny atrophied legs to its...face. Its face. Oh god [span_danger("its horrible [span_bold("face")]!")]"

	LAZYINITLIST(targets)
	LAZYINITLIST(oldViewers)
	LAZYINITLIST(current_path)

/mob/living/scp096/Destroy()
	target = null
	LAZYCLEARLIST(targets)
	LAZYCLEARLIST(oldViewers)
	LAZYCLEARLIST(current_path)

	..()

//Mechanics

///Triggers 096 on a target
/mob/living/scp096/proc/trigger(mob/living/carbon/human/Ptarget)
	if(Ptarget in targets)
		return

	if(istype(Ptarget.client.eye, /obj/machinery/camera))
		to_chat(Ptarget, span_danger("You catch a glimpse of [span_bold("its face")] through the monitor!"))

	switch(current_state)
		if(STATE_096_IDLE)
			icon_state = "scp-screaming"
			current_state = STATE_096_SCREAMING
			update_icon()

			target = Ptarget
			targets += Ptarget

			playsound(src, 'sound/scp/scp096/096-rage.ogg', 100, ignore_walls = TRUE)
			addtimer(CALLBACK(src, PROC_REF(finish_screaming)), 30 SECONDS)
		if(STATE_096_SCREAMING, STATE_096_CHASING, STATE_096_SLAUGHTER, STATE_096_STAGGERED)
			targets += Ptarget

/mob/living/scp096/proc/finish_screaming()
	current_state = STATE_096_CHASING
	icon_state = "scp-chasing"
	update_icon()
	chase_noise()
	add_movespeed_modifier(/datum/movespeed_modifier/scp096_enraged_speed, TRUE)

/mob/living/scp096/proc/chase_noise()
	if(current_state == STATE_096_IDLE)
		return
	playsound(src, 'sound/scp/scp096/096-chase.ogg', 100, ignore_walls = TRUE)
	addtimer(CALLBACK(src, PROC_REF(chase_noise)), 10 SECONDS)

/mob/living/scp096/proc/OpenDoor(obj/machinery/door/A)
	if(!istype(A))
		return

	if(!A.density)
		return

	if(!A.Adjacent(src))
		to_chat(src, span_warning("\The [A] is too far away."))
		return

	var/open_time = 0.5 SECOND
	if(istype(A, /obj/machinery/door/poddoor))
		open_time = 2.5 SECONDS

	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		if(AR.locked)
			open_time += 0.5 SECONDS
		if(AR.welded)
			open_time += 0.5 SECONDS
		if(AR.security_level > 0)
			open_time += 0.5 SECONDS

	visible_message(span_warning("\The [src] begins to pry open \the [A]!"))
	playsound(get_turf(A), 'sound/machines/airlock_alien_prying.ogg', 35, 1)
	if(!do_after(src, open_time, A))
		return

	if(istype(A, /obj/machinery/door/poddoor))
		var/obj/machinery/door/poddoor/DB = A
		DB.visible_message(span_danger("\The [src] forcefully opens \the [DB]!"))
		DB.open(1)
		return

	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = A
		AR.unlock(TRUE) // No more bolting in the SCPs and calling it a day
		AR.welded = FALSE
//	A.set_broken(TRUE) - TD: Integrate Doorbreacher component from #13, yell at someone if forgotten.
	var/check = A.open(1)
	src.visible_message("\The [src] slices \the [A]'s controls[check ? ", ripping it open!" : ", breaking it!"]")

// AI procs

///Handles 096 AI
//
/mob/living/scp096/proc/handle_AI()
	switch(current_state)
		if(STATE_096_IDLE)
			if(prob(45) && ((world.time - emote_cooldown_track) > emote_cooldown))
				audible_message(pick("[src] cries.", "[src] sobs.", "[src] wails."))
				playsound(src, 'sound/scp/scp096/096-idle.ogg', 80, ignore_walls = TRUE)
				emote_cooldown_track = world.time
		if(STATE_096_CHASING)
			//Find path to target
			for(var/mob/living/carbon/human/Ptarget in targets)
				if(QDELETED(Ptarget)) // If target is deleted, remove it and continue to next
					targets -= Ptarget
					continue
				if(LAZYLEN(current_path))
					break
				target = Ptarget
				lastTargetTurf = get_turf(target)
				current_path = jps_path_to(src, target, maxJPSdistance)
			//If we have no more targets, we go back to idle
			if(!LAZYLEN(targets))
				current_state = STATE_096_IDLE
				icon_state = "scp"
				target = null
				current_path = null
				//This resets the screaming noise for everyone.
				for(var/mob/living/carbon/human/hearer in hearers(world.view, src))
					hearer.playsound_local(src, sound(null))
				update_icon()
				remove_movespeed_modifier(/datum/movespeed_modifier/scp096_enraged_speed)
				return
			//If we havent found a path for any of our targets, we notify admins and switch ourselves to the first target in our list. Path code will also use byond's inherent pathfinding for this life call.
			if(!LAZYLEN(current_path))
				log_admin("Instance of SCP-[SCP.designation] failed to find paths for targets. Switching to byond pathfinding for current life iteration. SCP: [src], Location: [loc]")
				message_admins("Instance of SCP-[SCP.designation] failed to find paths for targets. Switching to byond pathfinding for current life iteration. SCP: [src], Location: [loc]")
				target = targets[1]
				lastTargetTurf = get_turf(target)
			//If the target moved, we must regenerate the path list
			if(get_turf(target) != lastTargetTurf)
				current_path = jps_path_to(src, target, maxJPSdistance)
				//if we cant path to target we reset the target
				if(!LAZYLEN(current_path))
					target = null
					return
				lastTargetTurf = get_turf(target)
			//Gets our next step
			LAZYINITLIST(current_path)
			var/turf/next_step = LAZYLEN(current_path) ? current_path[1] : get_step_towards(src, target)
			// If we couldn't find a valid next step (i.e., next_step is our current location),
			// we should not try to clear obstacles on our current tile.
			if(next_step == src.loc)
				return // Do nothing, allow next tick to re-evaluate pathing
			//Get rid of obstacles
			else if(next_step.contains_dense_objects())
				for(var/atom/obstacle in next_step)
					if(!obstacle.density)
						continue
					if(isturf(obstacle) && !istype(obstacle, /turf/closed/wall))
						continue
					UnarmedAttack(obstacle)
			//Murder!
			if(get_dist(src, target) <= 1)
				UnarmedAttack(target)
				return
			else if((get_dist(src, target) <= scp096_leap_range) && scp_tackler.can_leap(src, target))
				scp_tackler.leap(src, target, scp096_leap_range, src.movement_delay)
				return
			step_towards(src, next_step, src.movement_delay)
			if(get_turf(src) != next_step)
				return
			else
				current_path -= next_step
		if(STATE_096_STAGGERED)
			if(world.time > stagger_counter)
				current_state = STATE_096_CHASING
		if(STATE_096_SLAUGHTER) // If in slaughter state, do nothing in AI loop, wait for UnarmedAttack to resolve
			return

//Overrides

/mob/living/scp096/Life()
	//Sets the probability of someone seeing 096's face based on its current state
	var/probability_to_view
	switch(current_state)
		if(STATE_096_IDLE, STATE_096_SCREAMING)
			probability_to_view = idle_view_prob
		if(STATE_096_CHASING, STATE_096_SLAUGHTER, STATE_096_STAGGERED)
			probability_to_view = chasing_view_prob
	//Applies probability to each new viewer
	for(var/mob/living/carbon/human/viewer in viewers(world.view, src))
		if(viewer in oldViewers)
			continue
		if(!can_see(viewer, src))
			continue
		var/message = "[span_notice("You notice [src], and instinctively look away ")]"
		if(prob(probability_to_view))
			message += "[span_notice("but you catch a glimpse of")] [span_danger("its [span_bold("face")]!")]"
			trigger(viewer)
		else
			message += "[span_notice("managing to avoid seeing its face.")]"

		to_chat(viewer, message)
		oldViewers += viewer

	//Now we remove any oldViewers that are no longer looking at 096
	for(var/mob/living/carbon/human/oldViewer in oldViewers)
		if(!can_see(oldViewer, src))
			oldViewers -= oldViewer

	adjustBruteLoss(-10)
	handle_AI()

/mob/living/scp096/examine(mob/user, distance, infix, suffix)
	if(user in GLOB.scramble_hud_users)
		to_chat(user, scramble_desc)
		return TRUE
	else
		return ..()

/mob/living/scp096/update_icon()
	switch(current_state)
		if(STATE_096_IDLE)
			icon_state = "scp"
		if(STATE_096_SCREAMING)
			icon_state = "scp-screaming"
		if(STATE_096_CHASING, STATE_096_SLAUGHTER, STATE_096_STAGGERED)
			icon_state = "scp-chasing"
	..()

//Our leap range
/mob/living/scp096/proc/get_jump_distance()
	return scp096_leap_range

/mob/living/scp096/UnarmedAttack(atom/A as obj|mob|turf)
	if(A == src)
		return

	else if(isobj(A) || istype(A, /turf/closed/wall))
		if(istype(A, /obj/machinery/door))
			OpenDoor(A)
			return
		else
			A.attack_generic(src, rand(120,350), "smashes")
	else if(ismob(A) && (A != target) && (isliving(A)))
		visible_message(span_danger("[src] rips [A] apart trying to get at [target]!"))
		var/mob/living/obstacle = A
		obstacle.gib()
	else if(A == target)
		current_state = STATE_096_SLAUGHTER

		visible_message(span_danger("[src] grabs [target] and starts trying to pull [target.p_them()] apart!"))

		// Create a grab object to hold the target in place
		var/obj/item/hand_item/grab/scp096_grab = new /obj/item/hand_item/grab(src, target, /datum/grab/normal/aggressive)
		if(!scp096_grab) // If grab creation fails, revert to chasing
			target = null
			current_path = null
			current_state = STATE_096_CHASING
			return

		playsound(src, 'sound/scp/scp096/096-kill.ogg', 100)
		target.emote("scream")

		addtimer(CALLBACK(src, PROC_REF(handle_grab_slashing), scp096_grab, target, world.time), scp096_slash_interval)

//Lets us attack after a leap
/mob/living/scp096/proc/handle_grab_slashing(obj/item/hand_item/grab/the_grab, mob/living/carbon/human/the_target, var/grab_start_time)
	if(QDELETED(the_grab) || QDELETED(the_target) || !(the_target in the_grab.affecting.grabbed_by) || current_state != STATE_096_SLAUGHTER)
		// Grab ended prematurely or state changed, clean up
		if(!QDELETED(the_grab))
			qdel(the_grab)
		if(!QDELETED(the_target))
			visible_message(span_danger("[src] loses its grip on [the_target]!"))
		targets -= the_target
		target = null
		current_path = null
		current_state = STATE_096_CHASING
		return

	if(world.time - grab_start_time >= scp096_grab_duration)
		// Grab duration ended, perform final gib and clean up
		visible_message(span_danger("[src] tears [the_target] apart!"))
		the_target.gib()
		log_admin("[the_target] ([the_target.ckey]) has been torn apart by an active SCP-[SCP.designation].")
		message_admins(span_warning("ALERT: [the_target.real_name] [ADMIN_JMP(the_target)] has been torn apart by an active SCP-[SCP.designation]."))
		qdel(the_grab)
		targets -= the_target
		target = null
		current_path = null
		current_state = STATE_096_CHASING
		return

	// Perform slash attack
	visible_message(span_danger("[src] slashes [the_target]!"))
	the_target.adjustBruteLoss(scp096_slash_damage)

	// Reschedule next slash
	addtimer(CALLBACK(src, PROC_REF(handle_grab_slashing), the_grab, the_target, grab_start_time), scp096_slash_interval)

/mob/living/scp096/proc/post_maneuver()
	if((get_dist(src, target) <= 1) && (current_state != STATE_096_SLAUGHTER))
		UnarmedAttack(target)

/mob/living/scp096/bullet_act(obj/projectile/Proj)
	if(!Proj || Proj.damage <= 0)
		return
	if(Proj.damage < 100)
		visible_message(span_danger("[src] is hit by [Proj], but the flesh regenerates and [src] seems unaffected!"))
	else if(current_state != STATE_096_IDLE)
		visible_message(span_danger("[src] is hit by [Proj] blowing a large chunk of flesh off! [src] is momentarily staggered!"))
		if(current_state == STATE_096_STAGGERED)
			stagger_counter = stagger_counter + 1 SECOND
		else
			stagger_counter = world.time + 1 SECOND
			current_state = STATE_096_STAGGERED

/mob/living/scp096/adjustBruteLoss(damage, updating_health = TRUE, forced = FALSE)
	health = clamp((health - damage), 200, maxHealth)

/mob/living/scp096/ex_act(severity)
	. = ..()
	if(current_state != STATE_096_IDLE)
		visible_message(span_danger("[src] is staggered by the explosion!"))
		if(current_state == STATE_096_STAGGERED)
			stagger_counter = stagger_counter + 5 SECOND
		else
			stagger_counter = world.time + 5 SECOND
			current_state = STATE_096_STAGGERED

/mob/living/scp096/get_status_tab_items()
	. = ..()
	for(var/mob/living/carbon/human/Ptarget in targets)
		if(Ptarget != null)
			. += "Real Name: [Ptarget.real_name]"
			. += "Job: [Ptarget.job]"
			. += "Locate X: [Ptarget.x]"
			. += "Locate Y: [Ptarget.y]"
			. += "Locate Z: [Ptarget.z]"

/obj/item/photo/scp096/scp096_photo
	name =  "???? photo"

/obj/item/photo/scp096/scp096_photo/examine(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/scp096))
		var/mob/living/scp096/scp_to_trigger = locate(/mob/living/scp096) in GLOB.SCP_list
		if(get_dist(user, src) <= 1 && isliving(user))
			scp_to_trigger.trigger(user)
			to_chat(user, span_danger("You catch [scp_to_trigger]"))
		else
			to_chat(user, span_notice("It is too far away."))

/proc/isscp096(atom/A)
    return istype(A, /mob/living/scp096)
