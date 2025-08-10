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
			var/force_print_to_terminal = FALSE

			// Check for -T tag
			if(copytext(actual_message, 1, 3) == "-T")
				force_print_to_terminal = TRUE
				actual_message = trim(copytext(actual_message, 3)) // Remove -T and trim whitespace

			if(!length(actual_message))
				return TRUE // Don't send empty chat bubble

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
				AI.handle_ascii_art_chat(actual_message, target_terminal.operating_system, force_print_to_terminal)
			else
				to_chat(AI, span_warning("Error: Target terminal's operating system is not active."))
			return TRUE // Consume the message, don't send as regular chat
		return FALSE

	return FALSE

/mob/living/silicon/ai/proc/handle_ascii_art_chat(message, datum/c4_file/terminal_program/operating_system/thinkdos/system, force_print_to_terminal = FALSE)
	set background = TRUE
	if(!message || !length(message) || !system)
		return

	var/obj/machinery/computer4/thinkdos_terminal = system.get_computer()
	if(!thinkdos_terminal)
		return

	var/target_terminal_id = REF(thinkdos_terminal)

	if(force_print_to_terminal)
		system.println("C:\\RmtUser\\[src.real_name]> [message]")
		return

	var/datum/aic_ascii_art/owner_art = system.get_aic_ascii_art(ckey, target_terminal_id)
	if(!owner_art)
		// If no main art for this terminal, print the message directly to the terminal.
		system.println("C:\\RmtUser\\[src.real_name]> [message]")
		return

	// Generate chat bubble ASCII art
	var/list/bubble_lines = generate_chat_bubble_ascii(message)
	if(!bubble_lines || !length(bubble_lines))
		system.println("C:\\RmtUser\\[src.real_name]> [message]") // Fallback if bubble generation fails
		return

	// Calculate position above the main art
	var/bubble_width = 0
	for(var/line in bubble_lines)
		bubble_width = max(bubble_width, length(line))

	var/datum/aic_ascii_art/chat_bubble = new /datum/aic_ascii_art
	chat_bubble.owner_ckey = ckey
	chat_bubble.terminal_id = target_terminal_id // Bind chat bubble to this terminal
	chat_bubble.ascii_data = bubble_lines
	chat_bubble.is_chat_bubble = TRUE
	chat_bubble.chat_bubble_id = system.next_chat_bubble_id++

	system.add_aic_ascii_art(chat_bubble)

	// Schedule removal of the chat bubble
	addtimer(CALLBACK(system, /datum/c4_file/terminal_program/operating_system/thinkdos/proc/remove_aic_ascii_art, chat_bubble), 50) // 5 seconds

/mob/living/silicon/ai/proc/generate_chat_bubble_ascii(message)
	var/datum/aic_ascii_art_library/art_library = new /datum/aic_ascii_art_library()
	var/list/template_lines = art_library.get_art_lines("chat_bubble")

	if(!template_lines || template_lines.len < 3) // Need at least top border, text line, bottom border
		// Fallback to simple border if template is missing or malformed
		var/list/lines = splittext(message, " ")
		var/max_line_length = 0
		for(var/line in lines)
			max_line_length = max(max_line_length, length(line))

		var/border_char = "#"
		var/padding = 1
		var/bubble_width = max_line_length + (padding * 2) + 2 // +2 for borders

		var/list/bubble = list()
		bubble += repeat_str(border_char, bubble_width)
		for(var/line in lines)
			var/padded_line = "[line][repeat_str(" ", max_line_length - length(line))]"
			bubble += "[border_char][repeat_str(" ", padding)][padded_line][repeat_str(" ", padding)][border_char]"
		bubble += repeat_str(border_char, bubble_width)
		return bubble

	var/list/final_bubble_lines = list()
	var/text_placeholder = "@@TEXT_PLACEHOLDER@@"
	var/text_line_index = -1
	var/template_text_width = 0

	// Find the line with the [TEXT] placeholder and determine its width
	for(var/i = 1, i <= template_lines.len, i++)
		var/line = template_lines[i]
		if(findtext(line, text_placeholder))
			text_line_index = i
			template_text_width = length(text_placeholder)
			break

	if(text_line_index == -1) // No placeholder found, use simple border fallback
		var/list/lines = splittext(message, " ")
		var/max_line_length = 0
		for(var/line in lines)
			max_line_length = max(max_line_length, length(line))

		var/border_char = "#"
		var/padding = 1
		var/bubble_width = max_line_length + (padding * 2) + 2 // +2 for borders

		var/list/bubble = list()
		bubble += repeat_str(border_char, bubble_width)
		for(var/line in lines)
			var/padded_line = "[line][repeat_str(" ", max_line_length - length(line))]"
			bubble += "[border_char][repeat_str(" ", padding)][padded_line][repeat_str(" ", padding)][border_char]"
		bubble += repeat_str(border_char, bubble_width)
		return bubble

	// Word wrap the message to fit the template's text width
	var/list/wrapped_message_lines = list()
	var/current_line = ""
	var/list/words = splittext(message, " ")

	for(var/word in words)
		if(length(current_line) + length(word) + (length(current_line) > 0 ? 1 : 0) <= template_text_width)
			if(length(current_line) > 0)
				current_line += " "
			current_line += word
		else
			wrapped_message_lines += current_line
			current_line = word
	if(length(current_line) > 0)
		wrapped_message_lines += current_line

	// Construct the final bubble
	for(var/i = 1, i <= template_lines.len, i++)
		var/template_line = template_lines[i]
		if(i == text_line_index)
			for(var/j = 1, j <= wrapped_message_lines.len, j++)
				var/msg_line = wrapped_message_lines[j]
				var/padded_msg_line = "[msg_line][repeat_str(" ", template_text_width - length(msg_line))]"
				final_bubble_lines += replacetext(template_line, text_placeholder, padded_msg_line)
		else
			final_bubble_lines += template_line

	return final_bubble_lines

// Helper proc to repeat a string (DM doesn't have a built-in one)
/proc/repeat_str(text, count)
	var/result = ""
	for(var/i = 1 to count)
		result += text
	return result
