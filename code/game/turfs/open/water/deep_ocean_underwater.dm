/turf/open/water/deep_ocean_underwater
	name = "deep ocean"
	desc = "The crushing depths of the ocean floor. You feel an immense pressure."
	icon = 'icons/turf/floors.dmi' // Placeholder, ideally a unique deep ocean icon
	icon_state = "deep_ocean_still" // Placeholder
	baseturfs = /turf/open/water/ocean // Inherit from ocean turf
	initial_gas = OPENTURF_DEFAULT_ATMOS // Or a custom underwater atmosphere
	slowdown = 2.5 // Clunk.. Clunk.. Movement is very slow here.
	turf_flags = NO_RUST | IS_UNDERWATER

/turf/open/water/deep_ocean_underwater/Initialize()
	. = ..()
	// Add FluidComponent, filled to max depth
	var/datum/component/fluid/fluid_comp = GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = AddComponent(/datum/component/fluid)
	fluid_comp.fluid_type = /datum/fluid/water
	fluid_comp.addFluid(FLUID_MAX_DEPTH, 276.65) // Fill to max depth, 3.5C

	// Add FluidSourceComponent, but keep it inactive to prevent unnecessary generation
	var/datum/component/fluid_source/fluid_source_comp = GetComponent(/datum/component/fluid_source)
	if (!fluid_source_comp)
		fluid_source_comp = AddComponent(/datum/component/fluid_source)
	fluid_source_comp.generated_fluid_type = /datum/fluid/water
	fluid_source_comp.flow_rate = 0 // No flow, it's already full
	fluid_source_comp.deactivate() // Ensure it's inactive
