/datum/component/floodable
	name = "Floodable Component"
	var/max_fluid_capacity = FLUID_MAX_DEPTH // Max fluid this turf can hold
	var/current_fluid_level = 0 // Current fluid level (synced with FluidComponent)
	var/is_breached = FALSE // Whether the turf/area is currently breached

/datum/component/floodable/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, .proc/onFluidAmountChanged)
	RegisterSignal(src, COMSIG_BREACH_STATE_CHANGED, .proc/onBreachStateChanged)

/datum/component/floodable/Destroy()
	UnregisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED)
	UnregisterSignal(src, COMSIG_BREACH_STATE_CHANGED)
	. = ..()

/datum/component/floodable/proc/onFluidAmountChanged(datum/component/fluid/fluid_comp, new_amount)
	current_fluid_level = new_amount
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_FLOODING_PROGRESS, current_fluid_level, max_fluid_capacity)

	if (current_fluid_level >= max_fluid_capacity)
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLOODING_COMPLETED)
	else if (current_fluid_level > FLUID_EVAPORATION_POINT && current_fluid_level - new_amount < 0) // If fluid was added and it's above evaporation point
		SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
		SEND_SIGNAL(src, COMSIG_FLOODING_STARTED, fluid_comp.fluid_type)

/datum/component/floodable/proc/onBreachStateChanged(datum/component/breach/breach_comp, new_state)
	is_breached = new_state
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_FLOODING_BREACH_STATE_CHANGED, is_breached)

// Signals for floodable components
#define COMSIG_FLOODING_STARTED "flooding_started" // Emitted when a turf starts flooding
#define COMSIG_FLOODING_PROGRESS "flooding_progress" // Emitted as fluid level changes
#define COMSIG_FLOODING_COMPLETED "flooding_completed" // Emitted when the turf is fully flooded
#define COMSIG_FLOODING_BREACH_STATE_CHANGED "flooding_breach_state_changed" // Emitted when breach state changes
