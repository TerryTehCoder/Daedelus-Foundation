/datum/persistent_progression_ui
	var/mob/living/carbon/human/user
	var/datum/mind/user_mind

/datum/persistent_progression_ui/New(mob/living/carbon/human/target_user)
	user = target_user
	user_mind = user.mind

/datum/persistent_progression_ui/ui_interact(mob/user, datum/tgui/ui)
	if(!user.client)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersistentProgression")
		ui.open()

/datum/persistent_progression_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/persistent_progression_ui/ui_data(mob/user)
	var/list/data = list()

	if(!user_mind || !user_mind.persistent_data)
		data["has_data"] = FALSE
		return data

	var/datum/persistent_player_data/player_data = user_mind.persistent_data
	var/datum/persistent_class/current_class = user_mind.get_current_class()
	var/datum/persistent_faction/current_faction = user_mind.get_current_faction()
	var/list/rank_info = user_mind.get_rank_progress()

	// Basic player info
	data["has_data"] = TRUE
	data["player_name"] = user.name
	data["player_key"] = user.key
	data["current_class"] = current_class ? current_class.class_name : "Unknown"
	data["current_faction"] = current_faction ? current_faction.faction_name : "Unknown"
	data["current_rank"] = rank_info["rank_name"]
	data["current_rank_level"] = rank_info["current_rank"]
	data["total_experience"] = player_data.total_experience
	data["rounds_played"] = player_data.rounds_played
	data["progress_to_next"] = rank_info["progress"]
	data["exp_needed"] = rank_info["exp_needed"]

	// Advanced stats
	data["total_rounds_survived"] = player_data.rounds_survived || 0
	data["total_rounds_died"] = player_data.rounds_died || 0
	data["survival_rate"] = player_data.rounds_played > 0 ? round((player_data.rounds_survived || 0) / player_data.rounds_played * 100, 1) : 0
	data["average_exp_per_round"] = player_data.rounds_played > 0 ? round(player_data.total_experience / player_data.rounds_played, 1) : 0

	// Achievement data
	data["achievement_points"] = player_data.achievement_points || 0
	data["total_achievements_unlocked"] = player_data.total_achievements_unlocked || 0
	data["achievement_progress"] = player_data.achievement_progress || list()

	// SSachievements integration data
	data["ss_achievements_enabled"] = SSachievements.achievements_enabled || FALSE
	data["ss_achievements_count"] = SSachievements.achievements.len || 0

	// Performance metrics
	data["performance_metrics"] = player_data.performance_metrics || list()

	// Current round stats
	data["current_round_damage_dealt"] = player_data.current_round_damage_dealt || 0
	data["current_round_damage_taken"] = player_data.current_round_damage_taken || 0
	data["current_round_healing_done"] = player_data.current_round_healing_done || 0
	data["current_round_objectives_completed"] = player_data.current_round_objectives_completed || 0
	data["current_round_team_contributions"] = player_data.current_round_team_contributions || 0
	data["current_round_map_exploration"] = player_data.current_round_map_exploration || 0
	data["current_round_pacifist"] = player_data.current_round_pacifist || TRUE

	// Job-specific data
	data["current_job"] = player_data.current_job || ""
	data["job_experience"] = player_data.job_experience || list()
	data["job_rounds_played"] = player_data.job_rounds_played || list()
	data["job_achievements"] = player_data.job_achievements || list()
	data["job_specializations"] = player_data.job_specializations || list()
	data["job_certifications"] = player_data.job_certifications || list()
	data["job_promotions"] = player_data.job_promotions || list()
	data["job_commendations"] = player_data.job_commendations || list()
	data["job_incidents"] = player_data.job_incidents || list()
	data["job_disciplinary_actions"] = player_data.job_disciplinary_actions || list()
	data["job_training_completed"] = player_data.job_training_completed || list()
	data["job_mentoring_sessions"] = player_data.job_mentoring_sessions || list()
	data["job_research_papers"] = player_data.job_research_papers || list()
	data["job_containment_breaches"] = player_data.job_containment_breaches || list()
	data["job_scp_interactions"] = player_data.job_scp_interactions || list()
	data["job_medical_procedures"] = player_data.job_medical_procedures || list()
	data["job_engineering_projects"] = player_data.job_engineering_projects || list()
	data["job_security_operations"] = player_data.job_security_operations || list()
	data["job_supply_management"] = player_data.job_supply_management || list()
	data["job_service_contributions"] = player_data.job_service_contributions || list()
	data["job_dclass_testing"] = player_data.job_dclass_testing || list()

	// Class information
	if(current_class)
		data["class_description"] = current_class.class_description
		data["class_exp_multiplier"] = current_class.experience_multiplier
		data["class_max_rank"] = current_class.max_rank
	else
		data["class_description"] = "No class selected"
		data["class_exp_multiplier"] = 1.0
		data["class_max_rank"] = 0

			// Available ranks
	var/list/ranks = list()
	if(current_class)
		for(var/rank_level = 0; rank_level <= current_class.max_rank; rank_level++)
			var/list/rank_data = list()
			rank_data["name"] = current_class.get_rank_name(rank_level)
			rank_data["requirement"] = current_class.get_rank_requirement(rank_level)
			rank_data["color"] = current_class.get_rank_color(rank_level)
			rank_data["unlocked"] = rank_level <= rank_info["current_rank"]
			ranks += list(rank_data)
	data["ranks"] = ranks

	// Faction information
	if(current_faction)
		data["faction_description"] = current_faction.faction_description
		data["faction_exp_multiplier"] = current_faction.experience_multiplier
	else
		data["faction_description"] = "No faction selected"
		data["faction_exp_multiplier"] = 1.0

		// Available classes for this faction
		var/list/available_classes = list()
		if(current_faction)
			for(var/class_id in current_faction.faction_classes)
				var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
				if(class)
					var/list/class_data = list()
					class_data["id"] = class_id
					class_data["name"] = class.class_name
					class_data["description"] = class.class_description
					class_data["current"] = (class_id == player_data.current_class_id)
					available_classes += list(class_data)
		data["available_classes"] = available_classes

	// Unlocked items and titles
	data["unlocked_items"] = player_data.unlocked_items
	data["unlocked_titles"] = player_data.unlocked_titles
	data["achievements"] = player_data.achievements

	// Recent experience sources
	var/list/recent_exp = list()
	var/count = 0
	for(var/list/source_data in player_data.experience_sources)
		if(count >= 5)
			break
		var/list/exp_data = list()
		exp_data["reason"] = source_data["reason"]
		exp_data["amount"] = source_data["amount"]
		exp_data["timestamp"] = source_data["timestamp"]
		recent_exp += list(exp_data)
		count++
	data["recent_experience"] = recent_exp

	// All available factions for class change
	var/list/all_factions = list()
	for(var/faction_id in SSpersistent_progression.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
		if(faction && (player_data.current_class_id in faction.faction_classes))
			var/list/faction_data = list()
			faction_data["id"] = faction_id
			faction_data["name"] = faction.faction_name
			faction_data["description"] = faction.faction_description
			faction_data["current"] = (faction_id == player_data.current_faction_id)
			all_factions += list(faction_data)
	data["available_factions"] = all_factions

	// All available classes (for comprehensive view)
	var/list/all_classes = list()
	for(var/class_id in SSpersistent_progression.classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		if(class)
			var/list/class_data = list()
			class_data["id"] = class_id
			class_data["name"] = class.class_name
			class_data["description"] = class.class_description
			class_data["exp_multiplier"] = class.experience_multiplier
			class_data["max_rank"] = class.max_rank
			class_data["current"] = (class_id == player_data.current_class_id)
			class_data["available"] = (player_data.current_faction_id in SSpersistent_progression.factions && (class_id in SSpersistent_progression.get_faction(player_data.current_faction_id).faction_classes))

			// Compatible factions for this class
			var/list/compatible_factions = list()
			for(var/faction_id in SSpersistent_progression.factions)
				var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
				if(faction && (class_id in faction.faction_classes))
					compatible_factions += faction.faction_name
			class_data["compatible_factions"] = compatible_factions

			all_classes += list(class_data)
	data["all_classes"] = all_classes

	// All factions (for comprehensive view)
	var/list/all_factions_comprehensive = list()
	for(var/faction_id in SSpersistent_progression.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
		if(faction)
			var/list/faction_data = list()
			faction_data["id"] = faction_id
			faction_data["name"] = faction.faction_name
			faction_data["description"] = faction.faction_description
			faction_data["exp_multiplier"] = faction.experience_multiplier
			faction_data["current"] = (faction_id == player_data.current_faction_id)
			faction_data["available"] = (player_data.current_class_id in faction.faction_classes)

			// Available classes for this faction
			var/list/available_classes = list()
			for(var/class_id in faction.faction_classes)
				var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
				if(class)
					available_classes += class.class_name
			faction_data["available_classes"] = available_classes

			all_factions_comprehensive += list(faction_data)
	data["all_factions"] = all_factions_comprehensive

	// Faction integration data
	if(SSpersistent_progression.faction_integration)
		var/list/faction_integration_data = list()
		faction_integration_data["enabled"] = TRUE

		// Current faction game faction mapping
		var/game_faction = SSpersistent_progression.faction_integration.get_game_faction(player_data.current_faction_id)
		faction_integration_data["current_game_faction"] = game_faction

		// Faction relationships
		var/list/relationships = list()
		for(var/faction_id in SSpersistent_progression.factions)
			if(faction_id != player_data.current_faction_id)
				var/status = SSpersistent_progression.faction_integration.get_relationship_status(player_data.current_faction_id, faction_id)
				relationships[faction_id] = status
		faction_integration_data["relationships"] = relationships

				// Faction statistics
		var/list/faction_stats = SSpersistent_progression.faction_integration.get_faction_stats()
		faction_integration_data["stats"] = faction_stats

		data["faction_integration"] = faction_integration_data
	else
		data["faction_integration"] = list("enabled" = FALSE)

	// Database status and statistics
	var/list/db_status = SSpersistent_progression.get_database_status()
	data["database_status"] = db_status

	if(db_status["initialized"] && db_status["healthy"])
		// Global statistics from database
		var/list/global_stats = SSpersistent_progression.get_global_stats_from_database()
		data["global_stats"] = global_stats

		// Faction statistics from database
		var/list/db_faction_stats = SSpersistent_progression.get_faction_stats_from_database()
		data["db_faction_stats"] = db_faction_stats

		// Recent experience from database
		var/list/db_recent_exp = SSpersistent_progression.database_adapter.get_recent_experience(user.ckey, 10)
		data["recent_experience"] = db_recent_exp

		// Job statistics from database
		var/list/job_stats = SSpersistent_progression.database_adapter.get_job_statistics(user.ckey)
		data["job_statistics"] = job_stats

		// Analytics from database
		var/list/analytics = SSpersistent_progression.database_adapter.get_analytics(user.ckey, "performance", 50)
		data["analytics_data"] = analytics
	else
		data["global_stats"] = list()
		data["db_faction_stats"] = list()
		data["recent_experience"] = list()
		data["job_statistics"] = list()
		data["analytics_data"] = list()

	// Achievement data
	var/list/achievement_data = list()
	if(SSpersistent_progression.achievement_manager)
		for(var/achievement_id in SSpersistent_progression.achievement_manager.achievements)
			var/datum/achievement/achievement = SSpersistent_progression.achievement_manager.get_achievement(achievement_id)
			if(achievement)
				var/list/ach_data = list()
				ach_data["id"] = achievement.achievement_id
				ach_data["name"] = achievement.achievement_name
				ach_data["description"] = achievement.achievement_description
				ach_data["category"] = achievement.achievement_category
				ach_data["icon"] = achievement.achievement_icon
				ach_data["points"] = achievement.achievement_points
				ach_data["rarity"] = achievement.achievement_rarity
				ach_data["secret"] = achievement.achievement_secret
				ach_data["unlocked"] = (achievement_id in player_data.achievements)
				ach_data["progress"] = player_data.achievement_progress[achievement_id] || 0
				ach_data["max_progress"] = achievement.achievement_max_progress
				achievement_data += list(ach_data)
	data["achievements"] = achievement_data

	return data

/datum/persistent_progression_ui/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_class")
			var/class_id = params["class_id"]
			if(class_id && user_mind)
				var/success = user_mind.change_class(class_id)
				if(success)
					. = TRUE
					to_chat(user, span_notice("Successfully changed your class!"))
				else
					to_chat(user, span_warning("Failed to change class."))

		if("change_faction")
			var/faction_id = params["faction_id"]
			if(faction_id && user_mind)
				var/success = user_mind.change_faction(faction_id)
				if(success)
					. = TRUE
					to_chat(user, span_notice("Successfully changed your faction!"))
				else
					to_chat(user, span_warning("Failed to change faction."))

		if("show_all_classes")
			show_all_classes_ui()

		if("show_all_factions")
			show_all_factions_ui()

		if("reset_progress")
			if(alert(user, "Are you sure you want to reset all your progress? This cannot be undone!", "Reset Progress", "Yes", "No") == "Yes")
				if(user_mind && user_mind.persistent_data)
					user_mind.persistent_data.reset_progress()
					. = TRUE
					to_chat(user, span_notice("Progress reset successfully!"))

		if("export_data")
			var/data_json = user_mind.persistent_data.export_to_json()
			user << browse(data_json, "window=progression_data;size=600x400;can_close=1;can_resize=1")
			. = TRUE

		if("test_action")
			to_chat(user, span_notice("Test action received!"))
			. = TRUE

/datum/persistent_progression_ui/proc/show_all_classes_ui()
	var/datum/persistent_progression_classes_ui/classes_ui = new()
	classes_ui.ui_interact(user)

/datum/persistent_progression_ui/proc/show_all_factions_ui()
	var/datum/persistent_progression_factions_ui/factions_ui = new()
	factions_ui.ui_interact(user)

// Classes overview UI
/datum/persistent_progression_classes_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersistentProgressionClasses", "Available Classes", 800, 600)
		ui.open()

/datum/persistent_progression_classes_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/persistent_progression_classes_ui/ui_data(mob/user)
	var/list/data = list()
	var/list/classes = list()

	for(var/class_id in SSpersistent_progression.classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		if(class)
			var/list/class_data = list()
			class_data["id"] = class_id
			class_data["name"] = class.class_name
			class_data["description"] = class.class_description
			class_data["exp_multiplier"] = class.experience_multiplier
			class_data["max_rank"] = class.max_rank

			// Compatible factions
			var/list/compatible_factions = list()
			for(var/faction_id in SSpersistent_progression.factions)
				var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
				if(faction && (class_id in faction.faction_classes))
					compatible_factions += faction.faction_name
			class_data["compatible_factions"] = compatible_factions

			// Ranks
			var/list/ranks = list()
			for(var/rank_level = 0; rank_level <= class.max_rank; rank_level++)
				var/list/rank_data = list()
				rank_data["name"] = class.get_rank_name(rank_level)
				rank_data["requirement"] = class.get_rank_requirement(rank_level)
				rank_data["color"] = class.get_rank_color(rank_level)
				ranks += list(rank_data)
			class_data["ranks"] = ranks

			classes += list(class_data)

	data["classes"] = classes
	return data

// Factions overview UI
/datum/persistent_progression_factions_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersistentProgressionFactions", "Available Factions", 800, 600)
		ui.open()

/datum/persistent_progression_factions_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/persistent_progression_factions_ui/ui_data(mob/user)
	var/list/data = list()
	var/list/factions = list()

	for(var/faction_id in SSpersistent_progression.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
		if(faction)
			var/list/faction_data = list()
			faction_data["id"] = faction_id
			faction_data["name"] = faction.faction_name
			faction_data["description"] = faction.faction_description
			faction_data["exp_multiplier"] = faction.experience_multiplier

			// Available classes
			var/list/available_classes = list()
			for(var/class_id in faction.faction_classes)
				var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
				if(class)
					var/list/class_data = list()
					class_data["name"] = class.class_name
					class_data["description"] = class.class_description
					available_classes += list(class_data)
			faction_data["available_classes"] = available_classes

			factions += list(faction_data)

	data["factions"] = factions
	return data

// Admin UI for managing player progression
/datum/persistent_progression_admin_ui
	var/client/admin_client

/datum/persistent_progression_admin_ui/New(client/admin)
	admin_client = admin
	ui_interact(admin.mob, null)

/datum/persistent_progression_admin_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersistentProgressionAdmin", "Persistent Progression Admin", 1000, 700)
		ui.open()

/datum/persistent_progression_admin_ui/ui_state(mob/user)
	if(!admin_client || !admin_client.holder || !check_rights(R_ADMIN, FALSE, admin_client))
		return GLOB.never_state
	return GLOB.always_state

/datum/persistent_progression_admin_ui/ui_data(mob/user)
	var/list/data = list()
	var/list/players = list()

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind && H.ckey)
			var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
			if(player_data)
				var/list/player_info = list()
				player_info["name"] = H.name
				player_info["ckey"] = H.ckey
				player_info["class"] = player_data.current_class_id
				player_info["rank"] = player_data.current_rank_name
				player_info["experience"] = player_data.total_experience
				player_info["rounds_played"] = player_data.rounds_played
				players += list(player_info)

	data["players"] = players
	return data

/datum/persistent_progression_admin_ui/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!admin_client || !admin_client.holder || !check_rights(R_ADMIN, FALSE, admin_client))
		return

	switch(action)
		if("award_experience")
			var/ckey = params["ckey"]
			var/amount = text2num(params["amount"])
			var/reason = params["reason"]

			if(ckey && amount > 0)
				var/awarded = SSpersistent_progression.award_experience(ckey, "admin_award", amount, reason)
				if(awarded > 0)
					to_chat(admin_client, span_notice("Successfully awarded [awarded] experience to [ckey]"))
					log_admin("[key_name(admin_client)] awarded [amount] experience to [ckey] for: [reason]")
					message_admins("[key_name(admin_client)] awarded [amount] experience to [ckey] for: [reason]")
					. = TRUE

		if("set_rank")
			var/ckey = params["ckey"]
			var/class_id = params["class_id"]
			var/rank_level = text2num(params["rank_level"])

			if(ckey && class_id && !isnull(rank_level))
				var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(ckey)
				var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

				if(data && class && rank_level >= 0 && rank_level <= class.max_rank)
					var/required_exp = class.get_rank_requirement(rank_level)
					var/exp_needed = required_exp - data.total_experience

					if(exp_needed > 0)
						SSpersistent_progression.award_experience(ckey, "admin_award", exp_needed, "Admin Rank Set")

					to_chat(admin_client, span_notice("Set [ckey]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]"))
					log_admin("[key_name(admin_client)] set [ckey]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")
					message_admins("[key_name(admin_client)] set [ckey]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")
					. = TRUE

		if("reset_progress")
			var/ckey = params["ckey"]

			if(ckey)
				var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(ckey)
				if(data)
					data.initialize_default_data()
					SSpersistent_progression.save_player_data(ckey)

					to_chat(admin_client, span_notice("Reset [ckey]'s persistent progress."))
					log_admin("[key_name(admin_client)] reset [ckey]'s persistent progress")
					message_admins("[key_name(admin_client)] reset [ckey]'s persistent progress")
					. = TRUE

		if("view_progress")
			var/ckey = params["ckey"]

			if(ckey)
				var/datum/persistent_progression_player_view_ui/player_view = new(ckey)
				player_view.ui_interact(admin_client.mob)

// Player view UI for admins
/datum/persistent_progression_player_view_ui
	var/ckey

/datum/persistent_progression_player_view_ui/New(target_ckey)
	ckey = target_ckey

/datum/persistent_progression_player_view_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersistentProgressionPlayerView", "Player Progress - [ckey]", 800, 600)
		ui.open()

/datum/persistent_progression_player_view_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/persistent_progression_player_view_ui/ui_data(mob/user)
	var/list/data = list()

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		data["has_data"] = FALSE
		return data

	data["has_data"] = TRUE
	data["ckey"] = ckey
	data["current_class"] = player_data.current_class_id
	data["current_faction"] = player_data.current_faction_id
	data["current_rank"] = player_data.current_rank_name
	data["current_rank_level"] = player_data.current_rank
	data["total_experience"] = player_data.total_experience
	data["rounds_played"] = player_data.rounds_played
	data["last_login"] = time2text(player_data.last_login, "YYYY-MM-DD hh:mm:ss")

	var/datum/persistent_class/class = SSpersistent_progression.get_class(player_data.current_class_id)
	if(class)
		var/progress = player_data.get_progress_to_next_rank()
		var/exp_needed = player_data.get_experience_needed_for_next_rank()
		data["progress_to_next"] = progress
		data["exp_needed"] = exp_needed

	data["unlocked_items"] = player_data.unlocked_items
	data["unlocked_titles"] = player_data.unlocked_titles
	data["achievements"] = player_data.achievements

	// Recent experience sources
	var/list/recent_exp = list()
	var/count = 0
	for(var/list/source_data in player_data.experience_sources)
		if(count >= 10)
			break
		var/list/exp_data = list()
		exp_data["reason"] = source_data["reason"]
		exp_data["amount"] = source_data["amount"]
		exp_data["timestamp"] = time2text(source_data["timestamp"], "hh:mm:ss")
		recent_exp += list(exp_data)
		count++
	data["recent_experience"] = recent_exp

	return data
