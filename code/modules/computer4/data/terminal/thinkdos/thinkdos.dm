/datum/c4_file/terminal_program/operating_system/thinkdos/no_login
	needs_login = FALSE

/datum/c4_file/terminal_program/operating_system/thinkdos
	name = "SciP-Net"

	var/system_version = "SciP-Net 1.2.0"

	/// If you need to login to use the computer.
	var/needs_login = TRUE

	/// Shell commmands for std_in, built on new.
	var/static/list/commands

	/// Boolean, determines if errors are written to the log file.
	var/log_errors = TRUE

	/// Current logged in user, if any.
	var/datum/c4_file/user/current_user

	/// The command log.
	var/datum/c4_file/text/command_log

	/// Tracks the last time a watchdog alert was triggered for physical input during AIC login.
	var/last_watchdog_alert_time = 0

	/// Stores the ckey of the player who logged in as the AIC.
	/// Used as a reference against usr for physical input when determing watchdog alert.
	var/logged_in_aic_ckey

/datum/c4_file/terminal_program/operating_system/thinkdos/New()
	if(!commands)
		commands = list()
		for(var/datum/shell_command/thinkdos/command_path as anything in subtypesof(/datum/shell_command/thinkdos))
			commands += new command_path

/datum/c4_file/terminal_program/operating_system/thinkdos/execute()
	if(!initialize_logs())
		println("<font color=red>Log system failure.</font>")

	if(!needs_login)
		println("Account system disabled.")

	else if(!initialize_accounts())
		println("<font color=red>Unable to start account system.</font>")

	change_dir(containing_folder)

	var/title_text = list(
		@"<pre style='margin: 0px'>   _____    _____   _   _____             _   _          _  </pre>",
		@"<pre style='margin: 0px'>  / ____|  / ____| (_) |  __ \           | \ | |        | | </pre>",
		@"<pre style='margin: 0px'> | (___   | |       _  | |__) |  ______  |  \| |   ___  | |_ </pre>",
		@"<pre style='margin: 0px'>  \___ \  | |      | | |  ___/  |______| | . ` |  / _ \ | __|</pre>",
		@"<pre style='margin: 0px'>  ____) | | |____  | | | |               | |\  | |  __/ | |_</pre>",
		@"<pre style='margin: 0px'> |_____/   \_____| |_| |_|               |_| \_|  \___|  \__|</pre>",
	).Join("")
	println(title_text)

	if(needs_login)
		println("Authentication required. Insert an identification card and type 'login'.")
	else
		println("Type 'help' to get started.")

/datum/c4_file/terminal_program/operating_system/thinkdos/std_in(text)
	. = ..()
	if(.)
		return

	var/encoded_in = html_encode(text)
	println(encoded_in)
	write_log(encoded_in)

	// Watchdog alert for physical input during AIC login
	if(logged_in_aic_ckey && usr && usr.client.ckey != logged_in_aic_ckey)
		if(world.time - last_watchdog_alert_time >= WATCHDOG_COOLDOWN_SECONDS * 10) // world.time is in centiseconds
			println("<font color=red>ALERT: External user input registered during remote session.</font>")
			last_watchdog_alert_time = world.time

	var/datum/shell_stdin/parsed_stdin = parse_std_in(text)
	if(!current_user && needs_login)
		var/datum/shell_command/thinkdos/login/login_command = locate() in commands
		if(!login_command.try_exec(parsed_stdin.command, src, src, parsed_stdin.arguments, parsed_stdin.options))
			println("Login required. Please login using 'login'.")
		return

	for(var/datum/shell_command/potential_command as anything in commands)
		if(potential_command.try_exec(parsed_stdin.command, src, src, parsed_stdin.arguments, parsed_stdin.options))
			return TRUE

	println("'[html_encode(parsed_stdin.raw)]' is not recognized as an internal or external command.")
	return TRUE

/// Write to the command log.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/write_log(text)
	if(!command_log || drive.read_only)
		return FALSE

	command_log.data += text
	return TRUE

/// Write to the command log if it's enabled, then print to the screen.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/print_error(text)
	if(log_errors)
		write_log(text)

	return println(text)

/// Schedule a callback for the system to invoke after the specified time if able.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/schedule_proc(datum/callback/callback, time)
	addtimer(CALLBACK(src, PROC_REF(execute_scheduled_proc)), time)

/// See schedule_proc()
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/execute_scheduled_proc(datum/callback/callback)
	PRIVATE_PROC(TRUE)

	if(!is_operational())
		return

	callback.Invoke()

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/login(account_name, account_occupation, account_access)
	if(current_user)
		println("<b>Error:</b> Already logged in as [html_encode(current_user.registered_name)]. Please logout first.")
		return FALSE

	if(!account_name || !account_occupation)
		return FALSE

	if(!initialize_accounts())
		return FALSE

	var/datum/c4_file/user/login_user = resolve_filepath("users/admin", drive.root)

	login_user.registered_name = account_name
	login_user.assignment = account_occupation
	login_user.access = text2access(account_access)

	set_current_user(login_user)

	write_log("<b>LOGIN</b>: [html_encode(account_name)] | [html_encode(account_occupation)]")

	if(usr?.has_unlimited_silicon_privilege)
		var/client/C = usr.client
		var/player_ckey = C.ckey
		var/datum/aic_key_data/aic_key = get_or_generate_aic_key(player_ckey, account_name)

		logged_in_aic_ckey = player_ckey // Store the ckey of the AIC player

		println("<b>Digital Handshake</b> accepted from <i>Networked AIC Unit</i>.")
		if(aic_key)
			println("<b>AIC Challenge Key Match:</b> <code>[aic_key.key_hash]</code> Registration: [usr.real_name]<br>")
			println("<span style='font-weight:bold; color:#0f0;'>Root Access Granted.</span>")
			if(aic_key.login_sound_path)
				var/obj/machinery/computer/C = get_computer()
				if(C)
					playsound(C, aic_key.login_sound_path, null, 50, FALSE)
					if(usr && get_dist(usr, C) > AIC_LOGIN_SOUND_RANGE) // Play to user only if outside range of computer sound
						playsound(usr, aic_key.login_sound_path, null, 50, FALSE)
				else
					playsound(usr, aic_key.login_sound_path, null, 50, FALSE)
		// Grant root access for Silicon
		login_user.access |= ACCESS_CAPTAIN
	else if(login_user.access & ACCESS_MANAGEMENT)
		println("Welcome, [html_encode(account_name)]. System Administrator privileges granted.")
	else
		println("Welcome [html_encode(account_name)]!<br><b>Current Directory: [current_directory.path_to_string()]</b>")
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/get_or_generate_aic_key(player_ckey, aic_name)
	if(!player_ckey || !aic_name)
		return null

	var/processed_new_aic_name = trim(aic_name)
	// Remove trailing numbers and optional preceding hyphen/space
	var/i = length(processed_new_aic_name)
	while(i >= 1 && (copytext(processed_new_aic_name, i, i + 1) >= "0" && copytext(processed_new_aic_name, i, i + 1) <= "9"))
		i--
	if(i < length(processed_new_aic_name)) // If numbers were found
		if(i >= 1 && (copytext(processed_new_aic_name, i, i + 1) == "-" || copytext(processed_new_aic_name, i, i + 1) == " "))
			i-- // Remove the hyphen or space too
		processed_new_aic_name = copytext(processed_new_aic_name, 1, i + 1)

	// Remove dots from the name
	processed_new_aic_name = replacetext(processed_new_aic_name, ".", "")

	var/normalized_new_aic_name = lowertext(processed_new_aic_name)
	var/datum/aic_key_data/found_key

	for(var/datum/aic_key_data/key in SSpersistence.aic_keys)
		if(key.ckey == player_ckey)
			var/processed_existing_aic_name = trim(key.aic_name)
			var/j = length(processed_existing_aic_name)
			while(j >= 1 && (copytext(processed_existing_aic_name, j, j + 1) >= "0" && copytext(processed_existing_aic_name, j, j + 1) <= "9"))
				j--
			if(j < length(processed_existing_aic_name))
				if(j >= 1 && (copytext(processed_existing_aic_name, j, j + 1) == "-" || copytext(processed_existing_aic_name, j, j + 1) == " "))
					j--
				processed_existing_aic_name = copytext(processed_existing_aic_name, 1, j + 1)

			// Remove dots from the existing name
			processed_existing_aic_name = replacetext(processed_existing_aic_name, ".", "")

			// Check if the normalized AIC name matches an existing key for this ckey
			if(lowertext(processed_existing_aic_name) == normalized_new_aic_name)
				found_key = key
				break

	if(found_key)
		// If a key is found for the ckey and normalized name, update its details
		// This handles minor name changes (case, whitespace) and updates dynamic data
		if(found_key.aic_name != aic_name) // Update stored name if different (e.g., case change)
			found_key.aic_name = aic_name
		found_key.rounds_as_ai = get_rounds_played_as_ai(player_ckey)
		found_key.admin_rank = get_admin_rank(player_ckey)
	else
		// No existing key found for this ckey and (normalized) aic_name, create a new one
		found_key = new /datum/aic_key_data
		found_key.ckey = player_ckey
		found_key.aic_name = aic_name
		found_key.rounds_as_ai = get_rounds_played_as_ai(player_ckey)
		found_key.admin_rank = get_admin_rank(player_ckey)
		found_key.key_hash = generate_aic_key_hash(player_ckey, found_key.rounds_as_ai, found_key.admin_rank)
		found_key.creation_timestamp = world.realtime
		SSpersistence.aic_keys += found_key

	return found_key

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/generate_aic_key_hash(player_ckey, rounds_as_ai, admin_rank)
	var/rounds_hex = num2hex(rounds_as_ai, 2)
	var/admin_hex = num2hex(admin_rank, 2)
	var/unique_segment = random_alphanumeric(4)

	return "AIC-[unique_segment]-[rounds_hex]-[admin_hex]"

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/random_alphanumeric(length)
	var/result = ""
	var/chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for(var/i in 1 to length)
		var/start_index = rand(1, length(chars))
		result += copytext(chars, start_index, start_index + 1)
	return result

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/get_rounds_played_as_ai(player_ckey)
	if(!SSdbcore.Connect())
		return 0

	var/total_minutes = 0
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT minutes FROM [format_table_name("role_time")] WHERE ckey = :ckey AND job IN ('AI', 'Cyborg', 'Borg')", list("ckey" = player_ckey))
	if(query.Execute())
		while(query.NextRow())
			total_minutes += text2num(query.item[1])
	qdel(query)

	// Assuming an average round length of 120 minutes for conversion
	return round(total_minutes / 120)

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/get_admin_rank(player_ckey)
	var/client/C
	for(var/client/potential_client in GLOB.clients)
		if(potential_client.ckey == player_ckey)
			C = potential_client
			break
	if(C && C.holder && C.holder.rank)
		// Return a numerical representation of the admin rank.
		// This might need a mapping from rank name to a numerical value if specific tiers are required.
		// For now, we'll return a simple indicator (e.g., 1 for any admin, or a specific value if rank names map to numbers).
		switch(C.holder.rank.name)
			if("Game Master")
				return 3
			if("Admin")
				return 2
			if("Mentor")
				return 1
			else
				return 1 // Default for other admin ranks
	return 0 // Not an admin

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/logout()
	if(!current_user)
		print_error("<b>Error:</b> Account system inactive.")
		return FALSE

	write_log("<b>LOGOUT:</b> [html_encode(current_user.registered_name)]")
	set_current_user(null)
	logged_in_aic_ckey = null // Clear the AIC ckey on logout
	return TRUE

/// Returns the logging folder, attempting to create it if it doesn't already exist.
/datum/c4_file/terminal_program/operating_system/thinkdos/get_log_folder()
	var/datum/c4_file/folder/log_dir = parse_directory("logs", drive.root)
	if(!log_dir)
		log_dir = new /datum/c4_file/folder
		log_dir.set_name("logs")
		if(!drive.root.try_add_file(log_dir))
			qdel(log_dir)
			return null

	return log_dir

/// Create the log file, or append a startup log.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/initialize_logs()
	if(command_log)
		return TRUE

	var/datum/c4_file/folder/log_dir = get_log_folder()
	var/datum/c4_file/text/log_file = log_dir.get_file("syslog")
	if(!log_file)
		log_file = new /datum/c4_file/text()
		log_file.set_name("syslog")
		if(!log_dir.try_add_file(log_file))
			qdel(log_file)
			return FALSE

	command_log = log_file
	RegisterSignal(command_log, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_PARENT_QDELETING), PROC_REF(log_file_gone))

	log_file.data += "<br><b>STARTUP:</b> [stationtime2text()], [stationdate2text()]"
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/initialize_accounts()
	var/datum/c4_file/folder/account_dir = parse_directory("users")
	if(!istype(account_dir))
		if(account_dir && !account_dir.containing_folder.try_delete_file(account_dir))
			print_error("<b>Error:</b> Unable to write account folder.")
			return FALSE

		account_dir = new
		account_dir.set_name("users")

		if(!containing_folder.try_add_file(account_dir))
			qdel(account_dir)
			print_error("<b>Error:</b> Unable to write account folder.")
			return FALSE

		RegisterSignal(account_dir, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED), PROC_REF(user_folder_gone))

	var/datum/c4_file/user/user_data = account_dir.get_file("admin", FALSE)
	if(!istype(user_data))
		if(user_data && !user_data.containing_folder.try_delete_file(user_data))
			print_error("<b>Error:</b> Unable to write account folder.")
			return FALSE

		user_data = new
		user_data.set_name("admin")

		if(!account_dir.try_add_file(user_data))
			qdel(user_data)
			print_error("<b>Error:</b> Unable to write account file.")
			return FALSE

		//set_current_user(user_data)
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/set_current_user(datum/c4_file/user/new_user)
	if(current_user)
		UnregisterSignal(current_user, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED))

	current_user = new_user

	if(current_user)
		RegisterSignal(current_user, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED), PROC_REF(user_file_gone))
	else
		for(var/datum/c4_file/terminal_program/running_program as anything in processing_programs)
			if(running_program == src)
				continue

			unload_program(running_program)

/datum/c4_file/terminal_program/operating_system/thinkdos/peripheral_input(obj/item/peripheral/invoker, command, datum/signal/packet)
	if(!packet)
		return

	if(packet.data[PACKET_NETCLASS] == NET_CLASS_REMOTE_COMMAND)
		var/remote_command_name = packet.data[PACKET_COMMAND_TYPE]
		var/remote_command_args = packet.data[PACKET_COMMAND_ARGS]
		var/remote_command_options = packet.data[PACKET_COMMAND_OPTIONS]
		var/source_address = packet.data[PACKET_SOURCE_ADDRESS]

		if(!remote_command_name)
			return

		println("Received remote command '[remote_command_name]' from [source_address].")

		for(var/datum/shell_command/potential_command as anything in commands)
			if(potential_command.try_exec(remote_command_name, src, src, remote_command_args, remote_command_options))
				return TRUE
		println("Remote command '[remote_command_name]' not recognized or executable.")
		return TRUE
