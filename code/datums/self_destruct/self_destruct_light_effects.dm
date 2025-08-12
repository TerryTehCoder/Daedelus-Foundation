/obj/effect/spinning_light/self_destruct_variant
	spin_rate = 1.5 SECONDS // Faster rotation for self-destruct
	_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm
	name = "self-destruct rotating alarm"
	desc = "A specialized rotating alarm light for self-destruct sequences."
	icon = 'icons/obj/rotating_alarm.dmi' // Re-use existing icon
	icon_state = "alarm"
	alarm_light_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm
	var/spin_rate = 1.5 SECONDS // Faster rotation for self-destruct

/obj/machinery/rotating_alarm/self_destruct_alarm/Initialize()
	. = ..()
	// The base rotating_alarm's Initialize will set up spin_effect.
	// We just need to ensure its spin_rate is set.
	if(spin_effect)
		spin_effect.spin_rate = spin_rate

/datum/self_destruct_profile/self_destruct_light_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/list/active_small_light_spinning_lights // Tracks self_destruct_variant spinning lights created for small lights
	var/list/active_alarm_spinning_lights // Tracks self_destruct_variant spinning lights created for rotating alarms
	var/list/affected_lights // To track lights whose properties were changed by this profile

/datum/self_destruct_profile/self_destruct_light_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller
	active_small_light_spinning_lights = list()
	active_alarm_spinning_lights = list()
	affected_lights = list()

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_CANCEL, SD_SIGNAL_PAUSE), PROC_REF(on_cancel_or_pause_signal))
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	// Activate red emergency lights and spinning effect
	for(var/obj/machinery/light/L in INSTANCES_OF(/obj/machinery/light)) // Iterate through all lights.
		if(istype(L) && is_station_level(L.z))
			if(!affected_lights[L]) // Store original states
				affected_lights[L] = list(L.bulb_colour, L.on, L.emergency_mode)
			L.bulb_colour = "#FF0000" // Set to pure red
			L.on = TRUE // Ensure light is on
			L.emergency_mode = TRUE // Set to emergency mode
			L.update_appearance() // Update icon state
			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
	for(var/obj/machinery/rotating_alarm/R in INSTANCES_OF(/obj/machinery/rotating_alarm)) // Iterate through rotating alarms.
		if(istype(R) && is_station_level(R.z))
			if(!affected_lights[R]) // Store original states
				affected_lights[R] = list(R.on, R.alarm_light_color, R.spin_effect?.spin_rate) // Store relevant states for rotating_alarm, including the original spin_effect's spin_rate
			R.set_color("#FF0000") // Set to pure red
			R.set_on() // Ensure alarm is on, which will activate its internal spinning light
			if(R.spin_effect)
				R.spin_effect.spin_rate = 1.5 SECONDS // Adjust the spin rate of the alarm's inherent spinning light
	addtimer(CALLBACK(src, PROC_REF(spawn_spinning_lights)), 40) // Allows time for Every Single wall-light on station to update to red lighting first.

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_final_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_cancel_or_pause_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	// Deactivate spinning effect and revert emergency lights for small lights
	for(var/obj/effect/spinning_light/self_destruct_variant/S in active_small_light_spinning_lights)
		qdel(S) // Delete the self-destruct variant spinning light
	active_small_light_spinning_lights.Cut()

	for(var/obj/machinery/light/L in affected_lights)
		if(L) // Check if light still exists
			if(istype(L, /obj/machinery/light))
				var/list/original_states = affected_lights[L]
				L.bulb_colour = original_states[1] // Restore original color
				L.on = original_states[2] // Restore original on state
				L.emergency_mode = original_states[3] // Restore original emergency_mode state
				L.update_appearance() // Update icon state
				L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
	for(var/obj/machinery/rotating_alarm/R_alarm in affected_lights)
		var/list/original_states = affected_lights[R_alarm]
		R_alarm.set_color(original_states[2]) // Restore original color
		R_alarm.set_off() // Explicitly turn off to clear any self-destruct spinning effect
		if(R_alarm.spin_effect) // Always reset spin_rate to default for the internal spin_effect
			R_alarm.spin_effect.spin_rate = 1 SECONDS // Default spin rate for /obj/effect/spinning_light
	affected_lights.Cut()


/datum/self_destruct_profile/self_destruct_light_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	for(var/obj/machinery/light/L in affected_lights)
		if(istype(L) && !QDELETED(L))
			if(istype(L, /obj/machinery/light))
				L.bulb_colour = "#FF0000" // Re-apply red
				L.on = TRUE // Ensure light is on
				L.emergency_mode = TRUE // Re-apply emergency mode
				L.update_appearance() // Update icon state
				L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
			else if(istype(L, /obj/machinery/rotating_alarm))
				var/obj/machinery/rotating_alarm/R_alarm = L
				R_alarm.set_color("#FF0000") // Re-apply red
				R_alarm.set_on() // Ensure alarm is on, which will activate its internal spinning light
				if(R_alarm.spin_effect)
					R_alarm.spin_effect.spin_rate = 1.5 SECONDS // Adjust the spin rate of the alarm's inherent spinning light
	addtimer(CALLBACK(src, PROC_REF(spawn_spinning_lights)), 40) // Re-activate spinning lights for small light fixtures after a 4-second delay

/datum/self_destruct_profile/self_destruct_light_profile/proc/spawn_spinning_lights()
	// Red Emergency Spinny Light Logic
	for(var/obj/machinery/light/small/L in INSTANCES_OF(/obj/machinery/light)) // Iterate through lights for small lights.
		if(istype(L) && is_station_level(L.z) && L.status != LIGHT_BROKEN) // Exclude broken lights
			// If there's a rotating_alarm at this location, it handles its own spinning light, so skip this light/small.
			if(locate(/obj/machinery/rotating_alarm) in L.loc)
				continue

			var/obj/effect/spinning_light/self_destruct_variant/S = new /obj/effect/spinning_light/self_destruct_variant(L.loc)
			if(istype(L, /obj/machinery/light/small/directional) || istype(L, /obj/machinery/light/small/maintenance/directional)) // Apply pixel shift for directional lights
				switch(L.dir)
					if(NORTH)
						S.pixel_y = 31
					if(SOUTH)
						S.pixel_y = -11
					if(EAST)
						S.pixel_x = 21
					if(WEST)
						S.pixel_x = -21
			active_small_light_spinning_lights += S
