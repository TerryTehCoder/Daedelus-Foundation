/datum/component/floodable
	var/max_fluid_capacity = FLUID_MAX_DEPTH // Max fluid this turf can hold
	var/current_fluid_level = 0 // Current fluid level (synced with FluidComponent)
	var/is_breached = FALSE // Whether the turf/area is currently breached

/datum/component/floodable/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED, PROC_REF(onFluidAmountChanged))
	RegisterSignal(src, COMSIG_BREACH_STATE_CHANGED, PROC_REF(onBreachStateChanged))

/datum/component/floodable/Destroy()
	UnregisterSignal(src, COMSIG_PARENT_FLUID_AMOUNT_CHANGED)
	UnregisterSignal(src, COMSIG_BREACH_STATE_CHANGED)
	. = ..()

/datum/component/floodable/proc/onFluidAmountChanged(datum/component/fluid/fluid_comp, new_amount)
	current_fluid_level = new_amount
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_FLOODING_PROGRESS, current_fluid_level, max_fluid_capacity)

	if (current_fluid_level >= max_fluid_capacity)
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLOODING_COMPLETED)
	else if (current_fluid_level > FLUID_EVAPORATION_POINT && current_fluid_level - new_amount < 0) // If fluid was added and it's above evaporation point
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLOODING_STARTED)

/datum/component/floodable/proc/onBreachStateChanged(datum/component/breach/breach_comp, new_state)
	is_breached = new_state
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_FLOODING_BREACH_STATE_CHANGED, is_breached)
