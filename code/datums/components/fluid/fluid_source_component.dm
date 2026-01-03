/*
 * I cannot understate how cool this concept is to me, fluid_sources are essentially a infinite source of whatever fluid you want.
 * You could use it to flood a room with water from a broken pipe, or chemicals, etc
 * You could make some sort of machinery leak fuel or coolant.
 *
 */

/datum/component/fluid_source
	var/flow_rate = FLUID_MAX_DEPTH / 5 // Amount of fluid generated per tick
	var/temperature = T20C // Temperature of generated fluid
	var/is_active = FALSE // Whether the source is currently active
	var/list/initial_reagents // List of reagents to generate
	var/list/reagent_color_overrides
	var/initial_fluid_amount = 0 // If greater than 0, this amount of fluid will be added to the turf on initialization
	var/list/deferred_turfs // List to hold turfs that couldn't be registered immediately

/datum/component/fluid_source/Initialize(list/args)
	if(args)
		for(var/arg_name in args)
			src.vars[arg_name] = args[arg_name]
	// Activate the fluid source by default upon initialization.
	activate()

	if (initial_fluid_amount > 0)
		var/datum/component/fluid/fluid_comp = parent.GetComponent(/datum/component/fluid)
		if (!fluid_comp)
			fluid_comp = parent.AddComponent(/datum/component/fluid)
		if (fluid_comp)
			var/datum/reagents/source_reagents = new()
			if (initial_reagents)
				var/total_initial_volume = get_total_reagent_volume()
				if (total_initial_volume > 0)
					source_reagents.add_reagent_list(initial_reagents, initial_fluid_amount / total_initial_volume)
			fluid_comp.addFluid(initial_fluid_amount, temperature, 0, 0, source_reagents, reagent_color_overrides)
			qdel(source_reagents)

	// Defer registration to avoid race conditions during initialization
	addtimer(CALLBACK(src, PROC_REF(register_source)), 1)

/datum/component/fluid_source/Destroy()
	UnregisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY)
	var/turf/T = get_turf(parent)
	if (istype(T))
		if (SScomponent_fluid_simulation)
			SScomponent_fluid_simulation.active_fluid_sources -= T
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidSourceComponent [src.parent]: Unregistered source on turf [T] from fluid simulation."))
	deferred_turfs = null
	. = ..()

/datum/component/fluid_source/proc/register_source()
	// Register the source with the relevant fluid simulation subsystem
	var/turf/T = get_turf(parent)
	if (istype(T))
		if (SScomponent_fluid_simulation)
			SScomponent_fluid_simulation.active_fluid_sources += T
			SScomponent_fluid_simulation.add_dirty_turf(T)

			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidSourceComponent [src.parent]: Registered source on turf [T] with fluid simulation."))
		else
			// Subsystem not ready, defer registration
			LAZYADD(deferred_turfs, T)
			RegisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY, PROC_REF(onFluidSimulationReady))
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidSourceComponent [src.parent]: Deferred source registration for turf [T]. Subsystem not ready."))

/datum/component/fluid_source/proc/activate()
	is_active = TRUE
/datum/component/fluid_source/proc/deactivate()
	is_active = FALSE

/datum/component/fluid_source/proc/get_total_reagent_volume()
	var/total_volume = 0
	if (initial_reagents)
		for (var/reagent_amount in initial_reagents)
			total_volume += initial_reagents[reagent_amount]
	return total_volume

/datum/component/fluid_source/proc/ProcessSource(delta_time)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidSourceComponent [src.parent]: ProcessSource() called. is_active: [is_active ? "TRUE" : "FALSE"]"))
	if (!is_active)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: ProcessSource() returning because source is not active."))
		return

	var/turf/T = get_turf(parent)
	if (!istype(T))
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Parent is not a turf. Returning."))
		return

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (!fluid_comp)
		fluid_comp = T.AddComponent(/datum/component/fluid)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Added new FluidComponent to [T]"))
	else
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Found existing FluidComponent on [T]"))

	if (fluid_comp)
		if (fluid_comp.getFluidAmount() >= FLUID_MAX_DEPTH)
			// Fluid is already at max depth, no need to generate more.
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidSourceComponent [src.parent]: Fluid on [T] is already at max depth ([fluid_comp.getFluidAmount()]/[FLUID_MAX_DEPTH]). Not generating."))
			return

		var/amount_to_add = flow_rate * delta_time
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Adding [amount_to_add] reagents to [T]'s FluidComponent."))

		if (initial_reagents)
			var/total_initial_volume = get_total_reagent_volume()
			if (total_initial_volume > 0)
				var/datum/reagents/source_reagents = new()
				source_reagents.add_reagent_list(initial_reagents, amount_to_add / total_initial_volume)
				fluid_comp.addFluid(amount_to_add, temperature, 0, 0, source_reagents, reagent_color_overrides)
				qdel(source_reagents)
		else
			fluid_comp.addFluid(amount_to_add, temperature, 0, 0, null, reagent_color_overrides)

		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Fluid amount on [T] after addFluid: [fluid_comp.getFluidAmount()]."))

		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_SOURCE_GENERATED, amount_to_add, fluid_comp.reagents, temperature)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Sent COMSIG_FLUID_SOURCE_GENERATED signal."))

/datum/component/fluid_source/proc/onFluidSimulationReady(datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidSourceComponent [src.parent]: Received COMSIG_FLUID_SIMULATION_READY. Processing deferred turfs."))
	for (var/turf/T in deferred_turfs)
		if (QDELETED(T))
			continue
		fluid_sim_subsystem.active_fluid_sources += T
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidSourceComponent [src.parent]: Registered deferred source on turf [T] with fluid simulation."))
	deferred_turfs.Cut() // Clear the list after processing
	UnregisterSignal(SScomponent_fluid_simulation, COMSIG_FLUID_SIMULATION_READY) // Unregister once processed
