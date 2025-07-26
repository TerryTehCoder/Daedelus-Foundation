/obj/item/electronics/airlock/brace
	name = "airlock brace access circuit"
	req_access = list()

/obj/item/electronics/airlock/brace/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 1)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, ui_data(), force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics.tmpl", src.name)
		ui.open()

/obj/item/electronics/airlock/brace/ui_data()
	var/list/data = list()
	var/obj/machinery/door/airlock/airlock = holder
	if(!airlock)
		return data
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	data["passedName"] = passed_name
	data["passedCycleId"] = passed_cycle_id
	return data

/obj/item/electronics/airlock/brace/ui_host()
	return holder
