/obj/item/scp113
	name = "red piece of quartz"
	desc = "A red piece of quartz that gleams with unnatural smoothness."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp113"

	force = 10.0
	throwforce = 10.0
	throw_range = 15
	throw_speed = 3

	var/list/victims = list()

/obj/item/scp113/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"red piece of quartz", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"113", //Numerical Designation
	)
	RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(handle_item_pickup))
	RegisterSignal(src, COMSIG_ITEM_UNEQUIPPED, PROC_REF(handle_item_unequipped))

//Mechanics

//Overrides

/obj/item/scp113/proc/handle_item_pickup(datum/source, mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/hand_covered = H.active_hand_index == LEFT_HANDS ? HAND_LEFT : HAND_RIGHT //determines which hand needs to be covered
	ADD_TRAIT(src, TRAIT_NODROP, SCP113_TRAIT)

	for(var/obj/item/clothing/C in H.get_equipped_items())
		if(C.body_parts_covered & hand_covered)
			return

	if(H.humanStageHandler.getStage("113_conversions") >= 1)
		if(prob(5 * H.humanStageHandler.getStage("113_conversions")))
			H.gib()
			return
		if(prob(20 * H.humanStageHandler.getStage("113_conversions")))
			H.apply_damage(100, BRUTE, GROIN)
			H.visible_message(span_warning("[H]'s groin suddenly and violently explodes!"), span_danger("You feel a horrible pain in your groin area!"))
			return

	H.humanStageHandler.setStage("113_effect", 0)
	H.AddComponent(/datum/component/scp113_effect_handler, H, src)
	SEND_SIGNAL(H, COMSIG_SCP113_EFFECT_STAGE_1, H)

/obj/item/scp113/proc/handle_item_unequipped(datum/source, mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	qdel(H.GetComponent(/datum/component/scp113_effect_handler))
	SEND_SIGNAL(H, COMSIG_SCP113_EFFECT_STAGE_1, H, 0)
