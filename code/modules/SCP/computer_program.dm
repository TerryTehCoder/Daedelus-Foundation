/datum/computer_file/program/scp_research
	filename = "SCPResearch"
	filedesc = "SCP Research & Containment"
	category = PROGRAM_CATEGORY_SCIENCE
	program_icon = "book"
	requires_ntnet = TRUE
	tgui_id = "SCPResearchConsole"
	required_access = list(ACCESS_RESEARCH)
	available_on_ntnet = TRUE

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

	var/list/scps = list()
	for(var/datum/scp_definition/scp in SSresearch.scp_definitions)
		var/list/tests = list()
		for(var/datum/scp_test/test in scp.tests)
			tests.Add(list(list(
				"name" = test.name,
				"description" = test.description
			)))

		scps.Add(list(list(
			"id" = scp.id_tag,
			"name" = scp.name,
			"dangerTier" = scp.danger_tier,
			"cost" = scp.cost,
			"unlocked" = (scp.id_tag in SSresearch.unlocked_scps),
			"tests" = tests
		)))
	data["scps"] = scps

	return data

/datum/computer_file/program/scp_research/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase_scp")
			var/scp_id = params["scp_id"]
			SSresearch.purchase_scp(scp_id, user)
			return TRUE
		if("submit_report")
			var/scp_id = params["scp_id"]
			var/test_name = params["test_name"]
			var/manual_report = params["manual_report"]
			SSresearch.submit_report(scp_id, test_name, manual_report, user)
			return TRUE

	return FALSE
