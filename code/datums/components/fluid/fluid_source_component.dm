/datum/component/fluid_source
	name = "Fluid Source Component"
	var/flow_rate = 10 // Amount of fluid generated per tick
	var/generated_fluid_type = /datum/fluid/water // Type of fluid generated
	var/temperature = T20C // Temperature of generated fluid
	var/is_active = FALSE // Whether the source is currently active

/datum/component/fluid_source/Initialize()
	. = ..()

/datum/component/fluid_source/Destroy()
	. = ..()

/datum/component/fluid_source/proc/activate()
	is_active = TRUE

/datum/component/fluid_source/proc/deactivate()
	is_active = FALSE

/datum/component/fluid_source/proc/ProcessSource(delta_time)
	if (!is_active)
		return

	var/turf/T = get_turf(parent)
	if (!istype(T))
		return

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = T.AddComponent(/datum/component/fluid, .args = list(fluid_type = generated_fluid_type))
	else if (fluid_comp.fluid_type != generated_fluid_type)
		// If a different fluid type is already present, we don't mix or override it.
		return

	if (fluid_comp)
		if (fluid_comp.getFluidAmount() >= FLUID_MAX_DEPTH)
			// Fluid is already at max depth, no need to generate more.
			return

		fluid_comp.addFluid(flow_rate * delta_time, temperature)
		// Ensure the turf is active in the relevant fluid simulation subsystem
		var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_fluid_simulation_subsystem(generated_fluid_type)
		if (fluid_sim_subsystem)
			fluid_sim_subsystem.add_active_fluid_turf(T)
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLUID_SOURCE_GENERATED, flow_rate * delta_time, generated_fluid_type, temperature)

/datum/component/fluid_source/proc/get_fluid_simulation_subsystem(datum/fluid/fluid_type_to_find)
	return GLOB.all_fluid_simulations[fluid_type_to_find]

// Signal for fluid source components
#define COMSIG_FLUID_SOURCE_GENERATED "fluid_source_generated" // Emitted by FluidSourceComponent when fluid is generated
