/datum/component/fluid
	var/fluid_amount = 0 // Current depth/volume of fluid
	var/original_footstep = null // The original footstep sound of the turf
	var/datum/reagents/reagents = null // Reagent holder for the fluid
	var/temperature = T20C // Default temperature
	var/list/reagent_color_overrides
	var/current_visual_state = "dry" // Current visual state (e.g., "dry", "shallow", "deep")
	var/image/fluid_overlay // Direct reference to the visual overlay for this fluid component

	// Momentum variables for more dynamic flow
	var/momentum_x = 0
	var/momentum_y = 0
	var/momentum_decay = 0.25 // Amount of momentum lost each tick
	var/pressure = 0 // Used for pressure calculations.
	var/body_average_amount = 0 // The average fluid amount for the contiguous body of fluid this turf is a part of.

	// Configuration for visual thresholds and icon states
	var/list/visual_thresholds = list(
		FLUID_EVAPORATION_POINT = "evaporation_still",
		FLUID_SHALLOW = "fluid_shallow_still",
		FLUID_MID_STILL = "fluid_mid_still",
		FLUID_DEEP = "fluid_deep_still",
		FLUID_DEEPEST = "fluid_deepest_still"
	)
/datum/component/fluid/Initialize()
	. = ..()
	reagents = new(FLUID_MAX_DEPTH) // Initialize the reagent holder
	reagents.my_atom = parent
	SSfluid_visuals.registerFluidComponent(src) // Register with the FluidVisuals subsystem
	if (fluid_amount > FLUID_EVAPORATION_POINT) // We need to flag for an update if it's being made with Fluid.
		SScomponent_fluid_simulation.global_active_fluid_turfs[parent] = TRUE
	updateVisuals()

	// Auto-add wave component for deep ocean turfs
	if (fluid_amount >= FLUID_DEEP && istype(parent, /turf/open/water/ocean))
		add_wave_component()

/datum/component/fluid/proc/add_wave_component()
	// Only add wave component if one doesn't already exist
	if (parent.GetComponent(/datum/component/wave))
		return

	// Create wave component with parameters based on fluid depth
	var/datum/component/wave/wave_comp = parent.AddComponent(/datum/component/wave, list(
		"wave_amplitude" = WAVE_DEFAULT_AMPLITUDE,
		"wave_frequency" = WAVE_DEFAULT_FREQUENCY,
		"wave_speed" = WAVE_DEFAULT_SPEED,
		"whitecap_threshold" = WHITECAP_THRESHOLD
	))

	// Register with fluid visuals subsystem
	SSfluid_visuals.registerWaveComponent(wave_comp)

	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Added WaveComponent for ocean waves"))

/datum/component/fluid/Destroy()
	SSfluid_visuals.unregisterFluidComponent(src) // Unregister from the FluidVisuals subsystem
	qdel(reagents)
	. = ..()

/datum/component/fluid/proc/addFluid(amount, new_temperature, incoming_momentum_x = 0, incoming_momentum_y = 0, datum/reagents/source_reagents, list/source_color_overrides)
	var/old_amount = fluid_amount
	if (old_amount < FLUID_SHALLOW && (fluid_amount + amount) >= FLUID_SHALLOW)
		var/turf/open/T = parent
		if (istype(T) && T.footstep != FOOTSTEP_WATER)
			original_footstep = T.footstep
			T.footstep = FOOTSTEP_WATER
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: addFluid([amount], [new_temperature]) called. Current amount: [fluid_amount]"))

	// Transfer reagents
	if (source_reagents)
		source_reagents.trans_to(src, amount)
	else
		reagents.add_reagent(/datum/reagent/water, amount) // Default to water if no source is provided

	if (source_color_overrides)
		if (!reagent_color_overrides)
			reagent_color_overrides = list()
		for(var/reagent_type in source_color_overrides)
			reagent_color_overrides[reagent_type] = source_color_overrides[reagent_type]

	fluid_amount = reagents.total_volume

	// Update momentum
	var/total_amount = fluid_amount
	if (total_amount > 0)
		momentum_x = (momentum_x * old_amount + incoming_momentum_x * amount) / total_amount
		momentum_y = (momentum_y * old_amount + incoming_momentum_y * amount) / total_amount
	// Simple temperature mixing for now
	if(fluid_amount > 0)
		temperature = (temperature * old_amount + new_temperature * amount) / fluid_amount
	else
		temperature = new_temperature

	if (old_amount <= FLUID_EVAPORATION_POINT && fluid_amount > FLUID_EVAPORATION_POINT)
		SScomponent_fluid_simulation.add_dirty_turf(parent)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Fluid amount after addFluid: [fluid_amount]"))
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Sent COMSIG_PARENT_FLUID_AMOUNT_CHANGED. New amount: [fluid_amount]"))
	updateVisuals()

/datum/component/fluid/proc/removeFluid(amount)
	var/old_amount = fluid_amount
	if (old_amount >= FLUID_SHALLOW && (fluid_amount - amount) < FLUID_SHALLOW)
		var/turf/open/T = parent
		if (istype(T) && !isnull(original_footstep))
			T.footstep = original_footstep
			original_footstep = null
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: removeFluid([amount]) called. Current amount: [fluid_amount]"))

	// Remove a proportional amount of reagents
	if (reagents && old_amount > 0)
		var/fraction_to_remove = amount / old_amount
		if (fraction_to_remove > 0)
			var/list/reagents_to_process = reagents.reagent_list.Copy()
			for (var/datum/reagent/R in reagents_to_process)
				reagents.remove_reagent(R.type, R.volume * fraction_to_remove)

	// Update fluid amount after reagent removal
	fluid_amount = reagents.total_volume

	if (old_amount > FLUID_EVAPORATION_POINT && fluid_amount <= FLUID_EVAPORATION_POINT)
		SScomponent_fluid_simulation.remove_active_fluid_turf(parent)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Fluid amount after removeFluid: [fluid_amount]"))
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Sent COMSIG_PARENT_FLUID_AMOUNT_CHANGED. New amount: [fluid_amount]"))
	updateVisuals()

/datum/component/fluid/proc/getFluidAmount()
	return fluid_amount

/datum/component/fluid/proc/getTemperature()
	return temperature

/datum/component/fluid/proc/get_viscosity()
	if (!reagents || reagents.total_volume == 0)
		return 1 // Default viscosity

	var/total_viscosity = 0
	for (var/datum/reagent/R in reagents.reagent_list)
		total_viscosity += R.viscosity * R.volume

	return total_viscosity / reagents.total_volume

/datum/component/fluid/proc/get_density()
	if (!reagents || reagents.total_volume == 0)
		return 1000 // Default density

	var/total_density = 0
	for (var/datum/reagent/R in reagents.reagent_list)
		total_density += R.density * R.volume

	return total_density / reagents.total_volume

/datum/component/fluid/proc/updateVisuals()
	var/new_visual_state = "dry"
	if (fluid_amount >= FLUID_DEEPEST)
		new_visual_state = "fluid_deepest_still"
	else if (fluid_amount >= FLUID_DEEP)
		new_visual_state = "fluid_deep_still"
	else if (fluid_amount >= FLUID_MID_STILL)
		new_visual_state = "fluid_mid_still"
	else if (fluid_amount >= FLUID_SHALLOW)
		new_visual_state = "fluid_shallow_still"
	else if (fluid_amount > FLUID_EVAPORATION_POINT)
		// If we still have some fluid but it's below shallow, show shallow still unless we were already showing fluid
		// This helps us avoid flickering between dry and fluid shallow, creating awkward looking bubbles in the fluid pool.
		if (current_visual_state != "dry" && current_visual_state != "evaporation_still")
			new_visual_state = "fluid_shallow_still"
		else
			new_visual_state = "evaporation_still"
	else if (fluid_amount > FLUID_DELETING)
		new_visual_state = "evaporation_still" // This state is for when fluid is barely present but not yet evaporated
	else
		new_visual_state = "dry" // No fluid, or fluid is being deleted, dry icon doesn't really exist so..

	if (new_visual_state != current_visual_state)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidComponent [src.parent]: updateVisuals() - Determined new_visual_state: [new_visual_state]"))
		current_visual_state = new_visual_state
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidComponent [src.parent]: Visual state changed to [current_visual_state]. Sending COMSIG_FLUID_VISUAL_STATE_CHANGED."))
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_VISUAL_STATE_CHANGED, current_visual_state, fluid_amount)
