/datum/dls_ui
	var/mob/living/silicon/ai/user

/datum/dls_ui/New(mob/living/silicon/ai/target_user)
	user = target_user

/datum/dls_ui/ui_interact(mob/user, datum/tgui/ui)
	if(!user.client)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DLS", "Data Listening System")
		ui.open()

/datum/dls_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/dls_ui/ui_data(mob/user)
	var/list/data = list()
	var/datum/component/dls_manager/manager = src.user.GetComponent(/datum/component/dls_manager)

	if(!manager)
		data["has_manager"] = FALSE
		return data

	data["has_manager"] = TRUE
	data["dls_mode"] = manager.dls_mode

	var/list/crew_data = list()
	for(var/datum/dls_crew_profile/profile in manager.crew_profiles)
		if(!profile.owner)
			continue
		var/list/profile_data = list()
		profile_data["name"] = profile.owner.name
//		profile_data["rank"] = profile.owner.rank (if we end up using a rank system of some sort)
		profile_data["job"] = profile.owner.job
		profile_data["status"] = profile.get_status_data()
		profile_data["confidence"] = profile.get_overall_confidence()
		profile_data["scores"] = list(
			"stress" = profile.get_score(DLS_SCORE_STRESS),
			"aggression" = profile.get_score(DLS_SCORE_AGGRESSION),
			"suspicion" = profile.get_score(DLS_SCORE_SUSPICION),
			"isolation" = profile.get_score(DLS_SCORE_ISOLATION)
		)
		profile_data["event_history"] = profile.event_history
		profile_data["traits"] = profile.traits
		crew_data += list(profile_data)
	data["crew_profiles"] = crew_data

	var/list/whisper_data = list()
	for(var/datum/dls_whisper/whisper in manager.active_whispers)
		if(!whisper.target)
			continue
		var/list/w_data = list()
		w_data["target"] = whisper.target.name
		w_data["text"] = whisper.description
		w_data["confidence"] = whisper.confidence
		w_data["tier"] = whisper.tier
		w_data["status"] = whisper.status
		w_data["timestamp"] = whisper.timestamp
		w_data["whisper_id"] = whisper.id
		whisper_data += list(w_data)
	data["active_whispers"] = whisper_data

	return data

/datum/dls_ui/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/datum/component/dls_manager/manager = user.GetComponent(/datum/component/dls_manager)
	if(!manager)
		return

	if(user != src.user) // Only the AI that opened this menu can perform actions.. hopefully
		return

	switch(action)
		if("set_mode")
			var/new_mode = text2num(params["mode"])
			if(new_mode in list(DLS_MODE_AUTONOMOUS, DLS_MODE_GUIDED, DLS_MODE_MANUAL))
				manager.dls_mode = new_mode
				. = TRUE
		if("validate_whisper")
			var/whisper_id = params["whisper_id"]
			if(whisper_id)
				manager.validate_whisper(whisper_id)
				. = TRUE
		if("invalidate_whisper")
			var/whisper_id = params["whisper_id"]
			if(whisper_id)
				manager.invalidate_whisper(whisper_id)
				. = TRUE
		if("add_trait")
			var/target_name = params["target"]
			var/trait = params["trait"]
			if(target_name && trait)
				manager.add_trait_to_crew(target_name, trait)
				. = TRUE
		if("remove_trait")
			var/target_name = params["target"]
			var/trait = params["trait"]
			if(target_name && trait)
				manager.remove_trait_from_crew(target_name, trait)
				. = TRUE
