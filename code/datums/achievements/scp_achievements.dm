/datum/award/achievement/scp
	category = "SCP"
	icon = "scp_default" // Placeholder icon for SCP achievements

// Containment & Research Achievements

/datum/award/achievement/scp/objectively_safe
	name = "Objectively Safe"
	desc = "Successfully recontain a Safe-class SCP without incident."
	database_id = "SCP_OBJECTIVELY_SAFE"
	icon = "scp_safe" // Placeholder icon
	// Mechanical Idea: Triggered when a Safe-class SCP is successfully recontained (e.g., returned to its chamber, secured)
	// without any damage to the SCP, personnel, or environment, and without any alarms being triggered during the recontainment process.
	// This would require tracking the state of the SCP and the environment during the recontainment procedure.

/datum/award/achievement/scp/keter_wrangler
	name = "Keter Wrangler"
	desc = "Assist in the containment or recontainment of a Keter-class SCP."
	database_id = "SCP_KETER_WRANGLER"
	icon = "scp_keter" // Placeholder icon
	// Mechanical Idea: Triggered when a player is actively involved in the containment or recontainment of a Keter-class SCP.
	// This could involve being within a certain proximity of the SCP during a successful containment, participating in a containment team,
	// or directly interacting with containment procedures (e.g., activating restraints, closing blast doors).

/datum/award/achievement/scp/cognitive_dissonance
	name = "Cognitive Dissonance"
	desc = "Complete a full analysis report on a cognitohazard without being affected by its memetic properties."
	database_id = "SCP_COGNITIVE_DISSONANCE"
	icon = "scp_cognitohazard" // Placeholder icon
	// Mechanical Idea: Triggered when a researcher successfully completes a full analysis report on a cognitohazardous SCP
	// without being affected by its cognitohazardous properties. This would require a system to track exposure to cognitohazards
	// and a mechanism for submitting "full analysis reports" (e.g., a specific research console interaction).

/datum/award/achievement/scp/classified_means_classified
	name = "Classified Means Classified"
	desc = "Attempt to access a Level 4+ terminal and get denied."
	database_id = "SCP_CLASSIFIED_DENIED"
	icon = "scp_denied" // Placeholder icon
	// Mechanical Idea: Triggered when a player attempts to access a terminal or data console requiring Level 4+ clearance,
	// but their current clearance level is insufficient, resulting in a "denied access" message.
	// This would involve checking the player's access level against the terminal's requirements.

/datum/award/achievement/scp/peer_reviewed
	name = "Peer Reviewed"
	desc = "Have your test proposal approved and completed by a research supervisor."
	database_id = "SCP_PEER_REVIEWED"
	icon = "scp_approved" // Placeholder icon
	// Mechanical Idea: Triggered when a player, as a researcher, submits a test proposal for an SCP,
	// and that proposal is subsequently approved by a research supervisor (another player with appropriate authority or an NPC)
	// and the test is then completed. This would require a system for proposal submission, approval, and tracking of test completion.

//  D-Class & Danger Achievements

/datum/award/achievement/scp/disposable_hero
	name = "Disposable Hero"
	desc = "Survive three consecutive SCP test deployments as a D-Class."
	database_id = "SCP_DISPOSABLE_HERO"
	icon = "scp_dclass_survive" // Placeholder icon
	// Mechanical Idea: Triggered when a D-Class survives three consecutive SCP test deployments.
	// "Survive" means not dying during the test and returning to the D-Class holding area or a safe zone.
	// This would require tracking the number of successful test deployments.

/datum/award/achievement/scp/my_turn_doc
	name = "My Turn, Doc"
	desc = "Suggest an SCP experiment and have it approved."
	database_id = "SCP_MY_TURN_DOC"
	icon = "scp_dclass_suggest" // Placeholder icon
	// Mechanical Idea: Triggered when a D-Class suggests an SCP experiment (e.g., through a specific interaction or communication channel)
	// and that suggestion is approved by a researcher or supervisor, leading to the experiment being conducted.
	// This would require a system for D-Class suggestions and approval.

/datum/award/achievement/scp/thats_probably_fine
	name = "That's Probably Fine"
	desc = "Participate in a test that results in at least two casualties."
	database_id = "SCP_PROBABLY_FINE"
	icon = "scp_casualties" // Placeholder icon
	// Mechanical Idea: Triggered when a player participates in an SCP test that results in at least two casualties
	// (e.g., deaths of D-Class, security, or other personnel). "Participate" could mean being present in the test chamber
	// or directly involved in the test setup.

/datum/award/achievement/scp/well_that_was_unexpected
	name = "Well That Was Unexpected"
	desc = "Die to an unintended SCP interaction (e.g. pressing the wrong button)."
	database_id = "SCP_UNEXPECTED_DEATH"
	icon = "scp_unexpected" // Placeholder icon
	// Mechanical Idea: Triggered when a player dies due to an unintended SCP interaction.
	// This could be a specific death condition tied to certain SCPs or environmental hazards caused by SCPs,
	// where the death is not a direct result of combat or intentional exposure.
	// For example, pressing a wrong button that triggers an SCP's ability.

/datum/award/achievement/scp/visual_confirmation
	name = "Visual Confirmation"
	desc = "Be the first person to spot an SCP during a breach."
	database_id = "SCP_BREACH_BABY"
	icon = "scp_first_spot" // Placeholder icon
	// Mechanical Idea: Triggered when a player is the first to visually spot an SCP during a containment breach
	// and reports it (e.g., via comms or an alarm system).
	// This would require tracking SCP movement during breaches and player line-of-sight/reporting actions.

// 🗄️ Administrative & Site Utility Achievements

/datum/award/achievement/scp/cogs_in_the_machine
	name = "Cogs in the Machine"
	desc = "Successfully run shift-long logistics or communications operations."
	database_id = "SCP_COGS_MACHINE"
	icon = "scp_logistics" // Placeholder icon
	// Mechanical Idea: Triggered when a player successfully manages shift-long logistics or communications operations.
	// This could involve maintaining a certain uptime for communication systems, successfully routing supplies,
	// or managing personnel assignments for a significant duration of the round.

/datum/award/achievement/scp/authorization_granted
	name = "Authorization Granted"
	desc = "Gain a new clearance level mid-round (e.g., get promoted or upgraded access)."
	database_id = "SCP_CLEARANCE_ACCEPTED"
	icon = "scp_clearance" // Placeholder icon
	// Mechanical Idea: Triggered when a player gains a new clearance level mid-round.
	// This could be through promotion, finding a higher-level access card, or having their access upgraded by an administrator.

/datum/award/achievement/scp/yes_director
	name = "Yes, Director"
	desc = "Follow through on an order from Site Command that alters the round's outcome."
	database_id = "SCP_YES_DIRECTOR"
	icon = "scp_director" // Placeholder icon
	// Mechanical Idea: Triggered when a player follows a direct order from Site Command (e.g., a Director or O5 Council member)
	// that significantly alters the outcome of the round (e.g., successfully containing a major breach,
	// preventing a catastrophic event, or achieving a specific objective).

/datum/award/achievement/scp/bureaucratic_excellence
	name = "Bureaucratic Excellence"
	desc = "Fill out five separate forms (test proposals, incident reports, etc.) correctly in one shift."
	database_id = "SCP_BUREAUCRATIC_EXCELLENCE"
	icon = "scp_forms" // Placeholder icon
	// Mechanical Idea: Triggered when a player correctly fills out and submits five separate forms
	// (e.g., test proposals, incident reports, requisition forms, personnel evaluations) within a single shift.
	// "Correctly" would imply all required fields are filled and the form is submitted through the proper channel.

// 😈 Mischievous or Morally Grey Achievements

/datum/award/achievement/scp/ethics_advisory_pending
	name = "Ethics Advisory Pending"
	desc = "Perform an ethically questionable experiment that somehow gets signed off."
	database_id = "SCP_ETHICS_PENDING"
	icon = "scp_ethics" // Placeholder icon
	// Mechanical Idea: Triggered when a player performs an ethically questionable experiment
	// (e.g., one that causes harm to D-Class or involves extreme risk) that somehow gets officially signed off
	// or approved by a superior, despite its questionable nature.

/datum/award/achievement/scp/oops_all_breaches
	name = "Oops, All Breaches"
	desc = "Contribute (directly or indirectly) to three breaches in a single round."
	database_id = "SCP_ALL_BREACHES"
	icon = "scp_breaches" // Placeholder icon
	// Mechanical Idea: Triggered when a player directly or indirectly contributes to three separate SCP containment breaches
	// in a single round. "Contributes" could mean leaving doors open, failing to follow containment procedures,
	// or actively sabotaging systems.

/datum/award/achievement/scp/internal_affairs_actually
	name = "Internal Affairs, Actually"
	desc = "Discover and report a mole, cultist, or traitor."
	database_id = "SCP_INTERNAL_AFFAIRS"
	icon = "scp_mole" // Placeholder icon
	// Mechanical Idea: Triggered when a player discovers and successfully reports a mole, cultist, or traitor
	// within the facility, leading to their apprehension or neutralization.
	// This would require a system for identifying and reporting such roles.

/datum/award/achievement/scp/whoops
	name = "Whoops!"
	desc = "Accidentally release an SCP."
	database_id = "SCP_WHOOPS"
	icon = "scp_release" // Placeholder icon
	// Mechanical Idea: Triggered when a player accidentally releases an SCP from its containment.
	// This could be through a misclick, an oversight, or a misunderstanding of a control panel.

/datum/award/achievement/scp/am_i_the_scp
	name = "Am I the SCP?"
	desc = "Get mistaken for a hostile entity during a containment breach."
	database_id = "SCP_MISTAKEN_ENTITY"
	icon = "scp_mistaken" // Placeholder icon
	// Mechanical Idea: Triggered when a player is mistaken for a hostile entity (e.g., an SCP or an intruder)
	// by other personnel (NPCs or players) during a containment breach, leading to them being targeted or attacked.

// 🎥 Tape & Anomaly Collecting Achievements

/datum/award/achievement/scp/rewound_unbound
	name = "Rewound & Unbound"
	desc = "Discover and play five different anomalous tapes."
	database_id = "SCP_REWOUND_UNBOUND"
	icon = "scp_tapes" // Placeholder icon
	// Mechanical Idea: Triggered when a player discovers and successfully plays five different anomalous tapes.
	// This would require a system for unique anomalous tapes and a mechanism for playing them (e.g., a tape player).

/datum/award/achievement/scp/recording_for_posterity
	name = "Recording for Posterity"
	desc = "Record your own experiment audio tape and archive it."
	database_id = "SCP_RECORDING_POSTERITY"
	icon = "scp_record" // Placeholder icon
	// Mechanical Idea: Triggered when a player records their own experiment audio tape (e.g., documenting an SCP interaction)
	// and successfully archives it in a designated storage location.

/datum/award/achievement/scp/this_isnt_from_our_archive
	name = "This Isn’t From Our Archive..."
	desc = "Discover a forbidden or off-site tape."
	database_id = "SCP_FORBIDDEN_TAPE"
	icon = "scp_forbidden" // Placeholder icon
	// Mechanical Idea: Triggered when a player discovers a forbidden or off-site tape.
	// This could be a tape found in a hidden location, a tape with unusual properties, or one explicitly marked as "forbidden."

/datum/award/achievement/scp/static_screamer
	name = "Static Screamer"
	desc = "Get jump-scared by a tape."
	database_id = "SCP_STATIC_SCREAMER"
	icon = "scp_jumpscare" // Placeholder icon
	// Mechanical Idea: Triggered when a player experiences a jump-scare event specifically caused by playing an anomalous tape.
	// This would involve a specific audio/visual event tied to certain tapes.

/datum/award/achievement/scp/field_broadcast
	name = "Field Broadcast"
	desc = "Transmit a corrupted or anomalous recording over site comms."
	database_id = "SCP_FIELD_BROADCAST"
	icon = "scp_broadcast" // Placeholder icon
	// Mechanical Idea: Triggered when a player successfully transmits a corrupted or anomalous recording over the site's communication system.
	// This would require a mechanism for broadcasting and a way to designate a recording as "corrupted" or "anomalous."

// 🧩 Meta or Hidden Achievements

/datum/award/achievement/scp/scp_unlocked
	name = "SCP-████ Unlocked"
	desc = "Trigger a previously undiscovered SCP interaction."
	database_id = "SCP_UNKNOWN_UNLOCKED"
	icon = "scp_unlocked" // Placeholder icon
	// Mechanical Idea: Triggered when a player performs a specific, previously undiscovered interaction with an SCP
	// that leads to a unique outcome or revelation. This would be a hidden trigger tied to specific SCP behaviors.

/datum/award/achievement/scp/the_administrator_watches
	name = "The Administrator Watches"
	desc = "Find and interact with an out-of-bounds or hidden dev room."
	database_id = "SCP_ADMIN_WATCHES"
	icon = "scp_admin" // Placeholder icon
	// Mechanical Idea: Triggered when a player finds and interacts with an out-of-bounds area or a hidden "developer room"
	// within the game map.

/datum/award/achievement/scp/you_werent_supposed_to_see_that
	name = "You Weren’t Supposed to See That"
	desc = "Glimpse an unreleased SCP entry, redacted file, or unfinished map room."
	database_id = "SCP_NOT_SUPPOSED_TO_SEE"
	icon = "scp_hidden_content" // Placeholder icon
	// Mechanical Idea: Triggered when a player glimpses an unreleased SCP entry, a heavily redacted file,
	// or an unfinished map room. This could involve specific visual triggers or interactions with placeholder content.

/datum/award/achievement/scp/cursed_metadata
	name = "Cursed Metadata"
	desc = "Experience a bug so strange it might as well be an anomaly."
	database_id = "SCP_CURSED_METADATA"
	icon = "scp_bug" // Placeholder icon
	// Mechanical Idea: Triggered when a player experiences a particularly strange or game-breaking bug
	// that is recognized by the system as an "anomaly." This would be a very rare, system-level trigger.

/datum/award/achievement/scp/meta_containment
	name = "Meta-Containment"
	desc = "Find an SCP that references another SCP you’ve already interacted with."
	database_id = "SCP_META_CONTAINMENT"
	icon = "scp_meta" // Placeholder icon
	// Mechanical Idea: Triggered when a player finds an SCP that explicitly references another SCP they have already interacted with
	// in the current round. This would require tracking player interactions with SCPs and cross-referencing SCP lore.
