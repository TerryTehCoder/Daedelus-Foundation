/datum/aic_ascii_art
	var/list/ascii_data // List of strings, each string is a line of the ASCII art
	var/list/emote_data // Map of emote names to lists of strings (ASCII art for that emote)
	var/owner_ckey // Ckey of the AIC player who owns this ASCII art
	var/terminal_id // Terminal binding (optional)
	var/current_emote = "default" // Current emote state (e.g., "default", "happy", "sad")

/datum/aic_ascii_art/New()
	. = ..()
	if(!emote_data)
		emote_data = list()
	if(!ascii_data)
		ascii_data = list()
	emote_data["default"] = ascii_data // Default emote is the base ASCII art
