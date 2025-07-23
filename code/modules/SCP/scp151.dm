/obj/structure/scp151
	name = "painting"
	desc = "A painting depicting a rising wave."
	icon = 'icons/scp/scpstructures(32x32).dmi'

	icon_state = "great_wave"
	anchored = TRUE
	density = TRUE

	//Config

	///How much oxygen damage we do per tick
	var/oxy_damage = 1.5
	///Message cooldown
	var/message_cooldown = 15 SECONDS
	///How much water is ingested per tick
	var/water_ingest = 2

/obj/structure/scp151/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"painting", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"151", //Numerical Designation
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MPERSISTENT|MSYNCED
	SCP.memetic_proc = TYPE_PROC_REF(/obj/structure/scp151, effect)
	SCP.compInit()

// Mechanics

/obj/structure/scp151/proc/effect(mob/living/carbon/human/H)
	H.apply_damage(oxy_damage, OXY)
	SEND_SIGNAL(H, COMSIG_SCP151_EFFECT_APPLIED, src)

	var/obj/item/organ/stomach/stomach_organ = H.getorganslot(ORGAN_SLOT_STOMACH)

	stomach_organ.reagents.add_reagent(/datum/reagent/water, water_ingest)

	if((H.getOxyLoss() > 10))
		if((stomach_organ.reagents.maximum_volume - stomach_organ.reagents.total_volume) <= 5)
			H.vomit()
		else if(prob(H.getOxyLoss() + 15))
			H.emote("cough")
	else if(prob(10) && ((world.time - H.humanStageHandler.getStage("151_message_cooldown")) > message_cooldown))
		to_chat(H, span_notice(pick("The taste of seawater permeates your mouth...", "Your lungs feel like they are filling with water...")))
		H.humanStageHandler.setStage("151_message_cooldown", world.time)

	if(prob(H.getOxyLoss() + 30) && (H.getOxyLoss() > 25) && ((world.time - H.humanStageHandler.getStage("151_message_cooldown")) > message_cooldown))
		to_chat(H, span_warning(pick("Your lungs feel like they are filled with water!", "You try to breath but your lungs are filled with water!", "You cannot breath!")))
		H.humanStageHandler.setStage("151_message_cooldown", world.time)
