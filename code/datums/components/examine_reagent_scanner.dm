/datum/component/examine_reagent_scanner

/datum/component/examine_reagent_scanner/Initialize(mapload)
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(OnExamine))

/datum/component/examine_reagent_scanner/Destroy()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	. = ..()

/datum/component/examine_reagent_scanner/proc/OnExamine(atom/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if (!istype(user))
		return

	if (HAS_TRAIT(user, TRAIT_REAGENT_SCANNER))
		var/turf/T = get_turf(source)
		if (!istype(T))
			return

		var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
		if (fluid_comp && fluid_comp.reagents && fluid_comp.reagents.total_volume > 0)
			examine_text += "<hr>"
			examine_text += span_notice("You see the following reagents:")
			for (var/datum/reagent/R in fluid_comp.reagents.reagent_list)
				examine_text += span_notice("* [round(R.volume, CHEMICAL_VOLUME_ROUNDING)] units of [R.name].")
			if (fluid_comp.reagents.is_reacting)
				examine_text += span_alert("A chemical reaction is taking place.")
			examine_text += span_notice("The solution's temperature is [fluid_comp.reagents.chem_temp]K.")
