SUBSYSTEM_DEF(fluid_visuals)
	name = "Fluid Visuals"
	wait = 1 // Update visuals every tick (or faster if needed)
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	priority = FIRE_PRIORITY_VISUALS // Run after other visual updates

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
	var/atom/parent_atom = fluid_comp.parent
	if (!istype(parent_atom))
		return

	var/image/fluid_overlay = get_fluid_overlay(fluid_comp.fluid_type, new_visual_state, current_fluid_amount)

	// Remove existing fluid overlays and add the new one
	for(var/image/I in parent_atom.overlays)
		if (I.name == "fluid_overlay") // Identify fluid overlays by name
			parent_atom.overlays -= I
			break // Assuming only one fluid overlay per turf

	if (fluid_overlay)
		parent_atom.overlays += fluid_overlay
	else if (current_fluid_amount <= FLUID_EVAPORATION_POINT) // If fluid is gone, ensure overlay is removed
		// Already removed above, but good to have a check
		return

/datum/controller/subsystem/fluid_visuals/proc/get_fluid_overlay(datum/fluid/fluid_type, visual_state, current_fluid_amount)
	var/cache_key = "[fluid_type.type]_[visual_state]_[current_fluid_amount]" // Include fluid amount in cache key for dynamic visuals
	if (fluid_image_cache[cache_key])
		return fluid_image_cache[cache_key]

	var/icon_state_name = fluid_type.icon_state_map[visual_state]
	if (!icon_state_name)
		return null

	var/image/new_image = image('icons/effects/liquids.dmi', icon_state_name)
	new_image.name = "fluid_overlay" // Tag for easy identification

	// Dynamic Layering
	if (current_fluid_amount > FLUID_OVER_MOB_HEAD) // Use FLUID_OVER_MOB_HEAD as a threshold for deep fluid layer
		new_image.layer = DEEP_FLUID_LAYER
	else
		new_image.layer = SHALLOW_FLUID_LAYER

	// Dynamic Alpha
	if (current_fluid_amount > FLUID_DEEPEST) // Max alpha for deepest fluid
		new_image.alpha = FLUID_MAX_ALPHA
	else if (current_fluid_amount > FLUID_DELETING)
		// Scale alpha between MIN and MAX based on fluid amount relative to FLUID_DEEPEST
		new_image.alpha = min(FLUID_MAX_ALPHA, max(FLUID_MIN_ALPHA, round(FLUID_MIN_ALPHA + (FLUID_MAX_ALPHA - FLUID_MIN_ALPHA) * (current_fluid_amount / FLUID_DEEPEST))))
	else
		new_image.alpha = 0 // No fluid, no alpha

	// Apply fluid-specific color
	if (fluid_type.color)
		new_image.color = fluid_type.color

	fluid_image_cache[cache_key] = new_image
	return new_image
