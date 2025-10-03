SUBSYSTEM_DEF(scp_persistence)
	name = "SCP Persistence"
	wait = 300 // Check every 5 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	var/datum/scp_persistence_manager/manager

/datum/controller/subsystem/scp_persistence/Initialize()
	manager = new /datum/scp_persistence_manager()
	world.log << "SCP Persistence Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/scp_persistence/fire()
	if(manager)
		manager.process_scp()

// SCP Persistence Manager
/datum/scp_persistence_manager
	var/list/scp_instances = list()
	var/list/research_projects = list()
	var/list/containment_protocols = list()
	var/list/anomaly_effects = list()
	var/list/communication_logs = list()
	var/list/environmental_changes = list()
	var/global_containment_stability = 100
	var/active_breaches = 0
	var/research_progress = 0
	var/containment_effectiveness = 1.0

/datum/scp_persistence_manager/proc/process_scp()
	// Update SCP instances
	update_scp_instances()

	// Update research projects
	update_research_projects()

	// Update containment protocols
	update_containment_protocols()

	// Update anomaly effects
	update_anomaly_effects()

	// Update environmental changes
	update_environmental_changes()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 6000 == 0) // Every 10 minutes
		save_scp_data()

/datum/scp_persistence_manager/proc/update_scp_instances()
	// Find and update all SCP objects in the world
	for(var/obj/O in world)
		if(findtext(O.name, "SCP-"))
			var/scp_id = get_scp_id(O)
			if(scp_id)
				if(scp_id in scp_instances)
					var/datum/scp_instance/instance = scp_instances[scp_id]
					instance.update_status(O)
				else
					var/datum/scp_instance/new_instance = new /datum/scp_instance(scp_id, O)
					scp_instances[scp_id] = new_instance
					new_instance.update_status(O)

/datum/scp_persistence_manager/proc/get_scp_id(var/obj/O)
	// Extract SCP ID from object name or properties
	if(istype(O, /obj/item/paper)) // Check if it's a document with SCP info
		return "SCP-000"
	else if(findtext(O.name, "SCP-"))
		var/list/parts = splittext(O.name, " ")
		for(var/part in parts)
			if(findtext(part, "SCP-"))
				return part
	return null

/datum/scp_persistence_manager/proc/update_research_projects()
	// Update ongoing research projects
	for(var/project_id in research_projects)
		var/datum/research_project/project = research_projects[project_id]
		project.update_progress()

/datum/scp_persistence_manager/proc/update_containment_protocols()
	// Update containment protocol effectiveness
	for(var/protocol_id in containment_protocols)
		var/datum/containment_protocol/protocol = containment_protocols[protocol_id]
		protocol.update_effectiveness()

/datum/scp_persistence_manager/proc/update_anomaly_effects()
	// Update persistent anomaly effects
	for(var/effect_id in anomaly_effects)
		var/datum/anomaly_effect/effect = anomaly_effects[effect_id]
		effect.update_effect()

/datum/scp_persistence_manager/proc/update_environmental_changes()
	// Update environmental changes caused by SCPs
	for(var/change_id in environmental_changes)
		var/datum/environmental_change/change = environmental_changes[change_id]
		change.update_change()

/datum/scp_persistence_manager/proc/calculate_global_metrics()
	var/total_containment = 0
	var/instance_count = 0
	active_breaches = 0

	// Calculate global containment stability
	for(var/scp_id in scp_instances)
		var/datum/scp_instance/instance = scp_instances[scp_id]
		total_containment += instance.containment_health
		instance_count++

		if(instance.containment_status == "breached")
			active_breaches++

	if(instance_count > 0)
		global_containment_stability = total_containment / instance_count
		containment_effectiveness = global_containment_stability / 100

	// Calculate research progress
	var/total_progress = 0
	var/project_count = 0

	for(var/project_id in research_projects)
		var/datum/research_project/project = research_projects[project_id]
		total_progress += project.progress
		project_count++

	if(project_count > 0)
		research_progress = total_progress / project_count

/datum/scp_persistence_manager/proc/save_scp_data()
	var/list/data = list(
		"scp_instances" = scp_instances,
		"research_projects" = research_projects,
		"containment_protocols" = containment_protocols,
		"anomaly_effects" = anomaly_effects,
		"communication_logs" = communication_logs,
		"environmental_changes" = environmental_changes,
		"global_containment_stability" = global_containment_stability,
		"active_breaches" = active_breaches,
		"research_progress" = research_progress,
		"containment_effectiveness" = containment_effectiveness
	)

	// Save to JSON file
	var/filename = "data/scp_persistence.json"
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/scp_persistence_manager/proc/load_scp_data()
	var/filename = "data/scp_persistence.json"
	if(fexists(filename))
		var/json_data = file2text(filename)
		var/list/data = json_decode(json_data)

		if(data)
			scp_instances = data["scp_instances"] || list()
			research_projects = data["research_projects"] || list()
			containment_protocols = data["containment_protocols"] || list()
			anomaly_effects = data["anomaly_effects"] || list()
			communication_logs = data["communication_logs"] || list()
			environmental_changes = data["environmental_changes"] || list()
			global_containment_stability = data["global_containment_stability"] || 100
			active_breaches = data["active_breaches"] || 0
			research_progress = data["research_progress"] || 0
			containment_effectiveness = data["containment_effectiveness"] || 1.0

// SCP Instance Datum
/datum/scp_instance
	var/scp_id
	var/containment_status = "contained"
	var/containment_health = 100
	var/containment_difficulty = 1
	var/current_state = "normal"
	var/list/breach_history = list()
	var/list/research_projects = list()
	var/list/anomaly_effects = list()
	var/list/interaction_history = list()
	var/list/containment_protocols = list()
	var/reproduction_count = 0
	var/list/environmental_changes = list()
	var/list/communication_logs = list()
	var/last_breach = 0
	var/containment_class = "safe"
	var/containment_effectiveness = 1.0
	var/research_value = 100
	var/threat_level = 1

/datum/scp_instance/New(var/id, var/obj/O)
	scp_id = id
	if(O)
		update_status(O)

/datum/scp_instance/proc/update_status(var/obj/O)
	if(O)
		// Update containment status based on object state
		containment_status = "contained" // Simplified containment status

		// Update containment health
		containment_health = 100 // Simplified containment health

		// Update current state
		current_state = "normal" // Simplified current state

		// Check for breaches
		if(containment_health < 50 && containment_status != "breached")
			containment_status = "breached"
			last_breach = world.time
			add_breach_record()

		// Update containment effectiveness
		containment_effectiveness = containment_health / 100

/datum/scp_instance/proc/add_breach_record()
	var/list/breach_record = list(
		"timestamp" = world.time,
		"containment_health" = containment_health,
		"location" = "Unknown",
		"severity" = "Unknown"
	)
	breach_history += breach_record

/datum/scp_instance/proc/add_interaction_record(var/mob/user, var/interaction_type)
	var/list/interaction_record = list(
		"timestamp" = world.time,
		"user" = user ? user.name : "Unknown",
		"interaction_type" = interaction_type,
		"scp_id" = scp_id
	)
	interaction_history += interaction_record

/datum/scp_instance/proc/add_communication_log(var/message, var/source)
	var/list/communication_record = list(
		"timestamp" = world.time,
		"message" = message,
		"source" = source,
		"scp_id" = scp_id
	)
	communication_logs += communication_record

// Research Project Datum
/datum/research_project
	var/project_id
	var/project_name
	var/description
	var/progress = 0
	var/max_progress = 100
	var/research_team = list()
	var/start_time = 0
	var/estimated_completion = 0
	var/research_funding = 0
	var/list/discoveries = list()
	var/research_status = "active"
	var/priority_level = 1
	var/list/requirements = list()
	var/list/dependencies = list()

/datum/research_project/New(var/id, var/name, var/desc)
	project_id = id
	project_name = name
	description = desc
	start_time = world.time

/datum/research_project/proc/update_progress()
	// Update research progress based on team activity
	if(research_status == "active")
		var/time_elapsed = world.time - start_time
		var/base_progress = time_elapsed / 36000 // 1% per hour

		// Apply team efficiency bonus
		var/team_efficiency = 1.0
		for(var/member in research_team)
			// Calculate individual efficiency based on skills
			team_efficiency += 0.1 // Simplified

		progress = min(max_progress, base_progress * team_efficiency)

		// Check for completion
		if(progress >= max_progress)
			research_status = "completed"
			add_discovery()

/datum/research_project/proc/add_discovery()
	var/list/discovery = list(
		"timestamp" = world.time,
		"project_id" = project_id,
		"discovery_type" = "research_completion",
		"description" = "Research project completed"
	)
	discoveries += discovery

// Containment Protocol Datum
/datum/containment_protocol
	var/protocol_id
	var/protocol_name
	var/description
	var/effectiveness = 1.0
	var/activation_cost = 0
	var/maintenance_cost = 0
	var/list/requirements = list()
	var/list/effects = list()
	var/protocol_status = "active"
	var/last_maintenance = 0
	var/next_maintenance = 0

/datum/containment_protocol/New(var/id, var/name, var/desc)
	protocol_id = id
	protocol_name = name
	description = desc
	last_maintenance = world.time
	next_maintenance = world.time + 36000 // 1 hour

/datum/containment_protocol/proc/update_effectiveness()
	// Update protocol effectiveness based on maintenance
	if(world.time > next_maintenance)
		effectiveness = max(0, effectiveness - 0.1) // Degrade over time
		next_maintenance = world.time + 36000

	// Check if protocol needs maintenance
	if(effectiveness < 0.5)
		protocol_status = "maintenance_required"

/datum/containment_protocol/proc/perform_maintenance()
	effectiveness = 1.0
	last_maintenance = world.time
	next_maintenance = world.time + 36000
	protocol_status = "active"

// Anomaly Effect Datum
/datum/anomaly_effect
	var/effect_id
	var/effect_name
	var/description
	var/effect_type = "passive"
	var/effect_strength = 1.0
	var/effect_radius = 1
	var/duration = -1 // -1 for permanent
	var/start_time = 0
	var/list/affected_areas = list()
	var/list/affected_objects = list()
	var/effect_status = "active"

/datum/anomaly_effect/New(var/id, var/name, var/desc)
	effect_id = id
	effect_name = name
	description = desc
	start_time = world.time

/datum/anomaly_effect/proc/update_effect()
	// Update anomaly effect
	if(duration > 0 && world.time > start_time + duration)
		effect_status = "expired"
		return

	// Apply effect to affected areas and objects
	for(var/area/A in affected_areas)
		apply_area_effect(A)

	for(var/obj/O in affected_objects)
		apply_object_effect(O)

/datum/anomaly_effect/proc/apply_area_effect(var/area/A)
	// Apply effect to area (simplified)
	if(A && effect_status == "active")
		// Modify area properties based on effect type
		switch(effect_type)
			if("temperature")
				// Modify temperature
				return
			if("radiation")
				// Modify radiation levels
				return
			if("reality")
				// Modify reality properties
				return

/datum/anomaly_effect/proc/apply_object_effect(var/obj/O)
	// Apply effect to object (simplified)
	if(O && effect_status == "active")
		// Modify object properties based on effect type
		switch(effect_type)
			if("corruption")
				// Corrupt object
				return
			if("enhancement")
				// Enhance object
				return
			if("transformation")
				// Transform object
				return

// Environmental Change Datum
/datum/environmental_change
	var/change_id
	var/change_name
	var/description
	var/change_type = "permanent"
	var/change_strength = 1.0
	var/affected_area = null
	var/start_time = 0
	var/duration = -1 // -1 for permanent
	var/list/change_effects = list()
	var/change_status = "active"

/datum/environmental_change/New(var/id, var/name, var/desc)
	change_id = id
	change_name = name
	description = desc
	start_time = world.time

/datum/environmental_change/proc/update_change()
	// Update environmental change
	if(duration > 0 && world.time > start_time + duration)
		change_status = "expired"
		return

	// Apply change effects
	if(affected_area && change_status == "active")
		apply_change_effects(affected_area)

/datum/environmental_change/proc/apply_change_effects(var/area/A)
	// Apply environmental change effects (simplified)
	if(A)
		switch(change_type)
			if("temperature")
				// Modify area temperature
				return
			if("atmosphere")
				// Modify atmospheric composition
				return
			if("gravity")
				// Modify gravity
				return
			if("reality")
				// Modify reality properties
				return

// SCP Persistence Verbs
/mob/proc/view_scp_persistence()
	set name = "View SCP Persistence"
	set category = "SCP"

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, "<span class='warning'>SCP Persistence system not available.</span>")
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/message = "<h2>SCP Persistence Status</h2>"
	message += "<b>Global Containment Stability:</b> [manager.global_containment_stability]%<br>"
	message += "<b>Active Breaches:</b> [manager.active_breaches]<br>"
	message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
	message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br><br>"

	message += "<h3>SCP Instances ([manager.scp_instances.len])</h3>"
	for(var/scp_id in manager.scp_instances)
		var/datum/scp_instance/instance = manager.scp_instances[scp_id]
		message += "<b>[scp_id]:</b> [instance.containment_status] ([instance.containment_health]% health)<br>"

	message += "<h3>Research Projects ([manager.research_projects.len])</h3>"
	for(var/project_id in manager.research_projects)
		var/datum/research_project/project = manager.research_projects[project_id]
		message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/proc/manage_scp_persistence()
	set name = "Manage SCP Persistence"
	set category = "SCP"

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to manage SCP persistence.</span>")
		return

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, "<span class='warning'>SCP Persistence system not available.</span>")
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/action = input(src, "Choose an action:", "SCP Persistence Management") as null|anything in list(
		"Save SCP Data",
		"Load SCP Data",
		"Reset SCP Data",
		"View Detailed Status"
	)

	switch(action)
		if("Save SCP Data")
			manager.save_scp_data()
			to_chat(src, "<span class='notice'>SCP data saved successfully.</span>")

		if("Load SCP Data")
			manager.load_scp_data()
			to_chat(src, "<span class='notice'>SCP data loaded successfully.</span>")

		if("Reset SCP Data")
			if(alert(src, "Are you sure you want to reset all SCP persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.scp_instances = list()
				manager.research_projects = list()
				manager.containment_protocols = list()
				manager.anomaly_effects = list()
				manager.communication_logs = list()
				manager.environmental_changes = list()
				to_chat(src, "<span class='notice'>SCP persistence data reset.</span>")

		if("View Detailed Status")
			view_scp_persistence()
