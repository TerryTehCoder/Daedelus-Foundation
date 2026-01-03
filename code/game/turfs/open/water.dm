/turf/open/water
	gender = PLURAL
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	initial_gas = OPENTURF_LOW_PRESSURE

	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/water/jungle
	initial_gas = OPENTURF_DEFAULT_ATMOS

/turf/open/water/beach
	gender = PLURAL
	desc = "You get the feeling that nobody's bothered to actually make this water functional..."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/beach

//Same turf, but instead used in the Beach Biodome
/turf/open/water/beach/biodome
	initial_gas = OPENTURF_DEFAULT_ATMOS

/turf/open/water/ocean
	name = "ocean"
	desc = "The vast, deep ocean."
	baseturfs = /turf/open/water // Inherit from base water turf
	initial_gas = OPENTURF_DEFAULT_ATMOS
	slowdown = 1.5 // Slightly more slowdown for deep ocean

/turf/open/water/ocean/Initialize()
	. = ..()
	AddComponent(/datum/component/fluid_source, list(
		initial_fluid_amount = FLUID_MAX_DEPTH,
		temperature = 276.65, // 3.5C, or 38.3F || Around the avg ocean temp
		initial_reagents = list(/datum/reagent/water = FLUID_MAX_DEPTH),
		flow_rate = FLUID_MAX_DEPTH / 3, // Replenish 33% of max depth per tick
		is_active = TRUE,
		reagent_color_overrides = list(
			/datum/reagent/water = "#0B3D91"
		)
	))

	// Add wave component for ocean waves
	var/datum/component/fluid/fluid_comp = GetComponent(/datum/component/fluid)
	if (!fluid_comp) //There should be one, but just in case let's double check.
		fluid_comp = AddComponent(/datum/component/fluid)
	fluid_comp.add_wave_component()
