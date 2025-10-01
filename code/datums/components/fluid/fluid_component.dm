/datum/component/fluid
	var/fluid_amount = 0 // Current depth/volume of fluid
	var/original_footstep = null // The original footstep sound of the turf
	var/datum/fluid/fluid_type_instance // Store an instance of the fluid datum
	var/datum/reagents/reagents = null // Reagent holder for the fluid
	var/temperature = T20C // Default temperature
	var/current_visual_state = "dry" // Current visual state (e.g., "dry", "shallow", "deep")
	var/is_dirty = FALSE // Flag to indicate if this fluid component's turf needs re-evaluation for lateral diffusion
	var/image/fluid_overlay // Direct reference to the visual overlay for this fluid component

	// Momentum variables for more dynamic flow
	var/momentum_x = 0
	var/momentum_y = 0
	var/momentum_decay = 0.5 // Amount of momentum lost each tick

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
	if (!fluid_type_instance) // If fluid_type_instance is not set during component creation, default to water
		fluid_type_instance = new /datum/fluid/water
	reagents = new(FLUID_MAX_DEPTH) // Initialize the reagent holder
	reagents.my_atom = parent
	SSfluid_visuals.registerFluidComponent(src) // Register with the FluidVisuals subsystem
	if (fluid_amount > FLUID_EVAPORATION_POINT) // We need to flag for an update if it's being made with Fluid.
		SScomponent_fluid_simulation.global_active_fluid_turfs[parent] = TRUE
		mark_dirty()
	updateVisuals()

/datum/component/fluid/Destroy()
	SSfluid_visuals.unregisterFluidComponent(src) // Unregister from the FluidVisuals subsystem
	qdel(reagents)
	. = ..()

/datum/component/fluid/proc/addFluid(amount, new_temperature, incoming_momentum_x = 0, incoming_momentum_y = 0, datum/reagents/source_reagents = null)
	var/old_amount = fluid_amount
	if (old_amount < FLUID_SHALLOW && (fluid_amount + amount) >= FLUID_SHALLOW)
		var/turf/open/T = parent
		if (istype(T) && T.footstep != FOOTSTEP_WATER)
			original_footstep = T.footstep
			T.footstep = FOOTSTEP_WATER
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: addFluid([amount], [new_temperature]) called. Current amount: [fluid_amount]"))
	fluid_amount = min(FLUID_MAX_DEPTH, fluid_amount + amount)

	// Update momentum
	var/total_amount = old_amount + amount
	if (total_amount > 0)
		momentum_x = (momentum_x * old_amount + incoming_momentum_x * amount) / total_amount
		momentum_y = (momentum_y * old_amount + incoming_momentum_y * amount) / total_amount
	// Simple temperature mixing for now
	if(fluid_amount > 0)
		temperature = (temperature * (fluid_amount - amount) + new_temperature * amount) / fluid_amount
	else
		temperature = new_temperature

	// Transfer reagents
	if (source_reagents)
		source_reagents.trans_to(src, amount)

	if (old_amount <= FLUID_EVAPORATION_POINT && fluid_amount > FLUID_EVAPORATION_POINT)
		SScomponent_fluid_simulation.global_active_fluid_turfs[parent] = TRUE
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Fluid amount after addFluid: [fluid_amount]"))
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Sent COMSIG_PARENT_FLUID_AMOUNT_CHANGED. New amount: [fluid_amount]"))
	mark_dirty()
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
	fluid_amount = max(FLUID_DELETING, fluid_amount - amount)

	// Remove a proportional amount of reagents
	if (reagents && old_amount > 0)
		reagents.remove_reagent(reagents, amount)

	if (old_amount > FLUID_EVAPORATION_POINT && fluid_amount <= FLUID_EVAPORATION_POINT)
		SScomponent_fluid_simulation.global_active_fluid_turfs -= parent
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Fluid amount after removeFluid: [fluid_amount]"))
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidComponent [src.parent]: Sent COMSIG_PARENT_FLUID_AMOUNT_CHANGED. New amount: [fluid_amount]"))
	mark_dirty()
	updateVisuals()

/datum/component/fluid/proc/getFluidAmount()
	return fluid_amount

/datum/component/fluid/proc/getTemperature()
	return temperature

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


/datum/component/fluid/proc/mark_dirty()
	if (!is_dirty)
		is_dirty = TRUE
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidComponent [src.parent]: mark_dirty() called. Sending COMSIG_GLOB_FLUID_COMPONENT_DIRTY."))
		if (QDELETED(src))
			return
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FLUID_COMPONENT_DIRTY, parent)

// Define fluid types (simple datums for now)
/datum/fluid
	var/density = 1000 // Default density (e.g., water)
	var/viscosity = 1  // Default viscosity (e.g., water)
	var/color

	// Base Fluid Overlays; If you want you can override these for unique fluid appearances.
	var/list/icon_state_map = list(
		"evaporation_still" = "evaporation_still",
		"fluid_shallow_still" = "fluid_shallow_still",
		"fluid_mid_still" = "fluid_mid_still",
		"fluid_deep_still" = "fluid_deep_still",
		"fluid_deepest_still" = "fluid_deepest_still"
	)

/datum/fluid/water
	density = 1000
	viscosity = 1
	color = COLOR_OCEAN

/datum/fluid/oil
	density = 800
	viscosity = 5
	color = "#333333"

/datum/fluid/smoke
	density = 100
	viscosity = 0.5
	color = "#808080" // Grey

/datum/fluid/foam
	density = 500
	viscosity = 3
	color = COLOR_WHITE
