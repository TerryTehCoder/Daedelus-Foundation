/datum/dls_crew_profile
	/// The crew member this profile belongs to.
	var/mob/living/carbon/human/owner
	/// A log of recent, significant events.
	var/list/event_history = list()
	/// A list of behavioral traits assigned to this profile.
	var/list/traits = list()
	/// Timers for assigning traits.
	var/list/trait_timers = list()
	/// The last time a whisper was generated for each score type.
	var/list/last_whisper_time = list()

	// --- Behavioral Scores ---
	/// Provisional scores are temporary and await AI validation.
	var/list/provisional_scores = list()
	/// Permanent scores have been validated by the AI.
	var/list/permanent_scores = list()

/datum/dls_crew_profile/New(mob/living/carbon/human/new_owner)
	if(!new_owner)
		CRASH("dls_crew_profile created with null owner")
	owner = new_owner
	// Initialize all score types to zero.
	var/static/list/score_types = list(DLS_SCORE_STRESS, DLS_SCORE_AGGRESSION, DLS_SCORE_SUSPICION, DLS_SCORE_ISOLATION, DLS_SCORE_ILLICIT)
	for(var/score_type in score_types)
		provisional_scores[score_type] = 0
		permanent_scores[score_type] = 0
		trait_timers[score_type] = 0
		last_whisper_time[score_type] = 0

/datum/dls_crew_profile/proc/get_score(score_type)
	if(!(score_type in provisional_scores) || !(score_type in permanent_scores))
		return 0
	return provisional_scores[score_type] + permanent_scores[score_type]

/datum/dls_crew_profile/proc/get_recent_score(score_type)
	var/recent_score = 0
	for(var/list/L in event_history)
		if(world.time - L["timestamp"] < DLS_RECENT_EVENT_WINDOW)
			var/datum/dls_whisper/W = L["event"]
			if(istype(W) && W.score_type == score_type)
				recent_score += W.confidence
	return recent_score

/datum/dls_crew_profile/proc/add_provisional_score(score_type, amount)
	provisional_scores[score_type] += amount

/datum/dls_crew_profile/proc/validate_provisional_score(score_type, amount)
	if(provisional_scores[score_type] >= amount)
		provisional_scores[score_type] -= amount
		permanent_scores[score_type] += amount
		return TRUE
	return FALSE

/datum/dls_crew_profile/proc/invalidate_provisional_score(score_type, amount)
	if(provisional_scores[score_type] >= amount)
		provisional_scores[score_type] -= amount
		return TRUE
	return FALSE

/datum/dls_crew_profile/proc/decay_all_scores()
	for(var/score_type in permanent_scores)
		permanent_scores[score_type] *= DLS_DECAY_RATE
		if(permanent_scores[score_type] < 1)
			permanent_scores[score_type] = 0

/datum/dls_crew_profile/proc/get_status_data()
	// Simple logic for now. This can be expanded.
	var/total_score = get_overall_confidence()
	if(total_score > 75)
		return list("text" = "Critical", "class" = "bad")
	if(total_score > 50)
		return list("text" = "Elevated", "class" = "average")
	if(total_score > 25)
		return list("text" = "Suspicious", "class" = "warning")
	return list("text" = "Nominal", "class" = "good")

/datum/dls_crew_profile/proc/get_overall_confidence()
	var/total_score = 0
	for(var/score_type in permanent_scores) //Loop through all score types and sum provisional + permanent scores.
		total_score += get_score(score_type)
	return round(clamp(total_score, 0, 100)) // Clamp to 100 max

/datum/dls_crew_profile/proc/log_event(datum/dls_whisper/whisper, confidence)
	// Add to history and prune old events.
	event_history += list("timestamp" = world.time, "event" = whisper, "confidence" = confidence)
	if(event_history.len > 10) // Keep the last 10 events
		event_history.Cut(1, event_history.len - 9)

/datum/dls_crew_profile/proc/add_trait(trait)
	if(!(trait in traits))
		traits += trait

/datum/dls_crew_profile/proc/remove_trait(trait)
	if(trait in traits)
		traits -= trait


/datum/dls_area_profile
	/// The area this profile represents.
	var/area/owner
	/// A list of crew members currently in this hotspot.
	var/list/occupants = list()
	/// The type of hotspot (e.g., Combat, Anomaly).
	var/hotspot_type
	/// The intensity of the hotspot.
	var/intensity = 0
	/// Timestamp of the last event.
	var/last_event_time = 0
	/// A list of recent event strings that contributed to this hotspot.
	var/list/recent_events = list()
