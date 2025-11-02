#define DLS_DECAY_RATE 0.95 // Each processing cycle, scores are multiplied by this value.

/datum/component/dls_manager
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// A list of all crew members being tracked, indexed by mob reference.
	var/list/crew_profiles = list()
	/// A list of active hotspots, indexed by area reference.
	var/list/area_profiles = list()
	/// A queue of raw signal data waiting to be processed.
	var/list/event_queue = list()
	/// A list of active whispers to be displayed to the AI.
	var/list/active_whispers = list()
	/// The AI's current operating mode for the DLS.
	var/dls_mode = DLS_MODE_GUIDED
	/// A set of areas that are known to be observable by at least one active camera.
	var/list/cached_observable_areas = list()

/datum/component/dls_manager/proc/Register(parent)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_AIRLOCK_ACCESS_DENIED, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_LIVING_USE_RADIO, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(queue_event))
	RegisterSignal(parent, COMSIG_APC_POWER_STATE_CHANGE, PROC_REF(queue_event))

/datum/component/dls_manager/proc/sync_crew_profiles()
	var/list/records = SSdatacore.get_records(DATACORE_RECORDS_STATION)
	for(var/datum/data/record/R in records)
		var/mob/living/carbon/human/H = R.fields["mob_ref"]
		if(H && !crew_profiles[H])
			crew_profiles[H] = new /datum/dls_crew_profile(H)
			log_game("DLS: Now tracking [H.name].")

/datum/component/dls_manager/proc/queue_event(event_type, source, list/params)
	// Before adding to the queue, perform the observation check.
	if(!can_ai_observe(source))
		return

	var/list/event_data = list(
		"type" = event_type,
		"source" = source,
		"params" = params,
		"timestamp" = world.time
	)
	event_queue += event_data

/datum/component/dls_manager/proc/process_events()
	sync_crew_profiles()
	if(!event_queue.len)
		// Decay scores even if no new events happened.
		decay_scores()
		return

	// Process a batch of events from the queue.
	for(var/list/event_data in event_queue)
		var/event_type = event_data["type"]
		var/mob/source_mob = event_data["source"]
		var/list/params = event_data["params"]

		if(!ismob(source_mob))
			continue

		var/datum/dls_crew_profile/profile = crew_profiles[source_mob]
		if(!profile)
			continue

		var/list/context = get_event_context(source_mob)
		var/score = 0
		var/score_type
		switch(event_type)
			if(COMSIG_PARENT_ATTACKBY)
				score = 25
				var/mob/living/carbon/human/H = source_mob
				var/mob/living/target_mob = params ? params["target"] : null
				var/datum/dls_crew_profile/target_profile = target_mob ? crew_profiles[target_mob] : null

				if(target_profile && ("Volatile" in target_profile.traits))
					score *= 0.6 // It's more likely to be self-defense.

				var/datum/job/job = H.job
				if(job && (job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
					score *= 0.5 // Security is expected to use force.
				if(context["area_security_level"] == "High")
					score *= 1.5
				if(context["site_security_level"] >= SEC_LEVEL_RED)
					score *= 1.5
				score_type = DLS_SCORE_AGGRESSION
			if(COMSIG_AIRLOCK_ACCESS_DENIED)
				score = 10
				if(profile.get_score(DLS_SCORE_STRESS) > 50)
					score *= 0.7 // More likely to be panicked fumbling than malicious intent
				if(context["area_security_level"] == "High")
					score *= 2
				if(context["site_security_level"] >= SEC_LEVEL_RED)
					score *= 1.2
				score_type = DLS_SCORE_SUSPICION
			if(COMSIG_LIVING_USE_RADIO)
				var/message = params ? params["message"] : null
				if(message && (findtext(lowertext(message), "help") || findtext(lowertext(message), "security") || findtext(lowertext(message), "breach")))
					score = 5
					if(context["site_security_level"] >= SEC_LEVEL_RED)
						score *= 2
					score_type = DLS_SCORE_STRESS
			if(COMSIG_ATOM_TAKE_DAMAGE)
				score = 15
				if(context["area_security_level"] == "High")
					score *= 1.2
				if(context["site_security_level"] >= SEC_LEVEL_RED)
					score *= 0.6 //People expect to be hurt in high alerts, we need to be more sensitive.
				score_type = DLS_SCORE_STRESS
			if(COMSIG_ITEM_EQUIPPED)
				var/obj/item/I = params ? params["item"] : null
				if(!I)
					continue

				var/mob/living/carbon/human/H = source_mob
				var/list/item_context = get_event_context(source_mob)
				var/suspicion_increase = 0

				if(I.force || I.throwforce)
					suspicion_increase += 10
				else if(istype(I, /obj/item/modular_computer/tablet/pda))
					suspicion_increase += 2
				else if(istype(I, /obj/item/reagent_containers))
					suspicion_increase += 5

				if(H && context["job"])
					var/datum/job/job = H.job
					if(job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
						suspicion_increase *= 0.5 // Security are expected to carry weapons/tools.
					else if(is_scientist_job(job) && istype(I, /obj/item/reagent_containers))
						suspicion_increase *= 0.3
					else if(is_assistant_job(job))
						suspicion_increase *= 1.2 // Yes, this complex data aggregation tool is biased towards assistants; no I don't have any reason for this.

				if(item_context["area_security_level"] == "High")
					suspicion_increase += 5

				if(profile.get_recent_score(DLS_SCORE_AGGRESSION) > 50)
					suspicion_increase *= 1.5
				if(profile.get_recent_score(DLS_SCORE_ILLICIT) > 50)
					suspicion_increase *= 1.3

				score = clamp(suspicion_increase, 0, 30)
				score_type = DLS_SCORE_SUSPICION
			if(COMSIG_MOVABLE_MOVED)
				return // Currently no DLS impact.
			if(COMSIG_APC_POWER_STATE_CHANGE)
				if(!params || params.len < 2)
					continue
				var/charge = params[1]
				var/load = params[2]
				if(charge < 20 || load > 50000)
					score = 15
					score_type = DLS_SCORE_SUSPICION

		if(score > 0)
			profile.add_provisional_score(score_type, score)
			generate_whisper_if_needed(profile, event_type, params, score, score_type)
		update_hotspots(event_type, source_mob, context)

	// Clear the queue after processing.
	event_queue.Cut()

	// Decay scores after processing new events.
	decay_scores()

	// Update traits based on scores.
	update_traits()

/datum/component/dls_manager/proc/update_hotspots(event_type, source, list/context)
	var/area/A = context["area"]
	if(!A)
		return

	var/datum/dls_area_profile/area_profile = area_profiles[A]
	if(!area_profile)
		area_profile = new /datum/dls_area_profile(A)
		area_profiles[A] = area_profile

	area_profile.last_event_time = world.time
	area_profile.intensity += 5 // Generic intensity increase for now.

	var/atom/source_atom = source
	var/event_string = "[source_atom.name] - [event_type]"
	area_profile.recent_events += event_string
	if(area_profile.recent_events.len > 5)
		area_profile.recent_events.Cut(1, area_profile.recent_events.len - 4)

/datum/component/dls_manager/proc/decay_scores()
	for(var/mob/M in crew_profiles)
		var/datum/dls_crew_profile/profile = crew_profiles[M]
		profile.decay_all_scores()

	for(var/area/A in area_profiles)
		var/datum/dls_area_profile/area_profile = area_profiles[A]
		area_profile.intensity *= DLS_DECAY_RATE
		if(area_profile.intensity < 1)
			qdel(area_profile)
			area_profiles -= A

/datum/component/dls_manager/proc/get_event_context(atom/source)
	var/list/context = list()
	context["area"] = get_area(source)
	context["job"] = null
	context["site_security_level"] = SSsecurity_level.current_level || SEC_LEVEL_GREEN
	context["area_security_level"] = "Low"

	var/area/A = context["area"]
	if(isarea(A))
		if(A.area_flags & SECURITY_AREA)
			context["area_security_level"] = "High"

	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		context["job"] = H.job

	return context

/datum/component/dls_manager/proc/can_ai_observe(atom/source)
	var/area/A = get_area(source)
	if(!A)
		return FALSE

	if(A in cached_observable_areas)
		return TRUE

	for(var/obj/machinery/camera/C in A.cameras)
		if(C.can_use() && get_dist(source, C) <= C.view_range)
			cached_observable_areas[A] = TRUE
			return TRUE

	return FALSE

/datum/component/dls_manager/proc/invalidate_area_cache(area/A)
	if(A in cached_observable_areas)
		cached_observable_areas -= A

/datum/component/dls_manager/proc/generate_whisper_if_needed(datum/dls_crew_profile/profile, event_type, list/params, confidence, score_type)
	if(confidence < 25) //Score rating determined by process_events IS the confidence rating passed in here.
		return

	if(world.time < profile.last_whisper_time[score_type] + DLS_WHISPER_COOLDOWN)
		return

	var/whisper_text = ""
	var/tier = DLS_TIER_ROUTINE

	var/list/context = get_event_context(profile.owner)
	var/area/A = context["area"]
	var/mob/living/carbon/human/H = profile.owner

	confidence = round(confidence + rand(-5, 5)) // Add flavor randomization

	switch(event_type)
		if(COMSIG_PARENT_ATTACKBY)
			var/obj/item/weapon = params ? params["weapon"] : null
			if(weapon && weapon.name)
				whisper_text = ">Aggressive crewmember [H.name] detected in [A.name], wielding [weapon.name]. CONF: [confidence]%"
			else
				whisper_text = ">Aggressive crewmember [H.name] detected in [A.name]. CONF: [confidence]%"
			tier = DLS_TIER_CRITICAL
		if(COMSIG_AIRLOCK_ACCESS_DENIED)
			whisper_text = ">Anomalous access pattern detected at [A.name] by [H.name] ([params["user_job"]]). Required access level: [params["req_access"]]. CONF: [confidence]%"
			tier = DLS_TIER_SUSPICIOUS
		if(COMSIG_LIVING_USE_RADIO)
			whisper_text = ">Elevated stress indicators in vocal patterns from [H.name] in [A.name]. CONF: [confidence]%"
			tier = DLS_TIER_ROUTINE
		if(COMSIG_APC_POWER_STATE_CHANGE)
			whisper_text = ">Anomalous power fluctuations detected in [A.name]. CONF: [confidence]%"
			tier = DLS_TIER_SUSPICIOUS
		else
			return

	var/datum/dls_whisper/new_whisper = new(profile.owner, whisper_text, confidence, tier, score_type)
	active_whispers += new_whisper
	profile.log_event(new_whisper, confidence)
	profile.last_whisper_time[score_type] = world.time

/datum/component/dls_manager/proc/add_trait_to_crew(mob/target, trait)
	var/datum/dls_crew_profile/profile = crew_profiles[target]
	if(profile)
		profile.add_trait(trait)

/datum/component/dls_manager/proc/remove_trait_from_crew(mob/target, trait)
	var/datum/dls_crew_profile/profile = crew_profiles[target]
	if(profile)
		profile.remove_trait(trait)

/datum/component/dls_manager/proc/update_traits()
	for(var/datum/dls_crew_profile/profile in crew_profiles)
		// Volatile Trait
		if(profile.get_score(DLS_SCORE_AGGRESSION) > 75)
			profile.trait_timers[DLS_SCORE_AGGRESSION] += 1
			if(profile.trait_timers[DLS_SCORE_AGGRESSION] > 3000) // 5 minutes (300 seconds * 10 deciseconds/second)
				profile.add_trait("Volatile")
		else
			profile.trait_timers[DLS_SCORE_AGGRESSION] = 0
			profile.remove_trait("Volatile")

/datum/component/dls_manager/proc/poll_suit_sensors()
	for(var/mob/living/carbon/human/H in crew_profiles)
		if(!H.w_uniform)
			continue
		var/obj/item/clothing/under/uniform = H.w_uniform
		if(!istype(uniform) || uniform.has_sensor <= NO_SENSORS || !uniform.sensor_mode)
			continue

		var/datum/dls_crew_profile/profile = crew_profiles[H]
		if(!profile || !can_ai_observe(H))
			continue

		// Vitals
		var/heart_rate = H.get_pulse_as_number()
		var/blood_pressure = H.get_blood_pressure()

		if(heart_rate > 140 || blood_pressure > 160)
			if(world.time >= profile.last_whisper_time[DLS_SCORE_STRESS] + DLS_WHISPER_COOLDOWN)
				profile.add_provisional_score(DLS_SCORE_STRESS, 20)
				var/whisper_text = ">Elevated physiological stress detected in [H.name] in [get_area(H)]. CONF: [20]%"
				var/datum/dls_whisper/new_whisper = new(H, whisper_text, 20, DLS_TIER_SUSPICIOUS, DLS_SCORE_STRESS)
				active_whispers += new_whisper
				profile.log_event(new_whisper, 20)
				profile.last_whisper_time[DLS_SCORE_STRESS] = world.time

		// Damage
		if(H.health < 50)
			if(world.time >= profile.last_whisper_time[DLS_SCORE_STRESS] + DLS_WHISPER_COOLDOWN)
				profile.add_provisional_score(DLS_SCORE_STRESS, 35)
				var/whisper_text = ">Critical life signs detected from [H.name] in [get_area(H)]. CONF: [35]%"
				var/datum/dls_whisper/new_whisper = new(H, whisper_text, 35, DLS_TIER_CRITICAL, DLS_SCORE_STRESS)
				active_whispers += new_whisper
				profile.log_event(new_whisper, 35)
				profile.last_whisper_time[DLS_SCORE_STRESS] = world.time

/datum/component/dls_manager/proc/update_isolation_scores()
	var/list/human_locations = list()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		human_locations[H] = get_turf(H)

	for(var/mob/living/carbon/human/H in crew_profiles)
		var/datum/dls_crew_profile/profile = crew_profiles[H]
		if(!profile || !can_ai_observe(H))
			continue

		var/is_isolated = TRUE
		var/turf/h_turf = human_locations[H]
		if(!h_turf)
			continue

		for(var/mob/living/carbon/human/other in human_locations)
			if(H == other)
				continue
			var/turf/other_turf = human_locations[other]
			if(other_turf && get_dist(h_turf, other_turf) <= 5)
				is_isolated = FALSE
				break

		if(is_isolated)
			profile.add_provisional_score(DLS_SCORE_ISOLATION, 1)
		else
			var/current = profile.provisional_scores[DLS_SCORE_ISOLATION] || 0
			profile.provisional_scores[DLS_SCORE_ISOLATION] = current * 0.95 // Decay when not isolated

		if(profile.get_score(DLS_SCORE_ISOLATION) > 100)
			if(world.time >= profile.last_whisper_time[DLS_SCORE_ISOLATION] + DLS_WHISPER_COOLDOWN)
				profile.add_provisional_score(DLS_SCORE_ISOLATION, 15)
				var/whisper_text = ">Subject [H.name] exhibiting prolonged solitary behavior in [get_area(H)]. Potential for anomalous activity is elevated. CONF: [15]%"
				var/datum/dls_whisper/new_whisper = new(H, whisper_text, 15, DLS_TIER_ROUTINE, DLS_SCORE_ISOLATION)
				active_whispers += new_whisper
				profile.log_event(new_whisper, 15)
				profile.provisional_scores[DLS_SCORE_ISOLATION] = 0 // Reset after firing
				profile.last_whisper_time[DLS_SCORE_ISOLATION] = world.time

/datum/component/dls_manager/proc/validate_whisper(whisper_id)
	var/datum/dls_whisper/W = locate(whisper_id) in active_whispers
	if(W && W.status == DLS_STATUS_UNVALIDATED)
		var/datum/dls_crew_profile/profile = crew_profiles[W.target]
		if(profile)
			profile.validate_provisional_score(W.score_type, W.confidence)
			W.status = DLS_STATUS_VALIDATED

/datum/component/dls_manager/proc/invalidate_whisper(whisper_id)
	var/datum/dls_whisper/W = locate(whisper_id) in active_whispers
	if(W && W.status == DLS_STATUS_UNVALIDATED)
		var/datum/dls_crew_profile/profile = crew_profiles[W.target]
		if(profile)
			profile.invalidate_provisional_score(W.score_type, W.confidence)
			W.status = DLS_STATUS_INVALIDATED
