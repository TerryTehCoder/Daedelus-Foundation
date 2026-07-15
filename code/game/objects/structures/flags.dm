/var/list/all_flag_variants
/var/list/flag_state_to_type

/proc/populate_flag_variants()
	if(all_flag_variants)
		return
	all_flag_variants = list()
	flag_state_to_type = list()
	for(var/flag_type in typesof(/obj/structure/flag_base))
		var/obj/structure/flag_base/F = new flag_type
		if(F.flag_icon_state)
			all_flag_variants[F.name] = F.flag_icon_state
			flag_state_to_type[F.flag_icon_state] = flag_type
		qdel(F)

/obj/structure/flag_base
	name = "flag pole"
	desc = "A sturdy pole designed to display flags."
	icon = 'icons/obj/flags.dmi' //If for whatever reason you want a custom pole icon down the line.
	icon_state = "pole64" // Default pole icon state for 64px height
	var/flag_icon = 'icons/obj/flags.dmi'
	var/flag_icon_state = "flag_default"
	layer = ABOVE_MOB_LAYER
	var/current_pole_height = 64 // Current pole height in pixels
	var/max_pole_height = 64 // Maximum pole height in pixels
	var/min_pole_height = 48 // Minimum pole height in pixels
	var/pole_height_step = 4 // How much to change height per action

/obj/structure/flag_base/examine(mob/user)
	. = ..()
	. += span_notice("Left click to lower the flagpole, right click to raise.")
	. += span_notice("Alt-click to change the flag displayed.")

	// How /DOES/ the flag move without wind???
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.unsafe_return_air()
	var/pressure = environment.returnPressure()
	if(pressure < WARNING_LOW_PRESSURE)
		. += span_notice("There's no wind... how is it moving? I suspect microscopic space elves personally..")

/obj/structure/flag_base/Initialize()
	. = ..()
	icon_state = "pole[current_pole_height]" // Set initial pole icon state
	update_flag_overlay()

/obj/structure/flag_base/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	icon_state = "pole[current_pole_height]" // Update pole icon state when moved
	update_flag_overlay()

/obj/structure/flag_base/proc/update_flag_overlay()
	overlays.Cut() // Clear existing overlays
	if(flag_icon_state)
		var/image/flag_overlay = image(flag_icon, icon_state = flag_icon_state)
		flag_overlay.pixel_y = current_pole_height - min_pole_height - 16 // Position flag relative to pole top
		if(dir == WEST) //We do some fancy magic to flip the flag if it's facing west.
			flag_overlay.transform = matrix().Scale(-1, 1) //I am Not making dozens of west facing variants.
		overlays += flag_overlay

/obj/structure/flag_base/attack_hand(mob/user)
	if(!iscarbon(user))
		return ..()

	if(current_pole_height > min_pole_height)
		current_pole_height -= pole_height_step
		icon_state = "pole[current_pole_height]" // Update pole icon state
		playsound(loc, 'sound/structures/safe_toggle.ogg', 25, 1)
		update_flag_overlay()
		to_chat(user, span_notice("You lower the flag pole."))
	else
		to_chat(user, span_warning("The flag pole is already at its minimum height."))
	return TRUE

/obj/structure/flag_base/attack_hand_secondary(mob/user, list/modifiers)
	if(!iscarbon(user))
		return ..()

	if(current_pole_height < max_pole_height)
		current_pole_height += pole_height_step
		icon_state = "pole[current_pole_height]" // Update pole icon state
		playsound(loc, 'sound/structures/safe_toggle.ogg', 25, 1)
		update_flag_overlay()
		to_chat(user, span_notice("You raise the flag pole."))
	else
		to_chat(user, span_warning("The flag pole is already at its maximum height."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/flag_base/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, TRUE))
		return

	populate_flag_variants()
	var/list/choices = list()
	choices["none"] = image('icons/effects/effects.dmi', "nothing") // "No Flag" option
	for(var/flag_name in all_flag_variants)
		var/flag_state = all_flag_variants[flag_name]
		var/image/flag_image = image(flag_icon, icon_state = flag_state)
		flag_image.pixel_y = -32 // Center the flag in the radial menu
		choices[flag_state] = flag_image

	var/selection = show_radial_menu(user, src, choices, require_near = TRUE)

	if(selection && user.canUseTopic(src, TRUE))
		if(selection == "none")
			if(flag_icon_state) // How will you take down a flag that isn't there?
				flag_icon_state = null
				name = initial(name)
				desc = initial(desc)
				playsound(loc, 'sound/items/handling/cloth_drop.ogg', 20, 1)
			else
				to_chat(user, span_warning("There is no flag to take down."))
		else
			flag_icon_state = selection
			var/flag_type = flag_state_to_type[selection]
			var/obj/structure/flag_base/F = new flag_type
			name = F.name
			desc = F.desc
			qdel(F)
			playsound(loc, 'sound/items/handling/cloth_pickup.ogg', 20, 1)
		update_flag_overlay()


// Nautical Flags

/obj/structure/flag_base/bravo
	name = "Bravo Flag"
	flag_icon_state = "flag_bravo"
	desc = "A flag suggesting the flyer is taking in, discharging, or otherwise dealing with dangerous cargo. "


/obj/structure/flag_base/charlie
	name = "Charlie Flag"
	flag_icon_state = "flag_charlie"
	desc = "A flag flown to provide an Affirmative response. When flown with November, it indicates distress."


/obj/structure/flag_base/foxtrot
	name = "Foxtrot Flag"
	flag_icon_state = "flag_foxtrot"
	desc = "A flag suggesting the flyer is contacted by other ships or vessels due to distress or disablement."


/obj/structure/flag_base/green
	name = "Green Flag"
	flag_icon_state = "flag_green"
	desc = "A green flag. Its message is unclear, but green is often used to indicate safety or permission to proceed."


/obj/structure/flag_base/red
	name = "Red Flag"
	flag_icon_state = "flag_red"
	desc = "A red flag. Its message is unclear, but in most cultures red generally means danger, bad, or stop."


/obj/structure/flag_base/lima
	name = "Lima Flag"
	flag_icon_state = "flag_lima"
	desc = "A flag that says Stop Immediately to any other ships or vessels that may see it."


/obj/structure/flag_base/november
	name = "November Flag"
	flag_icon_state = "flag_november"
	desc = "A flag flown to provide a Negative response. When flown with Charlie, it indicates distress."


/obj/structure/flag_base/tango
	name = "Tango Flag"
	flag_icon_state = "flag_tango"
	desc = "A flag that suggests viewing vessels keep clear of the ship or facility bearing it. It might also apply to people when in a particularly bad mood."


/obj/structure/flag_base/victor
	name = "Victor Flag"
	flag_icon_state = "flag_victor"
	desc = "Generally used to indicate that a ship or facility is in need of assistance, or that it is in distress."


/obj/structure/flag_base/xray
	name = "Xray Flag"
	flag_icon_state = "flag_xray"
	desc = "A flag that suggests viewers stop what they're doing, and look for the flyers signals. An arguably common sight given the lack of communication in most flag flying facilities."


/obj/structure/flag_base/redstripe
	name = "Redstripe Flag"
	flag_icon_state = "flag_redstripe"
	desc = "A flag with a red and white stripe pattern. You can't derive any particular meaning from it, but then again not all things in life seem to have a purpose."

// Misc Flags

/obj/structure/flag_base/moon
	name = "Moon Flag"
	flag_icon_state = "flag_moon"
	desc = "A flag with a full moon and a starry sky shining across it. Long seen as a symbol of tranquility."


/obj/structure/flag_base/noentry
	name = "No-entry Flag"
	flag_icon_state = "flag_noentry"
	desc = "This flags meaning is clear, viewers are not permitted to enter the area it's flown in. But then again, you could just ignore it."


/obj/structure/flag_base/asexual
	name = "Asexual Flag"
	flag_icon_state = "flag_asexual"
	desc = "A flag representing the asexual community, with a black stripe for asexuality, a gray stripe for gray-asexuality, a white stripe for non-asexual partners, and a purple stripe for the community itself."


/obj/structure/flag_base/bisexual
	name = "Bisexual Flag"
	flag_icon_state = "flag_bisexual"
	desc = "A flag representing the bisexual community, with a pink stripe for attraction to women, a blue stripe for attraction to men, and a purple stripe for attraction to both."


/obj/structure/flag_base/femboy
	name = "Femboy Flag"
	flag_icon_state = "flag_femboy"
	desc = "This flag elicits in you a desire to wear womens clothing, and to spin around in circles."


/obj/structure/flag_base/gay
	name = "Gay Flag"
	flag_icon_state = "flag_gay"
	desc = "A flag representing the gay community, for those who enjoy the good company of men."


/obj/structure/flag_base/lesbian
	name = "Lesbian Flag"
	flag_icon_state = "flag_lesbian"
	desc = "A flag representing the lesbian community, for all who love women."


/obj/structure/flag_base/nyanbinary
	name = "Non-Binary Flag"
	flag_icon_state = "flag_nyanbinary"
	desc = "A flag representing the non-binary community, with a yellow stripe for non-binary identities, a purple stripe for genderqueer identities, and a blue stripe for genderfluid identities."


/obj/structure/flag_base/pansexual
	name = "Pansexual Flag"
	flag_icon_state = "flag_pansexual"
	desc = "A flag representing the pansexual community, for those who love all people, regardless of gender identity."


/obj/structure/flag_base/quebec
	name = "Quebec Flag"
	flag_icon_state = "flag_quebec"
	desc = "A flag representing the province of Quebec, a Canadian region known for its French-speaking population."


/obj/structure/flag_base/bakersrainbow
	name = "Bakersrainbow Flag"
	flag_icon_state = "flag_bakersrainbow"
	desc = "A flag with a rainbow pattern, representing the diversity of the LGBTQIA+ Community. It is often used to symbolize inclusivity and acceptance."


/obj/structure/flag_base/trans
	name = "Trans Flag"
	flag_icon_state = "flag_trans"
	desc = "A blue, pink, and white striped flag, representing the transgender community. The blue represents masculinity, the pink represents femininity, and the white represents those who are transitioning or identify as non-binary."
