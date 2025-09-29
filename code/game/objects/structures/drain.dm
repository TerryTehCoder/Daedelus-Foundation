/obj/structure/drain
	name = "floor drain"
	desc = "A common metal drain, hopefully not clogged with hair."
	icon = 'icons/obj/watercloset.dmi' // Assuming a suitable icon exists
	icon_state = "drain"
	anchored = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER // Should be below mobs, similar to fluid visuals
	var/welded = FALSE
	var/datum/component/drain/drain_comp

/obj/structure/drain/Initialize()
	. = ..()
	drain_comp = AddComponent(/datum/component/drain) // Add the DrainComponent to the drain object
	update_icon()

/obj/structure/drain/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	var/obj/item/weldingtool/WT = tool
	if(WT.isOn())
		welded = !welded
		to_chat(user, span_notice("You weld \the [src] [welded ? "closed" : "open"]."))
	else
		to_chat(user, span_warning("Turn \the [tool] on, first."))
	update_icon()
	return TRUE

/obj/structure/drain/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	new /obj/item/drain(src.loc)
	tool.play_tool_sound(user)
	to_chat(user, span_warning("[user] unwrenches the [src]."))
	qdel(src)
	return TRUE

/obj/structure/drain/update_icon_state()
	icon_state = "[initial(icon_state)][welded ? "-welded" : ""]"
	..()

/obj/structure/drain/examine(mob/user)
	. = ..()
	if(welded)
		to_chat(user, "It is welded shut.")

//for construction.
/obj/item/drain
	name = "drain frame"
	desc = "The frame of a metal drain, ready to be installed."
	icon = 'icons/obj/watercloset.dmi' // Using the same icon as the structure for consistency
	icon_state = "drain"

/obj/item/drain/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	new /obj/structure/drain(src.loc)
	tool.play_tool_sound(user)
	to_chat(user, span_warning("[user] wrenches the [src] down."))
	qdel(src)
	return TRUE
