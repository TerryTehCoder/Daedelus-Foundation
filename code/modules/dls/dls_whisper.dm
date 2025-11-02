/datum/dls_whisper
	/// The crew member this whisper is about.
	var/mob/living/carbon/human/target
	/// A human-readable description of the event.
	var/description
	/// The confidence score of this whisper.
	var/confidence = 0
	/// The tier of this whisper (Routine, Suspicious, Critical).
	var/tier = ""
	/// The status of this whisper (Unvalidated, Validated, Invalidated).
	var/status = DLS_STATUS_UNVALIDATED
	/// The unique identifier for this whisper.
	var/id
	/// The type of score this whisper is associated with.
	var/score_type = ""
	/// The timestamp of the event.
	var/timestamp = 0

/datum/dls_whisper/New(mob/living/carbon/human/new_target, new_text, new_confidence, new_tier, new_score_type)
	..()
	if(!new_target)
		CRASH("dls_whisper created with null target")
	if(!new_text || !length(new_text))
		CRASH("dls_whisper created with invalid description")
	if(!isnull(new_confidence))
		confidence = new_confidence
	if(!isnull(new_tier))
		tier = new_tier
	if(!isnull(new_score_type))
		score_type = new_score_type
	target = new_target
	description = new_text
	confidence = new_confidence
	tier = new_tier
	score_type = new_score_type
	id = REF(src)
	timestamp = world.time
