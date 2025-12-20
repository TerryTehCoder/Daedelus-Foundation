#define JOBS_PER_COLUMN 15

/datum/preference_group/category/occupation
	name = "Occupation"
	priority = 80

/datum/preference_group/category/occupation/Topic(href, list/href_list)
	. = ..()
	if(.)
		return

	if(href_list["job_info"])
		var/datum/job/J = SSjob.GetJob(href_list["job_info"])
		if(!J)
			return
		var/datum/browser/window = new(usr, "JobInfo", J.title, 400, 120)
		window.set_content(J.description)
		window.open()
		return TRUE

	var/datum/preferences/prefs = locate(href_list["prefs"])
	if(!prefs)
		return

	if(prefs.parent != usr.client && !check_rights())
		CRASH("Unable to edit prefs that don't belong to you, [usr.key]! (pref owner: [prefs.parent?.key || "NULL"])")

	if(href_list["change_alt_title"])
		if(set_job_title(prefs, href_list["job"]))
			prefs.update_html()
			return TRUE
		return


/datum/preference_group/category/occupation/get_content(datum/preferences/prefs)
	. = ..()
	var/static/list/job_data
	if(!job_data)
		job_data = compile_job_data()

	var/static/priority2text = list("Never", "Low", "Medium", "High")

	var/list/job_bans = get_job_bans(prefs.parent?.mob)
	var/employer = prefs.read_preference(/datum/preference/choiced/employer)
	employer = SSjob.GetEmployer(employer).type

	var/datum/preference/choiced/employer/employer_pref = GLOB.preference_entries[/datum/preference/choiced/employer]
	var/info_button = button_element(prefs, "?", "pref_act=[/datum/preference/choiced/employer];info=1")

	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:50%;max-width:50%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>Faction</b>
			<span class='tooltiptext'>Choose your employer faction.</span>
		</legend>
		<div style='text-align: center; margin-bottom: 10px'>
			[employer_pref.get_button(prefs)][info_button]
		</div>
	</fieldset>
	"}

	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:50%;max-width:50%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>Occupation Preferences</b>
			<span class='tooltiptext'>Set your job preferences and priorities.</span>
		</legend>
		<div class='zebraTable' style='display: flex; flex-direction: column; height: 560px; overflow-y: scroll'>
	"}
	var/list/job_prefs = prefs.read_preference(/datum/preference/blob/job_priority)
	// Group jobs by department
	var/list/department_jobs = list()
	for(var/datum/job/job in job_data)
		var/datum/job_department/department_type = job.department_for_prefs || job.departments_list?[1]
		if(!department_type)
			continue
		var/department_name = initial(department_type.department_name)
		if(!department_jobs[department_name])
			department_jobs[department_name] = list()
		department_jobs[department_name] += job

		// Display jobs by department
	for(var/department_name in department_jobs)
		. += {"
		<div class='flexRow' style='justify-content: center; background-color: #7c5500; padding: 5px; margin: 2px 0;'>
			<span class='computerText' style='font-weight: bold; font-size: 14px;'>[department_name]</span>
		</div>
		"}

		for(var/datum/job/job in department_jobs[department_name])
			var/is_banned = job_bans[job.title] == "banned"
			var/is_too_new = job_bans[job.title]?["job_days_left"]
			var/job_priority = priority2text[(job_prefs[job.title] + 1)]
			var/title_link = length(job.alt_titles) ? button_element(src, prefs.alt_job_titles?[job.title] || job.title, "change_alt_title=1;prefs=\ref[prefs];job=[job.title]") : "[job.title]"
			var/rejection_reason = ""

			if(is_banned)
				rejection_reason = "\[BANNED]"
			else if(is_too_new)
				rejection_reason = "\[[is_too_new]]"
			else if(length(job.employers) && !(employer in job.employers))
				rejection_reason = "\[CHANGE FACTION]"

			var/background_color = "#7c5500"
			if(job_priority == "High")
				background_color = "#533200"
			else if(job_priority == "Medium")
				background_color = "#7c5500"
			else
				background_color = "#533200"

			. += {"
		<div class='flexRow' style='justify-content: space-between; background-color:[background_color]; padding: 2px 5px; margin: 1px 0;'>
			<div style='display: flex; align-items: center; gap: 10px;'>
				<span class='computerText'>[title_link]</span>
				[button_element(src, "?", "job_info=[job.title]", style = "margin-left: 5px")]
			</div>
			<div>
				[rejection_reason || button_element(prefs, job_priority, "pref_act=[/datum/preference/blob/job_priority];job=[job.title]", style = "margin-right: 5px")]
			</div>
		</div>
		"}


	.+= {"
		</div>
	</fieldset>
	"}

/datum/preference_group/category/occupation/proc/compile_job_data()
	var/list/departments = list()
	var/list/jobs = list()

	for (var/datum/job/job as anything in SSjob.joinable_occupations)
		var/datum/job_department/department_type = job.department_for_prefs || job.departments_list?[1]
		if (isnull(department_type))
			stack_trace("[job] does not have a department set, yet is a joinable occupation!")
			continue

		if (isnull(job.description))
			stack_trace("[job] does not have a description set, yet is a joinable occupation!")
			continue

		var/department_name = initial(department_type.department_name)
		if (isnull(departments[department_name]))
			var/datum/job/department_head_type = initial(department_type.department_head)

			departments[department_name] = list(
				"head" = department_head_type && initial(department_head_type.title),
			)

		jobs +=  job

	return jobs

/datum/preference_group/category/occupation/proc/get_job_bans(mob/user)
	var/list/data = list()

	var/list/job_days_left = list()
	var/list/job_required_experience = list()

	for (var/datum/job/job as anything in SSjob.all_occupations)
		var/required_playtime_remaining = job.required_playtime_remaining(user.client)
		if (is_banned_from(user.client?.ckey, job.title))
			data["job_banned"] = TRUE
			continue

		if (required_playtime_remaining)
			job_required_experience[job.title] = list(
				"experience_type" = job.get_exp_req_type(),
				"required_playtime" = required_playtime_remaining,
			)

			continue

		if (!job.player_old_enough(user.client))
			job_days_left[job.title] = job.available_in_days(user.client)

	if (job_days_left.len)
		data["job_days_left"] = job_days_left

	if (job_required_experience)
		data["job_required_experience"] = job_required_experience

	return data

/datum/preference_group/category/occupation/proc/set_job_title(datum/preferences/prefs, job_title)
	var/datum/job/job = SSjob.GetJob(job_title)
	if(!job)
		return

	var/new_job_title = input(usr, "Select Job Title",, prefs.alt_job_titles?[job_title] || job_title) as null|anything in job.alt_titles
	if(!new_job_title)
		return

	if (!(new_job_title in job.alt_titles))
		if(length(job.alt_titles))
			new_job_title = job.alt_titles[1]
		else
			return FALSE

	prefs.alt_job_titles[job_title] = new_job_title

	prefs.character_preview_view?.update_body()
	return TRUE

#undef JOBS_PER_COLUMN
