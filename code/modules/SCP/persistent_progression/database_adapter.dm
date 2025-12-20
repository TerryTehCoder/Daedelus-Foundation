// Database Adapter for Persistent Progression System
// This file provides an adapter layer between the existing system and the database

/datum/persistent_progression_database_adapter
	var/datum/persistent_progression_database/database
	var/initialized = FALSE

/datum/persistent_progression_database_adapter/New()
	initialize_adapter()

/datum/persistent_progression_database_adapter/proc/initialize_adapter()
	if(initialized)
		return

	database = new /datum/persistent_progression_database()
	initialized = TRUE
	world.log << "Persistent Progression Database Adapter: Initialized successfully"

// Convert database row to persistent_player_data format
/datum/persistent_progression_database_adapter/proc/db_row_to_player_data(db_row)
	if(!db_row)
		return null

	var/datum/persistent_player_data/data = new()

	// Basic player data
	data.current_class_id = db_row["current_class_id"] || "security"
	data.current_faction_id = db_row["current_faction_id"] || "foundation"
	data.current_rank = text2num(db_row["current_rank"]) || 0
	data.current_rank_name = db_row["current_rank_name"] || "Recruit"
	data.total_experience = text2num(db_row["total_experience"]) || 0
	data.rounds_played = text2num(db_row["rounds_played"]) || 0
	data.rounds_survived = text2num(db_row["rounds_survived"]) || 0
	data.rounds_died = text2num(db_row["rounds_died"]) || 0
	data.last_login = text2num(db_row["last_login"]) || world.time

	// Load achievements
	var/list/achievements = database.get_achievements(db_row["ckey"])
	for(var/list/achievement in achievements)
		data.achievements[achievement["achievement_id"]] = achievement["unlocked_at"]
		data.achievement_progress[achievement["achievement_id"]] = text2num(achievement["progress"]) || 0

	// Load items
	var/list/items = database.get_unlocked_items(db_row["ckey"])
	for(var/list/item in items)
		data.unlocked_items[item["item_id"]] = item["unlocked_at"]

	// Load titles
	var/list/titles = database.get_unlocked_titles(db_row["ckey"])
	for(var/list/title in titles)
		data.unlocked_titles[title["title_id"]] = title["unlocked_at"]

	// Load recent experience
	var/list/exp_data = database.get_recent_experience(db_row["ckey"], 20)
	for(var/list/exp in exp_data)
		var/list/exp_entry = list()
		exp_entry["source"] = exp["source"]
		exp_entry["amount"] = text2num(exp["amount"])
		exp_entry["reason"] = exp["reason"]
		exp_entry["timestamp"] = text2num(exp["timestamp"])
		data.experience_sources += list(exp_entry)

	// Load job stats
	var/list/job_stats = database.get_job_stats(db_row["ckey"])
	for(var/list/job_stat in job_stats)
		var/job_title = job_stat["job_title"]
		data.job_rounds_played[job_title] = text2num(job_stat["rounds_played"]) || 0
		// Store additional job stats in performance_metrics for now
		data.performance_metrics["job_[job_title]_survived"] = text2num(job_stat["rounds_survived"]) || 0
		data.performance_metrics["job_[job_title]_experience"] = text2num(job_stat["total_experience"]) || 0
		data.performance_metrics["job_[job_title]_achievements"] = text2num(job_stat["achievements_unlocked"]) || 0

	return data

// Convert persistent_player_data to database format
/datum/persistent_progression_database_adapter/proc/player_data_to_db_format(datum/persistent_player_data/data)
	if(!data)
		return null

	var/list/db_data = list()
	db_data["current_class_id"] = data.current_class_id
	db_data["current_faction_id"] = data.current_faction_id
	db_data["current_rank"] = data.current_rank
	db_data["current_rank_name"] = data.current_rank_name
	db_data["total_experience"] = data.total_experience
	db_data["rounds_played"] = data.rounds_played
	db_data["rounds_survived"] = data.rounds_survived
	db_data["rounds_died"] = data.rounds_died

	return db_data

// Get player data from database
/datum/persistent_progression_database_adapter/proc/get_player_data(ckey)
	if(!ckey || !initialized)
		return null

	var/list/db_row = database.get_player_data(ckey)
	if(!db_row)
		return null

	return db_row_to_player_data(db_row)

// Create new player data in database
/datum/persistent_progression_database_adapter/proc/create_player_data(ckey, player_name)
	if(!ckey || !player_name || !initialized)
		return FALSE

	return database.create_player_data(ckey, player_name)

// Save player data to database
/datum/persistent_progression_database_adapter/proc/save_player_data(ckey, datum/persistent_player_data/data)
	if(!ckey || !data || !initialized)
		return FALSE

	var/list/db_data = player_data_to_db_format(data)
	if(!db_data)
		return FALSE

	return database.update_player_data(ckey, db_data)

// Add experience to database
/datum/persistent_progression_database_adapter/proc/add_experience(ckey, source, amount, reason)
	if(!ckey || !source || amount <= 0 || !initialized)
		return FALSE

	return database.add_experience(ckey, source, amount, reason)

// Unlock achievement in database
/datum/persistent_progression_database_adapter/proc/unlock_achievement(ckey, achievement_id, progress = 0)
	if(!ckey || !achievement_id || !initialized)
		return FALSE

	return database.unlock_achievement(ckey, achievement_id, progress)

// Check if player has achievement
/datum/persistent_progression_database_adapter/proc/has_achievement(ckey, achievement_id)
	if(!ckey || !achievement_id || !initialized)
		return FALSE

	return database.has_achievement(ckey, achievement_id)

// Unlock item in database
/datum/persistent_progression_database_adapter/proc/unlock_item(ckey, item_id)
	if(!ckey || !item_id || !initialized)
		return FALSE

	return database.unlock_item(ckey, item_id)

// Unlock title in database
/datum/persistent_progression_database_adapter/proc/unlock_title(ckey, title_id)
	if(!ckey || !title_id || !initialized)
		return FALSE

	return database.unlock_title(ckey, title_id)

// Start round tracking
/datum/persistent_progression_database_adapter/proc/start_round(ckey, round_id, job_title, faction_id)
	if(!ckey || !round_id || !initialized)
		return FALSE

	return database.start_round(ckey, round_id, job_title, faction_id)

// End round tracking
/datum/persistent_progression_database_adapter/proc/end_round(ckey, round_id, survived, experience_gained, achievements_unlocked)
	if(!ckey || !round_id || !initialized)
		return FALSE

	return database.end_round(ckey, round_id, survived, experience_gained, achievements_unlocked)

// Update job stats
/datum/persistent_progression_database_adapter/proc/update_job_stats(ckey, job_title, survived, experience_gained, achievements_unlocked)
	if(!ckey || !job_title || !initialized)
		return FALSE

	return database.update_job_stats(ckey, job_title, survived, experience_gained, achievements_unlocked)

// Record analytics metric
/datum/persistent_progression_database_adapter/proc/record_metric(ckey, metric_name, metric_value)
	if(!ckey || !metric_name || !initialized)
		return FALSE

	return database.record_metric(ckey, metric_name, metric_value)

// Get global statistics
/datum/persistent_progression_database_adapter/proc/get_global_stats()
	if(!initialized)
		return list()

	return database.get_global_stats()

// Get faction statistics
/datum/persistent_progression_database_adapter/proc/get_faction_stats()
	if(!initialized)
		return list()

	return database.get_faction_stats()

// Export player data
/datum/persistent_progression_database_adapter/proc/export_player_data(ckey)
	if(!ckey || !initialized)
		return null

	return database.export_player_data(ckey)

// Reset player data
/datum/persistent_progression_database_adapter/proc/reset_player_data(ckey)
	if(!ckey || !initialized)
		return FALSE

	return database.reset_player_data(ckey)

// Cleanup old data
/datum/persistent_progression_database_adapter/proc/cleanup_old_data(days_to_keep = 30)
	if(!initialized)
		return

	database.cleanup_old_data(days_to_keep)

// Migration from JSON to database
/datum/persistent_progression_database_adapter/proc/migrate_from_json(ckey, datum/persistent_player_data/json_data)
	if(!ckey || !json_data || !initialized)
		return FALSE

	// Save the JSON data to database
	var/success = save_player_data(ckey, json_data)

	if(success)
		world.log << "Persistent Progression Database: Migrated data for [ckey] from JSON to database"

	return success

// Get recent experience for UI
/datum/persistent_progression_database_adapter/proc/get_recent_experience(ckey, limit = 10)
	if(!ckey || !initialized)
		return list()

	return database.get_recent_experience(ckey, limit)

// Get job statistics for UI
/datum/persistent_progression_database_adapter/proc/get_job_statistics(ckey)
	if(!ckey || !initialized)
		return list()

	return database.get_job_stats(ckey)

// Get analytics for UI
/datum/persistent_progression_database_adapter/proc/get_analytics(ckey, metric_name, limit = 100)
	if(!ckey || !initialized)
		return list()

	return database.get_analytics(ckey, metric_name, limit)

// Database health check
/datum/persistent_progression_database_adapter/proc/health_check()
	if(!initialized)
		return FALSE

	// Try a simple query to check database connectivity
	var/list/stats = get_global_stats()
	return stats && stats.len > 0

// Get database status for UI
/datum/persistent_progression_database_adapter/proc/get_database_status()
	var/list/status = list()
	status["initialized"] = initialized
	status["healthy"] = health_check()

	if(initialized)
		var/list/stats = get_global_stats()
		status["total_players"] = text2num(stats["total_players"]) || 0
		status["total_experience"] = text2num(stats["total_experience"]) || 0
		status["total_rounds"] = text2num(stats["total_rounds"]) || 0

	return status
