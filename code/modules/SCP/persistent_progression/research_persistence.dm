// Research Persistence System
// Tracks research projects, discoveries, publications, and scientific progress

SUBSYSTEM_DEF(research_persistence)
	name = "Research Persistence"
	wait = 600 // 1 minute
	priority = FIRE_PRIORITY_INPUT

	var/datum/research_persistence_manager/manager

/datum/research_persistence_manager
	var/list/research_projects = list() // project_id -> research_project
	var/list/scientific_discoveries = list() // discovery_id -> scientific_discovery
	var/list/publications = list() // publication_id -> publication
	var/list/research_facilities = list() // facility_id -> research_facility
	var/list/research_grants = list() // grant_id -> research_grant
	var/list/research_statistics = list() // stat_name -> value

	// Global research metrics
	var/total_research_projects = 0
	var/completed_projects = 0
	var/research_budget = 5000000
	var/research_efficiency = 1.0
	var/scientific_breakthroughs = 0
	var/publication_count = 0
	var/research_staff_count = 0

/datum/research_persistence_project
	var/project_id
	var/project_name
	var/project_description
	var/research_field
	var/lead_researcher
	var/list/researchers = list()
	var/progress = 0
	var/budget_allocated = 0
	var/budget_used = 0
	var/start_date
	var/estimated_completion
	var/actual_completion
	var/status = "ACTIVE" // ACTIVE, COMPLETED, CANCELLED, ON_HOLD
	var/priority = 1
	var/list/discoveries = list()
	var/list/publications = list()
	var/research_notes = ""

/datum/research_persistence_project/New(var/project_id, var/project_name, var/project_description, var/research_field, var/lead_researcher)
		src.project_id = project_id
		src.project_name = project_name
		src.project_description = project_description
		src.research_field = research_field
		src.lead_researcher = lead_researcher
		src.start_date = world.time

/datum/research_scientific_discovery
	var/discovery_id
	var/discovery_name
	var/discovery_description
	var/discovery_type
	var/research_field
	var/discoverer_ckey
	var/discovery_date
	var/significance_level = 1
	var/list/related_projects = list()
	var/list/applications = list()
	var/patent_status = "NONE" // NONE, PENDING, GRANTED, REJECTED
	var/commercial_value = 0

/datum/research_scientific_discovery/New(var/discovery_id, var/discovery_name, var/discovery_description, var/discovery_type, var/research_field, var/discoverer_ckey)
		src.discovery_id = discovery_id
		src.discovery_name = discovery_name
		src.discovery_description = discovery_description
		src.discovery_type = discovery_type
		src.research_field = research_field
		src.discoverer_ckey = discoverer_ckey
		src.discovery_date = world.time

/datum/publication
	var/publication_id
	var/publication_title
	var/publication_abstract
	var/authors = list()
	var/journal_name
	var/publication_date
	var/impact_factor = 1.0
	var/citation_count = 0
	var/peer_review_status = "PENDING" // PENDING, APPROVED, REJECTED, PUBLISHED
	var/doi_number = ""

/datum/publication/New(var/publication_id, var/publication_title, var/publication_abstract, var/authors, var/journal_name)
		src.publication_id = publication_id
		src.publication_title = publication_title
		src.publication_abstract = publication_abstract
		src.authors = authors
		src.journal_name = journal_name
		src.publication_date = world.time

/datum/research_persistence_facility
	var/facility_id
	var/facility_name
	var/facility_type
	var/location
	var/capacity = 100
	var/current_occupancy = 0
	var/equipment_quality = 1.0
	var/maintenance_level = 100
	var/list/active_projects = list()
	var/list/equipment = list()
	var/security_level = 1

/datum/research_persistence_facility/New(var/facility_id, var/facility_name, var/facility_type, var/location)
		src.facility_id = facility_id
		src.facility_name = facility_name
		src.facility_type = facility_type
		src.location = location

/datum/research_grant
	var/grant_id
	var/grant_name
	var/granting_organization
	var/amount = 0
	var/research_field
	var/recipient_ckey
	var/grant_date
	var/expiration_date
	var/status = "ACTIVE" // ACTIVE, EXPIRED, CANCELLED, COMPLETED
	var/requirements = list()
	var/progress_reports = list()

/datum/research_grant/New(var/grant_id, var/grant_name, var/granting_organization, var/amount, var/research_field, var/recipient_ckey)
		src.grant_id = grant_id
		src.grant_name = grant_name
		src.granting_organization = granting_organization
		src.amount = amount
		src.research_field = research_field
		src.recipient_ckey = recipient_ckey
		src.grant_date = world.time

// Research Persistence Manager Methods
/datum/research_persistence_manager/proc/process_research()
	// Update research statistics
	update_research_statistics()

	// Process active projects
	process_projects()

	// Update research facilities
	update_facilities()

	// Process grants
	process_grants()

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_research_data()

/datum/research_persistence_manager/proc/add_research_project(var/project_name, var/project_description, var/research_field, var/lead_researcher, var/budget = 0, var/priority = 1)
	var/project_id = "project_[world.time]"
	var/datum/research_persistence_project/project = new /datum/research_persistence_project(project_id, project_name, project_description, research_field, lead_researcher)
	project.budget_allocated = budget
	project.priority = priority

	research_projects[project_id] = project
	total_research_projects++
	return project

/datum/research_persistence_manager/proc/add_scientific_discovery(var/discovery_name, var/discovery_description, var/discovery_type, var/research_field, var/discoverer_ckey, var/significance_level = 1)
	var/discovery_id = "discovery_[world.time]"
	var/datum/research_scientific_discovery/discovery = new /datum/research_scientific_discovery(discovery_id, discovery_name, discovery_description, discovery_type, research_field, discoverer_ckey)
	discovery.significance_level = significance_level

	scientific_discoveries[discovery_id] = discovery
	scientific_breakthroughs++
	return discovery

/datum/research_persistence_manager/proc/add_publication(var/publication_title, var/publication_abstract, var/authors, var/journal_name, var/impact_factor = 1.0)
	var/publication_id = "pub_[world.time]"
	var/datum/publication/publication = new /datum/publication(publication_id, publication_title, publication_abstract, authors, journal_name)
	publication.impact_factor = impact_factor

	publications[publication_id] = publication
	publication_count++
	return publication

/datum/research_persistence_manager/proc/add_research_facility(var/facility_name, var/facility_type, var/location, var/capacity = 100, var/security_level = 1)
	var/facility_id = "facility_[world.time]"
	var/datum/research_persistence_facility/facility = new /datum/research_persistence_facility(facility_id, facility_name, facility_type, location)
	facility.capacity = capacity
	facility.security_level = security_level

	research_facilities[facility_id] = facility
	return facility

/datum/research_persistence_manager/proc/add_research_grant(var/grant_name, var/granting_organization, var/amount, var/research_field, var/recipient_ckey)
	var/grant_id = "grant_[world.time]"
	var/datum/research_grant/grant = new /datum/research_grant(grant_id, grant_name, granting_organization, amount, research_field, recipient_ckey)

	research_grants[grant_id] = grant
	return grant

/datum/research_persistence_manager/proc/update_research_statistics()
	research_statistics["total_projects"] = total_research_projects
	research_statistics["completed_projects"] = completed_projects
	research_statistics["active_projects"] = research_projects.len
	research_statistics["scientific_discoveries"] = scientific_discoveries.len
	research_statistics["publications"] = publication_count
	research_statistics["research_budget"] = research_budget
	research_statistics["research_efficiency"] = research_efficiency
	research_statistics["research_staff"] = research_staff_count
	research_statistics["facilities"] = research_facilities.len
	research_statistics["grants"] = research_grants.len

/datum/research_persistence_manager/proc/process_projects()
	for(var/project_id in research_projects)
		var/datum/research_persistence_project/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			// Simulate research progress
			var/progress_chance = 5 + (project.priority * 2) // Higher priority = faster progress
			if(prob(progress_chance))
				project.progress = min(100, project.progress + rand(1, 5))

			// Check for completion
			if(project.progress >= 100)
				project.status = "COMPLETED"
				project.actual_completion = world.time
				completed_projects++

				// Generate discovery chance
				if(prob(30)) // 30% chance of discovery upon completion
					var/discovery_name = "Discovery from [project.project_name]"
					var/discovery_description = "A significant discovery made during the completion of [project.project_name]"
					add_scientific_discovery(discovery_name, discovery_description, "EXPERIMENTAL", project.research_field, project.lead_researcher)

/datum/research_persistence_manager/proc/update_facilities()
	for(var/facility_id in research_facilities)
		var/datum/research_persistence_facility/facility = research_facilities[facility_id]

		// Simulate facility wear and tear
		if(prob(10)) // 10% chance to reduce maintenance
			facility.maintenance_level = max(0, facility.maintenance_level - rand(1, 3))

		// Update equipment quality based on maintenance
		if(facility.maintenance_level < 50)
			facility.equipment_quality = max(0.5, facility.equipment_quality - 0.01)

/datum/research_persistence_manager/proc/process_grants()
	for(var/grant_id in research_grants)
		var/datum/research_grant/grant = research_grants[grant_id]
		if(grant.status == "ACTIVE")
			// Check for expiration
			if(grant.expiration_date && world.time > grant.expiration_date)
				grant.status = "EXPIRED"

/datum/research_persistence_manager/proc/save_research_data()
	var/list/data = list()

	// Save research projects
	data["research_projects"] = list()
	for(var/project_id in research_projects)
		var/datum/research_persistence_project/project = research_projects[project_id]
		data["research_projects"][project_id] = list(
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"lead_researcher" = project.lead_researcher,
			"researchers" = project.researchers,
			"progress" = project.progress,
			"budget_allocated" = project.budget_allocated,
			"budget_used" = project.budget_used,
			"start_date" = project.start_date,
			"estimated_completion" = project.estimated_completion,
			"actual_completion" = project.actual_completion,
			"status" = project.status,
			"priority" = project.priority,
			"discoveries" = project.discoveries,
			"publications" = project.publications,
			"research_notes" = project.research_notes
		)

	// Save scientific discoveries
	data["scientific_discoveries"] = list()
	for(var/discovery_id in scientific_discoveries)
		var/datum/research_scientific_discovery/discovery = scientific_discoveries[discovery_id]
		data["scientific_discoveries"][discovery_id] = list(
			"discovery_name" = discovery.discovery_name,
			"discovery_description" = discovery.discovery_description,
			"discovery_type" = discovery.discovery_type,
			"research_field" = discovery.research_field,
			"discoverer_ckey" = discovery.discoverer_ckey,
			"discovery_date" = discovery.discovery_date,
			"significance_level" = discovery.significance_level,
			"related_projects" = discovery.related_projects,
			"applications" = discovery.applications,
			"patent_status" = discovery.patent_status,
			"commercial_value" = discovery.commercial_value
		)

	// Save publications
	data["publications"] = list()
	for(var/publication_id in publications)
		var/datum/publication/publication = publications[publication_id]
		data["publications"][publication_id] = list(
			"publication_title" = publication.publication_title,
			"publication_abstract" = publication.publication_abstract,
			"authors" = publication.authors,
			"journal_name" = publication.journal_name,
			"publication_date" = publication.publication_date,
			"impact_factor" = publication.impact_factor,
			"citation_count" = publication.citation_count,
			"peer_review_status" = publication.peer_review_status,
			"doi_number" = publication.doi_number
		)

	// Save research facilities
	data["research_facilities"] = list()
	for(var/facility_id in research_facilities)
		var/datum/research_persistence_facility/facility = research_facilities[facility_id]
		data["research_facilities"][facility_id] = list(
			"facility_name" = facility.facility_name,
			"facility_type" = facility.facility_type,
			"location" = facility.location,
			"capacity" = facility.capacity,
			"current_occupancy" = facility.current_occupancy,
			"equipment_quality" = facility.equipment_quality,
			"maintenance_level" = facility.maintenance_level,
			"active_projects" = facility.active_projects,
			"equipment" = facility.equipment,
			"security_level" = facility.security_level
		)

	// Save research grants
	data["research_grants"] = list()
	for(var/grant_id in research_grants)
		var/datum/research_grant/grant = research_grants[grant_id]
		data["research_grants"][grant_id] = list(
			"grant_name" = grant.grant_name,
			"granting_organization" = grant.granting_organization,
			"amount" = grant.amount,
			"research_field" = grant.research_field,
			"recipient_ckey" = grant.recipient_ckey,
			"grant_date" = grant.grant_date,
			"expiration_date" = grant.expiration_date,
			"status" = grant.status,
			"requirements" = grant.requirements,
			"progress_reports" = grant.progress_reports
		)

	// Save global statistics
	data["global_stats"] = list(
		"total_research_projects" = total_research_projects,
		"completed_projects" = completed_projects,
		"research_budget" = research_budget,
		"research_efficiency" = research_efficiency,
		"scientific_breakthroughs" = scientific_breakthroughs,
		"publication_count" = publication_count,
		"research_staff_count" = research_staff_count
	)

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/research_persistence.json")
	S["data"] << json_data

/datum/research_persistence_manager/proc/load_research_data()
	var/savefile/S = new /savefile("data/research_persistence.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load research projects
	if(data["research_projects"])
		for(var/project_id in data["research_projects"])
			var/list/project_data = data["research_projects"][project_id]
			var/datum/research_persistence_project/project = new /datum/research_persistence_project(project_id, project_data["project_name"], project_data["project_description"], project_data["research_field"], project_data["lead_researcher"])
			project.researchers = project_data["researchers"]
			project.progress = project_data["progress"]
			project.budget_allocated = project_data["budget_allocated"]
			project.budget_used = project_data["budget_used"]
			project.start_date = project_data["start_date"]
			project.estimated_completion = project_data["estimated_completion"]
			project.actual_completion = project_data["actual_completion"]
			project.status = project_data["status"]
			project.priority = project_data["priority"]
			project.discoveries = project_data["discoveries"]
			project.publications = project_data["publications"]
			project.research_notes = project_data["research_notes"]
			research_projects[project_id] = project
			if(project.status == "COMPLETED")
				completed_projects++

	// Load scientific discoveries
	if(data["scientific_discoveries"])
		for(var/discovery_id in data["scientific_discoveries"])
			var/list/discovery_data = data["scientific_discoveries"][discovery_id]
			var/datum/research_scientific_discovery/discovery = new /datum/research_scientific_discovery(discovery_id, discovery_data["discovery_name"], discovery_data["discovery_description"], discovery_data["discovery_type"], discovery_data["research_field"], discovery_data["discoverer_ckey"])
			discovery.discovery_date = discovery_data["discovery_date"]
			discovery.significance_level = discovery_data["significance_level"]
			discovery.related_projects = discovery_data["related_projects"]
			discovery.applications = discovery_data["applications"]
			discovery.patent_status = discovery_data["patent_status"]
			discovery.commercial_value = discovery_data["commercial_value"]
			scientific_discoveries[discovery_id] = discovery

	// Load publications
	if(data["publications"])
		for(var/publication_id in data["publications"])
			var/list/publication_data = data["publications"][publication_id]
			var/datum/publication/publication = new /datum/publication(publication_id, publication_data["publication_title"], publication_data["publication_abstract"], publication_data["authors"], publication_data["journal_name"])
			publication.publication_date = publication_data["publication_date"]
			publication.impact_factor = publication_data["impact_factor"]
			publication.citation_count = publication_data["citation_count"]
			publication.peer_review_status = publication_data["peer_review_status"]
			publication.doi_number = publication_data["doi_number"]
			publications[publication_id] = publication

	// Load research facilities
	if(data["research_facilities"])
		for(var/facility_id in data["research_facilities"])
			var/list/facility_data = data["research_facilities"][facility_id]
			var/datum/research_persistence_facility/facility = new /datum/research_persistence_facility(facility_id, facility_data["facility_name"], facility_data["facility_type"], facility_data["location"])
			facility.capacity = facility_data["capacity"]
			facility.current_occupancy = facility_data["current_occupancy"]
			facility.equipment_quality = facility_data["equipment_quality"]
			facility.maintenance_level = facility_data["maintenance_level"]
			facility.active_projects = facility_data["active_projects"]
			facility.equipment = facility_data["equipment"]
			facility.security_level = facility_data["security_level"]
			research_facilities[facility_id] = facility

	// Load research grants
	if(data["research_grants"])
		for(var/grant_id in data["research_grants"])
			var/list/grant_data = data["research_grants"][grant_id]
			var/datum/research_grant/grant = new /datum/research_grant(grant_id, grant_data["grant_name"], grant_data["granting_organization"], grant_data["amount"], grant_data["research_field"], grant_data["recipient_ckey"])
			grant.grant_date = grant_data["grant_date"]
			grant.expiration_date = grant_data["expiration_date"]
			grant.status = grant_data["status"]
			grant.requirements = grant_data["requirements"]
			grant.progress_reports = grant_data["progress_reports"]
			research_grants[grant_id] = grant

	// Load global statistics
	if(data["global_stats"])
		var/list/stats = data["global_stats"]
		total_research_projects = stats["total_research_projects"]
		research_budget = stats["research_budget"]
		research_efficiency = stats["research_efficiency"]
		scientific_breakthroughs = stats["scientific_breakthroughs"]
		publication_count = stats["publication_count"]
		research_staff_count = stats["research_staff_count"]

// Subsystem initialization
/datum/controller/subsystem/research_persistence/Initialize()
	manager = new /datum/research_persistence_manager()
	manager.load_research_data()
	return ..()

/datum/controller/subsystem/research_persistence/fire()
	if(manager)
		manager.process_research()
