//This file contains the core data structures for the SCP research system.

//The global handler for all SCP research activities.
/datum/controller/subsystem/research
	name = "Research"
	init_order = SS_INIT_RESEARCH
	var/list/scp_definitions = list()
	var/list/unlocked_scps = list()
	var/list/compoetedptdstests = list()
	var/research_points = 0
	var/logistics_points = 0

/datum/controller/subsystem/research/Initialize()
	..()
	SSresearch = src
	//TODO: Load SCP definitions from a config file or hardcoded list.
	log_debug("SCP Research Subsystem Initialized.")
	START_PROCESSING(SSobj, src)

/datum/controller/subsystem/research/proc/purchase_scp(scp_id, mob/user)
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

/datum/controller/subsystem/research/proc/submit_report(scp_id, test_name, manual_report, mob/user)
	var/datum/scp_definition/def
	for(var/datum/scp_definition/d in scp_definitions)
		if(d.id_tag == scp_id)
			def = d
			break
	if(!def)
		to_chat(user, span_warning("Invalid SCP ID."))
		return

	var/datum/scp_test/test
	for(var/datum/scp_test/t in def.tests)
		if(t.name == test_name)
			test = t
			break
	if(!test)
		to_chat(user, span_warning("Invalid test name."))
		return

	var/datum/scp_test_report/report = new()
	report.test = test
	report.scp_id = scp_id
	report.submitter = user.ckey
	report.manual_report = manual_report
	report.timestamp = world.time

	completed_tests.Add(report)

	research_points += test.reward_rp
	logistics_points += test.reward_lp
	if(manual_report)
		research_points += 5

	to_chat(user, span_notice("You have successfully submitted the test report."))
	SSblackbox.record_feedback("nested tally", "scp_report_submitted", 1, list(def.id_tag, test.name))
	message_admins("[key_name(user)] has submitted a test report for SCP-[def.id_tag]: [test.name].")

/datum/controller/subsystem/research/process()
	if(prob(10)) // 10% chance every tick to audit a report
		var/list/unaudited_reports = list()
		for(var/datum/scp_test_report/r in completed_tests)
			if(!r.audited)
				unaudited_reports.Add(r)

		if(unaudited_reports.len)
			var/datum/scp_test_report/report_to_audit = pick(unaudited_reports)
			report_to_audit.audited = TRUE

			var/test_proc = report_to_audit.test.check_completion
			var/result = call(test_proc)()

			if(!result)
				research_points -= report_to_audit.test.reward_rp * 2
				logistics_points -= report_to_audit.test.reward_lp * 2
				message_admins("AUDIT FAILED: [report_to_audit.submitter] submitted a fraudulent report for SCP-[report_to_audit.scp_id]: [report_to_audit.test.name].")
				// TODO: Send a fax
			else
				message_admins("AUDIT PASSED: [report_to_audit.submitter]'s report for SCP-[report_to_audit.scp_id]: [report_to_audit.test.name] was verified.")


//Datum that defines a single SCP's properties for the research system.
/datum/scp_definition
	var/id_tag = "000"
	var/name = "UNKNOWN"
	var/danger_tier = SCP_SAFE
	var/cost = 0 //Research points to unlock
	var/list/tests = list()
	var/list/traits = list()

//Datum that defines a single test that can be performed on an SCP.
/datum/supply_pack/scp_containment
	name = "SCP Containment Unit"
	cost = 0
	contains = list()
	amount = 1
	group = "SCPs"

/datum/scp_test_report
	var/datum/scp_test/test
	var/scp_id
	var/submitter
	var/manual_report
	var/timestamp
	var/audited = FALSE

/datum/scp_test
	var/name = "Unnamed Test"
	var/description = "No description."
	var/reward_rp = 10
	var/reward_lp = 5
	var/repeatable = FALSE
	var/proc/check_completion()
		return FALSE
