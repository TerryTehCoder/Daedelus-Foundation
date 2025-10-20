// Foundation-19 Medical Jobs
// These are the medical and healthcare personnel

/datum/job/medical_doctor
	title = "Medical Doctor"
	description = "Provide medical care to all personnel. Diagnose and treat injuries and illnesses. Work with other departments during medical emergencies."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

/datum/job/surgeon
	title = "Surgeon"
	description = "Perform surgical procedures and complex medical treatments. Handle emergency surgeries and trauma cases. Train other medical staff."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

/datum/job/paramedic
	title = "Paramedic"
	description = "Provide emergency medical care in the field. Respond to medical emergencies and containment breaches. Transport patients to medical facilities."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED

/datum/job/chemist
	title = "Chemist"
	description = "Create and manage pharmaceuticals and medical compounds. Develop treatments for SCP-related injuries. Maintain medical supply inventory."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED

/datum/job/virologist
	title = "Virologist"
	description = "Study and contain biological threats. Develop treatments for viral infections. Work with dangerous pathogens and SCPs."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

/datum/job/psychiatrist
	title = "Psychiatrist"
	description = "Provide mental health care to personnel. Treat psychological trauma from SCP encounters. Conduct psychological evaluations."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

/datum/job/medical_intern
	title = "Medical Intern"
	description = "Learn medical procedures under supervision. Assist doctors and nurses. Gain experience in Foundation medical protocols."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED

/datum/job/coroner
	title = "Coroner"
	description = "Examine deceased personnel and SCP victims. Determine causes of death. Maintain morgue facilities and records."
	department_head = list()
	head_announce = list("Medical")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED
