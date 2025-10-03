///What percentage of the crew can become changelings.
#define CHANGELING_SCALING_COEFF 0.1

/datum/game_mode/changeling
	name = "Changeling"

	weight = GAMEMODE_WEIGHT_NEVER
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/changeling/antag_selector

/datum/game_mode/changeling/pre_setup()
	. = ..()

	var/num_ling = max(1, round(length(SSticker.ready_players) * CHANGELING_SCALING_COEFF))

	antag_selector = new /datum/antagonist_selector/changeling()
	antag_selector.setup(num_ling, possible_antags)

/datum/game_mode/changeling/post_setup()
	. = ..()
	antag_selector.give_antag_datums(src)
