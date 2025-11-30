//now, how do you store coffee carts? well, in a rack, of course!
/obj/item/storage/fancy/coffee_cart_rack
	name = "coffeemaker cartridge rack"
	desc = "A small rack for storing coffeemaker cartridges."
	icon = 'icons/obj/coffee.dmi'
	icon_state = "coffee_cartrack"
	spawn_type = /obj/item/coffee_cartridge

/obj/item/storage/fancy/coffee_cart_rack/Initialize(mapload)
	..()
	atom_storage.max_slots = 4
	atom_storage.set_holdable(list(/obj/item/coffee_cartridge))

/obj/item/storage/fancy/coffee_cart_rack/update_icon()
	..()
	if(!contents.len)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)][contents.len]"
