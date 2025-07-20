/mob/living/simple_animal/hostile/scp017
	name = "shambling void"
	desc = "A weird shambling void. You can see nothing inside."
	icon = 'icons/scp/humanoidscps(32x32).dmi'

	icon_state = "scp-017"
	response_help_continuous = "tries to reach inside"
	response_disarm_continuous = "tries to push away"
	response_harm_continuous = "tries to punch"

	pass_flags = PASSTABLE
	density = FALSE

	maxHealth = 100
	health = 100

	turns_per_move = 1
	speak_chance = 1

	emote_hear = list("wooshes","whispers")
	emote_see = list("shambles", "shimmers")

	//Config

	///lumcount required for something to be considered a shadow
	var/shadow_threshold = 0.35

	// Ability Durations
	var/stun_duration_light = 20 // 2 seconds
	var/light_source_debuff_duration = 30 // 3 seconds
	var/shadow_veil_cooldown = 600 // 60 seconds
	var/shadow_veil_duration = 150 // 15 seconds
	var/shadow_sickness_range = 5
	var/shadow_sickness_duration = 100 // 10 seconds
	var/void_state_duration = 200 // 20 seconds

	var/last_shadow_veil_time = 0
	var/list/shadow_sickness_targets = list()

	// Enveloping Shadow and Light Suppression
	var/enveloping_duration = 30 // 3 seconds for enveloping
	var/datum/callback/enveloping_progress_timer_id // Timer for the enveloping progress
	var/mob/living/enveloping_target // The mob currently being enveloped

	var/light_suppression_range = 2
	var/light_suppression_chance = 10 // 10% chance per tick
	var/light_suppression_duration = 50 // 5 seconds

/mob/living/simple_animal/hostile/scp017/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"shambling void", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_KETER, //Obj Class
		"017", //Numerical Designation
	)

//Mob procs
/mob/living/simple_animal/hostile/scp017/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(!.) //dead
		return

	CheckLightExposure()
	ApplyShadowSickness()
	HandleLightSuppression() // Call the new light suppression proc

	if(prob(5) && world.time >= last_shadow_veil_time + shadow_veil_cooldown) // Small chance to activate Shadow Veil if off cooldown
		ShadowVeil()

/mob/living/simple_animal/hostile/scp017/proc/HandleLightSuppression()
	if(prob(light_suppression_chance))
		for(var/obj/machinery/light/L in range(light_suppression_range, src))
			if(L.on)
				L.on = FALSE
				addtimer(CALLBACK(L, "set_on", TRUE), light_suppression_duration)
				visible_message(span_warning("Lights flicker as [src] passes by!"))

/mob/living/simple_animal/hostile/scp017/proc/CheckLightExposure()
	var/turf/Tturf = get_turf(src)
	var/area/Tarea = get_area(src)

	if(!Tturf || !Tarea)
		return

	if((Tturf.get_lumcount() > shadow_threshold) || (!Tarea.area_lighting == AREA_LIGHTING_DYNAMIC))
		// SCP-017 is in light, apply stun/slow
		if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED)) // Check if already stunned
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_LIGHT_STUN")
			visible_message(span_warning("[src] recoils from the light!"))
			addtimer(CALLBACK(src, PROC_REF(RemoveLightStun)), stun_duration_light)
	else
		// SCP-017 is in a shadow, remove stun if present
		RemoveLightStun()

/mob/living/simple_animal/hostile/scp017/proc/RemoveLightStun()
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_LIGHT_STUN")
		visible_message(span_notice("[src] regains its composure in the shadows."))

/mob/living/simple_animal/hostile/scp017/proc/ApplyShadowSickness()
	var/list/current_sickness_targets = list()
	for(var/mob/living/carbon/human/M in range(shadow_sickness_range, src))
		if(M == src || M.stat == DEAD || M.status_flags & GODMODE)
			continue

		var/turf/M_turf = get_turf(M)
		var/area/M_area = get_area(M)

		if(!M_turf || !M_area)
			continue

		// Only apply sickness if SCP-017 is in shadow or has created a shadow veil
		if((M_turf.get_lumcount() <= shadow_threshold) && (M_area.area_lighting == AREA_LIGHTING_DYNAMIC))
			if(!(M in shadow_sickness_targets))
				// Apply debuffs
				M.see_in_dark = max(0, M.see_in_dark - 5) // Reduce vision
				M.adjust_blurriness(0.2)
				M.stamina.adjust(-7) // Stamina drain
				to_chat(M, span_warning("You feel a chilling presence..."))
				shadow_sickness_targets += M
			current_sickness_targets += M

	// Remove sickness from targets no longer in range or in light
	for(var/mob/living/carbon/human/M in shadow_sickness_targets)
		if(!(M in current_sickness_targets))
			// Remove debuffs
			M.see_in_dark = initial(M.see_in_dark) // Restore vision
			to_chat(M, span_notice("The chilling presence recedes."))
			shadow_sickness_targets -= M

/mob/living/simple_animal/hostile/scp017/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(!..())
		return FALSE
	if(the_target.SCP)
		return FALSE
	var/turf/Tturf = get_turf(the_target)
	var/area/Tarea = get_area(the_target)
	if(!Tturf || !Tarea)
		return FALSE
	if((Tturf.get_lumcount() > shadow_threshold) || (!Tarea.area_lighting == AREA_LIGHTING_DYNAMIC))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/scp017/Move(turf/newloc, safety = TRUE)
	var/turf/Tturf = newloc //Cleanliness
	var/area/Tarea = get_area(newloc)
	if((Tturf.get_lumcount() > shadow_threshold) || (!Tarea.area_lighting == AREA_LIGHTING_DYNAMIC))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/scp017/gib()
	return FALSE

/mob/living/simple_animal/hostile/scp017/dust(just_ash, drop_items, force)
	return FALSE


//Death

/mob/living/simple_animal/hostile/scp017/death(gibbed, cause_of_death = "disappears in a puff of smoke")
	. = ..()
	var/turf/T = get_turf(src)

	do_smoke(amount = 3, location = T)

	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/scp017/proc/ShadowVeil()
	if(world.time < last_shadow_veil_time + shadow_veil_cooldown)
		return FALSE

	last_shadow_veil_time = world.time
	visible_message(span_danger("[src] expands, casting a deep shadow around itself!"))

	var/list/affected_turfs = list()
	for(var/turf/T in range(3, src)) // 3x3 radius for now
		if(isturf(T))
			var/area/A = get_area(T)
			if(A.area_lighting == AREA_LIGHTING_DYNAMIC) // Only affect dynamic lighting areas
				T.set_light(0, 0, 0)
				affected_turfs += T

	ADD_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_SHADOW_VEIL_IMMUNITY")
	addtimer(CALLBACK(src, PROC_REF(RemoveShadowVeilImmunity)), shadow_veil_duration)

	return TRUE

/mob/living/simple_animal/hostile/scp017/proc/RemoveShadowVeilImmunity()
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_SHADOW_VEIL_IMMUNITY")
		visible_message(span_notice("The shadows around [src] recede."))

/mob/living/simple_animal/hostile/scp017/proc/IsStrongLightSource(atom/A)
	if(istype(A, /obj/machinery/light))
		var/obj/machinery/light/L = A
		if(L.on && L.light_power > 0)
			return TRUE
	if(istype(A, /obj/item/flashlight))
		var/obj/item/flashlight/F = A
		if(F.on && F.light_power > 0)
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/scp017/bullet_act(obj/projectile/Proj)
	if(enveloping_target && IsStrongLightSource(Proj))
		StopEnveloping(FALSE)
		LightSourceDebuff() // Apply debuff for being hit by strong light
		visible_message(span_notice("[src] recoils from the intense light, releasing [enveloping_target]!"))
		return TRUE // Consume the projectile
	if(Proj.damage_type == BRUTE)
		visible_message(span_warning("The [Proj] seems to pass right through it!"))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/scp017/proc/LightSourceDebuff()
	if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_LIGHT_DEBUFF")
		shadow_threshold -= 0.15 // Decrease threshold, making it vulnerable in slightly brighter areas
		visible_message(span_warning("[src] shimmers erratically as it absorbs the light!"))
		addtimer(CALLBACK(src, PROC_REF(RemoveLightSourceDebuff)), light_source_debuff_duration)

/mob/living/simple_animal/hostile/scp017/proc/RemoveLightSourceDebuff()
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "SCP017_LIGHT_DEBUFF")
		shadow_threshold = initial(shadow_threshold) // Reset threshold
		visible_message(span_notice("[src] stabilizes as the light's influence fades."))

//Attack

/mob/living/simple_animal/hostile/scp017/UnarmedAttack(atom/A)
	var/turf/Tturf = get_turf(A)
	var/area/Tarea = get_area(A)

	if(!ismovable(A) || A.SCP)
		return FALSE
	if(!Tturf || !Tarea)
		return FALSE
	if((Tturf.get_lumcount() > shadow_threshold) || (!Tarea.area_lighting == AREA_LIGHTING_DYNAMIC))
		return FALSE

	do_smoke(amount = 3, location = Tturf)

	var/death_message = pick("[A] disappears into [src]!", "[A] is enveloped by [src]!", "[A] is absorbed by [src]!")
	visible_message(span_danger(death_message))

	if(ismob(A))
		var/mob/living/target_mob = A
		StartEnveloping(target_mob)
	else
		qdel(A)

//General Interactions
/mob/living/simple_animal/hostile/scp017/proc/StartEnveloping(mob/living/target_mob)
	if(enveloping_target) // Already enveloping someone
		return FALSE

	enveloping_target = target_mob
	visible_message(span_danger("[enveloping_target] is being enveloped by [src]!"))

	// Apply initial vision reduction and blurriness
	if(enveloping_target.client)
		enveloping_target.client.eye = src // Force eye to SCP-017 for effect
		enveloping_target.see_in_dark = max(0, enveloping_target.see_in_dark - 5) // Initial vision reduction
		enveloping_target.adjust_blurriness(0.2) // Initial blurriness

	enveloping_progress_timer_id = addtimer(CALLBACK(src, PROC_REF(UpdateEnveloping)), 10, enveloping_duration / 10) // Call every 1 second for duration

	return TRUE

/mob/living/simple_animal/hostile/scp017/proc/UpdateEnveloping()
	if(!enveloping_target || QDELETED(enveloping_target))
		StopEnveloping()
		return

	if(enveloping_target.client)
		enveloping_target.see_in_dark = max(0, enveloping_target.see_in_dark - 5) // Progressively reduce vision
		enveloping_target.adjust_blurriness(0.2) // Progressively increase blurriness

		// Check if vision is fully obscured or timer runs out
		if(enveloping_target.see_in_dark <= 0 || QDELETED(enveloping_progress_timer_id))
			StopEnveloping(TRUE) // Fully enveloped, kill
			return

	// Add visual effects on SCP-017 or target
	do_smoke(amount = 1, location = enveloping_target.loc)

/mob/living/simple_animal/hostile/scp017/proc/StopEnveloping(force_death = FALSE)
	if(enveloping_progress_timer_id)
		deltimer(enveloping_progress_timer_id)
		enveloping_progress_timer_id = null

	if(enveloping_target && !QDELETED(enveloping_target))
		if(enveloping_target.client)
			enveloping_target.client.eye = enveloping_target // Reset eye
			enveloping_target.see_in_dark = initial(enveloping_target.see_in_dark) // Restore vision
			enveloping_target.set_blurriness(0) // Remove blurriness

		if(force_death)
			visible_message(span_danger("[enveloping_target] is fully absorbed by [src]!"))
			enveloping_target.ghostize()
			qdel(enveloping_target)
		else
			visible_message(span_notice("[enveloping_target] escapes from [src]'s grasp!"))

	enveloping_target = null

/mob/living/simple_animal/hostile/scp017/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(!M.combat_mode)
		if(prob(10))
			UnarmedAttack(M)
	if(M.combat_mode)
		if(prob(80))
			UnarmedAttack(M)

/mob/living/simple_animal/hostile/scp017/proc/IsPortableLightSource(atom/A)
	return istype(A, /obj/item/flashlight) // Removed light_tube due to unresolved path

/mob/living/simple_animal/hostile/scp017/attackby(obj/item/O, mob/user)
	if(enveloping_target && IsStrongLightSource(O))
		StopEnveloping(FALSE)
		LightSourceDebuff()
		visible_message(span_notice("[src] recoils from the intense light, releasing [enveloping_target]!"))
		return TRUE
	if(IsPortableLightSource(O))
		LightSourceDebuff()
		visible_message(span_warning("[O] is absorbed by the shadowy veil!"))
		qdel(O)
		return TRUE
	. = ..()
	UnarmedAttack(O)

/mob/living/simple_animal/hostile/scp017/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(enveloping_target && IsStrongLightSource(AM))
		StopEnveloping(FALSE)
		LightSourceDebuff()
		visible_message(span_notice("[src] recoils from the intense light, releasing [enveloping_target]!"))
		return TRUE
	if(IsPortableLightSource(AM))
		LightSourceDebuff()
		visible_message(span_warning("[AM] vanished within the shadowy shroud!"))
		qdel(AM)
		return TRUE
	. = ..()
	UnarmedAttack(AM)
