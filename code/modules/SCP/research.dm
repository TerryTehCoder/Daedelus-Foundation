//This file contains the core data structures for the SCP research system.

SUBSYSTEM_DEF(research)
	name = "Research"
	init_order = INIT_ORDER_RESEARCH
	var/list/scp_definitions = list()
	var/list/unlocked_scps = list()
	var/list/all_projects = list()
	var/research_points = 0
	var/logistics_points = 0

/datum/controller/subsystem/research/Initialize()
	..()
	load_scp_definitions()
	log_world("SCP Research Subsystem Initialized.")
	START_PROCESSING(SSobj, src)

/datum/controller/subsystem/research/proc/add_scp_definition(datum/scp_definition/def)
	if(!istype(def))
		return

	for(var/datum/scp_definition/d in scp_definitions)
		if(d.id_tag == def.id_tag)
			return

	scp_definitions.Add(def)

	for(var/datum/scp_test/test in def.tests)
		var/datum/research_project/p = new()
		p.project_name = test.name
		p.scp_id = def.id_tag
		p.description = test.description
		p.test = test
		all_projects.Add(p)

/datum/controller/subsystem/research/proc/requisition_scp(scp_id, mob/user)
	var/datum/scp_definition/def
	for(var/datum/scp_definition/d in scp_definitions)
		if(d.id_tag == scp_id)
			def = d
			break
	if(!def)
		to_chat(user, span_warning("Invalid SCP ID."))
		return

	if(def.id_tag in unlocked_scps)
		to_chat(user, span_warning("This SCP is already unlocked."))
		return

	if(research_points < def.cost)
		to_chat(user, span_warning("Not enough research points."))
		return

	research_points -= def.cost
	unlocked_scps.Add(def.id_tag)

	var/datum/supply_order/spawning_order = new()
	spawning_order.pack = new /datum/supply_pack/scp_containment()
	spawning_order.pack.name = "SCP-[def.id_tag] Containment Unit"
	spawning_order.pack.cost = 0
	spawning_order.pack.contains = list("/obj/structure/closet/crate/secure/containment/[def.id_tag]")
	spawning_order.orderer_ckey = user.ckey
	SSshuttle.shopping_list.Add(spawning_order)

	to_chat(user, span_notice("SCP-[def.id_tag] requisitioned for testing. It will be delivered to the logistics bay shortly."))
	SSblackbox.record_feedback("nested tally", "scp_purchased", 1, list(def.id_tag))
	message_admins("[key_name(user)] has purchased SCP-[def.id_tag].")

/datum/controller/subsystem/research/proc/submit_report(project_id, manual_report, mob/user)
	var/datum/research_project/project
	for(var/datum/research_project/p in all_projects)
		if(p.id == project_id)
			project = p
			break
	if(!project)
		to_chat(user, span_warning("Invalid project ID."))
		return

	var/datum/scp_test_report/report = new()
	report.project = project
	report.submitter = user.ckey
	report.manual_report = manual_report
	report.timestamp = world.time

	project.report = report
	project.status = "REPORT_SUBMITTED"

	research_points += project.test.reward_rp
	logistics_points += project.test.reward_lp
	if(manual_report)
		research_points += 5

	to_chat(user, span_notice("You have successfully submitted the test report."))
	SSblackbox.record_feedback("nested tally", "scp_report_submitted", 1, list(project.scp_id, project.project_name))
	message_admins("[key_name(user)] has submitted a test report for SCP-[project.scp_id]: [project.project_name].")

/datum/controller/subsystem/research/process()
	if(prob(10)) // 10% chance every tick to audit a report
		var/list/unaudited_projects = list()
		for(var/datum/research_project/p in all_projects)
			if(p.status == "REPORT_SUBMITTED" && !p.report.audited)
				unaudited_projects.Add(p)

		if(unaudited_projects.len)
			var/datum/research_project/project_to_audit = pick(unaudited_projects)
			project_to_audit.report.audited = TRUE

			if(!project_to_audit.test) // Custom tests are not auditable for now
				project_to_audit.status = "COMPLETED"
				return

			var/atom/movable/scp_object
			for(var/datum/scp/scp_instance in world)
				if(scp_instance.designation == project_to_audit.scp_id)
					scp_object = scp_instance.parent
					break

			if(!scp_object)
				message_admins("AUDIT SKIPPED: Could not find SCP-[project_to_audit.scp_id] object for audit. Report passed by default.")
				project_to_audit.status = "COMPLETED"
				return

			var/test_proc = project_to_audit.test.check_completion
			if(!test_proc)
				project_to_audit.status = "COMPLETED"
				return

			var/result = call(scp_object, test_proc)()

			if(!result)
				research_points -= project_to_audit.test.reward_rp * 2
				logistics_points -= project_to_audit.test.reward_lp * 2
				message_admins("AUDIT FAILED: [project_to_audit.report.submitter] submitted a fraudulent report for SCP-[project_to_audit.scp_id]: [project_to_audit.project_name].")
				project_to_audit.status = "AUDIT_FAILED"
				// TODO: Send a fax
			else
				message_admins("AUDIT PASSED: [project_to_audit.report.submitter]'s report for SCP-[project_to_audit.scp_id]: [project_to_audit.project_name] was verified.")
				project_to_audit.status = "COMPLETED"


//Datum that defines a single SCP's properties for the research system.
/datum/scp_definition
	var/id_tag = "000"
	var/name = "UNKNOWN"
	var/cost = 0 //Research points to unlock
	var/list/tests = list()
	var/list/traits = list()

//Datum that defines a single test that can be performed on an SCP.
/datum/supply_pack/scp_containment
	name = "SCP Containment Unit"
	cost = 0
	contains = list()
	group = "SCPs"

/datum/research_project
	var/id
	var/project_name
	var/scp_id
	var/proposer_ckey
	var/description
	var/status = "PROPOSED"
	var/authorizer_ckey
	var/digital_signature
	var/authorization_notes
	var/attachment_uid
	var/is_custom = FALSE
	var/datum/scp_test/test
	var/datum/scp_test_report/report

/datum/research_project/New()
	..()
	id = md5("[world.time][rand(1, 1000)]")

/datum/scp_test_report
	var/datum/research_project/project
	var/submitter
	var/manual_report
	var/timestamp
	var/audited = FALSE

/datum/scp_test
	var/name = "Unnamed Test"
	var/description = "No description."
	var/hypothesis = "No hypothesis."
	var/procedure = "No procedure."
	var/risks = "No risks."
	var/required_equipment = "None."
	var/reward_rp = 10
	var/reward_lp = 5
	var/repeatable = FALSE
	var/check_completion // Holds a proc path
