/obj/machinery/scp294
	name = "coffee machine"
	desc = "A standard coffee vending machine. This one seems to have a QWERTY keyboard."
	icon = 'icons/SCP/scp294.dmi'

	icon_state = "coffee_294"
	anchored = TRUE
	density = TRUE

	//Config

	///How long to wait until we can use again
	var/usage_cooldown = 15 MINUTES
	///How many times we can use the machine before it needs to cooldown
	var/max_uses = 30

	//Mechanical

	///Tracks our usage cooldown
	var/usage_cooldown_tracker
	///Tracks our uses
	var/uses_tracker
	///Have we started restock?
	var/started_restock = FALSE
	///Reagent types

	///Shortcut names for things like "poision" or "death" where it dosent match a reagent name exactly
	var/list/shortcut_chems = list(
		"spider" = /datum/reagent/toxin/venom,
		"death" = /datum/reagent/toxin/cyanide,
		"joe" = /datum/reagent/blood,
		"hair dye" = /datum/reagent/hair_dye,
		"plant nutriment" = /datum/reagent/plantnutriment,
		"ez nutriment" = /datum/reagent/plantnutriment/eznutriment,
		"fungal tuberculosis vaccine" = /datum/reagent/vaccine/fungal_tb,
		"tubercle bacillus cosmosis microbes" = /datum/reagent/fungalspores,
		"toxin" = /datum/reagent/toxin,
		"hot ice" = /datum/reagent/toxin/hot_ice,
		"fake beer" = /datum/reagent/toxin/fakebeer,
		"tirizene" = /datum/reagent/toxin/staminatoxin,
		"pump up" = /datum/reagent/drug/pumpup,
		"class a amnestics" = /datum/reagent/medicine/amnestics/classa,
		"class b amnestics" = /datum/reagent/medicine/amnestics/classb,
		"class c amnestics" = /datum/reagent/medicine/amnestics/classc,
		"class e amnestics" = /datum/reagent/medicine/amnestics/classe,
		"class f amnestics" = /datum/reagent/medicine/amnestics/classf,
		"class g amnestics" = /datum/reagent/medicine/amnestics/classg,
		"class h amnestics" = /datum/reagent/medicine/amnestics/classh,
		"class i amnestics" = /datum/reagent/medicine/amnestics/classi
	)

	///Blacklisted reagents DO NOT USE THIS UNLESS ABSOLUTLEY NECCESARY, I DISLIKE PEOPLE IDIOT PROOFING SCPS - Dark
	var/list/blacklist = list(
	)

	///Custom effect definitions
	var/list/custom_effect_definitions = list(
		new /datum/scp294_custom_effect/music(),
		new /datum/scp294_custom_effect/clarity(),
		new /datum/scp294_custom_effect/purity()
	)

/* TD: Need to be readded to the above blacklist once implemented.
		/datum/reagent/scp008,
		/datum/reagent/scp500

*/

/obj/machinery/scp294/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"coffee machine", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"294", //Numerical Designation
	)
//Mechanics

///Cycles through all reagents datums and picks out ones that contain the chemical we are looking for
/obj/machinery/scp294/proc/find_reagents_to_fill_from(input_path)
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE
	var/list/z_level_stack = SSmapping.get_zstack(current_turf.z, include_lateral = TRUE)
	if(!z_level_stack)
		return FALSE
	return SSreagents.get_reagent_sources_by_type(input_path, z_level_stack)

///Adds reagent we want to passed cup from list made in find_reagents_to_fill_from
/obj/machinery/scp294/proc/add_reagent_to_cup(input_path, D, reagents_to_fill_from)
	var/obj/item/reagent_containers/food/drinks/sillycup/cup = D
	var/amount_need_filled = cup.volume
	if(!ispath(input_path) || !istype(cup) || !islist(reagents_to_fill_from))
		return
	for(var/datum/reagents/reagent_container in reagents_to_fill_from)
		var/amount_contained = reagent_container.get_reagent_amount(input_path)

		amount_contained = clamp(amount_contained, 0, amount_need_filled)
		cup.reagents.add_reagent(input_path, amount_contained)
		reagent_container.remove_reagent(input_path, amount_contained)

		amount_need_filled -= amount_contained

		if(amount_need_filled <= 0)
			break

	cup.reagents.update_total()
	cup.on_reagent_change()

//Overrides

/obj/machinery/scp294/attack_hand(mob/living/user)
	if(user.combat_mode)
		return ..()

	if(((world.time - usage_cooldown_tracker) > usage_cooldown) && uses_tracker >= max_uses)
		uses_tracker = 0
		started_restock = FALSE

	if(uses_tracker >= max_uses)
		balloon_alert(user, "RESTOCKING...")
		if(!started_restock)
			usage_cooldown_tracker = world.time
			started_restock = TRUE
		return

	playsound(src, 'sound/machines/cb_button.ogg', 35, TRUE)
	var/chosen_reagen_text = tgui_input_text(user, "Please type in your preferred beverage.", "[src] Keyboard")
	if(!chosen_reagen_text)
		return

	var/datum/scp294_custom_effect/chosen_custom_effect

	for(var/datum/scp294_custom_effect/effect in custom_effect_definitions)
		if(findtext(chosen_reagen_text, effect.name, 1, length(chosen_reagen_text) + 1))
			chosen_custom_effect = effect
			break

	if(chosen_custom_effect)
		uses_tracker++
		playsound(src, 'sound/scp/scp294/dispense1.ogg', 35, FALSE)
		visible_message(span_notice("[src] dispenses a small paper cup and starts filling it with a liquid."))
		log_admin("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_custom_effect.name] (custom effect)", user, get_turf(src))
		message_admins(span_notice("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_custom_effect.name] (custom effect)"))

		SEND_SIGNAL(src, COMSIG_SCP294_DISPENSE_ATTEMPT, user, chosen_custom_effect)

		var/obj/item/reagent_containers/food/drinks/sillycup/D = new /obj/item/reagent_containers/food/drinks/sillycup(get_turf(src))
		D.anchored = TRUE
		D.desc = chosen_custom_effect.description
		D.icon_state = chosen_custom_effect.icon_state
		D.custom_scp294_effect = chosen_custom_effect // Attach the custom effect datum to the cup
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finish_dispensing_cup), D, chosen_custom_effect.reagent_to_add, find_reagents_to_fill_from(chosen_custom_effect.reagent_to_add)), 3 SECONDS)
		return

	var/datum/reagent/chosen_reagent

	for(var/reagent_name in shortcut_chems)
		if(findtext(chosen_reagen_text, reagent_name, 1, length(chosen_reagen_text) + 1))
			chosen_reagent = shortcut_chems[reagent_name]
			break

	if(!chosen_reagent)
		for(var/datum/reagent/possible as anything in subtypesof(/datum/reagent))
			if(isabstract(possible) || !initial(possible.name))
				continue
			var/chem_name = initial(possible.name) //It dosent work if we dont do this black magic
			if(findtext(chosen_reagen_text, chem_name))
				chosen_reagent = possible
				break

	if(!chosen_reagent || (chosen_reagent in blacklist))
		balloon_alert(user, "OUT OF RANGE")
		playsound(src, 'sound/machines/cb_button_fail.ogg', 35, TRUE)
		return

	var/list/reagents_to_fill_from = find_reagents_to_fill_from(chosen_reagent)
	if(!LAZYLEN(reagents_to_fill_from))
		balloon_alert(user, "OUT OF RANGE")
		playsound(src, 'sound/machines/cb_button_fail.ogg', 35, TRUE)
		return

	uses_tracker++
	playsound(src, 'sound/scp/scp294/dispense1.ogg', 35, FALSE)
	visible_message(span_notice("[src] dispenses a small paper cup and starts filling it with a liquid."))
	log_admin("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_reagent]", user, get_turf(src))
	message_admins(span_notice("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_reagent]"))

	SEND_SIGNAL(src, COMSIG_SCP294_DISPENSE_ATTEMPT, user, chosen_reagent)

	var/obj/item/reagent_containers/food/drinks/sillycup/D = new /obj/item/reagent_containers/food/drinks/sillycup(get_turf(src))
	D.anchored = TRUE
	D.desc = "A strange paper cup."
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finish_dispensing_cup), D, chosen_reagent, reagents_to_fill_from), 3 SECONDS)

/obj/machinery/scp294/proc/finish_dispensing_cup(obj/item/reagent_containers/food/drinks/sillycup/D, datum/reagent/chosen_reagent, list/reagents_to_fill_from)
	add_reagent_to_cup(chosen_reagent, D, reagents_to_fill_from)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finalize_cup_unanchoring), D), 10) // Increased delay to 10 ticks

/obj/machinery/scp294/proc/finalize_cup_unanchoring(obj/item/reagent_containers/food/drinks/sillycup/D)
	D.anchored = FALSE
	return

// Custom Liquids - This is for more Abstract liquids that aren't in the shortcuts list or a definable "reagent"

/datum/scp294_custom_effect
	var/name = "Abstract Liquid"
	var/description = "A strange, unidentifiable liquid."
	var/icon_state = "sillycup" // Default icon state for the cup
	var/reagent_to_add = /datum/reagent/water // Default reagent to add to the cup

/datum/scp294_custom_effect/proc/apply_effect(mob/living/user)
	// This proc will be overridden by specific custom effects
	// It will contain the logic for what happens when the drink is consumed.
	return

/datum/scp294_custom_effect/music
	name = "Music"
	reagent_to_add = /datum/reagent/water

/datum/scp294_custom_effect/music/apply_effect(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You feel a continuous rhythm pulsating through your body, and a sudden urge to dance!"))
	to_chat(user, span_notice("Your movements become more fluid and energetic!"))

	user.add_movespeed_modifier(/datum/movespeed_modifier/music_buff) // Add the modifier first

	var/datum/movespeed_modifier/music_buff/M = user.has_movespeed_modifier(/datum/movespeed_modifier/music_buff) // Get the actual instance

	if(M)
		var/sound_path = 'sound/scp/scp294/SCP294song.ogg'
		var/max_volume = 30 // Max volume for the music

		user.playsound_local(user, sound_path, max_volume, channel = CHANNEL_294_MUSIC)
		M.stamina_holder_ref = user.stamina
		M.start_music_stamina_effect()

	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/music_buff), 990) // Remove buff after 1 minute and 39 seconds
	return

/datum/movespeed_modifier/music_buff
	variable = TRUE
	slowdown = -2 // Speed buff
	priority = 10
	var/fumble_chance = 10 // Default fumble chance for the buff
	var/is_music_stamina_active = FALSE
	var/is_burnt_out = FALSE
	var/burnout_timer_id
	var/datum/stamina_container/stamina_holder_ref


/datum/movespeed_modifier/music_buff/proc/start_music_stamina_effect()
	is_music_stamina_active = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_music_stamina_effect)), 990) // End high regen after music duration
	return

/datum/movespeed_modifier/music_buff/proc/end_music_stamina_effect()
	is_music_stamina_active = FALSE
	is_burnt_out = TRUE
	if(stamina_holder_ref)
		stamina_holder_ref.adjust(-STAMINA_BURNOUT_HIT)
	burnout_timer_id = addtimer(CALLBACK(src, PROC_REF(end_burnout_effect)), STAMINA_BURNOUT_DURATION)
	return

/datum/movespeed_modifier/music_buff/proc/end_burnout_effect()
	is_burnt_out = FALSE
	if(burnout_timer_id)
		deltimer(burnout_timer_id)
		burnout_timer_id = null
	return

/datum/scp294_custom_effect/clarity
	name = "Clarity"
	description = "A liquid that grants unsettling insights."
	icon_state = "sillycup"
	reagent_to_add = /datum/reagent/water

/datum/scp294_custom_effect/clarity/apply_effect(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You understand far too much. That can’t be good."))

	var/list/all_messages = list()

	// Information about potential future events
	var/list/potential_events = list()
	var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.canSpawnEvent(players_amt))
			potential_events += E.name
	if(potential_events.len)
		all_messages += span_info("You glimpse threads of fate, revealing [english_list(potential_events)] on the horizon.")

	// Information about currently running events
	var/list/running_events = list()
	for(var/datum/round_event/R as anything in SSevents.running)
		if(R.control && R.control.name) // Ensure control and its name exist
			running_events += R.control.name
	if(running_events.len)
		all_messages += span_info("A chilling clarity reveals the present: [english_list(running_events)] already unfold.")

	if(all_messages.len) // Ensure there are messages to display
		var/chosen_message = pick(all_messages) // Pick one random message
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/scp294_custom_effect/clarity, display_single_clarity_message), user, chosen_message), 10) // Display the chosen message after 1 second
	return

/datum/scp294_custom_effect/clarity/proc/display_single_clarity_message(mob/living/user, message_to_display)
	if(!user || !message_to_display) // Basic checks
		return
	to_chat(user, message_to_display)
	return

/datum/scp294_custom_effect/purity
	name = "Purity"
	description = "A cleansing liquid that purges all chemicals."
	icon_state = "sillycup"
	reagent_to_add = /datum/reagent/water // We'll make it add water, and then apply the effect

/datum/scp294_custom_effect/purity/apply_effect(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You feel a profound cleansing as all foreign substances are purged from your system."))
	if(user.reagents)
		user.reagents.clear_reagents()
		user.reagents.update_total()
	return
