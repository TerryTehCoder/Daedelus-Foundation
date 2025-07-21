/datum/status_effect/vision_reduction
	id = "vision_reduction"
	status_type = STATUS_EFFECT_MULTIPLE
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

	var/vision_reduction_amount = 0

/datum/status_effect/vision_reduction/on_creation(mob/living/new_owner, amount)
	. = ..()
	if(!istype(new_owner))
		return COMPONENT_INCOMPATIBLE
	vision_reduction_amount = amount
	on_apply()

/datum/status_effect/vision_reduction/on_apply()
	if(!owner)
		return
	owner.see_in_dark = max(0, owner.see_in_dark - vision_reduction_amount)
	return TRUE

/datum/status_effect/vision_reduction/on_remove()
	if(!owner)
		return
	owner.see_in_dark = min(NIGHTVISION_FOV_RANGE, owner.see_in_dark + vision_reduction_amount) // Assuming NIGHTVISION_FOV_RANGE is the max
