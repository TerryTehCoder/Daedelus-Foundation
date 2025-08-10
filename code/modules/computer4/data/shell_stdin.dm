/// Struct for the parsed stdin
/datum/shell_stdin
	var/raw = ""
	var/command = ""
	var/list/arguments = list()
	var/list/options = list()

/datum/shell_stdin/New(text)
	raw = text
	command = ""
	arguments = list()
	options = list()

	var/current_token = ""
	var/in_single_quote = FALSE
	var/in_double_quote = FALSE
	var/in_curly_brace = FALSE
	var/curly_brace_nesting_level = 0
	var/escaped = FALSE

	for(var/i = 1, i <= length(text), i++)
		var/char = copytext(text, i, i + 1)

		if(escaped)
			current_token += char
			escaped = FALSE
			continue

		if(char == "\\")
			escaped = TRUE
			continue

		if(in_curly_brace)
			if(char == "{")
				curly_brace_nesting_level++
			else if(char == "}")
				curly_brace_nesting_level--
				if(curly_brace_nesting_level == 0)
					in_curly_brace = FALSE
					// Add the curly brace to the token, then finalize argument
					current_token += char
					if(command == "")
						command = lowertext(current_token)
					else
						arguments += current_token
					current_token = ""
					continue // Continue to next char, don't add space
			current_token += char
			continue

		if(in_single_quote)
			if(char == "'")
				in_single_quote = FALSE
				// Finalize argument
				if(command == "")
					command = lowertext(current_token)
				else
					arguments += current_token
				current_token = ""
			else
				current_token += char
			continue

		if(in_double_quote)
			if(char == "\"")
				in_double_quote = FALSE
				// Finalize argument
				if(command == "")
					command = lowertext(current_token)
				else
					arguments += current_token
				current_token = ""
			else
				current_token += char
			continue

		// Not in any special block, process delimiters
		if(char == " ")
			if(length(current_token) > 0)
				if(command == "")
					command = lowertext(current_token)
				else
					arguments += current_token
				current_token = ""
			continue

		if(char == "'")
			in_single_quote = TRUE
			continue

		if(char == "\"")
			in_double_quote = TRUE
			continue

		if(char == "{")
			in_curly_brace = TRUE
			curly_brace_nesting_level = 1 // Start nesting level
			current_token += char // Include the opening brace in the token
			continue

		current_token += char

	// Add the last token if any, after the loop finishes
	if(length(current_token) > 0)
		if(command == "")
			command = lowertext(current_token)
		else
			arguments += current_token

	// Now parse options from arguments list
	var/list/temp_arguments = list()
	var/option_parsing_finished = FALSE

	for(var/str in arguments)
		if(option_parsing_finished)
			temp_arguments += str
			continue

		if(length(str) <= 1 || str[1] != "-")
			option_parsing_finished = TRUE
			temp_arguments += str
			continue

		if(str[2] == "-")
			if(length(str) == 2) // "--", cease parsing options
				option_parsing_finished = TRUE
				continue

			var/option = copytext(str, 3)
			// Option-argument parsing
			var/list/option_argument_split = splittext(option, "=")
			if(length(option_argument_split) > 1)
				options[option_argument_split[1]] = jointext(option_argument_split.Copy(2), "")
			else
				options += option
			continue

		options |= splittext(copytext(str, 2), "")
	arguments = temp_arguments
	message_admins(span_adminnotice("Parsed STDIN: Raw Input: '[raw]'"))
	message_admins(span_adminnotice("Parsed STDIN: Command: '[command]'"))
	message_admins(span_adminnotice("Parsed STDIN: Arguments Count: [length(arguments)]"))
	if(length(arguments) > 0)
		message_admins(span_adminnotice("Parsed STDIN: First Argument: '[arguments[1]]'"))
	message_admins(span_adminnotice("Parsed STDIN: Options: [options]"))
