/datum/component/scp096_tackler
    parent_type = /datum/component/tackler

    ///SCP-096 does not use stamina for leaping.
    stamina_cost = 0
    ///SCP-096 does not get knocked down by its own leaps.
    base_knockdown = 0
    ///SCP-096's leap range is determined by its mob var.
    range = 0
    ///SCP-096's leap speed is determined by its mob var.
    speed = 0
    ///SCP-096's leap does not have a skill modifier.
    skill_mod = 0
    ///SCP-096's leap does not have a minimum distance.
    min_distance = 0

/datum/component/scp096_tackler/Initialize()
    if(!isscp096(parent))
        return COMPONENT_INCOMPATIBLE

    // No need for user messages or timers for SCP-096's internal leap
    // as it's not a player-controlled action with cooldowns like human tackling.
    return COMPONENT_INITIALIZE_PASSTHROUGH

/datum/component/scp096_tackler/RegisterWithParent()
    // SCP-096's leap is triggered by its AI, not user clicks or general impacts.
    // We only need to register for post-throw to handle the attack after movement.
    RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(scp_post_leap_attack))

/datum/component/scp096_tackler/UnregisterFromParent()
    UnregisterSignal(parent, COMSIG_MOVABLE_IMPACT)

/// Custom leap initiation for SCP-096, called by its AI.
/datum/component/scp096_tackler/proc/leap(mob/living/scp096/user, atom/target_atom, leap_range, leap_speed)
    if(!user || !target_atom)
        return FALSE

    // SCP-096's leap is always ready, no 'tackling' state or cooldown.
    // The AI handles the cooldown/readiness.

    user.face_atom(target_atom)
    playsound(user, 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)

    user.visible_message(span_warning("[user] leaps at [target_atom]!"), span_danger("You leap at [target_atom]!"))

    // SCP-096 does not get knocked down by its own leap.
    // user.Knockdown(base_knockdown, ignore_canstun = TRUE)
    // SCP-096 does not use stamina for leaping.
    // user.stamina.adjust(-stamina_cost)

    user.throw_at(target_atom, leap_range, leap_speed, user, FALSE)
    // No resetTackle timer needed, as SCP-096's AI manages its leap frequency.
    return TRUE

/// SCP-096's post-leap attack, replacing the generic sack/splat logic.
/datum/component/scp096_tackler/proc/scp_post_leap_attack(mob/living/scp096/user, atom/hit)
    SIGNAL_HANDLER

    // This proc is called after the throw completes.
    // SCP-096's leap always results in an UnarmedAttack on the target if within range.
    if(user.target && get_dist(user, user.target) <= 1)
        spawn(0) // Spawn a new topic for the blocking call
            user.UnarmedAttack(user.target)
    // If it hits a dense object, it should be staggered, not take damage.
    else if(hit && hit.density && !ismob(hit))
        user.visible_message(span_danger("[user] slams into [hit]!"))
        if(user.current_state == STATE_096_STAGGERED)
            user.stagger_counter = user.stagger_counter + 1 SECOND
        else
            user.stagger_counter = world.time + 1 SECOND
            user.current_state = STATE_096_STAGGERED
        playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)

    // No need for tackle.gentle = TRUE or COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH
    // as SCP-096's attack logic is handled directly.

    // We don't need to call resetTackle() from the parent, as SCP-096's AI
    // manages its own readiness for the next leap.

/// SCP-096's can_leap check, replacing the generic can_be_used_by.
/datum/component/scp096_tackler/proc/can_leap(mob/living/scp096/user, atom/target_atom)
    // SCP-096's leap is always available if its AI decides to use it.
    // No need for throw_mode, active_held_item, grabs, buckled, incapacitated,
    // or specific traits like TRAIT_HULK, TRAIT_HANDS_BLOCKED, LYING_DOWN.
    // The AI handles the conditions for leaping.
    return TRUE
