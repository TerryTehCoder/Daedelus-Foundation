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

/obj/structure/drain/attackby(obj/item/thing, mob/user)
	. = ..()
	if(isWelder(thing))
		var/obj/item/weldingtool/WT = thing
		if(WT.isOn())
			welded = !welded
			to_chat(user, SPAN_NOTICE("You weld \the [src] [welded ? "closed" : "open"]."))
		else
			to_chat(user, SPAN_WARNING("Turn \the [thing] on, first."))
		update_icon()
		return
	if(isWrench(thing))
		new /obj/item/drain(src.loc)
		playsound(src.loc, 'sounds/items/Ratchet.ogg', 50, 1)
		to_chat(user, SPAN_WARNING("[user] unwrenches the [src]."))
		qdel(src)
		return
	return ..()

/obj/structure/drain/on_update_icon()
	icon_state = "[initial(icon_state)][welded ? "-welded" : ""]"

/obj/structure/drain/Process()
	if(welded)
		return
	. = ..() // Call parent Process if it exists

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

/obj/item/drain/attackby(obj/item/thing, mob/user)
	if(isWrench(thing))
		new constructed_type(src.loc)
		playsound(src.loc, 'sounds/items/Ratchet.ogg', 50, 1)
		to_chat(user, SPAN_WARNING("[user] wrenches the [src] down."))
		qdel(src)
		return
	return ..()
