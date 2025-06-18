/obj/machinery/floodlight
	name = "emergency floodlight"
	desc = "A high-intensity flood lamp on a wheeled platform. It runs on a replaceable power cell."
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "floodlight"
	density = TRUE

	active_power_usage = 200
	power_channel = AREA_USAGE_LIGHT
	use_power = NO_POWER_USE

	/// Brightness of the light when on. Can be negative.
	var/lamp_brightness = 0.8
	/// Inner range of the light when on. Can be negative
	var/lamp_inner_range = 0
	/// Outer range of the light when on. Can be negative.
	var/lamp_outer_range = 4.5

/obj/machinery/floodlight/update_icon()
	..()
	cut_overlays()
	// We build the floodlight's appearance using overlays based on its status
	if (use_power == ACTIVE_POWER_USE)
		add_overlay("floodlight_on")
	if (panel_open)
		add_overlay("floodlight_open")
		if (get_cell())
			add_overlay("floodlight_open_cell")

/obj/machinery/floodlight/power_change()
	. = ..()
	if (!. || !use_power)
		return
	if (machine_stat & NOPOWER)
		turn_off()
		return

/// Turns on the floodlight, returning TRUE on a success or FALSE otherwise. If loud is defined, it will show a message and play a sound.
/obj/machinery/floodlight/proc/turn_on(loud = TRUE)
	if (!is_operational)
		return
	set_light(lamp_brightness, lamp_inner_range, lamp_outer_range)
	update_use_power(ACTIVE_POWER_USE)
	use_power(active_power_usage) //so we drain cell if they keep trying to use it
	update_icon()
	if (loud)
		visible_message(span_notice("\The [src] turns on."))
		playsound(src, 'sound/weapons/magin.ogg', 50)
	return TRUE

/// Turns off the floodlight. Doesn't return anything. If loud is defined, it will show a message and play a sound.
/obj/machinery/floodlight/proc/turn_off(loud = TRUE)
	set_light(0, 0)
	update_use_power(NO_POWER_USE)
	update_icon()
	if (loud)
		visible_message(span_notice("\The [src] shuts down."))
		playsound(src, 'sound/weapons/magin.ogg', 50)

/obj/machinery/floodlight/interact(mob/user)
	if (!src.can_interact(user))
		return FALSE
	if (use_power)
		turn_off()
	else
		if (!turn_on())
			to_chat(user, span_warning("You try to turn on \the [src], but nothing happens."))
			playsound(loc, 'sound/weapons/magin.ogg', 50)

	update_icon()
	return TRUE

/obj/machinery/floodlight/proc/get_component_rating_of_type(type_path)
	var/total_rating = 0
	if(component_parts)
		for(var/obj/item/stock_parts/part in component_parts)
			if(istype(part, type_path))
				total_rating += part.energy_rating
	return total_rating

/obj/machinery/floodlight/RefreshParts() //if they're insane enough to modify a floodlight, let them
	..()
	var/light_mod = max(0, min(src.get_component_rating_of_type(/obj/item/stock_parts/capacitor), 10))
	lamp_brightness = light_mod ? light_mod * 0.01 + initial(lamp_brightness) : initial(lamp_brightness) / 2 //gives us between 0.8-0.9 with capacitor, or 0.4 without one
	lamp_inner_range = light_mod + initial(lamp_inner_range)
	lamp_outer_range = light_mod * 1.5 + initial(lamp_outer_range)
	update_mode_power_usage(ACTIVE_POWER_USE, initial(active_power_usage) * light_mod)
	if (use_power)
		set_light(lamp_brightness, lamp_inner_range, lamp_outer_range)

/obj/machinery/floodlight/wallmounted
	name = "Mounted Floodlight"
	desc = "A wall mounted floodlight for a broader range of illumintion needs."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "wallfloodlight"

//Needs a frame item
