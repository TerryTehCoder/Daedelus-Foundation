/obj/item/reagent_containers/barrel
	name = "Barrel"
	desc = "A dummy barrel."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_generic"
	possible_transfer_amounts = list(10,25,50,100)
	volume = 2500
	var/datum/reagent/selected_reagent

/obj/item/reagent_containers/barrel/proc/InitializeBarrelReagent()
	var/list/barrelreagents = list(/datum/reagent/consumable/cooking_oil = 30,
								/datum/reagent/medicine/cryoxadone = 20,
								/datum/reagent/cryptobiolin = 5,
								/datum/reagent/toxin/acid/hydrochloric = 3,
								/datum/reagent/nitroglycerin = 5,
								/datum/reagent/blood = 15,
								/datum/reagent/consumable/ethanol = 25,
								/datum/reagent/medicine/spaceacillin = 15,
								/datum/reagent/toxin/mutagen = 2,
								/datum/reagent/consumable/coffee = 20,
								/datum/reagent/drug/methamphetamine = 1,
								/datum/reagent/thermite = 3,
								/datum/reagent/consumable/laughter = 5,
								/datum/reagent/toxin/polonium = 1,
								/datum/reagent/consumable/orangejuice = 20,
								/datum/reagent/medicine/dexalin = 15,
								/datum/reagent/toxin/cyanide = 1,
								/datum/reagent/consumable/tea = 20,
								/datum/reagent/drug/space_drugs = 1,
								/datum/reagent/hydrogen = 25,
								/datum/reagent/silver = 15,
								/datum/reagent/consumable/caramel = 15,
								/datum/reagent/toxin/fentanyl = 1,
								/datum/reagent/medicine/morphine = 10,
								/datum/reagent/consumable/ethanol/whiskey = 20
								)
	var/reagentpicked = pick_weight(barrelreagents)  // Pick a random reagent based on weights
	selected_reagent = reagentpicked
	list_reagents = list(selected_reagent = volume)

/obj/item/reagent_containers/barrel/New()
	. = ..()
	InitializeBarrelReagent()

/obj/item/reagent_containers/barrel/generic
	name = "Barrel"
	desc = "A generic barrel."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_generic"
	possible_transfer_amounts = list(10,25,50,100)
	volume = 2500

//These two hitch off water and fuel tank logic since that's easier then rewriting all of the code, plus barrels aren't all That unique.
//The notable difference is that the quantities are much smaller.

/obj/item/reagent_containers/watertank/barrel
	name = "Blue Barrel"
	desc = "A blue barrel that probably contains water."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_water"
	volume = 2500

/obj/item/reagent_containers/fueltank/barrel
	name = "Red Barrel"
	desc = "A deep red barrel which probably contains welding fuel. Better keep guns away from this..."
	icon = 'icons/obj/aquaticprops.dmi'
	icon_state = "barrel_weld"
	volume = 2500
