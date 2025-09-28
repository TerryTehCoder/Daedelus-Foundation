/datum/component/fluid
	name = "Fluid Component"
	var/fluid_amount = 0 // Current depth/volume of fluid
	var/fluid_type = /datum/fluid/water // Type of fluid (e.g., water, lava, chemicals)
	var/temperature = T20C // Default temperature
	var/current_visual_state = "dry" // Current visual state (e.g., "dry", "shallow", "deep")
	var/is_dirty = FALSE // Flag to indicate if this fluid component's turf needs re-evaluation for lateral diffusion

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
	RegisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, .proc/onFluidAmountChanged)
	updateVisuals()

/datum/component/fluid/Destroy()
	UnregisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED)
	. = ..()

/datum/component/fluid/proc/addFluid(amount, new_temperature)
	fluid_amount = min(FLUID_MAX_DEPTH, fluid_amount + amount)
	// Simple temperature mixing for now
	if(fluid_amount > 0)
		temperature = (temperature * (fluid_amount - amount) + new_temperature * amount) / fluid_amount
	else
		temperature = new_temperature
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
	mark_dirty()
	updateVisuals()

/datum/component/fluid/proc/removeFluid(amount)
	fluid_amount = max(FLUID_DELETING, fluid_amount - amount)
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, fluid_amount)
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
		current_visual_state = new_visual_state
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLUID_VISUAL_STATE_CHANGED, current_visual_state, fluid_amount)

/datum/component/fluid/proc/onFluidAmountChanged(datum/component/fluid/source_component, new_amount)
	// This signal handler is primarily for internal component use to trigger visuals.
	// Other systems will listen to COMSIG_FLUID_AMOUNT_CHANGED directly on the parent.
	updateVisuals()

/datum/component/fluid/proc/mark_dirty()
	if (!is_dirty)
		is_dirty = TRUE
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLUID_COMPONENT_DIRTY, parent)

// Define fluid types (simple datums for now)
/datum/fluid
	var/density = 1000 // Default density (e.g., water)
	var/viscosity = 1  // Default viscosity (e.g., water)

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
	color = "#0000FF"

/datum/fluid/oil
	density = 800
	viscosity = 5
	color = "#333333"

// Signals for fluid components
#define COMSIG_PARENT_FLUID_AMOUNT_CHANGED "fluid_amount_changed" // Emitted by parent when fluid amount changes
#define COMSIG_FLUID_VISUAL_STATE_CHANGED "fluid_visual_state_changed" // Emitted by FluidComponent when visual state changes
#define COMSIG_FLUID_COMPONENT_DIRTY "fluid_component_dirty" // Emitted by FluidComponent when its fluid amount changes and needs re-evaluation
