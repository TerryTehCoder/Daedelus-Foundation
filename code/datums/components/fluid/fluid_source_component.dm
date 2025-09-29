/datum/component/fluid_source
	var/flow_rate = 10 // Amount of fluid generated per tick
	var/generated_fluid_type = /datum/fluid/water // Type of fluid generated
	var/temperature = T20C // Temperature of generated fluid
	var/is_active = FALSE // Whether the source is currently active

/datum/component/fluid_source/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_PROCESS, PROC_REF(on_parent_process))

/datum/component/fluid_source/Destroy()
	. = ..()

/datum/component/fluid_source/proc/on_parent_process(datum/component/source_component, delta_time)
	ProcessSource(delta_time)

/datum/component/fluid_source/proc/activate()
	is_active = TRUE
/datum/component/fluid_source/proc/deactivate()
	is_active = FALSE

/datum/component/fluid_source/proc/ProcessSource(delta_time)
	message_admins(span_notice("FluidSourceComponent [src.parent]: ProcessSource() called. is_active: [is_active]"))
	if (!is_active)
		return

	var/turf/T = get_turf(parent)
	if (!istype(T))
		message_admins(span_notice("FluidSourceComponent [src.parent]: Parent is not a turf. Returning."))
		return

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = T.AddComponent(/datum/component/fluid, fluid_type_instance = new generated_fluid_type)
		message_admins(span_notice("FluidSourceComponent [src.parent]: Added new FluidComponent to [T]"))
	else
		message_admins(span_notice("FluidSourceComponent [src.parent]: Found existing FluidComponent on [T]"))

	if (fluid_comp.fluid_type_instance.type != generated_fluid_type)
		// If a different fluid type is already present, we don't mix or override it.
		message_admins(span_notice("FluidSourceComponent [src.parent]: Different fluid type ([fluid_comp.fluid_type_instance.type]) already present on [T]. Not generating."))
		return

	if (fluid_comp)
		if (fluid_comp.getFluidAmount() >= FLUID_MAX_DEPTH)
			// Fluid is already at max depth, no need to generate more.
			message_admins(span_notice("FluidSourceComponent [src.parent]: Fluid on [T] is already at max depth ([fluid_comp.getFluidAmount()]/[FLUID_MAX_DEPTH]). Not generating."))
			return

		message_admins(span_notice("FluidSourceComponent [src.parent]: Calling addFluid([flow_rate * delta_time], [temperature]) on [T]'s FluidComponent."))
		fluid_comp.addFluid(flow_rate * delta_time, temperature)
		// Ensure the turf is active in the relevant fluid simulation subsystem
		var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_fluid_simulation_subsystem(generated_fluid_type)
		if (fluid_sim_subsystem)
			fluid_sim_subsystem.add_active_fluid_turf(T)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Called add_active_fluid_turf on [T] for [generated_fluid_type] simulation."))
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SOURCE_GENERATED, flow_rate * delta_time, generated_fluid_type, temperature)
		message_admins(span_notice("FluidSourceComponent [src.parent]: Sent COMSIG_FLUID_SOURCE_GENERATED signal."))

/datum/component/fluid_source/proc/get_fluid_simulation_subsystem(datum/fluid/fluid_type_to_find)
	return SScomponent_fluid_simulation.all_fluid_simulations[fluid_type_to_find]
