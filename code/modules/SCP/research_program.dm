/datum/computer_file/program/scp_research
	filename = "SCPResearch"
	filedesc = "SCP-OS Research Suite"
	category = PROGRAM_CATEGORY_SCI
	program_icon = "book"
	requires_ntnet = TRUE
	tgui_id = "SCPResearchConsole"
	required_access = list(ACCESS_RESEARCH, ACCESS_RD, ACCESS_CAPTAIN)
	available_on_ntnet = TRUE
	alert_able = TRUE

/datum/computer_file/program/scp_research/ui_static_data(mob/user)
	var/list/data = list()
	data["dangerLevels"] = list(
		list("key" = SCP_SAFE, "label" = "Safe"),
		list("key" = SCP_EUCLID, "label" = "Euclid"),
		list("key" = SCP_KETER, "label" = "Keter")
	)
	return data

/datum/computer_file/program/scp_research/ui_data(mob/user)
	var/list/data = list()
	data["researchPoints"] = SSresearch.research_points
	data["logisticsPoints"] = SSresearch.logistics_points

	var/list/projects = list()
	for(var/datum/research_project/p in SSresearch.all_projects)
		var/mob/proposer_mob = get_mob_by_ckey(p.proposer_ckey)
		var/proposer_name = proposer_mob ? proposer_mob.real_name : p.proposer_ckey
		var/mob/authorizer_mob = get_mob_by_ckey(p.authorizer_ckey)
		var/authorizer_name = authorizer_mob ? authorizer_mob.real_name : p.authorizer_ckey

		projects.Add(list(list(
			"id" = p.id,
			"name" = p.project_name,
			"scp_id" = p.scp_id,
			"status" = p.status,
			"description" = p.description,
			"is_custom" = p.is_custom,
			"proposer" = proposer_name,
			"authorizer" = authorizer_name,
			"signature" = p.digital_signature
		)))
	data["projects"] = projects

	var/list/scps = list()
	for(var/datum/scp_definition/scp in SSresearch.scp_definitions)
		scps.Add(list(list(
			"id" = scp.id_tag,
			"name" = scp.name,
			"dangerTier" = scp.danger_tier,
			"cost" = scp.cost,
			"unlocked" = (scp.id_tag in SSresearch.unlocked_scps)
		)))
	data["scps"] = scps

	return data

/datum/computer_file/program/scp_research/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	switch(action)
		if("purchase_scp")
			var/scp_id = params["scp_id"]
			SSresearch.requisition_scp(scp_id, user)
			return TRUE
		if("propose_custom_test")
			var/scp_id = params["scp_id"]
			var/project_name = params["project_name"]
			var/description = params["description"]

			if(!scp_id)
				to_chat(user, span_warning("You must select an SCP to propose a test for."))
				return

			var/datum/research_project/p = new()
			p.project_name = project_name
			p.scp_id = scp_id
			p.description = description
			p.proposer_ckey = ui.user.ckey
			p.is_custom = TRUE
			SSresearch.all_projects.Add(p)
			computer.alert_call(src, "New custom test proposal submitted for SCP-[p.scp_id].")
			return TRUE
		if("authorize_test")
			var/project_id = params["project_id"]
			var/signature = params["signature"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					p.status = "AUTHORIZED"
					p.authorizer_ckey = ui.user.ckey
					p.digital_signature = signature
					break
			return TRUE
		if("begin_test")
			var/project_id = params["project_id"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					p.status = "ACTIVE"
					break
			return TRUE
		if("submit_report")
			var/project_id = params["project_id"]
			var/manual_report = params["manual_report"]
			SSresearch.submit_report(project_id, manual_report, ui.user)
			return TRUE

	return FALSE
