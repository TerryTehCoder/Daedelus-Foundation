// Tea
/datum/plant/tea
	species = "teaaspera"
	name = "Tea Aspera"

	growthstages = 5
	icon_dead = "tea-dead"

	base_health = 20
	base_maturation = 20
	base_production = 60
	base_harvest_amt = 1
	base_harvest_yield = 5
	base_endurance = 3

	genome = 1
	force_single_harvest = TRUE

	seed_path = /obj/item/seeds/tea
	product_path = /obj/item/food/grown/tea

	reagents_per_potency = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/teapowder = 0.1)

	possible_mutations = list(/datum/plant_mutation/tea_astra)

/obj/item/seeds/tea
	name = "pack of tea aspera seeds"
	desc = "These seeds grow into tea plants."
	icon_state = "seed-teaaspera"

	plant_type = /datum/plant/tea

/obj/item/food/grown/tea
	plant_datum = /datum/plant/tea
	name = "Tea Aspera tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"
	grind_results = list(/datum/reagent/toxin/teapowder = 0)
	dry_grind = TRUE
	can_distill = FALSE

// Tea Astra
/datum/plant_mutation/tea_astra
	plant_type = /datum/plant/tea/astra

	infusion_reagents = list(/datum/reagent/medicine/synaptizine)

/datum/plant/tea/astra
	species = "teaastra"
	name = "tea astra"

	seed_path = /obj/item/seeds/tea/astra
	product_path = /obj/item/food/grown/tea/astra

	reagents_per_potency = list(/datum/reagent/medicine/synaptizine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/teapowder = 0.1)
	possible_mutations = null

/obj/item/seeds/tea/astra
	name = "pack of tea astra seeds"
	icon_state = "seed-teaastra"

	plant_type = /datum/plant/tea/astra

/obj/item/food/grown/tea/astra
	plant_datum = /datum/plant/tea/astra
	name = "Tea Astra tips"
	icon_state = "tea_astra_leaves"
	bite_consumption_mod = 2
	grind_results = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/saline_glucose = 0)


// Coffee
/datum/plant/coffee
	species = "coffeea"
	name = "Coffee Arabica"

	growthstages = 5
	icon_dead = "coffee-dead"

	seed_path = /obj/item/seeds/coffee
	product_path = /obj/item/food/grown/coffee

	reagents_per_potency = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/coffeepowder = 0.1, /datum/reagent/nitrogen = 0.05)
	possible_mutations = list(/datum/plant_mutation/coffee_amallo)

/obj/item/seeds/coffee
	name = "pack of coffee arabica seeds"
	desc = "These seeds grow into coffee arabica bushes."
	icon_state = "seed-coffeea"

	plant_type = /datum/plant/coffee

/obj/item/food/grown/coffee
	plant_datum = /datum/plant/coffee
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/kahlua

// Coffee amallo
/datum/plant_mutation/coffee_amallo
	plant_type = /datum/plant/coffee/amallo

/datum/plant/coffee/amallo
	species = "coffeer"
	name = "coffee amallo bush"

	seed_path = /obj/item/seeds/coffee/amallo
	product_path = /obj/item/food/grown/coffee/amallo

	reagents_per_potency = list(/datum/reagent/medicine/ephedrine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/coffeepowder = 0.1)
	possible_mutations = null
	rarity = 20

/obj/item/seeds/coffee/amallo
	name = "pack of coffee amallo seeds"
	desc = "These seeds grow into coffee amallo bushes."
	icon_state = "seed-coffeer"

	plant_type =/datum/plant/coffee/amallo

/obj/item/food/grown/coffee/amallo
	plant_datum = /datum/plant/coffee/amallo
	name = "coffee amallo beans"
	desc = "Not guarenteed to produce anomalies; but definitely still useful."
	icon_state = "coffee_amallo"
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0)
