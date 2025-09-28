/obj/effect/particle_effect/fluid
	name = "fluid"
	icon = 'icons/effects/liquids.dmi'
	icon_state = "water_shallow" // Default visual state
	anchored = TRUE
	unacidable = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER
	var/datum/fluid/fluid_type = /datum/fluid/water
	var/fluid_amount = 0
	var/temperature = T20C

/obj/effect/particle_effect/fluid/Initialize()
	. = ..()
	AddComponent(/datum/component/fluid, .args = list(fluid_type = fluid_type, fluid_amount = fluid_amount, temperature = temperature))
	RegisterSignal(src, COMSIG_FLUID_VISUAL_STATE_CHANGED, .proc/onVisualStateChanged)
	RegisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, .proc/onFluidAmountChanged)

/obj/effect/particle_effect/fluid/Destroy()
	UnregisterSignal(src, COMSIG_FLUID_VISUAL_STATE_CHANGED)
	UnregisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED)
	. = ..()

/obj/effect/particle_effect/fluid/proc/onVisualStateChanged(datum/component/fluid/fluid_comp, new_visual_state, current_fluid_amount)
	icon_state = fluid_comp.icon_state_map[new_visual_state]
	// Update overlay if needed, handled by FluidVisualsSystem

/obj/effect/particle_effect/fluid/proc/onFluidAmountChanged(datum/component/fluid/fluid_comp, new_amount)
	fluid_amount = new_amount
	temperature = fluid_comp.temperature
	if (fluid_amount <= FLUID_DELETING)
		qdel(src)

/obj/effect/particle_effect/fluid/proc/get_component_fluid_simulation_subsystem()
	// This proc will find the correct component-based fluid simulation subsystem for this fluid type.
	// In a more complex system, this might be a global map or a more sophisticated lookup.
	// For now, we'll assume a direct lookup for water.
	if (fluid_type == /datum/fluid/water)
		return SSwater_simulation
	// Add other fluid types here as needed
	return null

/obj/effect/particle_effect/fluid/proc/spread(delta_time)
	// For component-based fluids, this simply tells the relevant subsystem to activate the turf.
	var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_component_fluid_simulation_subsystem()
	if (fluid_sim_subsystem)
		fluid_sim_subsystem.queue_spread(src)
	else
		// Fallback for non-component-based fluids (e.g., smoke/foam)
		// This should ideally be handled by the original fluids subsystem.
		. = ..()

/obj/effect/particle_effect/fluid/proc/process(delta_time)
	// For component-based fluids, this simply tells the relevant subsystem to activate the turf.
	var/datum/controller/subsystem/component_fluid_simulation/fluid_sim_subsystem = get_component_fluid_simulation_subsystem()
	if (fluid_sim_subsystem)
		fluid_sim_subsystem.start_processing(src)
	else //Fallback same as above.
		. = ..()
