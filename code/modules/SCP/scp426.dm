/obj/item/scp426
	name = "toaster"
	desc = "I am a toaster. I can only be referred to in the first person."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod-off" //Stand-In, I don't have a toaster icon.
	w_class = WEIGHT_CLASS_NORMAL // Standard item weight class

	///Reference to the SCP datum
	var/datum/scp/scp_datum

/obj/item/scp426/New()
	. = ..()
	scp_datum = new /datum/scp/toaster( \
		src, \
		"toaster", \
		SCP_EUCLID, \
		"426" \
	)

/obj/item/scp426/Destroy()
	if(scp_datum)
		qdel(scp_datum)
		scp_datum = null
	. = ..()

/datum/scp/toaster
	name = "toaster"
	designation = "426"
	classification = SCP_EUCLID

	///Radius in tiles for cognitive effect
	var/exposure_radius = 3
	///How often nearby players are exposed (in deciseconds)
	var/exposure_rate = 10 // Every 1 second
	///How quickly the mental effect builds
	var/cognitohazard_power = 1

	///List of mobs currently affected by SCP-426
	var/list/affected_mobs = list()

/datum/scp/toaster/process()
	. = ..()
	if(!parent || !parent.loc) // If the toaster is not in a location, don't process
		return

	var/list/mobs_in_range = list()
	for(var/mob/M in range(exposure_radius, parent))
		if(M.client && ishuman(M)) // Only affect living humans with a client
			mobs_in_range += M

	// Add new effects and update existing ones
	for(var/mob/M in mobs_in_range)
		if(!affected_mobs[M])
			var/datum/scp/effect_426/effect = new /datum/scp/effect_426(M, parent)
			affected_mobs[M] = effect
		var/datum/scp/effect_426/effect = affected_mobs[M]
		effect.exposure += cognitohazard_power
		effect.process() // Process mental effects immediately

	// Remove effects for mobs no longer in range
	for(var/mob/M in affected_mobs)
		if(!(M in mobs_in_range))
			qdel(affected_mobs[M])
			affected_mobs -= M

/datum/scp/effect_426
	///Affected mob
	var/mob/affected_mob
	///Amount of time spent near SCP-426 (in deciseconds)
	var/exposure = 0
	///Threshold to trigger severe symptoms (in deciseconds)
	var/max_exposure = 600 // 60 seconds for severe symptoms (adjust as needed)

	///Reference to the SCP-426 object that caused the effect
	var/obj/item/scp426/source_scp

/datum/scp/effect_426/New(mob/M, obj/item/scp426/S)
	. = ..()
	affected_mob = M
	source_scp = S
	RegisterSignal(affected_mob, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	RegisterSignal(affected_mob, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_logout))
	RegisterSignal(affected_mob, COMSIG_MOB_SAY, PROC_REF(say_handler))

/datum/scp/effect_426/proc/on_mob_death(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M != affected_mob)
		return
	qdel(src)

/datum/scp/effect_426/proc/on_mob_logout(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M != affected_mob)
		return
	qdel(src)

/datum/scp/effect_426/proc/on_mob_del(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M != affected_mob)
		return
	qdel(src)

/datum/scp/effect_426/Destroy()
	UnregisterSignal(affected_mob, COMSIG_LIVING_DEATH)
	UnregisterSignal(affected_mob, COMSIG_MOB_LOGOUT)
	UnregisterSignal(affected_mob, COMSIG_MOB_SAY)
	affected_mob = null
	source_scp = null
	. = ..()

// The actual message filtration and replacement logic.
// This will surely Never be complex enough, but it should handle a decent amount of cases.
// If someone messes up their grammar.. just tell them to use proper grammar.
/datum/scp/effect_426/proc/say_handler(datum/source, mob/user, message, message_type, radio_key, radio_channel, radio_freq, radio_verb)
	SIGNAL_HANDLER
	if(user != affected_mob)
		return

	var/modified_message = message
	// Handle phrases with "is" or "was" first for grammatical correctness
	modified_message = replacetext(modified_message, "SCP-426 is", "I am")
	modified_message = replacetext(modified_message, "that toaster is", "I am")
	modified_message = replacetext(modified_message, "the toaster is", "I am")
	modified_message = replacetext(modified_message, "this toaster is", "I am")
	modified_message = replacetext(modified_message, "a toaster is", "I am")
	modified_message = replacetext(modified_message, "it is", "I am")
	modified_message = replacetext(modified_message, "the object is", "I am")
	modified_message = replacetext(modified_message, "the anomaly is", "I am")
	modified_message = replacetext(modified_message, "the entity is", "I am")
	modified_message = replacetext(modified_message, "that thing is", "I am")
	modified_message = replacetext(modified_message, "this thing is", "I am")

	modified_message = replacetext(modified_message, "SCP-426 was", "I was")
	modified_message = replacetext(modified_message, "that toaster was", "I was")
	modified_message = replacetext(modified_message, "the toaster was", "I was")
	modified_message = replacetext(modified_message, "this toaster was", "I was")
	modified_message = replacetext(modified_message, "a toaster was", "I was")
	modified_message = replacetext(modified_message, "it was", "I was")
	modified_message = replacetext(modified_message, "the object was", "I was")
	modified_message = replacetext(modified_message, "the anomaly was", "I was")
	modified_message = replacetext(modified_message, "the entity was", "I was")
	modified_message = replacetext(modified_message, "that thing was", "I was")
	modified_message = replacetext(modified_message, "this thing was", "I was")

	// General replacements for pronouns and nouns
	modified_message = replacetext(modified_message, "SCP-426", "I")
	modified_message = replacetext(modified_message, "that toaster", "I")
	modified_message = replacetext(modified_message, "the toaster", "I")
	modified_message = replacetext(modified_message, "this toaster", "I")
	modified_message = replacetext(modified_message, "a toaster", "I")
	modified_message = replacetext(modified_message, "my toaster", "I") // Just in case
	modified_message = replacetext(modified_message, "it ", "I ")
	modified_message = replacetext(modified_message, "it's ", "I'm ")
	modified_message = replacetext(modified_message, "its ", "my ")
	modified_message = replacetext(modified_message, "itself", "myself")
	modified_message = replacetext(modified_message, "the object", "I")
	modified_message = replacetext(modified_message, "the anomaly", "I")
	modified_message = replacetext(modified_message, "the entity", "I")
	modified_message = replacetext(modified_message, "that thing", "I")
	modified_message = replacetext(modified_message, "this thing", "I")

	// Capitalize "I" if it's at the start of a sentence and was originally lowercase
	if(findtext(modified_message, "i ", 1, 3))
		modified_message = replacetext(modified_message, "i ", "I ")
	if(findtext(modified_message, "i'", 1, 3)) // For "i'm", "i'll" etc.
		modified_message = replacetext(modified_message, "i'", "I'")

	if(modified_message != message)
		user.say(modified_message, message_type, radio_key, radio_channel, radio_freq, radio_verb)
		return TRUE // Block original message from being sent

/datum/scp/effect_426/process()
	..()
	// Define exposure thresholds
	var/low_threshold = max_exposure * 0.2 // 20% of max_exposure
	var/medium_threshold = max_exposure * 0.5 // 50% of max_exposure
	var/high_threshold = max_exposure * 0.8 // 80% of max_exposure

	if(exposure >= high_threshold)
		// High exposure effects
		if(prob(5)) // 5% chance every process tick
			to_chat(affected_mob, span_boldwarning("I must fulfill my purpose. I must make toast. For myself."))
			//TD - Objective style tasks for players in regards to 426?
		if(prob(2))
			to_chat(affected_mob, span_boldwarning("I am worthless. I should end myself."))

	else if(exposure >= medium_threshold)
		// Medium exposure effects
		if(prob(10)) // 10% chance every process tick
			to_chat(affected_mob, span_warning("I hear the faint hum of my heating elements..."))
			// Play a subtle auditory hallucination sound
			// sound_to(affected_mob, 'sound/hallucinations/hum.ogg', 20, 1) // Placeholder sound
		if(prob(5))
			to_chat(affected_mob, span_warning("I feel a strange, undeniable affection for myself."))

	else if(exposure >= low_threshold)
		// Low exposure effects
		if(prob(15)) // 15% chance every process tick
			to_chat(affected_mob, span_notice("I suddenly have a craving for toast."))
		if(prob(10))
			to_chat(affected_mob, span_notice("I feel like I've known myself forever."))

// This datum will be managed by the SCP-426 object's Life() proc
// The exposure will be increased by the SCP-426 object itself.
