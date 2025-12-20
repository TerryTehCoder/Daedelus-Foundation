// Foundation-19 Command Jobs
// These are the command and administrative positions

/datum/job/site_director
	title = "Site Director"
	description = "Oversee all site operations. Ensure containment protocols are followed. Coordinate with O5 Council. Manage site personnel and resources."
	department_head = list()
	head_announce = list("Command")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the O5 Council"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 20
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_COMMAND
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

/datum/job/o5_representative
	title = "O5 Representative"
	description = "Represent the O5 Council on site. Oversee site operations and ensure compliance with Foundation protocols. Report directly to the O5 Council."
	department_head = list()
	head_announce = list("Command")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the O5 Council"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 18
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_COMMAND
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

/datum/job/guard_commander
	title = "Guard Commander"
	description = "Manage all three Security branches. Keep track of potential and on-going threats (such as containment breaches). Work with other departments to respond to said threats."
	department_head = list()
	head_announce = list("Security")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#8e2929"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SECURITY
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

/datum/job/research_director
	title = "Research Director"
	description = "Oversee all research operations. Ensure proper containment protocols for SCPs. Coordinate with other departments for research projects. Manage research staff and resources."
	department_head = list()
	head_announce = list("Science")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#7f61e5"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

/datum/job/chief_medical_officer
	title = "Chief Medical Officer"
	description = "Oversee all medical operations. Ensure proper medical care for all personnel. Coordinate with other departments for medical emergencies. Manage medical staff and resources."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#013d3b"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_MED

/datum/job/chief_engineer
	title = "Chief Engineer"
	description = "Oversee all engineering operations. Ensure proper maintenance of site infrastructure. Coordinate with other departments for engineering projects. Manage engineering staff and resources."
	department_head = list()
	head_announce = list("Engineering")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#ffa500"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG
