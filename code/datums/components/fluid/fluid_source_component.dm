/datum/component/fluid_source
	var/flow_rate = 10 // Amount of fluid generated per tick
	var/generated_fluid_type = /datum/fluid/water // Type of fluid generated
	var/temperature = T20C // Temperature of generated fluid
	var/is_active = FALSE // Whether the source is currently active
	var/list/deferred_turfs // List to hold turfs that couldn't be registered immediately

/datum/component/fluid_source/Initialize()
	. = ..()
	// Activate the fluid source by default upon initialization.
	activate()

	// Defer registration to avoid race conditions during initialization
	addtimer(CALLBACK(src, PROC_REF(register_source)), 1)

/datum/component/fluid_source/Destroy()
	UnregisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY)
	var/turf/T = get_turf(parent)
	if (istype(T))
		var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_fluid_simulation_subsystem(generated_fluid_type)
		if (fluid_sim_subsystem)
			fluid_sim_subsystem.active_fluid_sources -= T
			message_admins(span_notice("FluidSourceComponent [src.parent]: Unregistered source on turf [T] from fluid simulation."))
	qdel(deferred_turfs)
	. = ..()

/datum/component/fluid_source/proc/register_source()
	// Register the source with the relevant fluid simulation subsystem
	var/turf/T = get_turf(parent)
	if (istype(T))
		var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_fluid_simulation_subsystem(generated_fluid_type)
		if (fluid_sim_subsystem)
			fluid_sim_subsystem.active_fluid_sources += T
			var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
			if(fluid_comp)
				fluid_comp.mark_dirty()
			message_admins(span_notice("FluidSourceComponent [src.parent]: Registered source on turf [T] with fluid simulation."))
		else
			// Subsystem not ready, defer registration
			LAZYADD(deferred_turfs, T)
			RegisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY, PROC_REF(onFluidSimulationReady))
			message_admins(span_notice("FluidSourceComponent [src.parent]: Deferred source registration for turf [T]. Subsystem not ready."))

/datum/component/fluid_source/proc/activate()
	is_active = TRUE
/datum/component/fluid_source/proc/deactivate()
	is_active = FALSE

/datum/component/fluid_source/proc/ProcessSource(delta_time)
	message_admins(span_notice("FluidSourceComponent [src.parent]: ProcessSource() called. is_active: [is_active ? "TRUE" : "FALSE"]"))
	if (!is_active)
		message_admins(span_notice("FluidSourceComponent [src.parent]: ProcessSource() returning because source is not active."))
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
		message_admins(span_notice("FluidSourceComponent [src.parent]: Different fluid type ([fluid_comp.fluid_type_instance.type]) already present on [T] (expected [generated_fluid_type]). Not generating."))
		return

	if (fluid_comp)
		if (fluid_comp.getFluidAmount() >= FLUID_MAX_DEPTH)
			// Fluid is already at max depth, no need to generate more.
			message_admins(span_notice("FluidSourceComponent [src.parent]: Fluid on [T] is already at max depth ([fluid_comp.getFluidAmount()]/[FLUID_MAX_DEPTH]). Not generating."))
			return

		var/amount_to_add = flow_rate * delta_time
		message_admins(span_notice("FluidSourceComponent [src.parent]: Calling addFluid([amount_to_add], [temperature]) on [T]'s FluidComponent."))
		fluid_comp.addFluid(amount_to_add, temperature)
		fluid_comp.mark_dirty() // Explicitly mark as dirty to trigger simulation
		message_admins(span_notice("FluidSourceComponent [src.parent]: Fluid amount on [T] after addFluid: [fluid_comp.getFluidAmount()]."))

		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SOURCE_GENERATED, amount_to_add, generated_fluid_type, temperature)
		message_admins(span_notice("FluidSourceComponent [src.parent]: Sent COMSIG_FLUID_SOURCE_GENERATED signal."))

/datum/component/fluid_source/proc/onFluidSimulationReady(datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem)
	if (fluid_sim_subsystem.simulated_fluid_type == generated_fluid_type)
		message_admins(span_notice("FluidSourceComponent [src.parent]: Received COMSIG_FLUID_SIMULATION_READY for [fluid_sim_subsystem.simulated_fluid_type]. Processing deferred turfs."))
		for (var/turf/T in deferred_turfs)
			if (QDELETED(T))
				continue
			fluid_sim_subsystem.active_fluid_sources += T
			message_admins(span_notice("FluidSourceComponent [src.parent]: Registered deferred source on turf [T] with fluid simulation."))
		deferred_turfs.Cut() // Clear the list after processing
		UnregisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY) // Unregister once processed

/datum/component/fluid_source/proc/get_fluid_simulation_subsystem(datum/fluid/fluid_type_to_find)
	return SScomponent_fluid_simulation.get_fluid_simulation_subsystem(fluid_type_to_find)
