SUBSYSTEM_DEF(fluid_visuals)
	name = "Fluid Visuals"
	wait = 1 // Update visuals every tick (or faster if needed)
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	priority = FIRE_PRIORITY_OBJ

	var/static/list/fluid_image_cache = list() // Cache for image objects

/datum/controller/subsystem/fluid_visuals/Initialize()
	. = ..()
	// FluidVisualsSystem listens to COMSIG_FLUID_VISUAL_STATE_CHANGED directly from FluidComponent,
	// as this signal is emitted by the component itself regardless of which subsystem manages its simulation.
	RegisterSignal(src, COMSIG_FLUID_VISUAL_STATE_CHANGED, .proc/onFluidVisualStateChanged)

/datum/controller/subsystem/fluid_visuals/Destroy()
	UnregisterSignal(src, COMSIG_FLUID_VISUAL_STATE_CHANGED)
	. = ..()

/datum/controller/subsystem/fluid_visuals/proc/onFluidVisualStateChanged(datum/component/fluid/fluid_comp, new_visual_state, current_fluid_amount)
	message_admins(span_notice("FluidVisuals: onFluidVisualStateChanged() called for [fluid_comp.parent]. New state: [new_visual_state], Amount: [current_fluid_amount]"))
	var/atom/parent_atom = fluid_comp.parent
	if (!istype(parent_atom))
		message_admins(span_notice("FluidVisuals: Parent atom is not of type atom. Returning."))
		return

	var/image/fluid_overlay = get_fluid_overlay(fluid_comp.fluid_type, new_visual_state, current_fluid_amount)
	message_admins(span_notice("FluidVisuals: get_fluid_overlay returned [fluid_overlay ? "an image" : "null"] for [parent_atom]"))

	// Remove existing fluid overlays and add the new one
	for(var/image/I in parent_atom.overlays)
		if (I.name == "fluid_overlay") // Identify fluid overlays by name
			parent_atom.overlays -= I
			message_admins(span_notice("FluidVisuals: Removed existing fluid overlay from [parent_atom]"))
			break // Assuming only one fluid overlay per turf

	if (fluid_overlay)
		parent_atom.overlays += fluid_overlay
		message_admins(span_notice("FluidVisuals: Added new fluid overlay to [parent_atom]"))
	else if (current_fluid_amount <= FLUID_EVAPORATION_POINT) // If fluid is gone, ensure overlay is removed
		message_admins(span_notice("FluidVisuals: Fluid amount <= FLUID_EVAPORATION_POINT. Ensuring overlay is removed."))
		// Already removed above, but good to have a check
		return

/datum/controller/subsystem/fluid_visuals/proc/get_fluid_overlay(datum/fluid/fluid_type, visual_state, current_fluid_amount)
	message_admins(span_notice("FluidVisuals: get_fluid_overlay([fluid_type.type], [visual_state], [current_fluid_amount]) called."))
	var/cache_key = "[fluid_type.type]_[visual_state]_[current_fluid_amount]" // Include fluid amount in cache key for dynamic visuals
	if (fluid_image_cache[cache_key])
		message_admins(span_notice("FluidVisuals: Returning cached image for key [cache_key]"))
		return fluid_image_cache[cache_key]

	var/icon_state_name = fluid_type.icon_state_map[visual_state]
	if (!icon_state_name)
		message_admins(span_notice("FluidVisuals: No icon_state_name found for visual_state [visual_state]. Returning null."))
		return null

	var/image/new_image = image('icons/effects/liquids.dmi', icon_state_name)
	new_image.name = "fluid_overlay" // Tag for easy identification
	message_admins(span_notice("FluidVisuals: Created new image with icon_state [icon_state_name]"))

	// Dynamic Layering
	if (current_fluid_amount > FLUID_OVER_MOB_HEAD) // Use FLUID_OVER_MOB_HEAD as a threshold for deep fluid layer
		new_image.layer = DEEP_FLUID_LAYER
		message_admins(span_notice("FluidVisuals: Setting layer to DEEP_FLUID_LAYER ([DEEP_FLUID_LAYER])"))
	else
		new_image.layer = SHALLOW_FLUID_LAYER
		message_admins(span_notice("FluidVisuals: Setting layer to SHALLOW_FLUID_LAYER ([SHALLOW_FLUID_LAYER])"))

	// Dynamic Alpha
	if (current_fluid_amount > FLUID_DEEPEST) // Max alpha for deepest fluid
		new_image.alpha = FLUID_MAX_ALPHA
		message_admins(span_notice("FluidVisuals: Setting alpha to FLUID_MAX_ALPHA ([FLUID_MAX_ALPHA])"))
	else if (current_fluid_amount > FLUID_DELETING)
		// Scale alpha between MIN and MAX based on fluid amount relative to FLUID_DEEPEST
		new_image.alpha = min(FLUID_MAX_ALPHA, max(FLUID_MIN_ALPHA, round(FLUID_MIN_ALPHA + (FLUID_MAX_ALPHA - FLUID_MIN_ALPHA) * (current_fluid_amount / FLUID_DEEPEST))))
		message_admins(span_notice("FluidVisuals: Setting alpha to scaled value ([new_image.alpha])"))
	else
		new_image.alpha = 0 // No fluid, no alpha
		message_admins(span_notice("FluidVisuals: Setting alpha to 0"))

	// Apply fluid-specific color
	if (fluid_type.color)
		new_image.color = fluid_type.color
		message_admins(span_notice("FluidVisuals: Setting color to [fluid_type.color]"))

	fluid_image_cache[cache_key] = new_image
	message_admins(span_notice("FluidVisuals: Cached new image for key [cache_key]"))
	return new_image
