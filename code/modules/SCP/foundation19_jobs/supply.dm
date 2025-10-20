// Foundation-19 Supply Jobs
// These are the supply and logistics personnel

/datum/job/quartermaster
	title = "Quartermaster"
	description = "Manage site supplies and logistics. Coordinate with other departments for resource needs. Maintain inventory and distribution systems."
	department_head = list()
	head_announce = list("Supply")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

/datum/job/cargo_technician
	title = "Cargo Technician"
	description = "Handle cargo shipments and deliveries. Process supply requests from departments. Maintain cargo bay operations."
	department_head = list()
	head_announce = list("Supply")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

/datum/job/shaft_miner
	title = "Shaft Miner"
	description = "Extract resources from mining operations. Supply materials for construction and research. Maintain mining equipment and safety protocols."
	department_head = list()
	head_announce = list("Supply")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

/datum/job/logistics_officer
	title = "Logistics Officer"
	description = "Coordinate supply chains and resource distribution. Plan and execute logistics operations. Ensure efficient resource allocation."
	department_head = list()
	head_announce = list("Supply")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

/datum/job/supply_specialist
	title = "Supply Specialist"
	description = "Handle specialized supply requests and equipment. Manage hazardous materials and SCP-related supplies. Ensure proper handling protocols."
	department_head = list()
	head_announce = list("Supply")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
