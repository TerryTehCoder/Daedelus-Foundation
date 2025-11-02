SUBSYSTEM_DEF(dls)
	name = "Data Listening System"
	wait = 50 // 5 seconds
	priority = FIRE_PRIORITY_DLS
	flags = SS_KEEP_TIMING

	/// The manager component, usually attached to the AI core.
	var/datum/component/dls_manager/manager

/datum/controller/subsystem/dls/Initialize()
	// We need to find the DLS manager component.
	var/list/ais = active_ais()
	for(var/mob/living/silicon/ai/ai in ais)
		manager = ai.GetComponent(/datum/component/dls_manager)
		if(manager)
			break

	if(!manager)
		log_game("DLS subsystem could not find the dls_manager component. The AI may not have spawned or is missing the component.")
		return 0 // Don't run if there's no manager.

	log_game("DLS subsystem initialized successfully.")
	return ..()

/datum/controller/subsystem/dls/fire()
	if(manager)
		manager.process_events()
		manager.poll_suit_sensors()
		manager.update_isolation_scores()
