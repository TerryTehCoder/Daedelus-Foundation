/obj/effect/spinning_light/self_destruct_variant
	spin_rate = 1.5 SECONDS // Faster rotation for self-destruct
	_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm
	name = "self-destruct rotating alarm"
	desc = "A specialized rotating alarm light for self-destruct sequences."
	icon = 'icons/obj/rotating_alarm.dmi' // Re-use existing icon
	icon_state = "alarm"
	alarm_light_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm/Initialize()
	. = ..()
	// Override the spin_effect initialization to use our variant
	if (isnull(spinning_lights_cache["[alarm_light_color]"]))
		spinning_lights_cache["[alarm_light_color]"] = new /obj/effect/spinning_light/self_destruct_variant()
	spin_effect = spinning_lights_cache["[alarm_light_color]"]

	// The parent Initialize calls set_color, which will use the new spin_effect
	// and set its color.

/datum/self_destruct_profile/self_destruct_light_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/list/active_spinning_lights // Tracks self_destruct_variant spinning lights created by this profile
	var/list/affected_lights // To track lights whose properties were changed by this profile

/datum/self_destruct_profile/self_destruct_light_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller
	active_spinning_lights = list()
	affected_lights = list()

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_CANCEL, SD_SIGNAL_FINAL, SD_SIGNAL_PAUSE), PROC_REF(on_stop_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	message_admins(span_adminnotice("Self-destruct Light Profile: SD_SIGNAL_START - Activating red emergency lights and spinning effect."))
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
				affected_lights[R] = list(R.on, R.alarm_light_color, R.spin_effect) // Store relevant states for rotating_alarm, including the original spin_effect
			R.set_color("#FF0000") // Set to pure red
			R.set_on() // Ensure alarm is on
			// Create a new self_destruct_variant for this specific alarm, not from cache
			var/obj/effect/spinning_light/self_destruct_variant/new_spin_effect = new /obj/effect/spinning_light/self_destruct_variant(R.loc)
			if(R.spin_effect) // If there was an existing spin_effect, remove it from vis_contents before replacing
				R.remove_viscontents(R.spin_effect)
			R.spin_effect = new_spin_effect // Assign the new self-destruct variant
			R.add_viscontents(R.spin_effect) // Add the new spin effect to visible contents
			active_spinning_lights += new_spin_effect // Track this specific instance for cleanup
	addtimer(CALLBACK(src, PROC_REF(spawn_spinning_lights)), 40) // Allows time for Every Single wall-light on station to update to red lighting first.

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_stop_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	message_admins(span_adminnotice("Self-destruct Light Profile: SD_SIGNAL_CANCEL/FINAL/PAUSE - Deactivating spinning effect and reverting emergency lights."))
	// Deactivate spinning effect and revert emergency lights
	for(var/obj/effect/spinning_light/self_destruct_variant/S in active_spinning_lights)
		qdel(S) // Delete the self-destruct variant spinning light
	active_spinning_lights.Cut()

	for(var/obj/machinery/light/L in affected_lights)
		if(L) // Check if light still exists
			if(istype(L, /obj/machinery/light))
				var/list/original_states = affected_lights[L]
				L.bulb_colour = original_states[1] // Restore original color
				L.on = original_states[2] // Restore original on state
				L.emergency_mode = original_states[3] // Restore original emergency_mode state
				L.update_appearance() // Update icon state
				L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
			else if(istype(L, /obj/machinery/rotating_alarm))
				var/obj/machinery/rotating_alarm/R_alarm = L
				var/list/original_states = affected_lights[L]
				// Restore original spin_effect object
				// The self_destruct_variant spin_effect will be qdel'd by the active_spinning_lights loop.
				R_alarm.spin_effect = original_states[3] // Restore the original spin_effect object

				R_alarm.set_color(original_states[2]) // Restore original color
				if(original_states[1]) // Restore original on state
					R_alarm.set_on()
				else
					R_alarm.set_off()
	affected_lights.Cut()

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct: Resuming light effects.")
	message_admins(span_adminnotice("Self-destruct Light Profile: SD_SIGNAL_RESUME - Resuming light effects."))
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
				R_alarm.set_on() // Ensure alarm is on
				// Re-create the self_destruct_variant for this specific alarm
				var/obj/effect/spinning_light/self_destruct_variant/new_spin_effect = new /obj/effect/spinning_light/self_destruct_variant(R_alarm.loc)
				if(R_alarm.spin_effect) // If there was an existing spin_effect, remove it from vis_contents before replacing
					R_alarm.remove_viscontents(R_alarm.spin_effect)
					qdel(R_alarm.spin_effect) // Delete the old spin effect
				R_alarm.spin_effect = new_spin_effect // Assign the new self-destruct variant
				R_alarm.add_viscontents(R_alarm.spin_effect) // Re-add the new spin effect to visible contents
				active_spinning_lights += new_spin_effect // Track this specific instance for cleanup
	addtimer(CALLBACK(src, PROC_REF(spawn_spinning_lights)), 40) // Re-activate spinning lights for small light fixtures after a 4-second delay

/datum/self_destruct_profile/self_destruct_light_profile/proc/spawn_spinning_lights()
	// First, clean up any existing spinning lights managed by this profile
	for(var/obj/effect/spinning_light/self_destruct_variant/S in active_spinning_lights)
		qdel(S)
	active_spinning_lights.Cut()

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
			active_spinning_lights += S
