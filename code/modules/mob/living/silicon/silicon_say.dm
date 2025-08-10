/mob/living/proc/robot_talk(message)
	log_talk(message, LOG_SAY, tag="binary")
	var/desig = "Default Cyborg" //ezmode for taters
	if(issilicon(src))
		var/mob/living/silicon/S = src
		desig = trim_left(S.designation + " " + S.job)
	var/message_a = say_quote(message)
	var/rendered = "[RADIO_TAG("robo.png")][span_name("[name]")] <span class='message'>[message_a]</span>"
	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				var/renderedAI = span_binarysay("[RADIO_TAG("robo.png")]<a href='?src=[REF(M)];track=[html_encode(name)]'>[span_name("[name] ([desig])")]</a> <span class='message'>[message_a]</span>")
				to_chat(M, renderedAI, avoid_highlighting = src == M)
			else
				to_chat(M, span_binarysay("[rendered]"), avoid_highlighting = src == M)
		if(isobserver(M))
			var/following = src
			// If the AI talks on binary chat, we still want to follow
			// it's camera eye, like if it talked on the radio
			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj
			var/link = FOLLOW_LINK(M, following)
			to_chat(M, span_binarysay("[link] [rendered]"))

/mob/living/silicon/binarycheck()
	return TRUE

/mob/living/silicon/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(.)
		return
	if(message_mods[MODE_HEADSET])
		if(radio)
			radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	if(copytext(message, 1, 2) == "~") // Check for the ASCII art chat prefix
		var/chat_content = copytext(message, 2)
		if(isAI(src))
			var/mob/living/silicon/ai/AI = src
			var/target_terminal_id = null
			var/chat_message_start_index = 1

			// Check for explicit terminal ID: ~-REF_XXXX message
			if(copytext(chat_content, 1, 6) == "-REF_") {
				var/space_index = findtext(chat_content, " ", 6) // Find the first space after -REF_
				if(space_index > 0) {
					target_terminal_id = copytext(chat_content, 6, space_index)
					chat_message_start_index = space_index + 1
				} else {
					// If no space, assume the rest of the string is the ID and there's no message
					target_terminal_id = copytext(chat_content, 6)
					chat_message_start_index = length(chat_content) + 1 // Set to end of string
				}
			}

			var/actual_message = copytext(chat_content, chat_message_start_index)

			if(!length(actual_message))
				return TRUE // Don't send empty chat message

			var/obj/machinery/computer4/target_terminal = null

			if(target_terminal_id)
				// Find the specific terminal by ID
				for(var/obj/machinery/computer4/T in AI.logged_in_terminals)
					if(REF(T) == target_terminal_id)
						target_terminal = T
						break
				if(!target_terminal)
					to_chat(AI, span_warning("Error: Terminal '[target_terminal_id]' not found or not logged into."))
					return TRUE
			else
				// Default to active terminal
				target_terminal = AI.active_thinkdos_terminal
				if(!target_terminal)
					to_chat(AI, span_warning("Error: No active ThinkDOS terminal. Please log into one or specify a terminal ID (e.g., ~\[REF_XXXX\] message)."))
					return TRUE

			if(target_terminal.operating_system)
				AI.handle_ascii_art_chat(actual_message, target_terminal.operating_system) // Removed force_print_to_terminal
			else
				to_chat(AI, span_warning("Error: Target terminal's operating system is not active."))
			return TRUE // Consume the message, don't send as regular chat
		return FALSE

	return FALSE

/mob/living/silicon/ai/proc/handle_ascii_art_chat(message, datum/c4_file/terminal_program/operating_system/thinkdos/system)
	set background = TRUE
	if(!message || !length(message) || !system)
		return

	var/obj/machinery/computer4/thinkdos_terminal = system.get_computer()
	if(!thinkdos_terminal)
		return

	if(system.current_main_aic_art) // Only use dynamic display if ASCII art is active
		system.current_aic_chat_message_display = "C:\\RmtUser\\[src.real_name]> [html_encode(message)]"
	else
		// If no ASCII art, append to the regular text buffer for scrolling behavior
		thinkdos_terminal.text_buffer += "C:\\RmtUser\\[src.real_name]> [html_encode(message)]<br>"
		// Also clear any lingering dynamic message if art was just deactivated
		system.current_aic_chat_message_display = null

	system.render_terminal_content()
