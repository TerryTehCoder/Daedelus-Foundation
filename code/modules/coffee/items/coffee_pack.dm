/obj/item/storage/box/coffeepack/amallo
	name = "amallo beans"
	desc = "A bag containing fresh, dry coffee amallo beans. Sourced and packaged under Foundation contract."
	illustration = null
	icon = 'icons/obj/coffee.dmi'
	icon_state = "amallo_beans"

/obj/item/storage/box/coffeepack/amallo/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.set_holdable(list(/obj/item/food/grown/coffee))
	for(var/i in 1 to 5)
		var/obj/item/food/grown/coffee/amallo/bean = new(src)
		ADD_TRAIT(bean, TRAIT_DRIED, "Amallo Dried Coffee Beans")
		bean.add_atom_colour("#ad7257", FIXED_COLOUR_PRIORITY)

/obj/item/storage/box/coffeepack/arabica
	name = "arabica beans"
	desc = "A bag containing fresh, dry coffee arabica beans. Sourced and packaged under Foundation contract."
	illustration = null
	icon = 'icons/obj/coffee.dmi'
	icon_state = "arabica_beans"

/obj/item/storage/box/coffeepack/arabica/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.set_holdable(list(/obj/item/food/grown/coffee))
	for(var/i in 1 to 5)
		var/obj/item/food/grown/coffee/bean = new(src)
		ADD_TRAIT(bean, TRAIT_DRIED, "Arabica Dried Coffee Beans")
		bean.add_atom_colour("#ad7257", FIXED_COLOUR_PRIORITY)
