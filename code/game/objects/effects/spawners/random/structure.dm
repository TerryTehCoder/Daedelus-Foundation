/obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	name = "crate spawner"
	icon_state = "crate_secure"
	loot = list(
		/obj/effect/spawner/random/structure/crate_loot = 745,
		/obj/structure/closet/crate/trashcart/filled = 75,
		/obj/effect/spawner/random/trash/moisture_trap = 50,
		/obj/effect/spawner/random/trash/hobo_squat = 30,
		/obj/structure/closet/mini_fridge = 35,
		/obj/effect/spawner/random/trash/mess = 30,
		/obj/item/kirbyplants/fern = 20,
		/obj/structure/closet/crate/decorations = 15,
	)

/obj/effect/spawner/random/structure/crate_abandoned
	name = "locked crate spawner"
	icon_state = "crate_secure"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)

/obj/effect/spawner/random/structure/girder
	name = "girder spawner"
	icon_state = "girder"
	spawn_loot_chance = 90
	loot = list( // 80% chance normal girder, 10% chance of displaced, 10% chance of nothing
		/obj/structure/girder = 8,
		/obj/structure/girder/displaced = 1,
	)

/obj/effect/spawner/random/structure/grille
	name = "grille spawner"
	icon_state = "grille"
	spawn_loot_chance = 90
	loot = list( // 80% chance normal grille, 10% chance of broken, 10% chance of nothing
		/obj/structure/grille = 8,
		/obj/structure/grille/broken = 1,
	)

/obj/effect/spawner/random/structure/furniture_parts
	name = "furniture parts spawner"
	icon_state = "table_parts"
	loot = list(
		/obj/structure/table_frame,
		/obj/structure/table_frame/wood,
		/obj/item/rack_parts,
	)

/obj/effect/spawner/random/structure/table_or_rack
	name = "table or rack spawner"
	icon_state = "rack_parts"
	loot = list(
		/obj/effect/spawner/random/structure/table,
		/obj/structure/rack,
	)

/obj/effect/spawner/random/structure/table
	name = "table spawner"
	icon_state = "table"
	loot = list(
		/obj/structure/table = 40,
		/obj/structure/table/wood = 30,
		/obj/structure/table/glass = 20,
		/obj/structure/table/reinforced = 5,
		/obj/structure/table/wood/poker = 5,
	)

/obj/effect/spawner/random/structure/table_fancy
	name = "table spawner"
	icon_state = "table_fancy"
	loot_type_path = /obj/structure/table/wood/fancy
	loot = list()

/obj/effect/spawner/random/structure/tank_holder
	name = "tank holder spawner"
	icon_state = "tank_holder"
	loot = list(
		/obj/structure/tank_holder/oxygen = 40,
		/obj/structure/tank_holder/extinguisher = 40,
		/obj/structure/tank_holder = 20,
		/obj/structure/tank_holder/extinguisher/advanced = 1,
	)

/obj/effect/spawner/random/structure/closet_empty
	name = "empty closet spawner"
	icon_state = "locker"
	loot = list(
		/obj/structure/closet = 850,
		/obj/structure/closet/cabinet = 150,
		/obj/structure/closet/acloset = 1,
	)

/obj/effect/spawner/random/structure/closet_empty/crate
	name = "empty crate spawner"
	icon_state = "crate"
	loot = list(
		/obj/structure/closet/crate = 20,
		/obj/structure/closet/crate/wooden = 1,
		/obj/structure/closet/crate/internals = 1,
		/obj/structure/closet/crate/medical = 1,
		/obj/structure/closet/crate/freezer = 1,
		/obj/structure/closet/crate/radiation = 1,
		/obj/structure/closet/crate/hydroponics = 1,
		/obj/structure/closet/crate/engineering = 1,
		/obj/structure/closet/crate/engineering/electrical = 1,
		/obj/structure/closet/crate/science = 1,
	)

/obj/effect/spawner/random/structure/closet_empty/crate/with_loot
	name = "crate spawner with maintenance loot"
	icon_state = "crate"

/obj/effect/spawner/random/structure/closet_empty/crate/with_loot/spawn_item(location, path)
	var/obj/structure/closet/crate/crate_to_fill = ..()
	for(var/i in 1 to rand(2,6))
		new /obj/effect/spawner/random/maintenance(crate_to_fill)

	return crate_to_fill

/obj/effect/spawner/random/structure/crate_loot
	name = "lootcrate spawner"
	icon_state = "crate"
	loot = list(
		/obj/effect/spawner/random/structure/closet_empty/crate/with_loot = 15,
		/obj/effect/spawner/random/structure/closet_empty/crate = 4,
		/obj/structure/closet/crate/secure/loot = 1,
	)

/obj/effect/spawner/random/structure/closet_private
	name = "private closet spawner"
	icon_state = "cabinet"
	loot = list(
		/obj/structure/closet/secure_closet/personal,
		/obj/structure/closet/secure_closet/personal/cabinet,
	)

/obj/effect/spawner/random/structure/closet_empty
	name = "empty closet spawner"
	icon_state = "locker"
	loot = list(
		/obj/structure/closet = 850,
		/obj/structure/closet/cabinet = 150,
		/obj/structure/closet/acloset = 1,
	)

/obj/effect/spawner/random/structure/closet_maintenance
	name = "maintenance closet spawner"
	icon_state = "locker"
	loot = list( // use these for maintenance areas
		/obj/effect/spawner/random/structure/closet_empty = 10,
		/obj/structure/closet/emcloset = 2,
		/obj/structure/closet/firecloset = 2,
		/obj/structure/closet/toolcloset = 2,
		/obj/structure/closet/l3closet = 1,
		/obj/structure/closet/radiation = 1,
		/obj/structure/closet/bombcloset = 1,
		/obj/structure/closet/mini_fridge = 1,
	)

/obj/effect/spawner/random/structure/chair_flipped
	name = "flipped chair spawner"
	icon_state = "chair"
	loot = list(
		/obj/item/chair/wood,
		/obj/item/chair/stool/bar,
		/obj/item/chair/stool,
		/obj/item/chair,
	)

/obj/effect/spawner/random/structure/chair_comfy
	name = "comfy chair spawner"
	icon_state = "chair"
	loot_type_path = /obj/structure/chair/comfy
	loot = list()

/obj/effect/spawner/random/structure/chair_maintenance
	name = "maintenance chair spawner"
	icon_state = "chair"
	loot = list(
		/obj/structure/chair = 200,
		/obj/structure/chair/stool = 200,
		/obj/structure/chair/stool/bar = 200,
		/obj/effect/spawner/random/structure/chair_flipped = 150,
		/obj/structure/chair/wood = 100,
		/obj/effect/spawner/random/structure/chair_comfy = 50,
		/obj/structure/chair/office/light = 50,
		/obj/structure/chair/office = 50,
		/obj/structure/chair/wood/wings = 1,
		/obj/structure/chair/old = 1,
	)

/obj/effect/spawner/random/structure/barricade
	name = "barricade spawner"
	icon_state = "barricade"
	spawn_loot_chance = 80
	loot = list(
		/obj/structure/barricade/wooden,
		/obj/structure/barricade/wooden/crude,
	)

/obj/effect/spawner/random/structure/billboard
	name = "billboard spawner"
	icon = 'icons/obj/billboard.dmi'
	icon_state = "billboard_random"
	loot = list(
		/obj/structure/billboard/azik = 50,
		/obj/structure/billboard/donk_n_go = 50,
		/obj/structure/billboard/space_cola = 50,
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)

/obj/effect/spawner/random/structure/billboard/nanotrasen //useful for station maps- NT isn't the sort to advertise for competitors
	name = "\improper Nanotrasen billboard spawner"
	loot = list(
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)

/obj/effect/spawner/random/structure/billboard/lizardsgas //for the space ruin, The Lizard's Gas. I don't see much use for the sprites below anywhere else since they're unifunctional.
	name = "\improper The Lizards Gas billboard spawner"
	loot = list(
		/obj/structure/billboard/lizards_gas = 75,
		/obj/structure/billboard/lizards_gas/defaced = 25,
	)

/obj/effect/spawner/random/structure/billboard/roadsigns //also pretty much only unifunctionally useful for gas stations
	name = "\improper Gas Station billboard spawner"
	loot = list(
		/obj/structure/billboard/roadsign/two = 25,
		/obj/structure/billboard/roadsign/twothousand = 25,
		/obj/structure/billboard/roadsign/twomillion = 25,
		/obj/structure/billboard/roadsign/error = 25,
	)

/obj/effect/spawner/random/structure/security_crate
	name = "security crate spawner"
	icon_state = "crate_secure"
	loot = list(
		/obj/structure/closet/crate/secure/weapon = 33,
		/obj/structure/closet/crate/secure/gear = 33,
		/obj/structure/closet/crate/secure/large = 34
	)

/obj/effect/spawner/random/structure/security_crate/spawn_item(location, path)
	var/obj/structure/closet/crate/secure/C = ..()
	if(!C)
		return

	var/list/security_items = list(
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/head/helmet/sec,
		/obj/item/melee/baton/security/loaded,
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/storage/box/flashes,
		/obj/item/storage/box/handcuffs,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/storage/box/beanbag,
		/obj/item/storage/box/rubbershot,
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/c38/hotshot,
		/obj/item/ammo_box/c38/iceblox,
		/obj/item/storage/box/firingpins,
		/obj/item/storage/box/firingpins/paywall,
		/obj/item/clothing/head/helmet/justice,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/clothing/suit/armor/bulletproof,
		/obj/item/clothing/head/helmet/alt,
		/obj/item/storage/box/chemimp,
		/obj/item/gun/ballistic/shotgun/automatic/combat,
		/obj/item/storage/belt/bandolier,
		/obj/item/gun/energy/e_gun/dragnet,
		/obj/item/gun/energy/e_gun,
		/obj/item/storage/box/exileimp,
		/obj/item/flamethrower/full,
		/obj/item/tank/internals/plasma,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/weaponcrafting/gunkit/ion,
		/obj/item/storage/lockbox/loyalty,
		/obj/item/storage/box/trackimp,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/head/helmet/riot,
		/obj/item/shield/riot,
		/obj/item/clothing/head/helmet/swat/nanotrasen,
		/obj/item/clothing/suit/armor/swat,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/storage/belt/military/assault,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/storage/belt/holster/shoulder/thermal,
		/obj/item/storage/box/stingbangs,
		/obj/item/storage/box/wall_flash,
		/obj/item/storage/scene_cards,
		/obj/item/storage/box/evidence,
		/obj/item/camera,
		/obj/item/taperecorder,
		/obj/item/toy/crayon/white,
		/obj/item/clothing/head/fedora/det_hat,
		/obj/item/storage/briefcase/crimekit,
		/obj/item/grenade/barrier
	)

	var/num_items = rand(2, 5) // Spawn between 2 and 5 items
	for(var/i in 1 to num_items)
		var/item_path = pick(security_items)
		new item_path(C)

	return C

/obj/effect/spawner/random/structure/medical_crate
	name = "medical crate spawner"
	icon_state = "crate_secure"
	loot = list(
		/obj/structure/closet/crate/medical = 50,
		/obj/structure/closet/crate/freezer = 50
	)

/obj/effect/spawner/random/structure/medical_crate/spawn_item(location, path)
	var/obj/structure/closet/crate/C = ..()
	if(!C)
		return

	var/list/medical_items = list(
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/blood/a_plus,
		/obj/item/reagent_containers/blood/a_minus,
		/obj/item/reagent_containers/blood/b_plus,
		/obj/item/reagent_containers/blood/b_minus,
		/obj/item/reagent_containers/blood/o_plus,
		/obj/item/reagent_containers/blood/o_minus,
		/obj/item/reagent_containers/blood/lizard,
		/obj/item/reagent_containers/blood/ethereal,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/hypospray/medipen/ekit,
		/obj/item/reagent_containers/hypospray/medipen/blood_loss,
		/obj/item/clothing/glasses/science,
		/obj/item/reagent_containers/dropper,
		/obj/item/storage/box/beakers,
		/obj/item/defibrillator/loaded,
		/obj/item/reagent_containers/glass/bottle/dylovene,
		/obj/item/reagent_containers/glass/bottle/epinephrine,
		/obj/item/reagent_containers/glass/bottle/morphine,
		/obj/item/stack/gauze,
		/obj/item/storage/box/medigels,
		/obj/item/storage/box/syringes,
		/obj/item/storage/box/bodybags,
		/obj/item/storage/medkit/regular,
		/obj/item/storage/medkit/o2,
		/obj/item/storage/medkit/toxin,
		/obj/item/storage/medkit/brute,
		/obj/item/storage/medkit/fire,
		/obj/item/storage/pill_bottle/mining,
		/obj/item/reagent_containers/pill/alkysine,
		/obj/item/stack/medical/bone_gel/twelve,
		/obj/item/vending_refill/medical,
		/obj/item/vending_refill/drugs,
		/obj/item/storage/backpack/duffelbag/med/surgery,
		/obj/item/roller,
		/obj/machinery/iv_drip/saline,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/suture,
		/obj/item/bodybag/stasis
	)

	var/num_items = rand(2, 5) // Spawn between 2 and 5 items
	for(var/i in 1 to num_items)
		var/item_path = pick(medical_items)
		new item_path(C)

	return C
