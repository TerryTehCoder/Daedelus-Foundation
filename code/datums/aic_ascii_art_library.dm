/datum/aic_ascii_art_library
	var/static/list/predefined_art = list() // Map: art_name -> (Map: emote_type -> list of strings)

/datum/aic_ascii_art_library/New()
	. = ..()
	if(!predefined_art.len) // Only initialize once
		predefined_art["cat"] = list(
			"default" = list(
				" /\\_/\\",
				"( o.o )",
				" > ^ <"
			),
			"happy" = list(
				" /\\_/\\",
				"( ^.^ )",
				" > ^ <"
			),
			"sad" = list(
				" /\\_/\\",
				"( ;.; )",
				" > ^ <"
			)
		)
		predefined_art["dog"] = list(
			"default" = list(
				"  __",
				"o'--'o",
				" (oo)"
			),
			"happy" = list(
				"  __",
				"o'--'o",
				" (^^)"
			),
			"bark" = list(
				"  __",
				"o'--'o",
				" (ww)"
			)
		)
		predefined_art["robot"] = list(
			"default" = list(
				"  ____",
				" | [] |",
				" |____|",
				" (____)"
			),
			"alert" = list(
				"  ____",
				" | !! |",
				" |____|",
				" (____)"
			),
			"off" = list(
				"  ____",
				" | -- |",
				" |____|",
				" (____)"
			)
		)

/datum/aic_ascii_art_library/proc/get_art_data(art_name)
	return predefined_art[lowertext(art_name)]

/datum/aic_ascii_art_library/proc/get_art_lines(art_name, emote_type = "default")
	var/list/art_data = get_art_data(art_name)
	if(art_data)
		return art_data[lowertext(emote_type)]
	return null
