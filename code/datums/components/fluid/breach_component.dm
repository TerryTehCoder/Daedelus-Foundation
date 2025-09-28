/datum/component/breach
	name = "Breach Component"
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
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_BREACH_CREATED, get_turf(parent), fluid_flow_rate)
	SEND_SIGNAL(src, COMSIG_BREACH_STATE_CHANGED, TRUE)

/datum/component/breach/proc/repairBreach()
	if (!is_breached)
		return

	is_breached = FALSE
	SIGNAL_HANDLER_RELEASE_IF_QDELETED(src)
	SEND_SIGNAL(src, COMSIG_BREACH_REPAIRED, get_turf(parent))
	SEND_SIGNAL(src, COMSIG_BREACH_STATE_CHANGED, FALSE)

// Signals for breach components
#define COMSIG_BREACH_CREATED "breach_created" // Emitted when a breach occurs
#define COMSIG_BREACH_REPAIRED "breach_repaired" // Emitted when a breach is fixed
#define COMSIG_BREACH_STATE_CHANGED "breach_state_changed" // Emitted when breach state changes (true/false)
