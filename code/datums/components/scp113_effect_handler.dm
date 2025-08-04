/datum/component/scp113_effect_handler
	var/mob/living/carbon/human/user_mob
	var/obj/item/scp113/scp_item // Reference to the SCP-113 item being handled for TRAITS.

/datum/component/scp113_effect_handler/Initialize(mob/living/carbon/human/user, obj/item/scp113/scp_object)
	. = ..()
	user_mob = user
	scp_item = scp_object
	RegisterSignal(user_mob, COMSIG_SCP113_EFFECT_STAGE_1, PROC_REF(handle_stage_1))
	RegisterSignal(user_mob, COMSIG_SCP113_EFFECT_STAGE_2, PROC_REF(handle_stage_2))
	RegisterSignal(user_mob, COMSIG_SCP113_EFFECT_STAGE_3, PROC_REF(handle_stage_3))
	RegisterSignal(user_mob, COMSIG_SCP113_EFFECT_STAGE_4, PROC_REF(handle_stage_4))

/datum/component/scp113_effect_handler/proc/handle_stage_1(datum/source, mob/living/carbon/human/user)
	if(user != user_mob)
		return

	to_chat(user, span_warning("The SCP-113 begins to sear your hand, burning the skin on contact, and you feel yourself unable to drop it."))
	var/hand_used = user.active_hand_index == LEFT_HANDS ? HAND_LEFT : HAND_RIGHT // determine hand to burn
	user.apply_damage(5, BURN, hand_used) //administer damage
	user.apply_damage(10, TOX, hand_used)
	addtimer(CALLBACK(src, PROC_REF(dispatch_signal_on_user), COMSIG_SCP113_EFFECT_STAGE_2, user), 0.2 SECONDS)

/datum/component/scp113_effect_handler/proc/handle_stage_2(datum/source, mob/living/carbon/human/user)
	if(user != user_mob)
		return

	to_chat(user, span_notice("You feel a weird stinging sensation throughout your body."))
	if(prob(45))
		user.vomit()
	addtimer(CALLBACK(src, PROC_REF(dispatch_signal_on_user), COMSIG_SCP113_EFFECT_STAGE_3, user), 20 SECONDS)

/datum/component/scp113_effect_handler/proc/handle_stage_3(datum/source, mob/living/carbon/human/user)
	if(user != user_mob)
		return

	to_chat(user, span_warning("Bones begin to shift and grind inside of you, and every single one of your nerves seems like it's on fire!"))
	user.visible_message(span_notice("\The [user] starts to scream and writhe in pain as their bone structure reforms."))
	addtimer(CALLBACK(src, PROC_REF(dispatch_signal_on_user), COMSIG_SCP113_EFFECT_STAGE_4, user), 60 SECONDS)

/datum/component/scp113_effect_handler/proc/handle_stage_4(datum/source, mob/living/carbon/human/user)
	if(user != user_mob)
		return

	to_chat(user, span_warning("The burning begins to fade, and you feel your hand relax its grip on the quartz."))
	if(user.humanStageHandler.getStage("BlueLady"))
		if(user.gender == MALE)
			to_chat(user, span_notice("A vast sense of relief washes over you, as you feel your body reshape itself to be more like hers.."))
		else
			to_chat(user, span_warning("There's something you can't see, and it feels unbearably wrong. It's all wrong. You weren't ... she wasn't ... a man."))
	if (user.gender == MALE)
		user.gender = FEMALE
	else
		user.gender = MALE
	user.dna.update_dna_identity()
	user.update_body()
	user.humanStageHandler.adjustStage("113_conversions", 1)
	REMOVE_TRAIT(scp_item, TRAIT_NODROP, SCP113_TRAIT)
	qdel(src) // Effect complete, remove the handler

/datum/component/scp113_effect_handler/proc/dispatch_signal_on_user(signal_type, mob/living/carbon/human/user)
	SEND_SIGNAL(user_mob, signal_type, user)
