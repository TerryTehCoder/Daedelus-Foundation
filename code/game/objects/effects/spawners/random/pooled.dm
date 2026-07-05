/*
 * Subtypes of /obj/effect/spawner/random that use the shared offset pool system.
 * All spawners sharing a pool_id will distribute items across their positions
 * without doubling up.
 */

/obj/effect/spawner/random/pooled
	name = "pooled spawn location"
	spawn_loot_double = FALSE
	spawn_random_offset = FALSE

/obj/effect/spawner/random/pooled/auspicious_ducky
	name = "auspicious ducky spawn location"
	icon_state = "ducky"
	pool_id = "auspicious_ducks"
	loot = list(/obj/item/bikehorn/rubberducky)
	pool_spawn_name = "Auspicious Ducky"
	pool_spawn_desc = "Wu-Huh? How did This get here??"
	pool_spawn_max = 6

// Site-104

	// Utility Carts

/obj/effect/spawner/random/pooled/utilitycartshabitation
	name = "utility cart spawn location - habitation"
	icon_state = "trashcart"
	pool_id = "utilitycartshabitation"
	loot = list(/obj/structure/closet/crate/utilitycart/prefilled)
	pool_spawn_max = 5

	// Roller Beds

/obj/effect/spawner/random/pooled/rollerbedshabitation
	name = "roller bed spawn location - habitation"
	icon_state = "rollerbed"
	pool_id = "rollerbedshabitation"
	loot = list(/obj/structure/bed/roller)
	pool_spawn_max = 6

	// Janitorial Cart

/obj/effect/spawner/random/pooled/janitorialcarthabitation
	name = "janitorial cart spawn location - habitation"
	icon_state = "janitorialcart"
	pool_id = "janitorialcarthabitation"
	loot = list(/obj/structure/janitorialcart)
	pool_spawn_max = 1

	// Batsy!

/obj/effect/spawner/random/pooled/batsy
	name = "batsy - cat"
	icon_state = "batsy"
	pool_id = "batsycatwalkcat"
	loot = list(/mob/living/simple_animal/pet/cat/original)
	pool_spawn_max = 1
	pool_spawn_desc = "Get it? Batsy likes hanging out on catwalks? Because.. she's a cat? Cause cat.. walk...? I'll see myself out."
