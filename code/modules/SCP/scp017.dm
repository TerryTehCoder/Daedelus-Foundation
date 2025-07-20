// AI States for SCP-017
#define IDLE 0
#define HUNTING 1
#define STALKING 2
#define VINDICTIVE 3

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

	var/list/last_escaped_targets = list() // stores mob/living references and a timestamp
	var/times_spotted_by_light = 0
	var/times_driven_off_by_light = 0
	var/current_ai_state = IDLE // define constants for states
	var/vindictive_threshold_spotted = 5
	var/vindictive_threshold_driven_off = 3
	var/vindictive_duration = 600 // 60 seconds
	var/last_vindictive_time = 0

	var/list/target_priority_list = list() // Stores mobs with associated priority scores

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

	UpdateTargetPriorities()
	DecideAction()
	HandleMovement()

	if(prob(5) && world.time >= last_shadow_veil_time + shadow_veil_cooldown) // Small chance to activate Shadow Veil if off cooldown
		ShadowVeil()

	// Check for VINDICTIVE state transition
	if(current_ai_state != VINDICTIVE && world.time >= last_vindictive_time + vindictive_duration)
		if(times_spotted_by_light >= vindictive_threshold_spotted || times_driven_off_by_light >= vindictive_threshold_driven_off)
			EnterVindictiveState()

/mob/living/simple_animal/hostile/scp017/proc/DecideAction()
	// Default to IDLE
	current_ai_state = IDLE

	// Check for high-priority targets
	var/mob/living/highest_priority_target
	var/highest_priority_score = 0

	for(var/mob/living/M in target_priority_list)
		var/priority = target_priority_list[M]
		if(priority > highest_priority_score)
			highest_priority_score = priority
			highest_priority_target = M

	if(highest_priority_target)
		current_ai_state = HUNTING
		// Further logic to transition to STALKING or VINDICTIVE based on target and counters
		if(times_spotted_by_light > 0 || times_driven_off_by_light > 0)
			current_ai_state = STALKING // Or VINDICTIVE if thresholds are met, handled in Life()
		if(current_ai_state == STALKING && get_dist(src, highest_priority_target) > 2) // Example stalking condition
			// Consider pausing or moving slower
			turns_per_move = 2 // Slower movement
		else
			turns_per_move = initial(turns_per_move) // Reset to normal

	if(current_ai_state == VINDICTIVE && world.time >= last_vindictive_time + vindictive_duration)
		ExitVindictiveState()
		return

	// If no high-priority targets, check for general light avoidance
	var/turf/Tturf = get_turf(src)
	if(Tturf.get_lumcount() > shadow_threshold)
		// If in light, prioritize moving to shadow
		current_ai_state = HUNTING // Treat seeking shadow as a hunting behavior

	// Check for VINDICTIVE state transition
	if(current_ai_state != VINDICTIVE && world.time >= last_vindictive_time + vindictive_duration)
		if(times_spotted_by_light >= vindictive_threshold_spotted || times_driven_off_by_light >= vindictive_threshold_driven_off)
			EnterVindictiveState()

/mob/living/simple_animal/hostile/scp017/proc/HandleMovement()
	var/turf/Tturf = get_turf(src)
	if(!Tturf)
		return

	var/list/light_sources_in_range = list()

	// Find light sources in range
	for(var/obj/machinery/light/L in range(light_suppression_range, src))
		if(L.on)
			light_sources_in_range += L
	for(var/mob/living/M in range(light_suppression_range, src))
		if(mob_has_strong_light_source(M))
			light_sources_in_range += M

	// Movement based on AI state
	switch(current_ai_state)
		if(IDLE)
			// Stay still or wander slowly in shadows
			if(Tturf.get_lumcount() > shadow_threshold)
				// If in light, try to find a shadow
				var/turf/target_turf = find_darkest_adjacent_turf()
				if(target_turf)
					step_to(src, target_turf)
			else
				// Wander slowly
				if(prob(10)) // Small chance to wander
					step(src, pick(NORTH, SOUTH, EAST, WEST))

		if(HUNTING)
			var/mob/living/target_mob = get_highest_priority_target()
			if(target_mob)
				if(light_sources_in_range.len > 0)
					// Fleeing light sources
					var/turf/flee_turf = find_flee_turf(light_sources_in_range)
					if(flee_turf)
						step_to(src, flee_turf)
					else
						// If no clear flee path, try to find darkest adjacent
						var/turf/dark_turf = find_darkest_adjacent_turf()
						if(dark_turf)
							step_to(src, dark_turf)
				else
					// Move towards target, prioritizing shadows
					var/turf/target_turf = get_turf(target_mob)
					if(target_turf)
						Goto(target_turf)

		if(STALKING)
			var/mob/living/target_mob = get_highest_priority_target()
			if(target_mob)
				// Move slower and deliberately, prioritize shadows
				turns_per_move = 2 // Slower movement
				var/turf/target_turf = get_turf(target_mob)
				if(target_turf)
					Goto(target_turf)
			else
				turns_per_move = initial(turns_per_move) // Reset to normal
				current_ai_state = IDLE // No target, go back to idle

		if(VINDICTIVE)
			// Prioritize breaking lights or attacking specific targets
			var/obj/machinery/light/light_to_break
			for(var/obj/machinery/light/L in range(light_suppression_range, src))
				if(L.on)
					light_to_break = L
					break
			if(light_to_break)
				step_to(src, light_to_break)
				if(get_dist(src, light_to_break) <= 1)
					UnarmedAttack(light_to_break) // Directly attack the light
			else
				var/mob/living/target_mob = get_highest_priority_target()
				if(target_mob)
					step_to(src, target_mob)

/mob/living/simple_animal/hostile/scp017/proc/find_darkest_adjacent_turf()
	var/turf/darkest_turf
	var/min_lumcount = INFINITY
	for(var/dir in GLOB.alldirs) // Check all 8 directions: cardinals and diagonals - Substitute for .Adjacent() not working here.

		var/turf/T = get_step(get_turf(src), dir)
		var/area/A = get_area(T)

		if(A.area_lighting == AREA_LIGHTING_DYNAMIC)
			var/lum = T.get_lumcount()
			if(lum < min_lumcount)
				min_lumcount = lum
				darkest_turf = T
	if(darkest_turf && darkest_turf.get_lumcount() <= shadow_threshold)
		return darkest_turf
	return null

/mob/living/simple_animal/hostile/scp017/proc/find_flee_turf(list/light_sources)
	var/turf/current_turf = get_turf(src)
	var/turf/flee_turf
	var/max_distance_from_lights = -1

	for(var/turf/T in current_turf.Adjacent())
		var/area/A = get_area(T)
		if(A.area_lighting == AREA_LIGHTING_DYNAMIC && T.get_lumcount() <= shadow_threshold)
			var/min_dist_to_light = INFINITY
			for(var/atom/L in light_sources)
				min_dist_to_light = min(min_dist_to_light, get_dist(T, L))
			if(min_dist_to_light > max_distance_from_lights)
				max_distance_from_lights = min_dist_to_light
				flee_turf = T
	return flee_turf

/mob/living/simple_animal/hostile/scp017/proc/UpdateTargetPriorities()
	target_priority_list.Cut() // Clear old priorities

	// Add mobs in range to consideration
	for(var/mob/living/M in view(src)) // Consider mobs in view range
		if(M == src || M.stat == DEAD || M.status_flags & GODMODE)
			continue

		var/priority_score = 0
		var/turf/M_turf = get_turf(M)
		if(!M_turf)
			continue

		// Base priority for being a living mob
		priority_score += 10

		// Prioritizing targets that are in a dark area and are not incapacitated.
		if((M_turf.get_lumcount() <= shadow_threshold) && (M.stat == CONSCIOUS))
			priority_score += 50

		// High Priority (Light Sources on Body)
		if(mob_has_strong_light_source(M))
			priority_score += 100

		// Remembered Escaped Targets
		for(var/list/escaped_data in last_escaped_targets)
			var/mob/living/escaped_mob = escaped_data["mob"]
			var/timestamp = escaped_data["time"]
			if(escaped_mob == M && (world.time - timestamp < 1200)) // Within 2 minutes of escape
				priority_score += 75 // Higher base priority

		if(priority_score > 0)
			target_priority_list[M] = priority_score

	// Sort targets by priority (highest first)
	// I... forgot how to do an associated list sort ):
	var/list/sorted_targets = list()
	while(target_priority_list.len)
		var/highest_score = -INFINITY
		var/mob/living/highest_target
		for(var/mob/living/M in target_priority_list)
			if(target_priority_list[M] > highest_score)
				highest_score = target_priority_list[M]
				highest_target = M
		if(highest_target)
			sorted_targets += highest_target
			target_priority_list.Remove(highest_target)
	target_priority_list = sorted_targets

/mob/living/simple_animal/hostile/scp017/proc/get_highest_priority_target()
	if(target_priority_list.len > 0)
		return target_priority_list[1] // First element after sorting is highest priority
	return null

/mob/living/simple_animal/hostile/scp017/proc/EnterVindictiveState()
	current_ai_state = VINDICTIVE
	last_vindictive_time = world.time
	visible_message(span_danger("[src] lets out an enraged shriek, its form flickering violently!"))
	// Temporarily ignore shadow_threshold for pursuit
	shadow_threshold = 1.0 // Effectively ignore shadows for a duration
	light_suppression_chance = 100 // Always suppress lights

/mob/living/simple_animal/hostile/scp017/proc/ExitVindictiveState()
	current_ai_state = IDLE
	times_spotted_by_light = 0
	times_driven_off_by_light = 0
	shadow_threshold = initial(shadow_threshold) // Reset threshold
	light_suppression_chance = initial(light_suppression_chance) // Reset chance
	visible_message(span_notice("[src] calms, its form settling back into the shadows."))

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

	// In VINDICTIVE state, SCP-017 might ignore shadow_threshold for a short duration
	if(current_ai_state == VINDICTIVE)
		var/mob/living/target_mob = get_highest_priority_target()
		if(target_mob == the_target) // If it's the high priority target in vindictive state
			return TRUE // Attack regardless of light
		// Also prioritize breaking lights
		if(istype(the_target, /obj/machinery/light) && (the_target:on))
			return TRUE

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

/mob/living/simple_animal/hostile/scp017/proc/mob_has_strong_light_source(mob/living/M)
	if(!M)
		return FALSE
	// Check if the mob itself is a light source (e.g., a glowing creature)
	if(IsStrongLightSource(M))
		return TRUE
	// Check mob's held items
	if(M.held_items)
		for(var/obj/item/I in M.held_items)
			if(IsStrongLightSource(I))
				return TRUE
	// Check mob's inventory
	if(M.contents)
		for(var/obj/item/I in M.contents)
			if(IsStrongLightSource(I))
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
		times_driven_off_by_light++ // Increment counter
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
