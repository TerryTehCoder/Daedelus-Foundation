//This file contains all SCP definitions for the research system.

/datum/controller/subsystem/research/proc/load_scp_definitions()
	var/datum/scp_definition/def_012 = new()
	def_012.id_tag = "012"
	def_012.name = "On Mount Golgotha"
	def_012.cost = 100
	def_012.obj_class_label = SCP_EUCLID
	var/datum/scp_test/proximity = new()
	proximity.name = "Proximity Exposure"
	proximity.description = "Observe a subject's reaction to being in close proximity to SCP-012 for an extended period."
	proximity.hypothesis = "Subjects exposed to SCP-012 for an extended period will exhibit signs of psychological distress and potentially self-harm."
	proximity.procedure = "1. Place a handcuffed, conscious subject in a sealed room with SCP-012.\n2. Observe the subject for a minimum of 5 minutes.\n3. Record any unusual behavior or statements."
	proximity.risks = "Subject may attempt self-harm or suicide. Memetic effects may spread to observers if not properly shielded."
	proximity.required_equipment = "Handcuffs, observation room with one-way glass."
	proximity.reward_rp = 20
	proximity.reward_lp = 5
	proximity.check_completion = /obj/item/paper/scp012/proc/check_proximity_test
	var/datum/scp_test/sound_damp = new()
	sound_damp.name = "Sound Dampening"
	sound_damp.description = "Test the effectiveness of sound-dampening equipment on SCP-012's audible memetic properties."
	sound_damp.hypothesis = "Sound-dampening equipment will mitigate or nullify the audible memetic effects of SCP-012."
	sound_damp.procedure = "1. Place a conscious subject in a sealed room with SCP-012.\n2. Equip the subject with sound-dampening headgear.\n3. Observe the subject for any signs of memetic influence."
	sound_damp.risks = "If the equipment fails, the subject will be exposed to the full memetic effect of SCP-012."
	sound_damp.required_equipment = "Sound-dampening headset."
	sound_damp.reward_rp = 50
	sound_damp.reward_lp = 10
	sound_damp.check_completion = /obj/item/paper/scp012/proc/check_sound_damp_test
	def_012.tests = list(proximity, sound_damp)
	add_scp_definition(def_012)

	var/datum/scp_definition/def_013 = new()
	def_013.id_tag = "013"
	def_013.name = "'Blue Lady' cigarette"
	def_013.cost = 0 // Unlocked by default
	def_013.obj_class_label = SCP_SAFE
	var/datum/scp_test/analysis = new()
	analysis.name = "Chemical Analysis"
	analysis.description = "Analyze the chemical composition of an unlit SCP-013 cigarette."
	analysis.hypothesis = "The chemical composition of SCP-013 is anomalous and does not match any known terrestrial substance."
	analysis.procedure = "1. Place an unlit SCP-013 cigarette into a chemical analyzer.\n2. Run a full-spectrum analysis.\n3. Compare the results to known chemical databases."
	analysis.risks = "None known."
	analysis.required_equipment = "Chemical analyzer."
	analysis.reward_rp = 20
	analysis.reward_lp = 5
	analysis.check_completion = /obj/item/clothing/mask/cigarette/scp013/proc/check_analysis_test
	def_013.tests = list(analysis)
	add_scp_definition(def_013)
	unlocked_scps.Add(def_013.id_tag)
