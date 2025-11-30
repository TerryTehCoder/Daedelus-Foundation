//Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "coffeemaker cartridge - Foundation Standard Issue"
	desc = "A standard-issue coffee cartridge for Foundation personnel. Provides a mild stimulating effect to improve focus during long shifts."
	icon = 'icons/obj/coffee.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_TINY
	var/charges = 4
	var/list/drink_type = list(/datum/reagent/consumable/foundation_coffee = 120)

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += "<span class='warning'>The cartridge has [charges] portions of grounds remaining.</span>"
	else
		. += "<span class='warning'>The cartridge has no unspent grounds remaining.</span>"

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge - Caffè Fantasioso"
	desc = "A premium coffee cartridge, occasionally issued as a morale booster. The quality is noticeably better than the standard issue."
	icon_state = "cartridge_blend"
	drink_type = list(/datum/reagent/consumable/cafe_latte = 120)

/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "coffeemaker cartridge - Miscela di Piccione"
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "coffeemaker cartridge - Montagna Blu"
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "coffeemaker cartridge - Kilimangiaro"
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "coffeemaker cartridge - Moka Arabica"
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge - Caffè Decaffeinato"
	desc = "A decaffeinated coffee cartridge for personnel with caffeine sensitivity or those working late shifts."
	icon_state = "cartridge_decaf"
	drink_type = list(/datum/reagent/consumable/soy_latte = 120)

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge - Botany Blend"
	desc = "A jury-rigged coffee cartridge, likely assembled from scavenged materials. Use with caution, as its contents are unverified."
	icon_state = "cartridge_bootleg"
	drink_type = list(/datum/reagent/consumable/coffee = 120)

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "A blank coffee cartridge, ready to be filled."
	icon = 'icons/obj/coffee.dmi'
	icon_state = "cartridge_blank"
