/**
 * Random power cell spawners.
 * Does not include infinite cells, for..hopefully obvious reasons.
 */

/obj/effect/spawner/random/powercell
	name = "random power cell spawner"
	desc = "Spawns a random power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	spawn_loot_count = 1
	spawn_loot_double = TRUE

/obj/effect/spawner/random/powercell/low_tier
	name = "low tier power cell spawner"
	desc = "Spawns a low capacity power cell."
	loot = list(
		/obj/item/stock_parts/cell = 10,
		/obj/item/stock_parts/cell/empty = 10,
		/obj/item/stock_parts/cell/crap = 15,
		/obj/item/stock_parts/cell/crap/empty = 15,
		/obj/item/stock_parts/cell/secborg = 10,
		/obj/item/stock_parts/cell/secborg/empty = 10,
		/obj/item/stock_parts/cell/mini_egun = 10,
		/obj/item/stock_parts/cell/emergency_light = 5,
		/obj/item/stock_parts/cell/potato = 5,
		/obj/item/stock_parts/cell/emproof = 10,
		/obj/item/stock_parts/cell/emproof/empty = 10
	)

/obj/effect/spawner/random/powercell/low_tier/x2
	name = "low tier power cell spawner (x2)"
	desc = "Spawns two low capacity power cells."
	spawn_loot_count = 2

/obj/effect/spawner/random/powercell/low_tier/x3
	name = "low tier power cell spawner (x3)"
	desc = "Spawns three low capacity power cells."
	spawn_loot_count = 3

/obj/effect/spawner/random/powercell/low_tier/x4 // I genuinely cannot think of a reason why anyone would want to spawn more than 4 low tier power cells at once.
	name = "low tier power cell spawner (x4)"
	desc = "Spawns four low capacity power cells."
	spawn_loot_count = 4

/obj/effect/spawner/random/powercell/middle_tier
	name = "middle tier power cell spawner"
	desc = "Spawns a medium capacity power cell."
	loot = list(
		/obj/item/stock_parts/cell/upgraded = 10,
		/obj/item/stock_parts/cell/upgraded/plus = 10,
		/obj/item/stock_parts/cell/hos_gun = 5,
		/obj/item/stock_parts/cell/pulse/pistol = 5,
		/obj/item/stock_parts/cell/pulse/carbine = 5,
		/obj/item/stock_parts/cell/emproof/slime = 5,
		/obj/item/stock_parts/cell/inducer_supply = 5
	)

/obj/effect/spawner/random/powercell/middle_tier/x2
	name = "middle tier power cell spawner (x2)"
	desc = "Spawns two medium capacity power cells."
	spawn_loot_count = 2

/obj/effect/spawner/random/powercell/middle_tier/x3
	name = "middle tier power cell spawner (x3)"
	desc = "Spawns three medium capacity power cells."
	spawn_loot_count = 3

/obj/effect/spawner/random/powercell/middle_tier/x4
	name = "middle tier power cell spawner (x4)"
	desc = "Spawns four medium capacity power cells."
	spawn_loot_count = 4

/obj/effect/spawner/random/powercell/high_tier
	name = "high tier power cell spawner"
	desc = "Spawns a high capacity power cell."
	loot = list(
		/obj/item/stock_parts/cell/pulse = 10,
		/obj/item/stock_parts/cell/high = 10,
		/obj/item/stock_parts/cell/high/empty = 10,
		/obj/item/stock_parts/cell/super = 10,
		/obj/item/stock_parts/cell/super/empty = 10,
		/obj/item/stock_parts/cell/hyper = 10,
		/obj/item/stock_parts/cell/hyper/empty = 10,
		/obj/item/stock_parts/cell/bluespace = 10,
		/obj/item/stock_parts/cell/bluespace/empty = 10,
		/obj/item/stock_parts/cell/beam_rifle = 5,
		/obj/item/stock_parts/cell/crystal_cell = 5
	)

/obj/effect/spawner/random/powercell/high_tier/x2
	name = "high tier power cell spawner (x2)"
	desc = "Spawns two high capacity power cells."
	spawn_loot_count = 2

/obj/effect/spawner/random/powercell/high_tier/x3
	name = "high tier power cell spawner (x3)"
	desc = "Spawns three high capacity power cells."
	spawn_loot_count = 3

/obj/effect/spawner/random/powercell/high_tier/x4
	name = "high tier power cell spawner (x4)"
	desc = "Spawns four high capacity power cells."
	spawn_loot_count = 4

/obj/effect/spawner/random/powercell/all_inclusive
	name = "all inclusive power cell spawner"
	desc = "Spawns any random power cell."
	loot = list(
		/obj/item/stock_parts/cell = 10,
		/obj/item/stock_parts/cell/empty = 10,
		/obj/item/stock_parts/cell/crap = 15,
		/obj/item/stock_parts/cell/crap/empty = 15,
		/obj/item/stock_parts/cell/secborg = 10,
		/obj/item/stock_parts/cell/secborg/empty = 10,
		/obj/item/stock_parts/cell/mini_egun = 10,
		/obj/item/stock_parts/cell/emergency_light = 5,
		/obj/item/stock_parts/cell/potato = 5,
		/obj/item/stock_parts/cell/emproof = 10,
		/obj/item/stock_parts/cell/emproof/empty = 10,
		/obj/item/stock_parts/cell/upgraded = 10,
		/obj/item/stock_parts/cell/upgraded/plus = 10,
		/obj/item/stock_parts/cell/hos_gun = 5,
		/obj/item/stock_parts/cell/pulse/pistol = 5,
		/obj/item/stock_parts/cell/pulse/carbine = 5,
		/obj/item/stock_parts/cell/emproof/slime = 5,
		/obj/item/stock_parts/cell/inducer_supply = 5,
		/obj/item/stock_parts/cell/pulse = 10,
		/obj/item/stock_parts/cell/high = 10,
		/obj/item/stock_parts/cell/high/empty = 10,
		/obj/item/stock_parts/cell/super = 10,
		/obj/item/stock_parts/cell/super/empty = 10,
		/obj/item/stock_parts/cell/hyper = 10,
		/obj/item/stock_parts/cell/hyper/empty = 10,
		/obj/item/stock_parts/cell/bluespace = 10,
		/obj/item/stock_parts/cell/bluespace/empty = 10,
		/obj/item/stock_parts/cell/beam_rifle = 5,
		/obj/item/stock_parts/cell/crystal_cell = 5
	)

/obj/effect/spawner/random/powercell/all_inclusive/x2
	name = "all inclusive power cell spawner (x2)"
	desc = "Spawns two random power cells."
	spawn_loot_count = 2

/obj/effect/spawner/random/powercell/all_inclusive/x3
	name = "all inclusive power cell spawner (x3)"
	desc = "Spawns three random power cells."
	spawn_loot_count = 3

/obj/effect/spawner/random/powercell/all_inclusive/x4
	name = "all inclusive power cell spawner (x4)"
	desc = "Spawns four random power cells."
	spawn_loot_count = 4
