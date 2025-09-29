/datum/component/movable_fluid_interaction
	var/can_swim = TRUE // Can this mob swim?
	var/swim_speed_modifier = 0.7 // Multiplier for speed when swimming (e.g., 0.7 for 70% speed)
	var/breath_timer = 0 // Time remaining before drowning damage
	var/max_breath_time = 10 SECONDS // How long mob can hold breath
	var/is_swimming = FALSE
	var/is_drowning = FALSE
	var/is_waist_deep = FALSE // Track if mob is waist-deep in fluid
	var/base_pixel_y = 0 // Store original pixel_y for resetting
	var/is_submerged_visually = FALSE // Track if visual submersion is active
	var/float_offset_timer = 0 // Timer for floating animation
	var/drowning_timer = 0 // Time spent drowning
	var/cold_exposure_timer = 0 // Time spent in cold fluid
	var/last_fluid_z = 0 // Store the Z-level where the mob entered fluid
	var/image/submersion_overlay // Overlay for visual submersion effects

/datum/component/movable_fluid_interaction/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_ENTERED_TURF, .proc/onEnteredTurf)
	RegisterSignal(src, COMSIG_PARENT_EXITED_TURF, .proc/onExitedTurf)
	RegisterSignal(src, COMSIG_PARENT_PROCESS, .proc/onProcess)
	if (istype(parent, /mob))
		var/mob/M = parent
		base_pixel_y = M.pixel_y
	updateMobVisuals()

/datum/component/movable_fluid_interaction/Destroy()
	UnregisterSignal(src, COMSIG_PARENT_ENTERED_TURF)
	UnregisterSignal(src, COMSIG_PARENT_EXITED_TURF)
	UnregisterSignal(src, COMSIG_PARENT_PROCESS)
	. = ..()

/datum/component/movable_fluid_interaction/proc/onEnteredTurf(atom/movable/parent_atom, turf/old_loc, turf/new_loc)
	var/datum/component/fluid/fluid_comp = new_loc.GetComponent(/datum/component/fluid)
	if (fluid_comp && fluid_comp.fluid_amount > FLUID_EVAPORATION_POINT)
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_ENTERED_FLUID, fluid_comp.fluid_type, fluid_comp.fluid_amount)
		checkFluidState(fluid_comp.fluid_amount, fluid_comp.fluid_type)
		updateMobVisuals(fluid_comp.fluid_amount)
	else
		stopSwimming()
		stopDrowning()
		updateMobVisuals() // Reset visuals when exiting fluid

/datum/component/movable_fluid_interaction/proc/onExitedTurf(atom/movable/parent_atom, turf/old_loc, turf/new_loc)
	var/datum/component/fluid/fluid_comp = old_loc.GetComponent(/datum/component/fluid)
	if (fluid_comp && fluid_comp.fluid_amount > FLUID_EVAPORATION_POINT)
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_EXITED_FLUID, fluid_comp.fluid_type)
	stopSwimming()
	stopDrowning()
	updateMobVisuals() // Reset visuals when exiting fluid

/datum/component/movable_fluid_interaction/proc/onProcess(datum/component/movable_fluid_interaction/source_component, delta_time)
	if (is_drowning)
		breath_timer -= delta_time
		drowning_timer += delta_time // Increment drowning timer
		if (breath_timer <= 0)
			takeDrowningDamage()
			breath_timer = 0 // Reset to 0 to prevent negative values, damage is continuous

		// Check for Z-level teleportation if unconscious and drowning for too long
		if (istype(parent, /mob/living))
			var/mob/living/M = parent
			if (M.stat == UNCONSCIOUS && drowning_timer >= MAX_DROWNING_TIME)
				teleportToUnderwaterZ()
				return // Stop processing for this mob as it's moved to a new Z-level

	var/turf/T = get_turf(source_component.parent)
	if (!istype(T))
		return

	var/datum/component/fluid/fluid_comp = T.GetComponent(/datum/component/fluid)
	if (fluid_comp)
		checkFluidState(fluid_comp.fluid_amount, fluid_comp.fluid_type)
		handleTemperatureEffects(fluid_comp.fluid_amount, fluid_comp.temperature, delta_time)
		updateMobVisuals(fluid_comp.fluid_amount, delta_time)
	else
		stopSwimming()
		stopDrowning()
		clearTemperatureEffects()
		updateMobVisuals() // Reset visuals when not in fluid

/datum/component/movable_fluid_interaction/proc/checkFluidState(fluid_amount, fluid_type)
	var/old_is_waist_deep = is_waist_deep

	if (istype(parent, /mob/living))
		var/mob/living/M = parent
		if (M.stat == UNCONSCIOUS) // Prevent swimming if unconscious
			stopSwimming()
			stopDrowning()
			is_waist_deep = FALSE
			return

	if (fluid_amount > FLUID_OVER_MOB_HEAD)
		if (can_swim)
			startSwimming(SWIM_SPEED_MODIFIER_DEEP)
			startDrowning() // Mobs with fluid over their head are always drowning
		else
			startDrowning()
			stopSwimming()
		is_waist_deep = TRUE
	else if (fluid_amount > FLUID_WAIST_DEEP)
		stopDrowning() // Not deep enough to drown automatically
		startSwimming(SWIM_SPEED_MODIFIER_DEEP)
		is_waist_deep = TRUE
	else if (fluid_amount > FLUID_SHALLOW)
		stopDrowning()
		startSwimming(SWIM_SPEED_MODIFIER_SHALLOW)
		is_waist_deep = FALSE
	else if (fluid_amount > FLUID_EVAPORATION_POINT)
		stopDrowning()
		startSwimming(SWIM_SPEED_MODIFIER_SHALLOW) // Shallow water might still count as swimming for some mobs
		is_waist_deep = FALSE
	else
		stopSwimming()
		stopDrowning()
		is_waist_deep = FALSE

	if (old_is_waist_deep != is_waist_deep)
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_RESTRICTED_STATE_CHANGED, is_waist_deep, fluid_type)
	updateMobVisuals(fluid_amount)

/datum/component/movable_fluid_interaction/proc/startSwimming(new_speed_modifier)
	if (!istype(parent, /mob/living))
		return
	var/mob/living/M = parent
	if (M.stat == UNCONSCIOUS) // Unconscious mobs cannot swim
		return

	if (!is_swimming)
		is_swimming = TRUE
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_SWIMMING_STATE_CHANGED, TRUE)
		// Apply speed modifier to parent mob
		M.add_movespeed_modifier(new_speed_modifier)
		if (is_drowning) // Apply additional modifier if drowning
			M.add_movespeed_modifier(SWIM_SPEED_MODIFIER_DROWNING)

/datum/component/movable_fluid_interaction/proc/stopSwimming()
	if (is_swimming)
		is_swimming = FALSE
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_SWIMMING_STATE_CHANGED, FALSE)
		// Remove speed modifier from parent mob
		if (istype(parent, /mob/living))
			var/mob/living/M = parent
			// We need to know which modifier to remove. This implies storing the active modifier.
			// For now, we'll remove the default one, but this needs refinement if multiple modifiers are active.
			M.remove_movespeed_modifier(SWIM_SPEED_MODIFIER_DEEP) // Assuming deep is the most impactful
			M.remove_movespeed_modifier(SWIM_SPEED_MODIFIER_SHALLOW) // Remove shallow as well, just in case

/datum/component/movable_fluid_interaction/proc/startDrowning()
	if (!is_drowning)
		is_drowning = TRUE
		breath_timer = max_breath_time
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_DROWNING_STATE_CHANGED, TRUE)

/datum/component/movable_fluid_interaction/proc/stopDrowning()
	if (is_drowning)
		is_drowning = FALSE
		breath_timer = max_breath_time // Reset breath timer
		drowning_timer = 0 // Reset drowning timer
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_DROWNING_STATE_CHANGED, FALSE)
		// Remove drowning speed modifier if it was applied
		if (istype(parent, /mob/living))
			var/mob/living/M = parent
			M.remove_movespeed_modifier(SWIM_SPEED_MODIFIER_DROWNING)

/datum/component/movable_fluid_interaction/proc/handleTemperatureEffects(fluid_amount, fluid_temperature, delta_time)
	if (!istype(parent, /mob/living))
		return

	var/mob/living/M = parent

	var/has_cold_resistance = HAS_TRAIT(M, TRAIT_RESISTCOLD)
	var/has_heat_resistance = HAS_TRAIT(M, TRAIT_RESISTHEAT)

	// Check for insulated clothing / Other heat/cold resistance; should probably be expanded once the weather framework is in based on clothing flags.(9.28.25)
	if (istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		for (var/obj/item/I in C.get_all_gear())
			if (istype(I, /obj/item/clothing))
				if (istype(I, /obj/item/clothing/gloves/color/yellow))
					has_cold_resistance = TRUE
					has_heat_resistance = TRUE
					break
	else // For non-carbon mobs, check general equipped items
		for (var/obj/item/I in M.get_equipped_items(TRUE))
			if (istype(I, /obj/item/clothing))
				if (istype(I, /obj/item/clothing/gloves/color/yellow))
					has_cold_resistance = TRUE
					has_heat_resistance = TRUE
					break

	if (fluid_amount > FLUID_SHALLOW) // Only apply temperature effects if submerged enough
		if (fluid_temperature < FLUID_COLD_THRESHOLD)
			if (has_cold_resistance)
				return
			// Cold water: slow stamina drain
			M.apply_damage(1, STAMINA)
			M.visible_message(span_notice("[M] shivers from the cold water."))
			to_chat(M, span_danger("You feel a chill run down your spine from the temperature of the water!"))

			// Cold exposure leading to unconsciousness
			cold_exposure_timer += delta_time
			if (cold_exposure_timer >= MAX_COLD_EXPOSURE_TIME)
				M.SetUnconscious(TRUE)
				to_chat(M, span_danger("The extreme cold has rendered you unconscious!"))
		else if (fluid_temperature > FLUID_HOT_THRESHOLD)
			if (has_heat_resistance)
				return
			// Hot water: burn damage
			M.apply_damage(2, BURN) // Example: 2 burn damage per tick
			to_chat(M, span_danger("The scalding water burns your skin!"))
	else
		clearTemperatureEffects()
		cold_exposure_timer = 0 // Reset timer when not in cold fluid

/datum/component/movable_fluid_interaction/proc/clearTemperatureEffects()
	// If any continuous temperature effects were applied (e.g., debuffs), remove them here.
	// For now, since damage is applied per tick, no explicit "clear" is needed beyond stopping the `handleTemperatureEffects` calls.
	return

/datum/component/movable_fluid_interaction/proc/takeDrowningDamage()
	if (istype(parent, /mob/living))
		var/mob/living/M = parent
		M.adjustOxyLoss(5) // Apply oxygen loss
		M.apply_damage(5, STAMINA) // Apply stamina damage for panic mechanics
		if (M.stamina.current <= 0) // If stamina runs out, become unconscious
			M.SetUnconscious(TRUE)
			to_chat(M, span_danger("You are too exhausted to stay afloat and lose consciousness!"))
		// Play drowning sound, show visual effects, etc.
		if (QDELETED(src))
			return
		SEND_SIGNAL(src, COMSIG_FLUID_INTERACTION_DROWNING_DAMAGE_TAKEN)

/datum/component/movable_fluid_interaction/proc/teleportToUnderwaterZ()
	if (!istype(parent, /mob/living))
		return

	var/mob/living/M = parent
	last_fluid_z = M.z // Store current Z-level
	var/target_z_level = M.z - 1 // Simulate sinking one Z-level down
	var/turf/target_turf = findUnderwaterTurf(M.x, M.y, target_z_level)
	if (target_turf)
		M.forceMove(target_turf)
		M.visible_message(span_warning("[M] sinks beneath the waves..."))
		to_chat(M, span_warning("You sink deeper into the ocean, entering a dark, cold abyss."))
		// Ensure visuals are updated for the new Z-level
		updateMobVisuals(FLUID_MAX_DEPTH) // Assume max depth underwater
	else
		to_chat(M, span_danger("Some unseen force holds you above the water's surface!"))

/datum/component/movable_fluid_interaction/proc/findUnderwaterTurf(x, y, z_level)
	// First, try to locate the exact turf
	var/turf/T = locate(x, y, z_level)
	if (istype(T))
		return T

	// If not found, iterate randomly in a 3x3 area around the original coordinates
	for (var/i = -1; i <= 1; i++)
		for (var/j = -1; j <= 1; j++)
			var/new_x = x + i
			var/new_y = y + j
			T = locate(new_x, new_y, z_level)
			if (istype(T))
				return T
	return null // No suitable turf found in the 3x3 area.This seems unlikely to happen.

/datum/component/movable_fluid_interaction/proc/updateMobVisuals(fluid_amount = 0, delta_time = 0)
	if (!istype(parent, /mob))
		return

	var/mob/M = parent
	var/new_pixel_y = base_pixel_y
	var/should_be_submerged = FALSE

	if (fluid_amount > FLUID_EVAPORATION_POINT)
		should_be_submerged = TRUE
		if (is_drowning)
			new_pixel_y += FLUID_MOB_PIXEL_OFFSET_DROWNING
		else if (fluid_amount >= FLUID_OVER_MOB_HEAD)
			new_pixel_y += FLUID_MOB_PIXEL_OFFSET_DEEP
		else if (fluid_amount >= FLUID_WAIST_DEEP)
			new_pixel_y += FLUID_MOB_PIXEL_OFFSET_WAIST_DEEP
		else if (fluid_amount >= FLUID_SHALLOW)
			new_pixel_y += FLUID_MOB_PIXEL_OFFSET_SHALLOW

		// Apply floating animation if swimming
		if (is_swimming)
			float_offset_timer += delta_time * FLUID_MOB_FLOAT_SPEED
			var/float_y = sin(float_offset_timer) * FLUID_MOB_FLOAT_AMPLITUDE
			new_pixel_y += round(float_y)

	if (should_be_submerged != is_submerged_visually)
		is_submerged_visually = should_be_submerged
		if (is_submerged_visually)
			if (!submersion_overlay)
				submersion_overlay = image(M.icon, M.icon_state)
				M.overlays += submersion_overlay
			submersion_overlay.pixel_y = new_pixel_y
			M.pixel_y = base_pixel_y // Reset base mob pixel_y
		else
			if (submersion_overlay)
				M.overlays -= submersion_overlay
				qdel(submersion_overlay)
			M.pixel_y = base_pixel_y
	else if (should_be_submerged) // Update continuously if already submerged
		if (submersion_overlay)
			submersion_overlay.pixel_y = new_pixel_y
		else // Should not happen if logic is correct, but as a fallback
			submersion_overlay = image(M.icon, M.icon_state)
			M.overlays += submersion_overlay
			submersion_overlay.pixel_y = new_pixel_y
		M.pixel_y = base_pixel_y // Ensure base mob pixel_y is reset
