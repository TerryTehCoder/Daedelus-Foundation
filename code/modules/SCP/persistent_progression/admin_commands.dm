/client/proc/award_experience()
	set name = "Award Experience"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Award Experience") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/amount = input("Enter experience amount", "Award Experience") as num
	if(amount <= 0)
		to_chat(src, span_warning("Experience amount must be positive."))
		return

	var/reason = input("Enter reason for award", "Award Experience") as text
	if(!reason)
		reason = "Admin Award"

	var/awarded = SSpersistent_progression.award_experience(target.ckey, "admin_award", amount, reason)

	if(awarded > 0)
		to_chat(src, span_notice("Successfully awarded [awarded] experience to [target.name] for: [reason]"))
		to_chat(target, span_notice("You received [awarded] experience for: [reason]"))
		log_admin("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
		message_admins("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
	else
		to_chat(src, span_warning("Failed to award experience."))

/client/proc/set_player_rank()
	set name = "Set Player Rank"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Set Rank") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data)
		to_chat(src, span_warning("No persistent data found for this player."))
		return

	var/list/available_classes = list()
	for(var/class_id in SSpersistent_progression.classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		available_classes["[class.class_name] ([class_id])"] = class_id

	var/selected_class = input("Select class", "Set Rank") as null|anything in available_classes
	if(!selected_class)
		return

	var/class_id = available_classes[selected_class]
	var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

	var/rank_level = input("Select rank level (0-[class.max_rank])", "Set Rank") as num
	if(rank_level < 0 || rank_level > class.max_rank)
		to_chat(src, span_warning("Invalid rank level."))
		return

	// Set the rank by giving enough experience
	var/required_exp = class.get_rank_requirement(rank_level)
	var/exp_needed = required_exp - data.total_experience

	if(exp_needed > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_award", exp_needed, "Admin Rank Set")

	to_chat(src, span_notice("Set [target.name]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]"))
	log_admin("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")
	message_admins("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")

/client/proc/reset_player_progress()
	set name = "Reset Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Reset Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/confirm = alert("Are you sure you want to reset [target.name]'s persistent progress? This cannot be undone.", "Confirm Reset", "Yes", "No")
	if(confirm != "Yes")
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(data)
		data.initialize_default_data()
		SSpersistent_progression.save_player_data(target.ckey)

	to_chat(src, span_notice("Reset [target.name]'s persistent progress."))
	to_chat(target, span_warning("Your persistent progress has been reset by an administrator."))
	log_admin("[key_name(usr)] reset [key_name(target)]'s persistent progress")
	message_admins("[key_name(usr)] reset [key_name(target)]'s persistent progress")

/client/proc/view_player_progress()
	set name = "View Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "View Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_progression_player_view_ui/player_view = new(target.ckey)
	player_view.ui_interact(src)

/client/proc/persistent_progression_panel()
	set name = "Persistent Progression Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	new /datum/persistent_progression_admin_ui(src)

// Facility Persistence Admin Commands
/client/proc/facility_persistence_panel()
	set name = "Facility Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/facility_persistence_manager/manager = SSfacility_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Facility persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Facility Persistence Management") as null|anything in list(
		"View Facility Status",
		"Save Facility Data",
		"Load Facility Data",
		"Reset Facility Data",
		"View Room States",
		"View Equipment Status",
		"View Security Systems"
	)

	switch(action)
		if("View Facility Status")
			var/message = "<h2>Facility Persistence Status</h2>"
			message += "<b>Facility Health:</b> [manager.facility_health]%<br>"
			message += "<b>Maintenance Level:</b> [manager.maintenance_level]%<br>"
			message += "<b>Security Level:</b> [manager.security_level]<br>"
			message += "<b>Power Efficiency:</b> [manager.power_efficiency * 100]%<br>"
			message += "<b>Containment Stability:</b> [manager.containment_stability]%<br>"
			message += "<b>Facility Age:</b> [manager.facility_age] rounds<br><br>"

			message += "<b>Room States:</b> [manager.room_states.len]<br>"
			message += "<b>Equipment Status:</b> [manager.equipment_status.len]<br>"
			message += "<b>Security Systems:</b> [manager.security_systems.len]<br>"
			message += "<b>Containment Chambers:</b> [manager.containment_chambers.len]<br>"
			message += "<b>Research Labs:</b> [manager.research_labs.len]<br>"
			message += "<b>Medical Facilities:</b> [manager.medical_facilities.len]<br>"
			message += "<b>Engineering Systems:</b> [manager.engineering_systems.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save Facility Data")
			manager.save_facility_data()
			to_chat(src, span_notice("Facility data saved successfully."))

		if("Load Facility Data")
			manager.load_facility_data()
			to_chat(src, span_notice("Facility data loaded successfully."))

		if("Reset Facility Data")
			if(alert(src, "Are you sure you want to reset all facility persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.room_states = list()
				manager.equipment_status = list()
				manager.security_systems = list()
				manager.power_grid = list()
				manager.environmental_conditions = list()
				manager.containment_chambers = list()
				manager.research_labs = list()
				manager.medical_facilities = list()
				manager.engineering_systems = list()
				to_chat(src, span_notice("Facility persistence data reset."))

		if("View Room States")
			var/message = "<h3>Room States ([manager.room_states.len])</h3>"
			for(var/type in manager.room_states)
				var/datum/room_state/state = manager.room_states[type]
				message += "<b>[type]:</b> [state.health]% health, [state.damage_level] damage<br>"
			to_chat(src, span_notice("[message]"))

		if("View Equipment Status")
			var/message = "<h3>Equipment Status ([manager.equipment_status.len])</h3>"
			for(var/type in manager.equipment_status)
				var/datum/equipment_status/status = manager.equipment_status[type]
				message += "<b>[type]:</b> [status.health]% health, [status.operational ? "Operational" : "Non-operational"]<br>"
			to_chat(src, span_notice("[message]"))

		if("View Security Systems")
			var/message = "<h3>Security Systems ([manager.security_systems.len])</h3>"
			for(var/key in manager.security_systems)
				var/datum/security_component/comp = manager.security_systems[key]
				message += "<b>[key]:</b> [comp.health]% health, [comp.operational ? "Operational" : "Non-operational"]<br>"
			to_chat(src, span_notice("[message]"))

// SCP Persistence Admin Commands
/client/proc/scp_persistence_panel()
	set name = "SCP Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager
	if(!manager)
		to_chat(src, span_warning("SCP persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "SCP Persistence Management") as null|anything in list(
		"View SCP Status",
		"Save SCP Data",
		"Load SCP Data",
		"Reset SCP Data",
		"Add Research Project",
		"Add SCP Instance",
		"View Research Projects",
		"View Containment Protocols"
	)

	switch(action)
		if("View SCP Status")
			var/message = "<h2>SCP Persistence Status</h2>"
			message += "<b>Global Containment Stability:</b> [manager.global_containment_stability]%<br>"
			message += "<b>Active Breaches:</b> [manager.active_breaches]<br>"
			message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
			message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br><br>"

			message += "<b>SCP Instances:</b> [manager.scp_instances.len]<br>"
			message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Containment Protocols:</b> [manager.containment_protocols.len]<br>"
			message += "<b>Anomaly Effects:</b> [manager.anomaly_effects.len]<br>"
			message += "<b>Environmental Changes:</b> [manager.environmental_changes.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save SCP Data")
			manager.save_scp_data()
			to_chat(src, span_notice("SCP data saved successfully."))

		if("Load SCP Data")
			manager.load_scp_data()
			to_chat(src, span_notice("SCP data loaded successfully."))

		if("Reset SCP Data")
			if(alert(src, "Are you sure you want to reset all SCP persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.scp_instances = list()
				manager.research_projects = list()
				manager.containment_protocols = list()
				manager.anomaly_effects = list()
				manager.communication_logs = list()
				manager.environmental_changes = list()
				to_chat(src, span_notice("SCP persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text

			if(project_name && project_desc)
				var/project_id = "project_[world.time]"
				var/datum/research_project/new_project = new /datum/research_project(project_id, project_name, project_desc)
				manager.research_projects[project_id] = new_project
				to_chat(src, span_notice("Research project '[project_name]' added successfully."))

		if("Add SCP Instance")
			var/scp_id = input(src, "Enter SCP ID (e.g., SCP-173):", "Add SCP Instance") as text
			if(scp_id)
				var/datum/scp_instance/new_instance = new /datum/scp_instance(scp_id, null)
				manager.scp_instances[scp_id] = new_instance
				to_chat(src, span_notice("SCP instance '[scp_id]' added successfully."))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/research_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Containment Protocols")
			var/message = "<h3>Containment Protocols ([manager.containment_protocols.len])</h3>"
			for(var/protocol_id in manager.containment_protocols)
				var/datum/containment_protocol/protocol = manager.containment_protocols[protocol_id]
				message += "<b>[protocol.protocol_name]:</b> [protocol.effectiveness * 100]% effective ([protocol.protocol_status])<br>"
			to_chat(src, span_notice("[message]"))

// Technology Persistence Admin Commands
/client/proc/technology_persistence_panel()
	set name = "Technology Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/technology_persistence_manager/manager = SStechnology_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Technology persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Technology Persistence Management") as null|anything in list(
		"View Technology Status",
		"Save Technology Data",
		"Load Technology Data",
		"Reset Technology Data",
		"Add Research Project",
		"Add Technology",
		"View Research Projects",
		"View Technologies",
		"View Scientific Discoveries"
	)

	switch(action)
		if("View Technology Status")
			var/message = "<h2>Technology Persistence Status</h2>"
			message += "<b>Technology Level:</b> [manager.technology_level]<br>"
			message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
			message += "<b>Innovation Score:</b> [manager.innovation_score]<br>"
			message += "<b>Research Budget:</b> $[manager.research_budget]<br>"
			message += "<b>Research Efficiency:</b> [manager.research_efficiency * 100]%<br><br>"

			message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Technologies:</b> [manager.technology_tree.len]<br>"
			message += "<b>Scientific Discoveries:</b> [manager.scientific_discoveries.len]<br>"
			message += "<b>Research Facilities:</b> [manager.research_facilities.len]<br>"
			message += "<b>Patents:</b> [manager.patents.len]<br>"
			message += "<b>Technology Transfers:</b> [manager.technology_transfers.len]<br>"

			to_chat(src, span_notice("[message]"))

		if("Save Technology Data")
			manager.save_technology_data()
			to_chat(src, span_notice("Technology data saved successfully."))

		if("Load Technology Data")
			manager.load_technology_data()
			to_chat(src, span_notice("Technology data loaded successfully."))

		if("Reset Technology Data")
			if(alert(src, "Are you sure you want to reset all technology persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.research_projects = list()
				manager.technology_tree = list()
				manager.equipment_blueprints = list()
				manager.scientific_discoveries = list()
				manager.research_facilities = list()
				manager.patents = list()
				manager.technology_transfers = list()
				to_chat(src, span_notice("Technology persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text
			var/research_field = input(src, "Enter research field:", "Add Research Project") as text

			if(project_name && project_desc)
				var/project_id = "project_[world.time]"
				var/datum/tech_research_project/new_project = new /datum/tech_research_project(project_id, project_name, project_desc, research_field)
				manager.research_projects[project_id] = new_project
				to_chat(src, span_notice("Research project '[project_name]' added successfully."))

		if("Add Technology")
			var/tech_name = input(src, "Enter technology name:", "Add Technology") as text
			var/tech_desc = input(src, "Enter technology description:", "Add Technology") as text

			if(tech_name && tech_desc)
				var/tech_id = "tech_[world.time]"
				var/datum/technology/new_tech = new /datum/technology(tech_id, tech_name, tech_desc)
				manager.technology_tree[tech_id] = new_tech
				to_chat(src, span_notice("Technology '[tech_name]' added successfully."))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/tech_research_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Technologies")
			var/message = "<h3>Technologies ([manager.technology_tree.len])</h3>"
			for(var/tech_id in manager.technology_tree)
				var/datum/technology/tech = manager.technology_tree[tech_id]
				message += "<b>[tech.tech_name]:</b> [tech.tech_status] (Level [tech.tech_level])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Scientific Discoveries")
			var/message = "<h3>Scientific Discoveries ([manager.scientific_discoveries.len])</h3>"
			for(var/discovery_id in manager.scientific_discoveries)
				var/datum/scientific_discovery/discovery = manager.scientific_discoveries[discovery_id]
				message += "<b>[discovery.discovery_name]:</b> [discovery.discovery_type] ([discovery.innovation_value] innovation)<br>"
			to_chat(src, span_notice("[message]"))

// Master Persistence Panel - Now uses TGUI interface
// The TGUI version is defined in tgui_master_panel.dm

// Medical Persistence Admin Commands
/client/proc/medical_persistence_panel()
	set name = "Medical Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/medical_persistence_manager/manager = SSmedical_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Medical persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Medical Persistence Management") as null|anything in list(
		"View Medical Status",
		"Save Medical Data",
		"Load Medical Data",
		"Reset Medical Data",
		"Add Medical Record",
		"Add Treatment Log",
		"Add Outbreak",
		"Add Research Project",
		"View Medical Records",
		"View Treatment Logs",
		"View Outbreaks",
		"View Research Projects"
	)

	switch(action)
		if("View Medical Status")
			var/message = "<h2>Medical Persistence Status</h2>"
			message += "<b>Total Patients:</b> [manager.medical_records.len]<br>"
			message += "<b>Total Treatments:</b> [manager.treatment_logs.len]<br>"
			message += "<b>Active Outbreaks:</b> [manager.active_outbreaks]<br>"
			message += "<b>Research Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Medical Budget:</b> $[manager.medical_budget]<br>"
			message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br>"
			to_chat(src, span_notice("[message]"))

		if("Save Medical Data")
			manager.save_medical_data()
			to_chat(src, span_notice("Medical data saved successfully."))

		if("Load Medical Data")
			manager.load_medical_data()
			to_chat(src, span_notice("Medical data loaded successfully."))

		if("Reset Medical Data")
			if(alert(src, "Are you sure you want to reset all medical persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.medical_records = list()
				manager.treatment_logs = list()
				manager.outbreak_records = list()
				manager.research_projects = list()
				manager.disease_tracking = list()
				to_chat(src, span_notice("Medical persistence data reset."))

		if("Add Medical Record")
			var/ckey = input(src, "Enter patient ckey:", "Add Medical Record") as text
			var/real_name = input(src, "Enter patient name:", "Add Medical Record") as text
			if(ckey && real_name)
				manager.add_medical_record(ckey, real_name)
				to_chat(src, span_notice("Medical record added for [real_name]."))

		if("Add Treatment Log")
			var/patient_ckey = input(src, "Enter patient ckey:", "Add Treatment Log") as text
			var/treatment_type = input(src, "Enter treatment type:", "Add Treatment Log") as text
			var/doctor_ckey = input(src, "Enter doctor ckey:", "Add Treatment Log") as text
			if(patient_ckey && treatment_type && doctor_ckey)
				manager.add_treatment(patient_ckey, treatment_type, doctor_ckey)
				to_chat(src, span_notice("Treatment log added."))

		if("Add Outbreak")
			var/disease_name = input(src, "Enter disease name:", "Add Outbreak") as text
			var/disease_type = input(src, "Enter disease type:", "Add Outbreak") as text
			var/severity = input(src, "Enter severity (1-5):", "Add Outbreak") as num
			if(disease_name && disease_type)
				manager.add_outbreak(disease_name, disease_type, severity)
				to_chat(src, span_notice("Outbreak added: [disease_name]."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text
			var/research_field = input(src, "Enter research field:", "Add Research Project") as text
			var/lead_researcher = input(src, "Enter lead researcher:", "Add Research Project") as text
			if(project_name && project_desc && research_field && lead_researcher)
				manager.add_research_project(project_name, project_desc, research_field, lead_researcher)
				to_chat(src, span_notice("Research project added: [project_name]."))

		if("View Medical Records")
			var/message = "<h3>Medical Records ([manager.medical_records.len])</h3>"
			for(var/ckey in manager.medical_records)
				var/datum/medical_record/record = manager.medical_records[ckey]
				message += "<b>[record.real_name]:</b> [record.blood_type] blood, [record.health_rating]% health<br>"
			to_chat(src, span_notice("[message]"))

		if("View Treatment Logs")
			var/message = "<h3>Treatment Logs ([manager.treatment_logs.len])</h3>"
			var/count = 0
			for(var/treatment_id in manager.treatment_logs)
				if(count >= 10) break
				var/datum/treatment_log/treatment = manager.treatment_logs[treatment_id]
				message += "<b>[treatment.treatment_type]:</b> [treatment.patient_ckey] by [treatment.doctor_ckey]<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Outbreaks")
			var/message = "<h3>Outbreaks ([manager.outbreak_records.len])</h3>"
			for(var/outbreak_id in manager.outbreak_records)
				var/datum/outbreak_record/outbreak = manager.outbreak_records[outbreak_id]
				message += "<b>[outbreak.disease_name]:</b> [outbreak.status], [outbreak.affected_count] affected<br>"
			to_chat(src, span_notice("[message]"))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/medical_research_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.status])<br>"
			to_chat(src, span_notice("[message]"))

// Security Persistence Admin Commands
/client/proc/security_persistence_panel()
	set name = "Security Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/security_persistence_manager/manager = SSsecurity_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Security persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Security Persistence Management") as null|anything in list(
		"View Security Status",
		"Save Security Data",
		"Load Security Data",
		"Reset Security Data",
		"Add Security Record",
		"Add Security Incident",
		"Add Clearance Request",
		"Add Security Protocol",
		"View Security Records",
		"View Security Incidents",
		"View Clearance Requests",
		"View Security Protocols"
	)

	switch(action)
		if("View Security Status")
			var/message = "<h2>Security Persistence Status</h2>"
			message += "<b>Total Personnel:</b> [manager.security_records.len]<br>"
			message += "<b>Total Incidents:</b> [manager.total_security_incidents]<br>"
			message += "<b>Active Threats:</b> [manager.active_threats]<br>"
			message += "<b>Containment Breaches:</b> [manager.containment_breaches]<br>"
			message += "<b>Unauthorized Access:</b> [manager.unauthorized_access_attempts]<br>"
			message += "<b>Security Budget:</b> $[manager.security_budget]<br>"
			to_chat(src, span_notice("[message]"))

		if("Save Security Data")
			manager.save_security_data()
			to_chat(src, span_notice("Security data saved successfully."))

		if("Load Security Data")
			manager.load_security_data()
			to_chat(src, span_notice("Security data loaded successfully."))

		if("Reset Security Data")
			if(alert(src, "Are you sure you want to reset all security persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.security_records = list()
				manager.security_incidents = list()
				manager.clearance_requests = list()
				manager.security_protocols = list()
				manager.access_logs = list()
				to_chat(src, span_notice("Security persistence data reset."))

		if("Add Security Record")
			var/ckey = input(src, "Enter personnel ckey:", "Add Security Record") as text
			var/real_name = input(src, "Enter personnel name:", "Add Security Record") as text
			if(ckey && real_name)
				manager.add_security_record(ckey, real_name)
				to_chat(src, span_notice("Security record added for [real_name]."))

		if("Add Security Incident")
			var/incident_type = input(src, "Enter incident type:", "Add Security Incident") as text
			var/incident_desc = input(src, "Enter incident description:", "Add Security Incident") as text
			var/severity = input(src, "Enter severity (1-5):", "Add Security Incident") as num
			if(incident_type && incident_desc)
				manager.add_security_incident(incident_type, incident_desc, severity)
				to_chat(src, span_notice("Security incident added: [incident_type]."))

		if("Add Clearance Request")
			var/applicant_ckey = input(src, "Enter applicant ckey:", "Add Clearance Request") as text
			var/requested_clearance = input(src, "Enter requested clearance level:", "Add Clearance Request") as num
			var/reason = input(src, "Enter reason:", "Add Clearance Request") as text
			if(applicant_ckey && reason)
				manager.add_clearance_request(applicant_ckey, requested_clearance, reason)
				to_chat(src, span_notice("Clearance request added for [applicant_ckey]."))

		if("Add Security Protocol")
			var/protocol_name = input(src, "Enter protocol name:", "Add Security Protocol") as text
			var/protocol_desc = input(src, "Enter protocol description:", "Add Security Protocol") as text
			var/clearance_required = input(src, "Enter clearance required:", "Add Security Protocol") as num
			if(protocol_name && protocol_desc)
				manager.add_security_protocol(protocol_name, protocol_desc, clearance_required)
				to_chat(src, span_notice("Security protocol added: [protocol_name]."))

		if("View Security Records")
			var/message = "<h3>Security Records ([manager.security_records.len])</h3>"
			for(var/ckey in manager.security_records)
				var/datum/security_record/record = manager.security_records[ckey]
				message += "<b>[record.real_name]:</b> Clearance [record.security_clearance], Rating [record.security_rating]<br>"
			to_chat(src, span_notice("[message]"))

		if("View Security Incidents")
			var/message = "<h3>Security Incidents ([manager.security_incidents.len])</h3>"
			var/count = 0
			for(var/incident_id in manager.security_incidents)
				if(count >= 10) break
				var/datum/security_incident/incident = manager.security_incidents[incident_id]
				message += "<b>[incident.incident_type]:</b> [incident.resolved ? "RESOLVED" : "ACTIVE"], Severity [incident.severity]<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Clearance Requests")
			var/message = "<h3>Clearance Requests ([manager.clearance_requests.len])</h3>"
			for(var/request_id in manager.clearance_requests)
				var/datum/clearance_request/request = manager.clearance_requests[request_id]
				message += "<b>[request.applicant_ckey]:</b> Level [request.requested_clearance] ([request.status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Security Protocols")
			var/message = "<h3>Security Protocols ([manager.security_protocols.len])</h3>"
			for(var/protocol_id in manager.security_protocols)
				var/datum/security_protocol/protocol = manager.security_protocols[protocol_id]
				message += "<b>[protocol.protocol_name]:</b> [protocol.effectiveness_rating]% effective ([protocol.status])<br>"
			to_chat(src, span_notice("[message]"))

// Research Persistence Admin Commands
/client/proc/research_persistence_panel()
	set name = "Research Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/research_persistence_manager/manager = SSresearch_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Research persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Research Persistence Management") as null|anything in list(
		"View Research Status",
		"Save Research Data",
		"Load Research Data",
		"Reset Research Data",
		"Add Research Project",
		"Add Scientific Discovery",
		"Add Publication",
		"Add Research Facility",
		"Add Research Grant",
		"View Research Projects",
		"View Scientific Discoveries",
		"View Publications",
		"View Research Facilities",
		"View Research Grants"
	)

	switch(action)
		if("View Research Status")
			var/message = "<h2>Research Persistence Status</h2>"
			message += "<b>Total Projects:</b> [manager.total_research_projects]<br>"
			message += "<b>Completed Projects:</b> [manager.completed_projects]<br>"
			message += "<b>Active Projects:</b> [manager.research_projects.len]<br>"
			message += "<b>Scientific Discoveries:</b> [manager.scientific_discoveries.len]<br>"
			message += "<b>Publications:</b> [manager.publication_count]<br>"
			message += "<b>Research Budget:</b> $[manager.research_budget]<br>"
			message += "<b>Research Efficiency:</b> [manager.research_efficiency * 100]%<br>"
			to_chat(src, span_notice("[message]"))

		if("Save Research Data")
			manager.save_research_data()
			to_chat(src, span_notice("Research data saved successfully."))

		if("Load Research Data")
			manager.load_research_data()
			to_chat(src, span_notice("Research data loaded successfully."))

		if("Reset Research Data")
			if(alert(src, "Are you sure you want to reset all research persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.research_projects = list()
				manager.scientific_discoveries = list()
				manager.publications = list()
				manager.research_facilities = list()
				manager.research_grants = list()
				to_chat(src, span_notice("Research persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text
			var/research_field = input(src, "Enter research field:", "Add Research Project") as text
			var/lead_researcher = input(src, "Enter lead researcher:", "Add Research Project") as text
			var/budget = input(src, "Enter budget:", "Add Research Project") as num
			var/priority = input(src, "Enter priority (1-5):", "Add Research Project") as num
			if(project_name && project_desc && research_field && lead_researcher)
				manager.add_research_project(project_name, project_desc, research_field, lead_researcher, budget, priority)
				to_chat(src, span_notice("Research project added: [project_name]."))

		if("Add Scientific Discovery")
			var/discovery_name = input(src, "Enter discovery name:", "Add Scientific Discovery") as text
			var/discovery_desc = input(src, "Enter discovery description:", "Add Scientific Discovery") as text
			var/discovery_type = input(src, "Enter discovery type:", "Add Scientific Discovery") as text
			var/research_field = input(src, "Enter research field:", "Add Scientific Discovery") as text
			var/discoverer_ckey = input(src, "Enter discoverer ckey:", "Add Scientific Discovery") as text
			var/significance = input(src, "Enter significance level (1-5):", "Add Scientific Discovery") as num
			if(discovery_name && discovery_desc && discovery_type && research_field && discoverer_ckey)
				manager.add_scientific_discovery(discovery_name, discovery_desc, discovery_type, research_field, discoverer_ckey, significance)
				to_chat(src, span_notice("Scientific discovery added: [discovery_name]."))

		if("Add Publication")
			var/pub_title = input(src, "Enter publication title:", "Add Publication") as text
			var/pub_abstract = input(src, "Enter publication abstract:", "Add Publication") as text
			var/authors = input(src, "Enter authors (comma separated):", "Add Publication") as text
			var/journal = input(src, "Enter journal name:", "Add Publication") as text
			var/impact_factor = input(src, "Enter impact factor:", "Add Publication") as num
			if(pub_title && pub_abstract && authors && journal)
				var/list/author_list = splittext(authors, ",")
				manager.add_publication(pub_title, pub_abstract, author_list, journal, impact_factor)
				to_chat(src, span_notice("Publication added: [pub_title]."))

		if("Add Research Facility")
			var/facility_name = input(src, "Enter facility name:", "Add Research Facility") as text
			var/facility_type = input(src, "Enter facility type:", "Add Research Facility") as text
			var/location = input(src, "Enter location:", "Add Research Facility") as text
			var/capacity = input(src, "Enter capacity:", "Add Research Facility") as num
			var/security_level = input(src, "Enter security level:", "Add Research Facility") as num
			if(facility_name && facility_type && location)
				manager.add_research_facility(facility_name, facility_type, location, capacity, security_level)
				to_chat(src, span_notice("Research facility added: [facility_name]."))

		if("Add Research Grant")
			var/grant_name = input(src, "Enter grant name:", "Add Research Grant") as text
			var/organization = input(src, "Enter granting organization:", "Add Research Grant") as text
			var/amount = input(src, "Enter grant amount:", "Add Research Grant") as num
			var/research_field = input(src, "Enter research field:", "Add Research Grant") as text
			var/recipient_ckey = input(src, "Enter recipient ckey:", "Add Research Grant") as text
			if(grant_name && organization && research_field && recipient_ckey)
				manager.add_research_grant(grant_name, organization, amount, research_field, recipient_ckey)
				to_chat(src, span_notice("Research grant added: [grant_name]."))

		if("View Research Projects")
			var/message = "<h3>Research Projects ([manager.research_projects.len])</h3>"
			for(var/project_id in manager.research_projects)
				var/datum/research_persistence_project/project = manager.research_projects[project_id]
				message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Scientific Discoveries")
			var/message = "<h3>Scientific Discoveries ([manager.scientific_discoveries.len])</h3>"
			for(var/discovery_id in manager.scientific_discoveries)
				var/datum/research_scientific_discovery/discovery = manager.scientific_discoveries[discovery_id]
				message += "<b>[discovery.discovery_name]:</b> [discovery.discovery_type] (Significance [discovery.significance_level])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Publications")
			var/message = "<h3>Publications ([manager.publications.len])</h3>"
			var/count = 0
			for(var/publication_id in manager.publications)
				if(count >= 10) break
				var/datum/publication/pub = manager.publications[publication_id]
				message += "<b>[pub.publication_title]:</b> [pub.journal_name] (Impact [pub.impact_factor])<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Research Facilities")
			var/message = "<h3>Research Facilities ([manager.research_facilities.len])</h3>"
			for(var/facility_id in manager.research_facilities)
				var/datum/research_persistence_facility/facility = manager.research_facilities[facility_id]
				message += "<b>[facility.facility_name]:</b> [facility.facility_type] at [facility.location]<br>"
			to_chat(src, span_notice("[message]"))

		if("View Research Grants")
			var/message = "<h3>Research Grants ([manager.research_grants.len])</h3>"
			for(var/grant_id in manager.research_grants)
				var/datum/research_grant/grant = manager.research_grants[grant_id]
				message += "<b>[grant.grant_name]:</b> $[grant.amount] from [grant.granting_organization] ([grant.status])<br>"
			to_chat(src, span_notice("[message]"))

// Personnel Persistence Admin Commands
/client/proc/personnel_persistence_panel()
	set name = "Personnel Persistence Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/personnel_persistence_manager/manager = SSpersonnel_persistence.manager
	if(!manager)
		to_chat(src, span_warning("Personnel persistence system not available."))
		return

	var/action = input(src, "Choose an action:", "Personnel Persistence Management") as null|anything in list(
		"View Personnel Status",
		"Save Personnel Data",
		"Load Personnel Data",
		"Reset Personnel Data",
		"Add Personnel Record",
		"Add Assignment",
		"Add Performance Review",
		"Add Training Record",
		"Add Promotion",
		"View Personnel Records",
		"View Assignments",
		"View Performance Reviews",
		"View Training Records",
		"View Promotions"
	)

	switch(action)
		if("View Personnel Status")
			var/message = "<h2>Personnel Persistence Status</h2>"
			message += "<b>Total Staff:</b> [manager.total_staff]<br>"
			message += "<b>Active Staff:</b> [manager.active_staff]<br>"
			message += "<b>Personnel Budget:</b> $[manager.personnel_budget]<br>"
			message += "<b>Staff Satisfaction:</b> [manager.staff_satisfaction]%<br>"
			message += "<b>Turnover Rate:</b> [manager.turnover_rate * 100]%<br>"
			message += "<b>Average Performance:</b> [manager.average_performance]%<br>"
			message += "<b>Training Completion:</b> [manager.training_completion_rate * 100]%<br>"
			to_chat(src, span_notice("[message]"))

		if("Save Personnel Data")
			manager.save_personnel_data()
			to_chat(src, span_notice("Personnel data saved successfully."))

		if("Load Personnel Data")
			manager.load_personnel_data()
			to_chat(src, span_notice("Personnel data loaded successfully."))

		if("Reset Personnel Data")
			if(alert(src, "Are you sure you want to reset all personnel persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.personnel_records = list()
				manager.assignments = list()
				manager.performance_reviews = list()
				manager.training_records = list()
				manager.promotions = list()
				to_chat(src, span_notice("Personnel persistence data reset."))

		if("Add Personnel Record")
			var/ckey = input(src, "Enter employee ckey:", "Add Personnel Record") as text
			var/real_name = input(src, "Enter employee name:", "Add Personnel Record") as text
			var/department = input(src, "Enter department:", "Add Personnel Record") as text
			var/position = input(src, "Enter position:", "Add Personnel Record") as text
			var/salary = input(src, "Enter salary:", "Add Personnel Record") as num
			var/clearance = input(src, "Enter clearance level:", "Add Personnel Record") as num
			if(ckey && real_name && department && position)
				manager.add_personnel_record(ckey, real_name, department, position, salary, clearance)
				to_chat(src, span_notice("Personnel record added for [real_name]."))

		if("Add Assignment")
			var/employee_ckey = input(src, "Enter employee ckey:", "Add Assignment") as text
			var/assignment_type = input(src, "Enter assignment type:", "Add Assignment") as text
			var/assignment_desc = input(src, "Enter assignment description:", "Add Assignment") as text
			var/supervisor_ckey = input(src, "Enter supervisor ckey:", "Add Assignment") as text
			var/priority = input(src, "Enter priority (1-5):", "Add Assignment") as num
			if(employee_ckey && assignment_type && assignment_desc && supervisor_ckey)
				manager.add_assignment(employee_ckey, assignment_type, assignment_desc, supervisor_ckey, priority)
				to_chat(src, span_notice("Assignment added for [employee_ckey]."))

		if("Add Performance Review")
			var/employee_ckey = input(src, "Enter employee ckey:", "Add Performance Review") as text
			var/reviewer_ckey = input(src, "Enter reviewer ckey:", "Add Performance Review") as text
			var/performance_rating = input(src, "Enter performance rating (0-100):", "Add Performance Review") as num
			var/assessment = input(src, "Enter overall assessment:", "Add Performance Review") as text
			if(employee_ckey && reviewer_ckey)
				manager.add_performance_review(employee_ckey, reviewer_ckey, performance_rating, assessment)
				to_chat(src, span_notice("Performance review added for [employee_ckey]."))

		if("Add Training Record")
			var/employee_ckey = input(src, "Enter employee ckey:", "Add Training Record") as text
			var/training_type = input(src, "Enter training type:", "Add Training Record") as text
			var/training_name = input(src, "Enter training name:", "Add Training Record") as text
			var/trainer_ckey = input(src, "Enter trainer ckey:", "Add Training Record") as text
			if(employee_ckey && training_type && training_name && trainer_ckey)
				manager.add_training_record(employee_ckey, training_type, training_name, trainer_ckey)
				to_chat(src, span_notice("Training record added for [employee_ckey]."))

		if("Add Promotion")
			var/employee_ckey = input(src, "Enter employee ckey:", "Add Promotion") as text
			var/new_position = input(src, "Enter new position:", "Add Promotion") as text
			var/approver_ckey = input(src, "Enter approver ckey:", "Add Promotion") as text
			var/salary_increase = input(src, "Enter salary increase:", "Add Promotion") as num
			var/clearance_increase = input(src, "Enter clearance increase:", "Add Promotion") as num
			if(employee_ckey && new_position && approver_ckey)
				manager.add_promotion(employee_ckey, new_position, approver_ckey, salary_increase, clearance_increase)
				to_chat(src, span_notice("Promotion added for [employee_ckey]."))

		if("View Personnel Records")
			var/message = "<h3>Personnel Records ([manager.personnel_records.len])</h3>"
			for(var/ckey in manager.personnel_records)
				var/datum/personnel_record/record = manager.personnel_records[ckey]
				message += "<b>[record.real_name]:</b> [record.position] in [record.department] ([record.status])<br>"
			to_chat(src, span_notice("[message]"))

		if("View Assignments")
			var/message = "<h3>Assignments ([manager.assignments.len])</h3>"
			var/count = 0
			for(var/assignment_id in manager.assignments)
				if(count >= 10) break
				var/datum/assignment/assignment = manager.assignments[assignment_id]
				message += "<b>[assignment.assignment_type]:</b> [assignment.employee_ckey] ([assignment.status])<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Performance Reviews")
			var/message = "<h3>Performance Reviews ([manager.performance_reviews.len])</h3>"
			var/count = 0
			for(var/review_id in manager.performance_reviews)
				if(count >= 10) break
				var/datum/performance_review/review = manager.performance_reviews[review_id]
				message += "<b>[review.employee_ckey]:</b> Rating [review.performance_rating] by [review.reviewer_ckey]<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Training Records")
			var/message = "<h3>Training Records ([manager.training_records.len])</h3>"
			var/count = 0
			for(var/training_id in manager.training_records)
				if(count >= 10) break
				var/datum/training_record/training = manager.training_records[training_id]
				message += "<b>[training.training_name]:</b> [training.employee_ckey] ([training.status])<br>"
				count++
			to_chat(src, span_notice("[message]"))

		if("View Promotions")
			var/message = "<h3>Promotions ([manager.promotions.len])</h3>"
			for(var/promotion_id in manager.promotions)
				var/datum/promotion/promotion = manager.promotions[promotion_id]
				message += "<b>[promotion.employee_ckey]:</b> [promotion.old_position] → [promotion.new_position]<br>"
			to_chat(src, span_notice("[message]"))
