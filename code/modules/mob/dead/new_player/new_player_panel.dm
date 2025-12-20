#define LINKIFY_CONSOLE_OPTION(str, cmd) "<a class='rawLink' href='byond://?src=\ref[src];[cmd]' onmouseover='fillInput(\"[str]\");' onmouseout='fillInput(\"&#8203;\");'>[str]</a>"
#define CONSOLE_BACK "<a class='rawLink' href='byond://?src=\ref[src];main_menu=1' onmouseover='fillInput(\"cd..\");' onmouseout='fillInput(\"&#8203;\");'>Back</a>"
#define LINKIFY_READY(string, value) "<a class='cursorPointer' href='byond://?src=\ref[src];ready=[value]'>[string]</a>"

#define NPP_TAB_MAIN "main"
#define NPP_TAB_GAME "game"

/datum/new_player_panel
	var/mob/dead/new_player/parent
	var/active_tab = NPP_TAB_MAIN

/datum/new_player_panel/New(parent)
	src.parent = parent

/datum/new_player_panel/Destroy(force, ...)
	parent = null
	return ..()

/datum/new_player_panel/Topic(href, href_list[])
	if(parent != usr)
		return

	if(!parent.client)
		return


	if(href_list["verify"])
		show_otp_menu()
		return TRUE

	if(href_list["link_to_discord"])
		var/_link = CONFIG_GET(string/panic_bunker_discord_link)
		if(_link)
			parent << link(_link)
		return TRUE

	//Restricted clients can't do anything else.
	if(parent.client.restricted_mode)
		return TRUE

	if(href_list["npp_options"])
		var/datum/preferences/preferences = parent.client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return TRUE

	if(href_list["view_primer"])
		view_primer()
		return TRUE

	if(href_list["character_setup"])
		var/datum/preferences/preferences = parent.client.prefs
		preferences.html_show(usr)
		return TRUE

	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		//Avoid updating ready if we're after PREGAME (they should use latejoin instead)
		//This is likely not an actual issue but I don't have time to prove that this
		//no longer is required
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			parent.ready = tready

		//if it's post initialisation and they're trying to observe we do the needful
		if(SSticker.current_state >= GAME_STATE_SETTING_UP && tready == PLAYER_READY_TO_OBSERVE)
			parent.ready = tready
			parent.make_me_an_observer()
			return

		update()
		return

	if(href_list["npp_game"])
		change_tab(NPP_TAB_GAME)
		return

	if(href_list["main_menu"])
		change_tab(NPP_TAB_MAIN)
		return

	if(href_list["refresh"])
		parent << browse(null, "window=playersetup") //closes the player setup window
		open()

	if(href_list["manifest"])
		show_crew_manifest(parent)
		return

	if(href_list["late_join"]) //This still exists for queue messages in chat
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, span_boldwarning("The round is either not ready, or has already finished..."))
			return
		LateChoices()
		return

	if(href_list["SelectedJob"])
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, span_danger("The round is either not ready, or has already finished..."))
			return

		if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
			to_chat(usr, span_notice("There is an administrative lock on entering the game!"))
			return

		//Determines Relevent Population Cap
		var/relevant_cap
		var/hpc = CONFIG_GET(number/hard_popcap)
		var/epc = CONFIG_GET(number/extreme_popcap)
		if(hpc && epc)
			relevant_cap = min(hpc, epc)
		else
			relevant_cap = max(hpc, epc)

		if(SSticker.queued_players.len && !(ckey(parent.key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, span_warning("Server is full."))
				return

		parent.AttemptLateSpawn(href_list["SelectedJob"])
		return

	else if(!href_list["late_join"])
		open()

	if(href_list["showpoll"])
		parent.handle_player_polling()
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		parent.poll_player(poll)

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		parent.vote_on_poll_handler(poll, href_list)

/datum/new_player_panel/proc/update()
	change_tab(active_tab)

/datum/new_player_panel/proc/open()
	if(parent.client?.restricted_mode)
		restricted_client_panel()
		return

	active_tab = NPP_TAB_MAIN

	var/list/output = list()
	output += npp_header()
	output += "<div id='content'>"
	output += npp_main("dir")
	output += "</div>"

	var/datum/browser/popup = new(parent, "playersetup", "", 480, 360)
	popup.set_window_options("can_close=0;focus=false;can_resize=0")
	popup.set_content(output.Join())
	popup.open(FALSE)

/datum/new_player_panel/proc/change_tab(new_tab)
	var/content
	if(parent.client?.restricted_mode)
		restricted_client_panel()
		return

	switch(new_tab)
		if(NPP_TAB_MAIN)
			content = npp_main("cd..")
			active_tab = NPP_TAB_MAIN

		if(NPP_TAB_GAME)
			content = npp_game("space_station_13.exe")
			active_tab = NPP_TAB_GAME

		else
			return

	parent << output(url_encode(content), "playersetup.browser:update_content")

/datum/new_player_panel/proc/npp_header()
	return {"
		<script type='text/javascript'>
			function fillInput(text){
			const elem = document.getElementById("input");
			elem.innerHTML = text;
		}

		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}

		function byondCall(cmd){
			window.location = 'byond://?src=[ref(src)];' + cmd;
		}

		</script>
	"}

/datum/new_player_panel/proc/npp_main(last_cmd)
	var/list/output = list()

	var/poll = playerpolls()
	if(!is_guest_key(parent.client.key) && poll)
		poll = "<div>>[LINKIFY_CONSOLE_OPTION(poll, "showpoll=1")]</div>"

	output += {"
		<fieldset class='computerPane' style='height:260px'>
			<legend class='computerLegend' style='margin: 0 auto'>
				<b>SCipNet Terminal</b>
			</legend>
			<div class='computerLegend flexColumn' style='font-size: 14px; height: 80%; text-align:left'>
				<div style='font-size: 16px'>
					C:\\Users\\[parent.ckey]\\SCP-Link>[last_cmd]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Personnel_File.exe", "npp_game=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Site_Operations.cfg", "npp_options=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Foundation_Briefing (Lore).txt", "view_primer=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Secure_Comms_Link (Discord).lnk", "verify=1")]
				</div>
				[poll]
				<br>
				<div>
					<span>C:\\Users\\[parent.ckey]\\SCP-Link&gt</span>
					<span id='input' class='consoleInput'>&#8203;</span>
				</div>
			</div>
		</fieldset>
	"}

	output += join_or_ready()

	return jointext(output, "")

/datum/new_player_panel/proc/npp_game(last_cmd)
	var/list/output = list()
	var/name = parent.client?.prefs.read_preference(/datum/preference/name/real_name)

	var/status
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		switch(parent.ready)
			if(PLAYER_NOT_READY)
				status = "<div>>Status: Not Ready</div>"
			if(PLAYER_READY_TO_PLAY)
				status = "<div>>Status: Ready</div>"
			if(PLAYER_READY_TO_OBSERVE)
				status = "<div>>Status: Ready (Observe)</div>"
			else
				status = "<div>>Status: Not Ready</div>"

	output += {"
		<fieldset class='computerPane' style='height:260px'>
			<legend class='computerLegend' style='margin: 0 auto'>
				<b>ThinkDOS Terminal</b>
			</legend>
			<div class='computerLegend flexColumn' style='font-size: 14px; height: 80%; text-align:left'>
				<div style='font-size: 16px'>
					C:\\Users\\[parent.ckey]\\ss13&gt;[last_cmd]
				</div>
				<div>
					>Loaded File: <b>[name]</b>
				</div>
				[status]
				<br>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Modify [name].txt", "character_setup=1")]
				</div>
				<div>
					>[CONSOLE_BACK]
				</div>
				<br>
				<div>
					<span>C:\\Users\\[parent.ckey]\\ss13&gt</span>
					<span id='input' class='consoleInput'>&#8203;</span>
				</div>
			</div>
		</fieldset>
	"}

	output += join_or_ready()

	return jointext(output, "")

/datum/new_player_panel/proc/join_or_ready()
	var/list/output = list()
	output += {"
		<div class='flexColumn' style='justify-content: center;align-items: center;width:100%;font-size: 16px;'>
	"}

	if(SSticker.current_state > GAME_STATE_PREGAME)
		output += {"
			<div class='flexRow' style='justify-content: center;align-items: center;width:100%;margin-top: 4px;'>
				<div class='flexItem'>[button_element(src, "Join Game", "late_join=1")]</div>
				<div class='flexItem'>[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)]</div>
			</div>
		"}
		output += "<div class='flexItem' style='margin-top: 8px'>[button_element(src, "View Station Manifests", "manifest=1")]</div>"
	else
		switch(parent.ready)
			if(PLAYER_NOT_READY)
				output += "<div>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | <span class='linkOn'>Not Ready</span> | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</div>"
			if(PLAYER_READY_TO_PLAY)
				output += "<div>\[ <span class='linkOn'>Ready</span> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</div>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<div>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | <span class='linkOn'>Observe</span> \]</div>"
		output += "</div>"

	output += "</div>"
	return jointext(output, "")

/datum/new_player_panel/proc/restricted_client_panel()
	var/content = {"
		<div style='width:100%;height: 100%'>
			<fieldset class='computerPane'>
				<div class='computerLegend' style='margin: auto;height: 70%'>
				Welcome to Daedalus Dock's Test Server<br><br>
				We require discord verification in order to play, as a measure to protect us against griefing.
				</div>
			</fieldset>
			<div style = 'text-align: center'>[button_element(src, "Verify", "verify=1")]</div>
		</div>
	"}

	var/datum/browser/popup = new(parent, "playersetup", "<center><div>Welcome, New Player!</div></center>", 660, 270)
	popup.set_window_options("can_close=0;focus=false;can_resize=0")
	popup.set_content(content)
	popup.open(FALSE)

/datum/new_player_panel/proc/show_otp_menu()
	if(!parent.client)
		return

	if(!CONFIG_GET(flag/sql_enabled))
		alert(parent.client, "No database to link to, bud. Scream at the host.", "Writing to Nowhere.")
		return

	if(isnull(parent.client.linked_discord_account))
		alert(parent.client, "You haven't fully loaded, please wait...", "Please Wait")
		return

	if(parent.client.linked_discord_account?.valid)
		alert(parent.client, "Your discord account is already linked.\nIf you believe this is in error, please contact staff.\nLinked ID: [parent.client.linked_discord_account.discord_id]", "Already Linked")
		return

	var/discord_otp = parent.client.discord_get_or_generate_one_time_token_for_ckey(parent.ckey)
	var/discord_prefix = CONFIG_GET(string/discordbotcommandprefix)
	var/browse_body = {"
		<center>
		<span style='color:red'>Your One-Time-Password is:<br> [discord_otp]</span>
		<br><br>
		To link your Discord account, head to the Discord Server and make an entry ticket if you have not already. Then, paste the following into any channel:
		<hr/>
		</center>
		<code>
			[discord_prefix]verify [discord_otp]
		</code>
		<hr/>
		<center>[button_element(src, "Discord", "link_to_discord=1")]
		<br>
	"}

	var/datum/browser/popup = new(parent, "discordauth", "<center><div>Verification</div></center>", 660, 270)
	//If we aren't in restricted mode, let them close the window.
	popup.set_window_options("can_close=[!parent.client.restricted_mode];focus=true;can_resize=0")
	popup.set_content(browse_body)
	popup.open()

/datum/new_player_panel/proc/view_primer()
	var/content = {"
		<div style='width:100%; text-align:center; font-size: 16px'>
			Welcome, Foundation Personnel. The year is 2068.
		</div>
		<br><br>
		<div style='width:100%; text-align:center'>
			You are an employee of the SCP Foundation, a clandestine organization dedicated to containing anomalous entities, objects, and phenomena that pose a threat to global normalcy. Your current assignment is to a secure Foundation site, where you will contribute to the ongoing mission of Secure, Contain, Protect.
		</div>
		<br><br>
		<div style='width:100%; text-align:center'>
		Your duties may vary, from research and containment to security and logistics. Adhere strictly to all protocols, maintain operational security, and report any unusual occurrences immediately. The safety of humanity depends on your diligence.
		</div>
	"}
	var/datum/browser/popup = new(parent, "primer", "<center><div>Foundation Briefing</div></center>", 660, 350)
	popup.set_content(content)
	popup.open()

/datum/new_player_panel/proc/playerpolls()
	if (!SSdbcore.Connect())
		return

	var/isadmin = FALSE
	if(parent.client?.holder)
		isadmin = TRUE

	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = parent.ckey))

	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		return

	if(query_get_new_polls.NextRow())
		. = "polls.exe (new!)"
	else
		. = "polls.exe"

	qdel(query_get_new_polls)
	if(QDELETED(src))
		return null

	return .

/datum/new_player_panel/proc/LateChoices()
	world.log << "LateChoices function called"
	var/list/dat = list()

	// Simple, compact layout with inline styles only
	dat += "<div style='background: #000; color: #fff; font-family: monospace; padding: 10px; width: 100%; max-width: 100%; overflow-x: hidden;'>"
	dat += "<div style='font-size: 18px; font-weight: bold; margin-bottom: 10px; text-align: center;'>LATE JOIN SELECTION</div>"
	dat += "<div style='font-size: 12px; margin-bottom: 10px; text-align: center;'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>"

	// Status Notices
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		dat += "<div style='background: #600; border: 1px solid #f00; padding: 5px; text-align: center; margin-bottom: 10px;'>Only Observers may join at this time.</div>"

	// Emergency Status Notices
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div style='background: #600; border: 1px solid #f00; padding: 5px; text-align: center; margin-bottom: 10px;'>The station has been evacuated.</div>"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					dat += "<div style='background: #600; border: 1px solid #f00; padding: 5px; text-align: center; margin-bottom: 10px;'>The station is currently undergoing evacuation procedures.</div>"

	// Clean up prioritized jobs
	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	// Simple table layout
	dat += "<table style='width: 100%; border-collapse: collapse;'>"

	for(var/datum/job_department/department as anything in SSjob.departments)
		if(department.exclude_from_latejoin)
			continue

		dat += "<tr><td colspan='2' style='background: #333; color: [department.latejoin_color]; font-weight: bold; padding: 5px; text-align: center; border: 1px solid #555;'>[department.department_name]</td></tr>"

		var/list/dept_data = list()
		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(parent.IsJobUnavailable(job_datum.title, TRUE) != JOB_AVAILABLE)
				continue

			var/job_color = "#fff"
			if(job_datum in SSjob.prioritized_jobs)
				job_color = "#0f0"
			else if(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMPANY_LEADER)
				job_color = "#ff0"

			dept_data += "<tr><td style='padding: 2px 5px; border: 1px solid #555;'><a href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]' style='color: [job_color]; text-decoration: none; font-size: 11px;'>[job_datum.title]</a></td><td style='padding: 2px 5px; border: 1px solid #555; text-align: center; font-size: 11px;'>([job_datum.current_positions])</td></tr>"

		if(!length(dept_data))
			dept_data += "<tr><td colspan='2' style='padding: 5px; text-align: center; font-style: italic; color: #888;'>No positions open.</td></tr>"

		dat += dept_data.Join()

	dat += "</table>"
	dat += "</div>"

	world.log << "Simple browser interface prepared"
	var/datum/browser/popup = new(parent, "latechoices", "Choose Profession", 500, 400)
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)

#undef LINKIFY_CONSOLE_OPTION
#undef NPP_TAB_MAIN
#undef NPP_TAB_GAME
#undef CONSOLE_BACK
#undef LINKIFY_READY
