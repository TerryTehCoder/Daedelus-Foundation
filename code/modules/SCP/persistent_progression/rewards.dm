/datum/reward
	var/reward_id
	var/reward_name
	var/reward_description
	var/reward_type // "item", "title", "experience", "ability", "cosmetic"
	var/reward_rarity = "common" // "common", "uncommon", "rare", "epic", "legendary"
	var/reward_tier = 1 // 1-5, higher is better
	var/reward_seasonal = FALSE
	var/reward_requirements = list()
	var/reward_icon
	var/reward_value = 0

/datum/reward/New(id, name, desc, type, rarity, tier, seasonal, requirements, icon, value)
	reward_id = id
	reward_name = name
	reward_description = desc
	reward_type = type
	reward_rarity = rarity
	reward_tier = tier
	reward_seasonal = seasonal
	reward_requirements = requirements
	reward_icon = icon
	reward_value = value

// Item Rewards
/datum/reward/item/security_badge
	reward_id = "security_badge"
	reward_name = "Security Badge"
	reward_description = "A prestigious security badge showing your dedication to law enforcement"
	reward_type = "item"
	reward_rarity = "uncommon"
	reward_tier = 2
	reward_icon = "id-card"

/datum/reward/item/medical_kit
	reward_id = "medical_kit"
	reward_name = "Advanced Medical Kit"
	reward_description = "A high-quality medical kit for saving lives"
	reward_type = "item"
	reward_rarity = "uncommon"
	reward_tier = 2
	reward_icon = "first-aid"

/datum/reward/item/engineering_tool
	reward_id = "engineering_tool"
	reward_name = "Master Engineer's Tool"
	reward_description = "A specialized tool for advanced engineering work"
	reward_type = "item"
	reward_rarity = "uncommon"
	reward_tier = 2
	reward_icon = "wrench"

/datum/reward/item/research_device
	reward_id = "research_device"
	reward_name = "Research Scanner"
	reward_description = "An advanced device for scientific research"
	reward_type = "item"
	reward_rarity = "uncommon"
	reward_tier = 2
	reward_icon = "microscope"

// Title Rewards
/datum/reward/title/security_master
	reward_id = "security_master"
	reward_name = "Master of Security"
	reward_description = "A prestigious title for exceptional security officers"
	reward_type = "title"
	reward_rarity = "rare"
	reward_tier = 4
	reward_icon = "shield"

/datum/reward/title/medical_expert
	reward_id = "medical_expert"
	reward_name = "Medical Expert"
	reward_description = "A title for those who excel in medical care"
	reward_type = "title"
	reward_rarity = "rare"
	reward_tier = 4
	reward_icon = "heart"

/datum/reward/title/engineering_genius
	reward_id = "engineering_genius"
	reward_name = "Engineering Genius"
	reward_description = "A title for master engineers"
	reward_type = "title"
	reward_rarity = "rare"
	reward_tier = 4
	reward_icon = "cog"

/datum/reward/title/research_pioneer
	reward_id = "research_pioneer"
	reward_name = "Research Pioneer"
	reward_description = "A title for groundbreaking researchers"
	reward_type = "title"
	reward_rarity = "rare"
	reward_tier = 4
	reward_icon = "flask"

// Experience Rewards
/datum/reward/experience/milestone_bonus
	reward_id = "milestone_bonus"
	reward_name = "Milestone Bonus"
	reward_description = "Bonus experience for reaching important milestones"
	reward_type = "experience"
	reward_rarity = "common"
	reward_tier = 1
	reward_value = 1000

/datum/reward/experience/achievement_bonus
	reward_id = "achievement_bonus"
	reward_name = "Achievement Bonus"
	reward_description = "Bonus experience for unlocking achievements"
	reward_type = "experience"
	reward_rarity = "uncommon"
	reward_tier = 2
	reward_value = 500

// Seasonal Rewards
/datum/reward/seasonal/holiday_special
	reward_id = "holiday_special"
	reward_name = "Holiday Special"
	reward_description = "A special reward for participating in holiday events"
	reward_type = "cosmetic"
	reward_rarity = "epic"
	reward_tier = 3
	reward_seasonal = TRUE
	reward_icon = "gift"

// Reward Manager
/datum/reward_manager
	var/list/rewards = list()
	var/list/reward_categories = list("item", "title", "experience", "ability", "cosmetic")

/datum/reward_manager/New()
	initialize_rewards()

/datum/reward_manager/proc/initialize_rewards()
	// Item rewards
	rewards["security_badge"] = new /datum/reward/item/security_badge()
	rewards["medical_kit"] = new /datum/reward/item/medical_kit()
	rewards["engineering_tool"] = new /datum/reward/item/engineering_tool()
	rewards["research_device"] = new /datum/reward/item/research_device()

	// Title rewards
	rewards["security_master"] = new /datum/reward/title/security_master()
	rewards["medical_expert"] = new /datum/reward/title/medical_expert()
	rewards["engineering_genius"] = new /datum/reward/title/engineering_genius()
	rewards["research_pioneer"] = new /datum/reward/title/research_pioneer()

	// Experience rewards
	rewards["milestone_bonus"] = new /datum/reward/experience/milestone_bonus()
	rewards["achievement_bonus"] = new /datum/reward/experience/achievement_bonus()

	// Seasonal rewards
	rewards["holiday_special"] = new /datum/reward/seasonal/holiday_special()

/datum/reward_manager/proc/get_reward(reward_id)
	return rewards[reward_id]

/datum/reward_manager/proc/get_rewards_by_category(category)
	var/list/category_rewards = list()
	for(var/reward_id in rewards)
		var/datum/reward/reward = rewards[reward_id]
		if(reward.reward_type == category)
			category_rewards += reward
	return category_rewards

/datum/reward_manager/proc/get_rewards_by_rarity(rarity)
	var/list/rarity_rewards = list()
	for(var/reward_id in rewards)
		var/datum/reward/reward = rewards[reward_id]
		if(reward.reward_rarity == rarity)
			rarity_rewards += reward
	return rarity_rewards

/datum/reward_manager/proc/get_seasonal_rewards()
	var/list/seasonal_rewards = list()
	for(var/reward_id in rewards)
		var/datum/reward/reward = rewards[reward_id]
		if(reward.reward_seasonal)
			seasonal_rewards += reward
	return seasonal_rewards

