// Foundation-19 Job Integration System
// Automatically tracks job performance and integrates with persistent progression

/datum/job_integration
	var/list/job_tracking = list()
	var/list/job_events = list()
	var/list/job_metrics = list()

/datum/job_integration/New()
	initialize_job_tracking()

/datum/job_integration/proc/initialize_job_tracking()
	// Initialize tracking for all Foundation-19 jobs
	var/list/foundation19_jobs = list(
		// Command
		"site_director", "o5_representative", "guard_commander", "research_director", "chief_medical_officer", "chief_engineer",
		// Security
		"lcz_zone_commander", "hcz_zone_commander", "ez_zone_commander", "lcz_guard", "hcz_guard", "ez_guard", "warden", "detective", "mtf_commander", "mtf_operative",
		// Medical
		"medical_doctor", "surgeon", "paramedic", "chemist", "virologist", "psychiatrist", "medical_intern", "coroner",
		// Science
		"senior_researcher", "researcher", "research_associate", "lab_technician", "xenobiologist", "roboticist", "chemist_science", "archaeologist", "field_agent",
		// Engineering
		"senior_engineer", "engineer", "junior_engineer", "atmospheric_technician", "containment_engineer", "electrical_engineer", "communications_technician", "maintenance_technician",
		// Supply
		"quartermaster", "cargo_technician", "shaft_miner", "logistics_officer", "supply_specialist",
		// Service
		"janitor", "cook", "bartender", "botanist", "chaplain", "curator", "lawyer",
		// D-Class
		"dclass_general", "dclass_medical", "dclass_kitchen", "dclass_janitorial", "dclass_mining", "dclass_research"
	)

	for(var/job in foundation19_jobs)
		job_tracking[job] = list()
		job_events[job] = list()
		job_metrics[job] = list()

/datum/job_integration/proc/on_job_assigned(mob/living/carbon/human/H, datum/job/J)
	if(!H || !J || !H.mind)
		return

	var/ckey = H.ckey
	if(!ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return

	// Set current job
	player_data.set_current_job(J.title)

	// Record job assignment
	record_job_event(J.title, "assigned", ckey, "Job assigned to [J.title]")

	// Add initial job experience
	player_data.add_job_experience(J.title, 10, "Job Assignment")

/datum/job_integration/proc/on_job_performance(mob/living/carbon/human/H, job_title, action_type, details = "")
	if(!H || !job_title || !H.mind)
		return

	var/ckey = H.ckey
	if(!ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return

	// Record the performance event
	record_job_event(job_title, action_type, ckey, details)

	// Add appropriate experience based on action type
	var/exp_amount = get_experience_for_action(action_type)
	if(exp_amount > 0)
		player_data.add_job_experience(job_title, exp_amount, action_type)

	// Update job-specific metrics
	update_job_metrics(job_title, action_type, ckey)

/datum/job_integration/proc/get_experience_for_action(action_type)
	switch(action_type)
		// Security actions
		if("patrol")
			return 25
		if("investigation")
			return 50
		if("arrest")
			return 75
		if("containment_breach_response")
			return 150
		if("mtf_operation")
			return 200

		// Medical actions
		if("diagnosis")
			return 50
		if("treatment")
			return 75
		if("surgery")
			return 100
		if("emergency_medical")
			return 125

		// Research actions
		if("scp_research")
			return 50
		if("experiment")
			return 75
		if("field_research")
			return 100
		if("paper_published")
			return 200

		// Engineering actions
		if("maintenance")
			return 25
		if("repair")
			return 50
		if("construction")
			return 75
		if("containment_system")
			return 100

		// Supply actions
		if("cargo_management")
			return 25
		if("mining")
			return 50
		if("logistics")
			return 75

		// Service actions
		if("cleaning")
			return 25
		if("cooking")
			return 50
		if("counseling")
			return 75

		// D-Class actions
		if("routine_testing")
			return 25
		if("research_testing")
			return 50
		if("containment_testing")
			return 75
		if("emergency_testing")
			return 100

	return 10

/datum/job_integration/proc/record_job_event(job_title, event_type, ckey, details)
	if(!job_events[job_title])
		job_events[job_title] = list()

	var/list/event_data = list(
		"event_type" = event_type,
		"ckey" = ckey,
		"details" = details,
		"timestamp" = world.time
	)
	job_events[job_title] += event_data

/datum/job_integration/proc/update_job_metrics(job_title, action_type, ckey)
	if(!job_metrics[job_title])
		job_metrics[job_title] = list()

	if(!job_metrics[job_title][ckey])
		job_metrics[job_title][ckey] = list()

	var/list/metrics = job_metrics[job_title][ckey]

	// Update action count
	if(!metrics["actions"])
		metrics["actions"] = list()
	if(!metrics["actions"][action_type])
		metrics["actions"][action_type] = 0
	metrics["actions"][action_type]++

	// Update total actions
	if(!metrics["total_actions"])
		metrics["total_actions"] = 0
	metrics["total_actions"]++

	// Update last activity
	metrics["last_activity"] = world.time

/datum/job_integration/proc/on_round_end()
	// Process round-end job statistics
	for(var/ckey in SSpersistent_progression.player_data)
		var/datum/persistent_player_data/player_data = SSpersistent_progression.player_data[ckey]
		if(!player_data || !player_data.current_job)
			continue

		// Increment job rounds played
		player_data.increment_job_rounds(player_data.current_job)

		// Add round completion experience
		player_data.add_job_experience(player_data.current_job, 50, "Round Completion")

		// Check for round-based achievements
		check_round_based_achievements(player_data)

/datum/job_integration/proc/check_round_based_achievements(datum/persistent_player_data/player_data)
	var/job_title = player_data.current_job
	var/job_rounds = player_data.get_job_rounds_played(job_title)

	// Check for round-based achievements
	if(job_rounds >= 10)
		player_data.update_achievement_progress("job_[job_title]_dedicated", 1)
	if(job_rounds >= 50)
		player_data.update_achievement_progress("job_[job_title]_loyal", 1)
	if(job_rounds >= 100)
		player_data.update_achievement_progress("job_[job_title]_legendary", 1)

/datum/job_integration/proc/on_containment_breach(scp_id, responders)
	for(var/mob/living/carbon/human/H in responders)
		if(!H.mind || !H.ckey)
			continue

		var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
		if(!player_data || !player_data.current_job)
			continue

		// Record containment breach response
		player_data.respond_to_containment_breach(player_data.current_job, scp_id, "response", "successful")

		// Update achievement progress
		player_data.update_achievement_progress("job_containment_breach_responder", 1)

/datum/job_integration/proc/on_scp_interaction(mob/living/carbon/human/H, scp_id, interaction_type, outcome)
	if(!H.mind || !H.ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data || !player_data.current_job)
		return

	// Record SCP interaction
	player_data.interact_with_scp(player_data.current_job, scp_id, interaction_type, outcome)

	// Update achievement progress
	if(interaction_type == "research")
		player_data.update_achievement_progress("job_scp_researcher", 1)

/datum/job_integration/proc/on_medical_procedure(mob/living/carbon/human/H, procedure_type, patient, outcome)
	if(!H.mind || !H.ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data || !player_data.current_job)
		return

	// Record medical procedure
	player_data.perform_medical_procedure(player_data.current_job, procedure_type, patient, outcome)

	// Update achievement progress
	player_data.update_achievement_progress("job_medical_specialist", 1)

/datum/job_integration/proc/on_engineering_project(mob/living/carbon/human/H, project_type, complexity, outcome)
	if(!H.mind || !H.ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data || !player_data.current_job)
		return

	// Record engineering project
	player_data.complete_engineering_project(player_data.current_job, project_type, complexity, outcome)

	// Update achievement progress
	player_data.update_achievement_progress("job_engineering_master", 1)

/datum/job_integration/proc/on_security_operation(mob/living/carbon/human/H, operation_type, target, outcome)
	if(!H.mind || !H.ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data || !player_data.current_job)
		return

	// Record security operation
	player_data.conduct_security_operation(player_data.current_job, operation_type, target, outcome)

	// Update achievement progress
	player_data.update_achievement_progress("job_security_operator", 1)

/datum/job_integration/proc/on_dclass_testing(mob/living/carbon/human/H, test_type, scp_id, outcome)
	if(!H.mind || !H.ckey)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data || !player_data.current_job)
		return

	// Record D-Class testing
	player_data.participate_dclass_testing(player_data.current_job, test_type, scp_id, outcome)

	// Update achievement progress
	player_data.update_achievement_progress("job_dclass_tester", 1)

/datum/job_integration/proc/get_job_statistics(job_title)
	var/list/stats = list()

	// Get overall job statistics
	stats["total_events"] = length(job_events[job_title] || list())
	stats["active_players"] = length(job_metrics[job_title] || list())

	// Get player-specific statistics
	stats["player_stats"] = list()
	for(var/ckey in job_metrics[job_title])
		var/list/player_metrics = job_metrics[job_title][ckey]
		stats["player_stats"][ckey] = player_metrics

	return stats

/datum/job_integration/proc/get_player_job_history(ckey)
	var/list/history = list()

	for(var/job_title in job_events)
		var/list/job_events_for_player = list()
		for(var/list/event in job_events[job_title])
			if(event["ckey"] == ckey)
				job_events_for_player += event

		if(length(job_events_for_player) > 0)
			history[job_title] = job_events_for_player

	return history
