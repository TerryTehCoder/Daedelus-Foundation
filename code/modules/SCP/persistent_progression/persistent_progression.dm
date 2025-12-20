SUBSYSTEM_DEF(persistent_progression)
	name = "Persistent Progression"
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	init_order = INIT_ORDER_PERSISTENCE_PROGRESSION
	wait = 600 // 1 minute

	var/list/player_data = list()
	var/list/classes = list()
	var/list/factions = list()
	var/list/experience_sources = list()
	var/list/active_trackers = list()
	var/save_file_path = "data/persistent_progression/"
	var/round_start_time
	var/datum/achievement_manager/achievement_manager
	var/datum/reward_manager/reward_manager
	var/datum/player_analytics_manager/analytics_manager
	var/datum/achievement_integration/achievement_integration
	var/datum/job_integration/job_integration
	var/datum/faction_integration/faction_integration
	var/datum/persistent_progression_database_adapter/database_adapter
	var/use_database = TRUE // Set to FALSE to fall back to JSON storage

/datum/controller/subsystem/persistent_progression/Initialize()
	world.log << "Persistent Progression Subsystem: Initializing..."

	load_all_classes()
	load_all_factions()
	load_all_experience_sources()
	achievement_manager = new /datum/achievement_manager()
	reward_manager = new /datum/reward_manager()
	analytics_manager = new /datum/player_analytics_manager()
	achievement_integration = new /datum/achievement_integration()
	job_integration = new /datum/job_integration()
	initialize_faction_integration()

	// Initialize database adapter
	if(use_database)
		database_adapter = new /datum/persistent_progression_database_adapter()
		world.log << "Persistent Progression: Database adapter initialized"
	else
		world.log << "Persistent Progression: Using JSON storage (database disabled)"
	round_start_time = world.time

	// Register round end event
	SSticker.OnRoundend(CALLBACK(src, PROC_REF(process_round_end)))

	world.log << "Persistent Progression Subsystem: Initialized successfully with [classes.len] classes, [factions.len] factions, [experience_sources.len] experience sources, achievement system, reward system, analytics, achievement integration, job integration, and faction integration"

	return ..()

/datum/controller/subsystem/persistent_progression/proc/load_all_classes()
	world.log << "Persistent Progression: Loading classes..."
	classes["security"] = new /datum/persistent_class/security()
	classes["research"] = new /datum/persistent_class/research()
	classes["medical"] = new /datum/persistent_class/medical()
	classes["engineering"] = new /datum/persistent_class/engineering()
	classes["administrative"] = new /datum/persistent_class/administrative()
	classes["containment"] = new /datum/persistent_class/containment()
	world.log << "Persistent Progression: Loaded [classes.len] classes"

/datum/controller/subsystem/persistent_progression/proc/load_all_factions()
	world.log << "Persistent Progression: Loading factions..."
	factions["foundation"] = new /datum/persistent_faction/foundation()
	factions["goc"] = new /datum/persistent_faction/goc()
	factions["serpents_hand"] = new /datum/persistent_faction/serpents_hand()
	factions["chaos_insurgency"] = new /datum/persistent_faction/chaos_insurgency()
	factions["mcd"] = new /datum/persistent_faction/mcd()
	factions["uiu"] = new /datum/persistent_faction/uiu()
	world.log << "Persistent Progression: Loaded [factions.len] factions"

/datum/controller/subsystem/persistent_progression/proc/load_all_experience_sources()
	// Security sources
	experience_sources["security_combat"] = new /datum/experience_source/security_combat()
	experience_sources["security_arrest"] = new /datum/experience_source/security_arrest()
	experience_sources["security_protection"] = new /datum/experience_source/security_protection()
	experience_sources["security_breach_containment"] = new /datum/experience_source/security_breach_containment()
	experience_sources["security_scp_interaction"] = new /datum/experience_source/security_scp_interaction()

	// Research sources
	experience_sources["research_scp_study"] = new /datum/experience_source/research_scp_study()
	experience_sources["research_experiment"] = new /datum/experience_source/research_experiment()
	experience_sources["research_documentation"] = new /datum/experience_source/research_documentation()
	experience_sources["research_breakthrough"] = new /datum/experience_source/research_breakthrough()
	experience_sources["research_collaboration"] = new /datum/experience_source/research_collaboration()

	// Medical sources
	experience_sources["medical_treatment"] = new /datum/experience_source/medical_treatment()
	experience_sources["medical_surgery"] = new /datum/experience_source/medical_surgery()
	experience_sources["medical_revival"] = new /datum/experience_source/medical_revival()
	experience_sources["medical_diagnosis"] = new /datum/experience_source/medical_diagnosis()
	experience_sources["medical_prevention"] = new /datum/experience_source/medical_prevention()

	// Engineering sources
	experience_sources["engineering_repair"] = new /datum/experience_source/engineering_repair()
	experience_sources["engineering_construction"] = new /datum/experience_source/engineering_construction()
	experience_sources["engineering_maintenance"] = new /datum/experience_source/engineering_maintenance()
	experience_sources["engineering_emergency"] = new /datum/experience_source/engineering_emergency()
	experience_sources["engineering_innovation"] = new /datum/experience_source/engineering_innovation()

	// Administrative sources
	experience_sources["admin_coordination"] = new /datum/experience_source/admin_coordination()
	experience_sources["admin_communication"] = new /datum/experience_source/admin_communication()
	experience_sources["admin_decision_making"] = new /datum/experience_source/admin_decision_making()
	experience_sources["admin_crisis_management"] = new /datum/experience_source/admin_crisis_management()
	experience_sources["admin_team_success"] = new /datum/experience_source/admin_team_success()

	// Containment sources
	experience_sources["containment_scp_interaction"] = new /datum/experience_source/containment_scp_interaction()
	experience_sources["containment_breach_response"] = new /datum/experience_source/containment_breach_response()
	experience_sources["containment_procedure"] = new /datum/experience_source/containment_procedure()
	experience_sources["containment_research"] = new /datum/experience_source/containment_research()
	experience_sources["containment_innovation"] = new /datum/experience_source/containment_innovation()

	// Universal sources
	experience_sources["round_survival"] = new /datum/experience_source/round_survival()
	experience_sources["admin_award"] = new /datum/experience_source/admin_award()

/datum/controller/subsystem/persistent_progression/proc/get_player_data(ckey)
	if(!ckey)
		return null

	// Try database first if enabled
	if(use_database && database_adapter)
		var/datum/persistent_player_data/db_data = database_adapter.get_player_data(ckey)
		if(db_data)
			// Cache in memory for performance
			player_data[ckey] = db_data
			return db_data

		// Create new player in database
		var/player_name = "Unknown"
		for(var/client/C in GLOB.clients)
			if(C.ckey == ckey)
				player_name = C.prefs ? C.prefs.read_preference(/datum/preference/name/real_name) : "Unknown"
				break
		database_adapter.create_player_data(ckey, player_name)

		// Get the newly created data
		db_data = database_adapter.get_player_data(ckey)
		if(db_data)
			player_data[ckey] = db_data
			return db_data

	// Fall back to JSON storage
	if(!player_data[ckey])
		player_data[ckey] = load_player_data(ckey)
		if(!player_data[ckey])
			player_data[ckey] = new /datum/persistent_player_data(ckey)

	return player_data[ckey]

/datum/controller/subsystem/persistent_progression/proc/get_class(class_id)
	return classes[class_id]

/datum/controller/subsystem/persistent_progression/proc/get_faction(faction_id) as /datum/persistent_faction
	return factions[faction_id]

/datum/controller/subsystem/persistent_progression/proc/get_experience_source(source_id)
	return experience_sources[source_id]

/datum/controller/subsystem/persistent_progression/proc/save_player_data(ckey)
	var/datum/persistent_player_data/data = player_data[ckey]
	if(!data)
		return

	// Try database first if enabled
	if(use_database && database_adapter)
		database_adapter.save_player_data(ckey, data)
		return

	// Fall back to JSON storage
	var/list/save_data = list(
		"ckey" = ckey,
		"class_data" = data.class_data,
		"rank_data" = data.rank_data,
		"faction_data" = data.faction_data,
		"unlocked_items" = data.unlocked_items,
		"unlocked_titles" = data.unlocked_titles,
		"achievements" = data.achievements,
		"total_experience" = data.total_experience,
		"rounds_played" = data.rounds_played,
		"last_login" = world.time,
		"preferred_class" = data.preferred_class,
		"preferred_faction" = data.preferred_faction,
		"current_class_id" = data.current_class_id,
		"current_faction_id" = data.current_faction_id,
		"current_rank" = data.current_rank,
		"current_rank_name" = data.current_rank_name,
		"experience_sources" = data.experience_sources,
		"performance_metrics" = data.performance_metrics
	)

	var/json_data = json_encode(save_data)
	rustg_file_write(json_data, "[save_file_path][ckey].json")

/datum/controller/subsystem/persistent_progression/proc/load_player_data(ckey)
	var/file_path = "[save_file_path][ckey].json"
	if(!fexists(file_path))
		return null

	var/json_data = rustg_file_read(file_path)
	if(!json_data)
		return null

	var/list/load_data = json_decode(json_data)
	if(!load_data)
		return null

	var/datum/persistent_player_data/data = new /datum/persistent_player_data(ckey)
	data.class_data = load_data["class_data"] || list()
	data.rank_data = load_data["rank_data"] || list()
	data.faction_data = load_data["faction_data"] || list()
	data.unlocked_items = load_data["unlocked_items"] || list()
	data.unlocked_titles = load_data["unlocked_titles"] || list()
	data.achievements = load_data["achievements"] || list()
	data.total_experience = load_data["total_experience"] || 0
	data.rounds_played = load_data["rounds_played"] || 0
	data.last_login = load_data["last_login"] || world.time
	data.preferred_class = load_data["preferred_class"] || "security"
	data.preferred_faction = load_data["preferred_faction"] || "foundation"
	data.current_class_id = load_data["current_class_id"] || "security"
	data.current_faction_id = load_data["current_faction_id"] || "foundation"
	data.current_rank = load_data["current_rank"] || 0
	data.current_rank_name = load_data["current_rank_name"] || "Recruit"
	data.experience_sources = load_data["experience_sources"] || list()
	data.performance_metrics = load_data["performance_metrics"] || list()

	return data

/datum/controller/subsystem/persistent_progression/proc/award_experience(ckey, source_id, amount, reason)
	var/datum/persistent_player_data/data = get_player_data(ckey)
	if(!data)
		return 0

	var/datum/experience_source/source = get_experience_source(source_id)
	if(!source)
		return 0

	// Check if source is compatible with player's class
	if(!(data.current_class_id in source.compatible_classes))
		return 0

	// Check cooldown and max per round
	var/current_time = world.time
	var/source_count = 0
	for(var/list/source_data in data.experience_sources)
		if(source_data["source"] == source_id)
			source_count++
			if(source.cooldown_time > 0)
				var/time_diff = current_time - source_data["timestamp"]
				if(time_diff < source.cooldown_time)
					return 0

	if(source_count >= source.max_per_round)
		return 0

	// Award experience
	var/final_amount = amount > 0 ? amount : source.base_experience
	var/awarded = data.add_experience(final_amount, source_id, reason)

	// Save data
	save_player_data(ckey)

	return awarded

/datum/controller/subsystem/persistent_progression/proc/process_round_end()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind && H.ckey)
			var/datum/persistent_player_data/data = get_player_data(H.ckey)
			if(data)
				// Award round completion bonus
				award_experience(H.ckey, "round_survival", 200, "Round Completion Bonus")

				// Update rounds played
				data.rounds_played++

				// Save data
				save_player_data(H.ckey)

/datum/controller/subsystem/persistent_progression/fire()
	// Process any ongoing tasks
	return

// Database-specific methods
/datum/controller/subsystem/persistent_progression/proc/add_experience_to_database(ckey, source, amount, reason)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.add_experience(ckey, source, amount, reason)

/datum/controller/subsystem/persistent_progression/proc/unlock_achievement_in_database(ckey, achievement_id, progress = 0)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.unlock_achievement(ckey, achievement_id, progress)

/datum/controller/subsystem/persistent_progression/proc/has_achievement_in_database(ckey, achievement_id)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.has_achievement(ckey, achievement_id)

/datum/controller/subsystem/persistent_progression/proc/unlock_item_in_database(ckey, item_id)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.unlock_item(ckey, item_id)

/datum/controller/subsystem/persistent_progression/proc/unlock_title_in_database(ckey, title_id)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.unlock_title(ckey, title_id)

/datum/controller/subsystem/persistent_progression/proc/start_round_in_database(ckey, round_id, job_title, faction_id)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.start_round(ckey, round_id, job_title, faction_id)

/datum/controller/subsystem/persistent_progression/proc/end_round_in_database(ckey, round_id, survived, experience_gained, achievements_unlocked)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.end_round(ckey, round_id, survived, experience_gained, achievements_unlocked)

/datum/controller/subsystem/persistent_progression/proc/update_job_stats_in_database(ckey, job_title, survived, experience_gained, achievements_unlocked)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.update_job_stats(ckey, job_title, survived, experience_gained, achievements_unlocked)

/datum/controller/subsystem/persistent_progression/proc/record_metric_in_database(ckey, metric_name, metric_value)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.record_metric(ckey, metric_name, metric_value)

/datum/controller/subsystem/persistent_progression/proc/get_global_stats_from_database()
	if(!use_database || !database_adapter)
		return list()

	return database_adapter.get_global_stats()

/datum/controller/subsystem/persistent_progression/proc/get_faction_stats_from_database()
	if(!use_database || !database_adapter)
		return list()

	return database_adapter.get_faction_stats()

/datum/controller/subsystem/persistent_progression/proc/export_player_data_from_database(ckey)
	if(!use_database || !database_adapter)
		return null

	return database_adapter.export_player_data(ckey)

/datum/controller/subsystem/persistent_progression/proc/reset_player_data_in_database(ckey)
	if(!use_database || !database_adapter)
		return FALSE

	return database_adapter.reset_player_data(ckey)

/datum/controller/subsystem/persistent_progression/proc/get_database_status()
	if(!use_database || !database_adapter)
		return list("initialized" = FALSE, "healthy" = FALSE)

	return database_adapter.get_database_status()

/datum/controller/subsystem/persistent_progression/proc/migrate_from_json_to_database(ckey)
	if(!use_database || !database_adapter)
		return FALSE

	// Load from JSON
	var/datum/persistent_player_data/json_data = load_player_data(ckey)
	if(!json_data)
		return FALSE

	// Migrate to database
	return database_adapter.migrate_from_json(ckey, json_data)

/datum/controller/subsystem/persistent_progression/proc/cleanup_old_database_data(days_to_keep = 30)
	if(!use_database || !database_adapter)
		return

	database_adapter.cleanup_old_data(days_to_keep)
