/datum/experience_source
    var/source_id
    var/source_name
    var/base_experience
    var/class_multiplier
    var/rank_multiplier
    var/cooldown_time
    var/max_per_round
    var/list/compatible_classes = list()

// Security Experience Sources
/datum/experience_source/security_combat
    source_id = "security_combat"
    source_name = "Combat Engagement"
    base_experience = 50
    cooldown_time = 300
    max_per_round = 10
    compatible_classes = list("security")

/datum/experience_source/security_arrest
    source_id = "security_arrest"
    source_name = "Successful Arrest"
    base_experience = 25
    cooldown_time = 60
    max_per_round = 20
    compatible_classes = list("security")

/datum/experience_source/security_protection
    source_id = "security_protection"
    source_name = "Civilian Protection"
    base_experience = 30
    cooldown_time = 120
    max_per_round = 15
    compatible_classes = list("security")

/datum/experience_source/security_breach_containment
    source_id = "security_breach_containment"
    source_name = "Breach Containment"
    base_experience = 100
    cooldown_time = 600
    max_per_round = 5
    compatible_classes = list("security")

/datum/experience_source/security_scp_interaction
    source_id = "security_scp_interaction"
    source_name = "SCP Security Interaction"
    base_experience = 75
    cooldown_time = 300
    max_per_round = 8
    compatible_classes = list("security")

// Research Experience Sources
/datum/experience_source/research_scp_study
    source_id = "research_scp_study"
    source_name = "SCP Research"
    base_experience = 40
    cooldown_time = 180
    max_per_round = 12
    compatible_classes = list("research")

/datum/experience_source/research_experiment
    source_id = "research_experiment"
    source_name = "Scientific Experiment"
    base_experience = 60
    cooldown_time = 300
    max_per_round = 8
    compatible_classes = list("research")

/datum/experience_source/research_documentation
    source_id = "research_documentation"
    source_name = "Research Documentation"
    base_experience = 25
    cooldown_time = 120
    max_per_round = 15
    compatible_classes = list("research")

/datum/experience_source/research_breakthrough
    source_id = "research_breakthrough"
    source_name = "Research Breakthrough"
    base_experience = 150
    cooldown_time = 600
    max_per_round = 3
    compatible_classes = list("research")

/datum/experience_source/research_collaboration
    source_id = "research_collaboration"
    source_name = "Research Collaboration"
    base_experience = 35
    cooldown_time = 240
    max_per_round = 10
    compatible_classes = list("research")

// Medical Experience Sources
/datum/experience_source/medical_treatment
    source_id = "medical_treatment"
    source_name = "Medical Treatment"
    base_experience = 30
    cooldown_time = 60
    max_per_round = 20
    compatible_classes = list("medical")

/datum/experience_source/medical_surgery
    source_id = "medical_surgery"
    source_name = "Surgical Procedure"
    base_experience = 80
    cooldown_time = 300
    max_per_round = 6
    compatible_classes = list("medical")

/datum/experience_source/medical_revival
    source_id = "medical_revival"
    source_name = "Patient Revival"
    base_experience = 100
    cooldown_time = 600
    max_per_round = 3
    compatible_classes = list("medical")

/datum/experience_source/medical_diagnosis
    source_id = "medical_diagnosis"
    source_name = "Medical Diagnosis"
    base_experience = 25
    cooldown_time = 120
    max_per_round = 15
    compatible_classes = list("medical")

/datum/experience_source/medical_prevention
    source_id = "medical_prevention"
    source_name = "Disease Prevention"
    base_experience = 50
    cooldown_time = 240
    max_per_round = 8
    compatible_classes = list("medical")

// Engineering Experience Sources
/datum/experience_source/engineering_repair
    source_id = "engineering_repair"
    source_name = "Equipment Repair"
    base_experience = 25
    cooldown_time = 120
    max_per_round = 15
    compatible_classes = list("engineering")

/datum/experience_source/engineering_construction
    source_id = "engineering_construction"
    source_name = "Construction Work"
    base_experience = 40
    cooldown_time = 180
    max_per_round = 10
    compatible_classes = list("engineering")

/datum/experience_source/engineering_maintenance
    source_id = "engineering_maintenance"
    source_name = "System Maintenance"
    base_experience = 30
    cooldown_time = 150
    max_per_round = 12
    compatible_classes = list("engineering")

/datum/experience_source/engineering_emergency
    source_id = "engineering_emergency"
    source_name = "Emergency Response"
    base_experience = 75
    cooldown_time = 300
    max_per_round = 5
    compatible_classes = list("engineering")

/datum/experience_source/engineering_innovation
    source_id = "engineering_innovation"
    source_name = "Engineering Innovation"
    base_experience = 100
    cooldown_time = 600
    max_per_round = 3
    compatible_classes = list("engineering")

// Administrative Experience Sources
/datum/experience_source/admin_coordination
    source_id = "admin_coordination"
    source_name = "Team Coordination"
    base_experience = 35
    cooldown_time = 180
    max_per_round = 10
    compatible_classes = list("administrative")

/datum/experience_source/admin_communication
    source_id = "admin_communication"
    source_name = "Effective Communication"
    base_experience = 25
    cooldown_time = 120
    max_per_round = 15
    compatible_classes = list("administrative")

/datum/experience_source/admin_decision_making
    source_id = "admin_decision_making"
    source_name = "Strategic Decision"
    base_experience = 60
    cooldown_time = 300
    max_per_round = 6
    compatible_classes = list("administrative")

/datum/experience_source/admin_crisis_management
    source_id = "admin_crisis_management"
    source_name = "Crisis Management"
    base_experience = 100
    cooldown_time = 600
    max_per_round = 3
    compatible_classes = list("administrative")

/datum/experience_source/admin_team_success
    source_id = "admin_team_success"
    source_name = "Team Success"
    base_experience = 80
    cooldown_time = 400
    max_per_round = 5
    compatible_classes = list("administrative")

// Containment Experience Sources
/datum/experience_source/containment_scp_interaction
    source_id = "containment_scp_interaction"
    source_name = "SCP Containment"
    base_experience = 50
    cooldown_time = 240
    max_per_round = 8
    compatible_classes = list("containment")

/datum/experience_source/containment_breach_response
    source_id = "containment_breach_response"
    source_name = "Breach Response"
    base_experience = 100
    cooldown_time = 600
    max_per_round = 3
    compatible_classes = list("containment")

/datum/experience_source/containment_procedure
    source_id = "containment_procedure"
    source_name = "Containment Procedure"
    base_experience = 40
    cooldown_time = 180
    max_per_round = 10
    compatible_classes = list("containment")

/datum/experience_source/containment_research
    source_id = "containment_research"
    source_name = "Containment Research"
    base_experience = 60
    cooldown_time = 300
    max_per_round = 6
    compatible_classes = list("containment")

/datum/experience_source/containment_innovation
    source_id = "containment_innovation"
    source_name = "Containment Innovation"
    base_experience = 120
    cooldown_time = 600
    max_per_round = 2
    compatible_classes = list("containment")

// Universal Experience Sources
/datum/experience_source/round_survival
    source_id = "round_survival"
    source_name = "Round Survival"
    base_experience = 200
    cooldown_time = 0
    max_per_round = 1
    compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")

/datum/experience_source/admin_award
    source_id = "admin_award"
    source_name = "Admin Award"
    base_experience = 0 // Set by admin
    cooldown_time = 0
    max_per_round = 999
    compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
