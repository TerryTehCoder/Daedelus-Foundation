SUBSYSTEM_DEF(fluid_visuals)
	name = "Fluid Visuals"
	wait = 1 // Update visuals every tick (or faster if needed)
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	priority = FIRE_PRIORITY_OBJ

	var/static/list/fluid_image_cache = list() // Cache for image objects
	var/list/active_fluid_components = list() // List of FluidComponent instances to manage visuals for

/datum/controller/subsystem/fluid_visuals/Initialize()
	. = ..()

/datum/controller/subsystem/fluid_visuals/Destroy()
	active_fluid_components.Cut()
	. = ..()

/datum/controller/subsystem/fluid_visuals/proc/registerFluidComponent(datum/component/fluid/F)
	if (!(F in active_fluid_components))
		active_fluid_components += F
		RegisterSignal(F, COMSIG_FLUID_VISUAL_STATE_CHANGED, PROC_REF(onFluidVisualStateChanged)) // Register to the component's signal
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Registered FluidComponent [F.parent] and its visual state signal."))

/datum/controller/subsystem/fluid_visuals/proc/unregisterFluidComponent(datum/component/fluid/F)
	if (F in active_fluid_components)
		active_fluid_components -= F
		UnregisterSignal(F, COMSIG_FLUID_VISUAL_STATE_CHANGED) // Unregister from the component's signal
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Unregistered FluidComponent [F.parent] and its visual state signal."))
		// Ensure any existing overlays are removed when a component is unregistered
		var/atom/parent_atom = F.parent
		if (istype(parent_atom) && F.fluid_overlay)
			parent_atom.overlays -= F.fluid_overlay
			qdel(F.fluid_overlay)
			F.fluid_overlay = null
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidVisuals: Removed overlay from [parent_atom] during unregistration"))

/datum/controller/subsystem/fluid_visuals/fire(resumed)
	var/list/components_to_process = active_fluid_components.Copy() // Iterate over a copy to allow modification
	for(var/datum/component/fluid/fluid_comp in components_to_process)
		if (QDELETED(fluid_comp) || QDELETED(fluid_comp.parent))
			unregisterFluidComponent(fluid_comp)
			continue

		// Directly call updateVisuals on the component, which will then send the signal
		// if the visual state has changed. The onFluidVisualStateChanged proc will then
		// be triggered by the signal.
		fluid_comp.updateVisuals()

		if (MC_TICK_CHECK)
			break

/datum/controller/subsystem/fluid_visuals/proc/onFluidVisualStateChanged(datum/component/fluid/fluid_comp, new_visual_state, current_fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidVisuals: onFluidVisualStateChanged() called for [fluid_comp.parent]. New state: [new_visual_state], Amount: [current_fluid_amount]"))
	var/atom/parent_atom = fluid_comp.parent
	if (!istype(parent_atom))
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Parent atom is not of type atom. Returning."))
		return

	var/image/new_fluid_overlay_data = get_fluid_overlay(fluid_comp.fluid_type_instance, new_visual_state, current_fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidVisuals: get_fluid_overlay returned [new_fluid_overlay_data ? "an image" : "null"] for [parent_atom]"))

	if (new_fluid_overlay_data)
		// Always remove and re-add the overlay to ensure visual refresh
		if (fluid_comp.fluid_overlay)
			parent_atom.overlays -= fluid_comp.fluid_overlay
			qdel(fluid_comp.fluid_overlay)
			fluid_comp.fluid_overlay = null
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidVisuals: Removed old fluid overlay from [parent_atom] for refresh"))

		// Add new overlay and store reference
		fluid_comp.fluid_overlay = new_fluid_overlay_data
		parent_atom.overlays += fluid_comp.fluid_overlay
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Added new fluid overlay to [parent_atom]"))
	else if (fluid_comp.fluid_overlay)
		// Remove existing overlay if no fluid should be visible
		parent_atom.overlays -= fluid_comp.fluid_overlay
		qdel(fluid_comp.fluid_overlay)
		fluid_comp.fluid_overlay = null
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Removed fluid overlay from [parent_atom] as fluid amount <= FLUID_EVAPORATION_POINT"))

/datum/controller/subsystem/fluid_visuals/proc/get_fluid_overlay(datum/fluid/fluid_type, visual_state, current_fluid_amount)
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidVisuals: get_fluid_overlay([fluid_type.type], [visual_state], [current_fluid_amount]) called."))
	var/cache_key = "[fluid_type.type]_[visual_state]" // Cache based on type and state
	var/image/base_image = fluid_image_cache[cache_key]
	var/icon_state_name = fluid_type.icon_state_map[visual_state]

	if (!base_image)
		if (!icon_state_name)
			if(GLOB.fluid_debug_enabled)
				message_admins(span_notice("FluidVisuals: No icon_state_name found for visual_state [visual_state]. Returning null."))
			return null

		base_image = image('icons/effects/liquids.dmi', icon_state_name)
		base_image.name = "fluid_overlay_base" // Tag for easy identification
		fluid_image_cache[cache_key] = base_image
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Created and cached new base image with icon_state [icon_state_name]"))

	if (!icon_state_name)
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: No icon_state_name found for visual_state [visual_state]. Returning null."))
		return null

	// Create a copy to apply dynamic properties
	var/image/new_image = image(base_image)
	new_image.name = "fluid_overlay" // Tag for easy identification
	if(GLOB.fluid_debug_enabled)
		message_admins(span_notice("FluidVisuals: Created new image with icon_state [icon_state_name]"))

	// Dynamic Layering
	if (current_fluid_amount > FLUID_OVER_MOB_HEAD) // Use FLUID_OVER_MOB_HEAD as a threshold for deep fluid layer
		new_image.layer = DEEP_FLUID_LAYER
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting layer to DEEP_FLUID_LAYER ([DEEP_FLUID_LAYER])"))
	else
		new_image.layer = SHALLOW_FLUID_LAYER
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting layer to SHALLOW_FLUID_LAYER ([SHALLOW_FLUID_LAYER])"))

	// Dynamic Alpha
	if (current_fluid_amount > FLUID_DEEPEST) // Max alpha for deepest fluid
		new_image.alpha = FLUID_MAX_ALPHA
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting alpha to FLUID_MAX_ALPHA ([FLUID_MAX_ALPHA])"))
	else if (current_fluid_amount > FLUID_DELETING)
		// Scale alpha between MIN and MAX based on fluid amount relative to FLUID_DEEPEST
		new_image.alpha = min(FLUID_MAX_ALPHA, max(FLUID_MIN_ALPHA, round(FLUID_MIN_ALPHA + (FLUID_MAX_ALPHA - FLUID_MIN_ALPHA) * (current_fluid_amount / FLUID_DEEPEST))))
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting alpha to scaled value ([new_image.alpha])"))
	else
		new_image.alpha = 0 // No fluid, no alpha
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting alpha to 0"))

	// Apply fluid-specific color
	if (fluid_type.color)
		new_image.color = fluid_type.color
		if(GLOB.fluid_debug_enabled)
			message_admins(span_notice("FluidVisuals: Setting color to [fluid_type.color]"))

	return new_image
