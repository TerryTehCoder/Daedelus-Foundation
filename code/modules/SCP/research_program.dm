/datum/computer_file/program/scp_research
	filename = "SCPResearch"
	filedesc = "SCP-OS Research Suite"
	extended_desc = "A comprehensive suite of tools for managing and tracking SCP research projects."
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

	var/list/user_access = list()
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/access_card = card_slot?.GetID()
	if(access_card)
		user_access = access_card.GetAccess()
	data["user_access"] = user_access

	var/list/projects = list()
	for(var/datum/research_project/p in SSresearch.all_projects)
		var/mob/proposer_mob = get_mob_by_ckey(p.proposer_ckey)
		var/proposer_name = "Regional Command"
		if(proposer_mob)
			proposer_name = proposer_mob.real_name
		var/mob/authorizer_mob = get_mob_by_ckey(p.authorizer_ckey)
		var/authorizer_name = authorizer_mob ? authorizer_mob.real_name : p.authorizer_ckey

		var/list/test_data
		if(p.test)
			test_data = list(
				"name" = p.test.name,
				"description" = p.test.description,
				"hypothesis" = p.test.hypothesis,
				"procedure" = p.test.procedure,
				"risks" = p.test.risks,
				"required_equipment" = p.test.required_equipment,
				"reward_rp" = p.test.reward_rp,
				"reward_lp" = p.test.reward_lp
			)

		projects.Add(list(list(
			"id" = p.id,
			"name" = p.project_name,
			"scp_id" = p.scp_id,
			"status" = p.status,
			"description" = p.description,
			"is_custom" = p.is_custom,
			"proposer" = proposer_name,
			"authorizer" = authorizer_name,
			"signature" = p.digital_signature,
			"authorization_notes" = p.authorization_notes,
			"attachment_uid" = p.attachment_uid,
			"test" = test_data
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
			var/hypothesis = params["hypothesis"]
			var/procedure = params["procedure"]
			var/risks = params["risks"]
			var/required_equipment = params["required_equipment"]
			var/attachment_uid = params["attachment_uid"]

			if(!scp_id)
				to_chat(user, span_warning("You must select an SCP to propose a test for."))
				return

			var/datum/research_project/p = new()
			p.project_name = project_name
			p.scp_id = scp_id
			p.description = description
			p.proposer_ckey = ui.user.ckey
			p.is_custom = TRUE
			p.attachment_uid = attachment_uid

			var/datum/scp_test/custom_test = new()
			custom_test.name = project_name
			custom_test.description = description
			custom_test.hypothesis = hypothesis
			custom_test.procedure = procedure
			custom_test.risks = risks
			custom_test.required_equipment = required_equipment
			p.test = custom_test

			SSresearch.all_projects.Add(p)
			computer.alert_call(src, "New custom test proposal submitted for SCP-[p.scp_id].")
			return TRUE
		if("deny_test")
			var/project_id = params["project_id"]
			var/reason = params["reason"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					p.status = "DENIED"
					p.authorization_notes = reason
					computer.alert_call(src, "Research proposal '[p.project_name]' has been denied. Reason: [reason ? reason : "No reason provided."]")
					break
			return TRUE
		if("authorize_test")
			var/project_id = params["project_id"]
			var/signature = params["signature"]
			var/notes = params["notes"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					p.status = "AUTHORIZED"
					p.authorizer_ckey = ui.user.ckey
					p.digital_signature = signature
					p.authorization_notes = notes
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
		if("go_back")
			ui.close()
			return TRUE
		if("get_computer_files")
			var/list/files = list()
			var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
			if(drive)
				for(var/datum/computer_file/file in drive.stored_files)
					if(!file.unsendable)
						files.Add(list(list("name" = file.filename, "uid" = file.uid)))
			return files
		if("view_attachment")
			var/project_id = params["project_id"]
			var/datum/research_project/p
			for(var/datum/research_project/proj in SSresearch.all_projects)
				if(proj.id == project_id)
					p = proj
					break
			if(p && p.attachment_uid)
				var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
				if(drive)
					var/datum/computer_file/file = drive.find_file_by_uid(p.attachment_uid)
					if(file)
						// This will need a new TGUI window to display the file content.
						// For now, we'll just send the content back to the client to be displayed in a modal.
						// This is not ideal, but it's a start.
						var/datum/computer_file/data/text/textFile = file
						if(istype(textFile))
							return list("content" = textFile.stored_text)
			return list("content" = "File not found or not a text file.")
		if("download_attachment")
			var/project_id = params["project_id"]
			var/datum/research_project/p
			for(var/datum/research_project/proj in SSresearch.all_projects)
				if(proj.id == project_id)
					p = proj
					break
			if(p && p.attachment_uid)
				var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
				if(drive)
					var/datum/computer_file/file = drive.find_file_by_uid(p.attachment_uid)
					if(file)
						var/mob/user_mob = ui.user
						var/obj/item/modular_computer/tablet/pda/pda = user_mob.get_active_hand() // Assuming user holds PDA
						if(istype(pda))
							var/obj/item/computer_hardware/hard_drive/user_drive = pda.all_components[MC_HDD]
							if(user_drive)
								var/datum/computer_file/new_file = file.clone(TRUE)
								user_drive.store_file(new_file)
								to_chat(user_mob, span_notice("File '[new_file.filename]' downloaded to your PDA."))
								return TRUE
			return FALSE
		if("unauthorize_test")
			var/project_id = params["project_id"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					p.status = "PROPOSED"
					p.authorizer_ckey = null
					p.digital_signature = null
					p.authorization_notes = null
					var/mob/proposer_mob = get_mob_by_ckey(p.proposer_ckey)
					if(proposer_mob)
						to_chat(proposer_mob, span_warning("Your research proposal '[p.project_name]' has been unauthorized by [ui.user.real_name]."))
					break
			return TRUE
		if("remove_proposal")
			var/project_id = params["project_id"]
			for(var/datum/research_project/p in SSresearch.all_projects)
				if(p.id == project_id)
					computer.alert_call(src, "Research proposal '[p.project_name]' has been removed by [ui.user.real_name].")
					SSresearch.all_projects.Remove(p)
					qdel(p)
					break
			return TRUE


	return FALSE
