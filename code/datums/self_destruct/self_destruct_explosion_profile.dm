/datum/self_destruct_profile/self_destruct_explosion_profile
    // This profile handles the actual explosion logic for the self-destruct system.

/datum/self_destruct_explosion_profile/proc/handle_event(event_type, data = null)
    message_admins(span_adminnotice("Self-destruct Explosion Profile: handle_event received event_type: [event_type], data: [data]"))
    switch(event_type)
        if(SD_EFFECT_FINAL_DESTRUCTION)
            // The 'data' argument should be the nuclearbomb object itself
            var/obj/machinery/nuclearbomb/N = data
            if(!istype(N))
                message_admins(span_adminnotice("Self-destruct Explosion Profile: CRASH - Non-nuclearbomb data for final destruction. Data: [data]"))
                CRASH("Self-destruct explosion profile received non-nuclearbomb data for final destruction.")

            if(N.safety)
                message_admins(span_adminnotice("Self-destruct Explosion Profile: Nuke safety is ON, preventing explosion."))
                return

            N.exploding = TRUE
            N.yes_code = FALSE
            N.update_appearance()
            if(SSticker?.mode)
                SSticker.roundend_check_paused = TRUE
            message_admins(span_adminnotice("Self-destruct Explosion Profile: Final destruction event received. Setting timer for actually_explode_profile in 100 ticks."))
            addtimer(CALLBACK(src, PROC_REF(actually_explode_profile), N), 100)

/datum/self_destruct_explosion_profile/proc/actually_explode_profile(obj/machinery/nuclearbomb/N)
    message_admins(span_adminnotice("Self-destruct Explosion Profile: actually_explode_profile called for [N]."))
    if(!N.core)
        Cinematic(CINEMATIC_NUKE_NO_CORE,world)
        SSticker.roundend_check_paused = FALSE
        message_admins(span_adminnotice("Self-destruct Explosion Profile: Nuke core missing, explosion aborted."))
        return

    SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)

    var/off_station = 0
    var/turf/bomb_location = get_turf(N)
    var/area/A = get_area(bomb_location)

    if(bomb_location && is_station_level(bomb_location.z))
        if(istype(A, /area/space))
            off_station = NUKE_NEAR_MISS
        else if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.y < (128+NUKERANGE)))
            off_station = NUKE_NEAR_MISS
        else // station actually nuked
            off_station = STATION_DESTROYED_NUKE
            GLOB.station_was_nuked = TRUE
    else if(bomb_location.onSyndieBase())
        off_station = NUKE_SYNDICATE_BASE
    else
        off_station = NUKE_MISS_STATION

    message_admins(span_adminnotice("Self-destruct Explosion Profile: Calculated off_station status: [off_station]. Bomb location: [bomb_location]."))

    if(off_station < NUKE_MISS_STATION)
        SSshuttle.registerHostileEnvironment(N)
        SSshuttle.lockdown = TRUE
    //Cinematic
    GLOB.station_nuke_source = off_station
    message_admins(span_adminnotice("Self-destruct Explosion Profile: Calling really_actually_explode_profile with off_station [off_station]."))
    really_actually_explode_profile(off_station, N)
    SSticker.roundend_check_paused = FALSE

/datum/self_destruct_explosion_profile/proc/really_actually_explode_profile(off_station, obj/machinery/nuclearbomb/N)
    message_admins(span_adminnotice("Self-destruct Explosion Profile: really_actually_explode_profile called. off_station: [off_station]."))
    var/turf/bomb_location = get_turf(N)
    Cinematic(N.get_cinematic_type(off_station),world,CALLBACK(SSticker,TYPE_PROC_REF(/datum/controller/subsystem/ticker, station_explosion_detonation),N))
    if(istype(N, /obj/machinery/nuclearbomb/syndicate/bananium))
        var/obj/machinery/nuclearbomb/syndicate/bananium/bananium_nuke = N
        bananium_nuke.really_actually_explode(off_station)
        message_admins(span_adminnotice("Self-destruct Explosion Profile: Bananium nuke specific explosion triggered."))
    else if(istype(N, /obj/machinery/nuclearbomb/beer))
        var/obj/machinery/nuclearbomb/beer/beer_nuke = N
        if(is_station_level(bomb_location.z))
            beer_nuke.really_actually_explode()
            message_admins(span_adminnotice("Self-destruct Explosion Profile: Beer nuke station-wide foam triggered."))
        else
            beer_nuke.local_foam()
            message_admins(span_adminnotice("Self-destruct Explosion Profile: Beer nuke local foam triggered."))
    else if(off_station == STATION_DESTROYED_NUKE)
        INVOKE_ASYNC(GLOBAL_PROC,GLOBAL_PROC_REF(KillEveryoneOnStation))
        message_admins(span_adminnotice("Self-destruct Explosion Profile: Station destroyed, killing everyone on station."))
        return
    if(off_station != NUKE_NEAR_MISS) // Don't kill people in the station if the nuke missed, even if we are technically on the same z-level
        INVOKE_ASYNC(GLOBAL_PROC,GLOBAL_PROC_REF(KillEveryoneOnZLevel), bomb_location.z)
        message_admins(span_adminnotice("Self-destruct Explosion Profile: Killing everyone on Z-level [bomb_location.z]."))
