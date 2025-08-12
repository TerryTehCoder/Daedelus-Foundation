/obj/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	reflectable = REFLECT_NORMAL
	impact_effect_type = /obj/effect/temp_visual/impact_effect/energy

/obj/projectile/energy/flash/flare
	damage = 10

/obj/projectile/energy/flash/flare/on_hit(atom/target, blocked = 0, def_zone = null)
	. = ..()
	if(.)
		var/mob/living/M = target
		if(istype(M) && prob(33))
			M.fire_stacks = max(2, M.fire_stacks)
			M.ignite_mob()

/obj/projectile/energy/flash/flare/on_hit(atom/A)
	light_color = pick("#e58775", "#ffffff", "#faa159", "#e34e0e")
	set_light(1, 2, 6, 1, light_color)

	var/turf/TO = get_turf(src)
	var/area/AO = TO.loc
	if(AO)
		//Everyone saw that!
		for(var/mob/living/mob in GLOB.alive_mob_list)
			var/turf/T = get_turf(mob)
			if(T && (T != TO) && (TO.z == T.z) && can_see(mob))
				to_chat(mob, span_notice("You see a bright light to \the [dir2text(get_dir(T,TO))]"))
			CHECK_TICK
