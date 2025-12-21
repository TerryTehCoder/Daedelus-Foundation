//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1
	var/consumption = 0
	var/base_icon = "portgen0"
	var/datum/looping_sound/generator/soundloop
	var/start_up_time = 2 SECONDS
	var/start_up_chance = 60 //Percentage chance of successful startup.

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

/obj/machinery/power/port_gen/Initialize(mapload)
	. = ..()
	soundloop = new(src, active)

/obj/machinery/power/port_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/port_gen/should_have_node()
	return anchored

/obj/machinery/power/port_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return TRUE

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/proc/TogglePower(mob/user)
	if(active)
		active = FALSE
		update_appearance()
		soundloop.stop()

		/* We shouldn't have to do this because of the soundloop system, but sound_end has been broken since forever (11.16.25)
		// Workaround
		SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_GENERATOR))
		playsound(src, 'sound/machines/generator/generator_end.ogg', 50, TRUE, channel = CHANNEL_GENERATOR)
		*/

	else if(HasFuel())
		if(!anchored)
			to_chat(user, span_warning("You try to start the [src], but it won't stay in place! You need to anchor it first."))
			playsound(src, 'sound/machines/generator/gen_pull.ogg', 50, TRUE)
			return

		if(do_after(user, src, start_up_time))
			if(prob(start_up_chance))
				to_chat(user, span_notice("You manage to start the [src]'s engine."))
				active = TRUE
				START_PROCESSING(SSmachines, src)
				update_appearance()
				soundloop.start()
			else
				to_chat(user, span_warning("You tug at the starter cord, but the [src]'s engine sputters and dies."))
				playsound(src, 'sound/machines/generator/gen_pull.ogg', 50, TRUE)

/obj/machinery/power/port_gen/update_icon_state()
	if(active)
		icon_state = "[base_icon]_[active]"
	else
		icon_state = base_icon
	return ..()

/obj/machinery/power/port_gen/process()
	if(active)
		if(!HasFuel() || !anchored)
			TogglePower()
			return
		if(powernet)
			add_avail(power_gen * power_output)
		UseFuel()
	else
		handleInactive()

/obj/machinery/power/port_gen/examine(mob/user)
	. = ..()
	. += "It is[!active?"n't":""] running."

/////////////////
// Coal Generators //
/////////////////
/obj/machinery/power/port_gen/coal
	name = "portable coal generator"
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/coal
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 260
	var/current_heat = 0
	var/stationary = FALSE

/obj/machinery/power/port_gen/coal/falcon
	name = "C-60 \"Falcon\" Generator"
	desc = "A rugged mid-tier coal generator built for remote research sites and outposts by Prometheus Heavy Industries. Reliable, durable, and forgiving of poor-quality fuel."
	base_icon = "portgen0"
	power_gen = 10000
	time_per_sheet = 130
	circuit = /obj/item/circuitboard/machine/portgen/falcon

/obj/machinery/power/port_gen/coal/condor
	name = "C-120 \"Condor\" Field Generator"
	desc = "A high-output generator intended for long-duration, high-demand operations. Overbuilt, loud, and infamous for its voracious appetite."
	base_icon = "portgen1"
	power_gen = 20000
	time_per_sheet = 70
	circuit = /obj/item/circuitboard/machine/portgen/falcon

/obj/machinery/power/port_gen/coal/roc
	name = "C-480 \"Roc\" Stationary Generator"
	desc = "A massive noisy, stationary coal-fired generator designed to serve as the primary power source for Site-scale installations."
	icon = 'icons/obj/power(Big Gens).dmi'
	icon_state = "portgen0"
	base_icon = "portgen2"
	power_gen = 60000
	time_per_sheet = 50
	circuit = /obj/item/circuitboard/machine/portgen/roc
	stationary = TRUE


/obj/machinery/power/port_gen/coal/process()
	..()
	// The coal flung into the maw of hell
	if(HasFuel() && anchored && active)
		if(prob(40) + current_heat / 4)
			new /obj/effect/temp_visual/coal_gen_smoke(get_turf(src))

/obj/machinery/power/port_gen/coal/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

	var/obj/S = sheet_path
	sheet_name = initial(S.name)

/obj/machinery/power/port_gen/coal/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/coal/RefreshParts()
	. = ..()
	var/temp_rating = 0
	var/consumption_coeff = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/stock_parts/capacitor))
			temp_rating += SP.rating
		else
			consumption_coeff += SP.rating
	power_gen = round(initial(power_gen) * temp_rating * 2)
	consumption = consumption_coeff

/obj/machinery/power/port_gen/coal/examine(mob/user)
	. = ..()
	. += span_notice("The generator has [sheets] units of [sheet_name] fuel left, producing [display_power(power_gen)] per cycle.")
	if(anchored)
		. += span_notice("It is anchored to the ground.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Fuel efficiency increased by <b>[(consumption*100)-100]%</b>.")

/obj/machinery/power/port_gen/coal/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/coal/DropFuel()
	if(sheets)
		new sheet_path(drop_location(), sheets)
		sheets = 0

/obj/machinery/power/port_gen/coal/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet * consumption / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if (sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

	var/lower_limit = 56 + power_output * 10
	var/upper_limit = 76 + power_output * 10
	var/bias = 0
	if (power_output > 4)
		upper_limit = 400
		bias = power_output - consumption * (4 - consumption)
	if (current_heat < lower_limit)
		current_heat += 4 - consumption
	else
		current_heat += rand(-7 + bias, 7 + bias)
		if (current_heat < lower_limit)
			current_heat = lower_limit
		if (current_heat > upper_limit)
			current_heat = upper_limit

	if (current_heat > 300)
		overheat()
		qdel(src)

/obj/machinery/power/port_gen/coal/handleInactive()
	current_heat = max(current_heat - 2, 0)
	if(current_heat == 0)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/power/port_gen/coal/proc/overheat()
	explosion(src, devastation_range = 2, heavy_impact_range = 5, light_impact_range = 2, flash_range = -1)

/obj/machinery/power/port_gen/coal/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/port_gen/coal/attackby(obj/item/O, mob/user, params)
	if(istype(O, sheet_path))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, span_notice("The [src.name] is full!"))
			return
		to_chat(user, span_notice("You add [amount] sheets to the [src.name]."))
		sheets += amount
		addstack.use(amount)
		return
	else if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				set_anchored(TRUE)
				to_chat(user, span_notice("You secure the generator to the floor."))
			else if(anchored && !stationary)
				set_anchored(FALSE)
				to_chat(user, span_notice("You unsecure the generator from the floor."))
			else if(stationary)
				to_chat(user, span_notice("The generator is stationary and cannot be moved without disassembly!"))

			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return
		else if(O.tool_behaviour == TOOL_SCREWDRIVER)
			panel_open = !panel_open
			O.play_tool_sound(src)
			if(panel_open)
				to_chat(user, span_notice("You open the access panel."))
			else
				to_chat(user, span_notice("You close the access panel."))
			return
		else if(default_deconstruction_crowbar(O))
			return
	return ..()

/obj/machinery/power/port_gen/coal/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You hear a hefty clunk from inside the generator."))
	emp_act(EMP_HEAVY)

/obj/machinery/power/port_gen/coal/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/port_gen/coal/attack_paw(mob/user, list/modifiers)
	interact(user)

/obj/machinery/power/port_gen/coal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableGenerator", name)
		ui.open()

/obj/machinery/power/port_gen/coal/ui_data()
	var/data = list()

	data["active"] = active
	data["sheet_name"] = capitalize(sheet_name)
	data["sheets"] = sheets
	data["stack_percent"] = round(sheet_left * 100, 0.1)

	data["anchored"] = anchored
	data["connected"] = (powernet == null ? 0 : 1)
	data["ready_to_boot"] = anchored && HasFuel()
	data["power_generated"] = display_power(power_gen)
	data["power_output"] = display_power(power_gen * power_output)
	data["power_available"] = (powernet == null ? 0 : display_power(avail()))
	data["current_heat"] = current_heat
	. = data

/obj/machinery/power/port_gen/coal/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			TogglePower(usr)
			. = TRUE

		if("eject")
			if(!active)
				DropFuel()
				. = TRUE

		if("lower_power")
			if (power_output > 1)
				power_output--
				. = TRUE

		if("higher_power")
			if (power_output < 4 || (obj_flags & EMAGGED))
				power_output++
				. = TRUE

/obj/machinery/power/port_gen/coal/condor/overheat()
	explosion(src, devastation_range = 4, heavy_impact_range = 4, light_impact_range = 4, flash_range = -1)

/////////////////
// Welding Fuel//
/////////////////

/obj/machinery/power/port_gen/welding
	name = "C-20 \"Sparrow\" Field Generator"
	desc = "A compact utility generator designed for quick deployment in the field and emergency setups. Runs on welding fuel."
	base_icon = "portgen3"
	power_gen = 5000
	var/fuel_consumption = 1

/obj/machinery/power/port_gen/welding/Initialize(mapload)
	. = ..()
	create_reagents(100)

/obj/machinery/power/port_gen/welding/HasFuel()
	if(reagents.get_reagent_amount(/datum/reagent/fuel) > 0)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/welding/UseFuel()
	reagents.remove_reagent(/datum/reagent/fuel, fuel_consumption)

/obj/machinery/power/port_gen/welding/ui_data()
	var/list/data = ..()
	data["fuel_name"] = "Welding Fuel"
	data["fuel_amount"] = reagents.get_reagent_amount(/datum/reagent/fuel)
	data["fuel_capacity"] = reagents.maximum_volume
	return data

/obj/machinery/power/port_gen/welding/attackby(obj/item/O, mob/user, params)
	if(O.is_refillable(src))
		var/obj/item/refillable = O
		refillable.reagents.trans_to(src)
		return
	return ..()
