/datum/achievement
	var/achievement_id
	var/achievement_name
	var/achievement_description
	var/achievement_category // "milestone", "class", "faction", "hidden", "seasonal"
	var/achievement_icon
	var/achievement_points = 0
	var/achievement_rarity = "common" // "common", "uncommon", "rare", "epic", "legendary"
	var/achievement_secret = FALSE
	var/achievement_repeatable = FALSE
	var/achievement_max_progress = 1
	var/achievement_progress_type = "count" // "count", "time", "value"
	var/achievement_requirements = list()
	var/achievement_rewards = list()

/datum/achievement/New(id, name, desc, category, icon, points, rarity, secret, repeatable, max_progress, progress_type, requirements, rewards)
	achievement_id = id
	achievement_name = name
	achievement_description = desc
	achievement_category = category
	achievement_icon = icon
	achievement_points = points
	achievement_rarity = rarity
	achievement_secret = secret
	achievement_repeatable = repeatable
	achievement_max_progress = max_progress
	achievement_progress_type = progress_type
	achievement_requirements = requirements
	achievement_rewards = rewards

// Milestone Achievements
/datum/achievement/milestone/first_experience
	achievement_id = "first_experience"
	achievement_name = "First Steps"
	achievement_description = "Gain your first experience point"
	achievement_category = "milestone"
	achievement_icon = "star"
	achievement_points = 10
	achievement_rarity = "common"

/datum/achievement/milestone/experience_milestones
	achievement_id = "exp_1000"
	achievement_name = "Novice"
	achievement_description = "Accumulate 1,000 total experience"
	achievement_category = "milestone"
	achievement_icon = "medal"
	achievement_points = 25
	achievement_rarity = "common"
	achievement_max_progress = 1000

/datum/achievement/milestone/exp_10000
	achievement_id = "exp_10000"
	achievement_name = "Veteran"
	achievement_description = "Accumulate 10,000 total experience"
	achievement_category = "milestone"
	achievement_icon = "trophy"
	achievement_points = 100
	achievement_rarity = "uncommon"
	achievement_max_progress = 10000

/datum/achievement/milestone/exp_100000
	achievement_id = "exp_100000"
	achievement_name = "Master"
	achievement_description = "Accumulate 100,000 total experience"
	achievement_category = "milestone"
	achievement_icon = "crown"
	achievement_points = 500
	achievement_rarity = "rare"
	achievement_max_progress = 100000

/datum/achievement/milestone/rounds_played
	achievement_id = "rounds_10"
	achievement_name = "Regular Player"
	achievement_description = "Play 10 rounds"
	achievement_category = "milestone"
	achievement_icon = "calendar"
	achievement_points = 50
	achievement_rarity = "common"
	achievement_max_progress = 10

/datum/achievement/milestone/rounds_100
	achievement_id = "rounds_100"
	achievement_name = "Dedicated Player"
	achievement_description = "Play 100 rounds"
	achievement_category = "milestone"
	achievement_icon = "calendar-check"
	achievement_points = 200
	achievement_rarity = "uncommon"
	achievement_max_progress = 100

/datum/achievement/milestone/survival_master
	achievement_id = "survival_master"
	achievement_name = "Survival Master"
	achievement_description = "Achieve 90% survival rate over 50+ rounds"
	achievement_category = "milestone"
	achievement_icon = "shield"
	achievement_points = 300
	achievement_rarity = "rare"

// Class-specific Achievements
/datum/achievement/class/security_arrests
	achievement_id = "security_arrests"
	achievement_name = "Law Enforcer"
	achievement_description = "As Security, arrest 50 criminals"
	achievement_category = "class"
	achievement_icon = "handcuffs"
	achievement_points = 150
	achievement_rarity = "uncommon"
	achievement_max_progress = 50

/datum/achievement/class/medical_saves
	achievement_id = "medical_saves"
	achievement_name = "Life Saver"
	achievement_description = "As Medical, save 100 lives"
	achievement_category = "class"
	achievement_icon = "heart"
	achievement_points = 200
	achievement_rarity = "uncommon"
	achievement_max_progress = 100

/datum/achievement/class/engineering_builds
	achievement_id = "engineering_builds"
	achievement_name = "Master Builder"
	achievement_description = "As Engineering, construct 200 structures"
	achievement_category = "class"
	achievement_icon = "wrench"
	achievement_points = 150
	achievement_rarity = "uncommon"
	achievement_max_progress = 200

/datum/achievement/class/science_discoveries
	achievement_id = "science_discoveries"
	achievement_name = "Mad Scientist"
	achievement_description = "As Science, make 50 discoveries"
	achievement_category = "class"
	achievement_icon = "flask"
	achievement_points = 200
	achievement_rarity = "uncommon"
	achievement_max_progress = 50

// Faction-specific Achievements
/datum/achievement/faction/foundation_loyalty
	achievement_id = "foundation_loyalty"
	achievement_name = "Foundation Loyalist"
	achievement_description = "Remain with SCP Foundation for 50 rounds"
	achievement_category = "faction"
	achievement_icon = "building"
	achievement_points = 100
	achievement_rarity = "uncommon"
	achievement_max_progress = 50

/datum/achievement/faction/chaos_insurgency
	achievement_id = "chaos_insurgency"
	achievement_name = "Chaos Operative"
	achievement_description = "Remain with Chaos Insurgency for 50 rounds"
	achievement_category = "faction"
	achievement_icon = "skull"
	achievement_points = 100
	achievement_rarity = "uncommon"
	achievement_max_progress = 50

// Hidden Achievements
/datum/achievement/hidden/explorer
	achievement_id = "explorer"
	achievement_name = "Explorer"
	achievement_description = "Visit 90% of the map in a single round"
	achievement_category = "hidden"
	achievement_icon = "map"
	achievement_points = 75
	achievement_rarity = "rare"
	achievement_secret = TRUE

/datum/achievement/hidden/pacifist
	achievement_id = "pacifist"
	achievement_name = "Pacifist"
	achievement_description = "Complete a round without dealing any damage"
	achievement_category = "hidden"
	achievement_icon = "peace"
	achievement_points = 100
	achievement_rarity = "rare"
	achievement_secret = TRUE

// Seasonal/Event Achievements
/datum/achievement/seasonal/holiday_spirit
	achievement_id = "holiday_spirit"
	achievement_name = "Holiday Spirit"
	achievement_description = "Participate in a holiday event"
	achievement_category = "seasonal"
	achievement_icon = "gift"
	achievement_points = 50
	achievement_rarity = "uncommon"

// Achievement Manager
/datum/achievement_manager
	var/list/achievements = list()
	var/list/achievement_categories = list("milestone", "class", "faction", "hidden", "seasonal")

/datum/achievement_manager/New()
	initialize_achievements()

/datum/achievement_manager/proc/initialize_achievements()
	// Milestone achievements
	achievements["first_experience"] = new /datum/achievement/milestone/first_experience()
	achievements["exp_1000"] = new /datum/achievement/milestone/experience_milestones()
	achievements["exp_10000"] = new /datum/achievement/milestone/exp_10000()
	achievements["exp_100000"] = new /datum/achievement/milestone/exp_100000()
	achievements["rounds_10"] = new /datum/achievement/milestone/rounds_played()
	achievements["rounds_100"] = new /datum/achievement/milestone/rounds_100()
	achievements["survival_master"] = new /datum/achievement/milestone/survival_master()

	// Class achievements
	achievements["security_arrests"] = new /datum/achievement/class/security_arrests()
	achievements["medical_saves"] = new /datum/achievement/class/medical_saves()
	achievements["engineering_builds"] = new /datum/achievement/class/engineering_builds()
	achievements["science_discoveries"] = new /datum/achievement/class/science_discoveries()

	// Faction achievements
	achievements["foundation_loyalty"] = new /datum/achievement/faction/foundation_loyalty()
	achievements["chaos_insurgency"] = new /datum/achievement/faction/chaos_insurgency()

	// Hidden achievements
	achievements["explorer"] = new /datum/achievement/hidden/explorer()
	achievements["pacifist"] = new /datum/achievement/hidden/pacifist()

	// Seasonal achievements
	achievements["holiday_spirit"] = new /datum/achievement/seasonal/holiday_spirit()

/datum/achievement_manager/proc/get_achievement(achievement_id)
	return achievements[achievement_id]

/datum/achievement_manager/proc/get_achievements_by_category(category)
	var/list/category_achievements = list()
	for(var/achievement_id in achievements)
		var/datum/achievement/achievement = achievements[achievement_id]
		if(achievement.achievement_category == category)
			category_achievements += achievement
	return category_achievements

/datum/achievement_manager/proc/get_all_achievements()
	return achievements

