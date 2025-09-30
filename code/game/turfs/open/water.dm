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
	message_admins(span_notice("ocean/Initialize() called for [src]"))
	// Add FluidComponent
	var/datum/component/fluid/fluid_comp = GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = AddComponent(/datum/component/fluid)
		message_admins(span_notice("ocean/Initialize(): Added FluidComponent [fluid_comp] to [src]"))
	else
		message_admins(span_notice("ocean/Initialize(): FluidComponent [fluid_comp] already exists on [src]"))

	fluid_comp.fluid_type_instance = new /datum/fluid/water
	fluid_comp.addFluid(FLUID_MAX_DEPTH, 276.65) // Fill to max depth, 3.5C, or 38.3F for everyone else.
	message_admins(span_notice("ocean/Initialize(): Called addFluid on [fluid_comp] with amount [FLUID_MAX_DEPTH]"))

	// Add FluidSourceComponent to ensure continuous replenishment
	var/datum/component/fluid_source/fluid_source_comp = GetComponent(/datum/component/fluid_source)
	if (!fluid_source_comp)
		fluid_source_comp = AddComponent(/datum/component/fluid_source)
		message_admins(span_notice("ocean/Initialize(): Added FluidSourceComponent [fluid_source_comp] to [src]"))
	else
		message_admins(span_notice("ocean/Initialize(): FluidSourceComponent [fluid_source_comp] already exists on [src]"))

	fluid_source_comp.generated_fluid_type = /datum/fluid/water
	fluid_source_comp.flow_rate = FLUID_MAX_DEPTH / 5 // Replenish 20% of max depth per tick
	fluid_source_comp.activate()
	message_admins(span_notice("ocean/Initialize(): Activated FluidSourceComponent [fluid_source_comp]"))

	// Register the turf with the appropriate fluid simulation subsystem
	var/datum/controller/subsystem/component_fluid_simulation/water_sim = SScomponent_fluid_simulation.get_fluid_simulation_subsystem(/datum/fluid/water)
	if (water_sim)
		water_sim.add_active_fluid_turf(src)
		message_admins(span_notice("ocean/Initialize(): Registered [src] with the water simulation subsystem."))
