/datum/component/breach
	var/breach_size = 1 // How large the breach is (affects flow rate)
	var/fluid_flow_rate = 50 // Amount of fluid that flows through per tick when breached
	var/is_breached = FALSE // Whether the structure is currently breached

/datum/component/breach/Initialize()
	. = ..()
	// No specific signals to register here, as this component primarily emits.

/datum/component/breach/proc/createBreach()
	if (is_breached)
		return

	is_breached = TRUE
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_BREACH_CREATED, get_turf(parent), fluid_flow_rate)
	SEND_SIGNAL(src, COMSIG_BREACH_STATE_CHANGED, TRUE)

/datum/component/breach/proc/repairBreach()
	if (!is_breached)
		return

	is_breached = FALSE
	if (QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_BREACH_REPAIRED, get_turf(parent))
	SEND_SIGNAL(src, COMSIG_BREACH_STATE_CHANGED, FALSE)
