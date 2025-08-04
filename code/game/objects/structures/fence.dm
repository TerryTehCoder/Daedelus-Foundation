//Chain link fences
//Sprites ported from /VG/


#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE

	icon = 'icons/obj/fence.dmi'
	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE
	layer = ABOVE_OBJ_LAYER

/obj/structure/fence/Initialize(mapload)
	. = ..()

	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()

	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/door/examine(mob/user)
	. = ..()
	if(current_lock)
		. += "It has a [current_lock.name] attached."
		if(current_lock.locked)
			. += " The [current_lock.name] is currently locked."

/obj/structure/fence/end
	icon_state = "end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!cuttable)
			to_chat(user, span_warning("This section of the fence can't be cut!"))
			return
		if(invulnerable)
			to_chat(user, span_warning("This fence is too strong to cut through!"))
			return
		var/current_stage = hole_size
		if(current_stage >= MAX_HOLE_SIZE)
			to_chat(user, span_warning("This fence has too much cut out of it already!"))
			return

		user.visible_message(span_danger("\The [user] starts cutting through \the [src] with \the [W]."),\
		span_danger("You start cutting through \the [src] with \the [W]."))

		if(do_after(user, src, CUT_TIME*W.toolspeed))
			if(current_stage == hole_size)
				switch(++hole_size)
					if(MEDIUM_HOLE)
						visible_message(span_notice("\The [user] cuts into \the [src] some more."))
						to_chat(user, span_info("You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger."))
						AddElement(/datum/element/climbable)
					if(LARGE_HOLE)
						visible_message(span_notice("\The [user] completely cuts through \the [src]."))
						to_chat(user, span_info("The hole in \the [src] is now big enough to walk through."))
						RemoveElement(/datum/element/climbable)

				update_cut_status()

	return TRUE

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	var/new_density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			new_density = FALSE
	set_density(new_density)

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/obj/item/fence_door_lock/current_lock = null
	var/locked = FALSE

/obj/structure/fence/door/Initialize(mapload)
	. = ..()
	if(current_lock)
		current_lock.forceMove(src) // Ensure the lock is on the door
		locked = current_lock.locked
		update_icon_state() // Update door icon based on lock state

	update_icon_state()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	density = FALSE

/obj/structure/fence/door/attack_hand(mob/user, list/modifiers)
	if(can_open(user))
		toggle(user)

	return TRUE

/obj/structure/fence/door/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/fence_door_lock))
		if(current_lock)
			to_chat(user, span_warning("There's already a lock on this door."))
			return
		user.transferItemToLoc(W, src)
		current_lock = W
		locked = current_lock.locked
		update_icon_state()
		to_chat(user, span_notice("You attach \the [W] to \the [src]."))
		qdel(W)
		return TRUE
	if(istype(W, /obj/item/fence_door_key))
		if(!current_lock)
			to_chat(user, span_warning("There's no lock on this door."))
			return
		current_lock.attack_self(user) // Let the lock handle the key interaction
		locked = current_lock.locked
		update_icon_state()
		return TRUE
	return ..()

/obj/structure/fence/door/proc/toggle(mob/user)
	if(locked)
		to_chat(user, span_warning("The door is locked!"))
		return
	visible_message(span_notice("\The [user] [density ? "opens" : "closes"] \the [src]."))
	set_density(!density)
	update_icon_state()
	playsound(src, 'sound/structures/fencedoortoggle.ogg', 100, TRUE)

/obj/structure/fence/door/update_icon_state()
	icon_state = density ? "door_closed" : "door_opened"
	return ..()

/obj/structure/fence/door/proc/can_open(mob/user)
	if(current_lock && current_lock.locked)
		to_chat(user, span_warning("The door is locked!"))
		return FALSE
	return TRUE

/obj/structure/fence/door/locked
	name = "locked fence door"
	desc = "A sturdy fence door with a built-in lock."
	var/initial_lock_id = "" // Mapper can set this to define the lock's ID

/obj/structure/fence/door/locked/Initialize(mapload)
	. = ..()
	if(!current_lock) // If a lock wasn't already attached (e.g., by another map var)
		current_lock = new /obj/item/fence_door_lock(src.loc)
	if(initial_lock_id) // If mapper set an initial_lock_id on the door
		current_lock.lock_id = initial_lock_id
	current_lock.forceMove(src) // Ensure the lock is on the door
	current_lock.locked = TRUE // Ensure the lock starts locked
	locked = TRUE // Synchronize door's locked state
	update_icon_state()

/obj/structure/fence/door/locked/opened
	icon_state = "door_opened"

/obj/structure/fence/door/locked/opened/Initialize(mapload)
	. = ..()
	density = FALSE // Start open
	if(!current_lock)
		current_lock = new /obj/item/fence_door_lock(src.loc)
	if(initial_lock_id)
		current_lock.lock_id = initial_lock_id
	current_lock.forceMove(src)
	current_lock.locked = TRUE
	locked = TRUE
	update_icon_state()

// FENCE DOOR KEY
/obj/item/fence_door_key
	name = "fence door key"
	desc = "A key for a fence door lock."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	var/key_id = "" // This will be set by mappers

/obj/item/fence_door_key/Initialize(mapload)
	. = ..()
	if (!key_id)
		key_id = "default" // Default ID if not set by mapper

// FENCE DOOR LOCK
/obj/item/fence_door_lock
	name = "fence door lock"
	desc = "A lock for a fence door."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key" //Placeholder
	var/lock_id = "" // This will be set by mappers
	var/locked = FALSE // Initial state

/obj/item/fence_door_lock/Initialize(mapload)
	. = ..()
	if (!lock_id)
		lock_id = "default" // Default ID if not set by mapper
	update_icon()

/obj/item/fence_door_lock/attack_self(mob/user)
	if(!ismob(user) || !isliving(user))
		return
	var/obj/item/fence_door_key/found_key
	for(var/obj/item/I in user.contents)
		if(istype(I, /obj/item/fence_door_key))
			var/obj/item/fence_door_key/K = I
			if(K.key_id == lock_id)
				found_key = K
				break
	if(found_key)
		locked = !locked
		update_icon()
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] \the [src]."))
		playsound(src, 'sound/weapons/gun/pistol/lock_small.ogg', 100, TRUE) //Nefarious sound reusage.
	else
		to_chat(user, span_warning("You don't have the correct key for this lock."))

/obj/item/fence_door_luck/update_icon(updates)
	. = ..()
	return

#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE
