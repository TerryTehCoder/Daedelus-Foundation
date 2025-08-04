/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	inhand_icon_state = "analyzer"
	worn_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=60, /datum/material/glass=30)
	force = 2
	throwforce = 2
	speech_span = SPAN_TAPE_RECORDER
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	var/recording = FALSE
	var/playing = FALSE
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/starting_tape_type = /obj/item/tape/random
	var/open_panel = FALSE
	var/canprint = TRUE
	var/list/icons_available = list()
	var/radial_icon_file = 'icons/hud/radial_taperecorder.dmi'
	///Whether we've warned during this recording session that the tape is almost up.
	var/time_warned = FALSE
	///Seconds under which to warn that the tape is almost up.
	var/time_left_warning = 60 SECONDS
	///Sound loop that plays when recording or playing back.
	var/datum/looping_sound/tape_recorder_hiss/soundloop

/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	soundloop = new(src)
	update_appearance()
	become_hearing_sensitive()

/obj/item/taperecorder/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(mytape)
	return ..()

/obj/item/taperecorder/proc/readout()
	if(mytape)
		if(playing)
			return span_notice("<b>PLAYING</b>")
		else
			var/time = mytape.used_capacity / 10 //deciseconds / 10 = seconds
			var/mins = round(time / 60)
			var/secs = time - mins * 60
			return span_notice("<b>[mins]</b>m <b>[secs]</b>s")
	return span_notice("<b>NO TAPE INSERTED</b>")

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += span_notice("The wire panel is [open_panel ? "opened" : "closed"]. The display reads:")
		. += "[readout()]"

/obj/item/taperecorder/AltClick(mob/user)
	. = ..()
	play()

/obj/item/taperecorder/proc/update_available_icons()
	icons_available = list()

	if(!playing && !recording)
		icons_available += list("Record" = image(radial_icon_file,"record"))
		icons_available += list("Play" = image(radial_icon_file,"play"))
		if(canprint && mytape?.storedinfo.len)
			icons_available += list("Print Transcript" = image(radial_icon_file,"print"))

	if(playing || recording)
		icons_available += list("Stop" = image(radial_icon_file,"stop"))

	if(mytape)
		icons_available += list("Eject" = image(radial_icon_file,"eject"))

/obj/item/taperecorder/proc/update_sound()
	if(!playing && !recording)
		soundloop.stop()
	else
		soundloop.start()

/obj/item/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		to_chat(user, span_notice("You insert [I] into [src]."))
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		update_appearance()


/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		to_chat(user, span_notice("You remove [mytape] from [src]."))
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_appearance()

/obj/item/taperecorder/fire_act(exposed_temperature, exposed_volume, turf/adjacent)
	mytape.unspool() //Fires unspool the tape, which makes sense if you don't think about it
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/taperecorder/attack_hand(mob/user, list/modifiers)
	if(loc != user || !mytape || !user.is_holding(src))
		return ..()
	eject(user)

/obj/item/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE


/obj/item/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/taperecorder/update_icon_state()
	if(!mytape)
		icon_state = "taperecorder_empty"
		return ..()
	if(recording)
		icon_state = "taperecorder_recording"
		return ..()
	if(playing)
		icon_state = "taperecorder_playing"
		return ..()
	icon_state = "taperecorder_idle"
	return ..()


/obj/item/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list(), atom/sound_loc, message_range)
	. = ..()
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity,"mm:ss")]\] [message]"


/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.unspooled)
		return
	if(recording)
		return
	if(playing)
		return

	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)

	if(mytape.used_capacity < mytape.max_capacity)
		recording = TRUE
		say("Recording started.")
		update_sound()
		update_appearance()
		var/used = mytape.used_capacity //to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		while(recording && used < max)
			mytape.used_capacity += 1 SECONDS
			used += 1 SECONDS
			if(max - used < time_left_warning && !time_warned)
				time_warned = TRUE
				say("[(max - used) / 10] seconds left!") //deciseconds / 10 = seconds
			sleep(1 SECONDS)
		if(used >= max)
			say("Tape full.")
		stop()
	else
		say("The tape is full!")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		say("Recording stopped.")
		recording = FALSE
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		say("Playback stopped.")
		playing = FALSE
	time_warned = FALSE
	update_appearance()
	update_sound()

/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.unspooled)
		return
	if(recording)
		return
	if(playing)
		return

	playing = TRUE
	update_appearance()
	update_sound()
	say("Playback started.")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity //to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max, sleep(playsleepseconds))
		if(!mytape)
			break
		if(playing == FALSE)
			break
		if(mytape.storedinfo.len < i)
			say("End of recording.")
			break
		say("[mytape.storedinfo[i]]", sanitize=FALSE)//We want to display this properly, don't double encode
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(1 SECONDS)
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14 SECONDS)
			sleep(1 SECONDS)
			say("Skipping [playsleepseconds / 10] seconds of silence.")
			playsleepseconds = clamp(playsleepseconds / 10, 1 SECONDS, 3 SECONDS)
		i++

	stop()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape)
		to_chat(user, span_notice("\The [src] is empty."))
		return
	if(mytape.unspooled)
		to_chat(user, span_warning("\The tape inside \the [src] is broken!"))
		return

	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Stop")
				stop()
			if("Record")
				record()
			if("Play")
				play()
			if("Print Transcript")
				print_transcript()
			if("Eject")
				eject(user)

/obj/item/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(!mytape.storedinfo.len)
		return
	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, span_warning("The recorder can't print that fast!"))
		return
	if(recording || playing)
		return

	say("Transcript printed.")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 50, FALSE)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i in 1 to mytape.storedinfo.len)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	var/tapename = mytape.name
	var/prototapename = initial(mytape.name)
	P.name = "paper- '[tapename == prototapename ? "Tape" : "[tapename]"] Transcript'"
	P.update_icon_state()
	usr.put_in_hands(P)
	canprint = FALSE
	addtimer(VARSET_CALLBACK(src, canprint, TRUE), 30 SECONDS)


//empty tape recorders
/obj/item/taperecorder/empty
	starting_tape_type = null


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content on either side."
	icon_state = "tape_white"
	icon = 'icons/obj/device.dmi'
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=20, /datum/material/glass=5)
	force = 1
	throwforce = 0
	obj_flags = UNIQUE_RENAME //my mixtape
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	///Because we can't expect God to do all the work.
	var/initial_icon_state
	var/max_capacity = 10 MINUTES
	var/used_capacity = 0 SECONDS
	///Numbered list of chat messages the recorder has heard with spans and prepended timestamps. Used for playback and transcription.
	var/list/storedinfo = list()
	///Numbered list of seconds the messages in the previous list appear at on the tape. Used by playback to get the timing right.
	var/list/timestamp = list()
	var/used_capacity_otherside = 0 SECONDS //Separate my side
	var/list/storedinfo_otherside = list()
	var/list/timestamp_otherside = list()
	var/unspooled = FALSE
	var/list/icons_available = list()
	var/radial_icon_file = 'icons/hud/radial_tape.dmi'

/obj/item/tape/fire_act(exposed_temperature, exposed_volume, turf/adjacent)
	unspool()
	..()

/obj/item/tape/Initialize(mapload)
	. = ..()
	initial_icon_state = icon_state //random tapes will set this after choosing their icon

	var/mycolor = random_short_color()
	name += " ([mycolor])" //multiple tapes can get confusing fast
	if(icon_state == "tape_greyscale")
		add_atom_colour("#[mycolor]", FIXED_COLOUR_PRIORITY)

	if(prob(50))
		tapeflip()

/obj/item/tape/proc/update_available_icons()
	icons_available = list()

	if(!unspooled)
		icons_available += list("Unwind tape" = image(radial_icon_file,"tape_unwind"))
	icons_available += list("Flip tape" = image(radial_icon_file,"tape_flip"))

/obj/item/tape/attack_self(mob/user)
	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Flip tape")
				if(loc != user)
					return
				tapeflip()
				to_chat(user, span_notice("You turn \the [src] over."))
				playsound(src, 'sound/items/taperecorder/tape_flip.ogg', 70, FALSE)
			if("Unwind tape")
				if(loc != user)
					return
				unspool()
				to_chat(user, span_warning("You pull out all the tape!"))

/obj/item/tape/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(prob(50))
		tapeflip()
	. = ..()

/obj/item/tape/proc/unspool()
	//Let's not add infinite amounts of overlays when our fire_act is called repeatedly
	if(!unspooled)
		add_overlay("ribbonoverlay")
	unspooled = TRUE

/obj/item/tape/proc/respool()
	cut_overlay("ribbonoverlay")
	unspooled = FALSE

/obj/item/tape/proc/tapeflip()
	//first we save a copy of our current side
	var/list/storedinfo_currentside = storedinfo.Copy()
	var/list/timestamp_currentside = timestamp.Copy()
	var/used_capacity_currentside = used_capacity
	//then we overwite our current side with our other side
	storedinfo = storedinfo_otherside.Copy()
	timestamp = timestamp_otherside.Copy()
	used_capacity = used_capacity_otherside
	//then we overwrite our other side with the saved side
	storedinfo_otherside = storedinfo_currentside.Copy()
	timestamp_otherside = timestamp_currentside.Copy()
	used_capacity_otherside = used_capacity_currentside

	if(icon_state == initial_icon_state)
		icon_state = "[initial_icon_state]_reverse"
	else if(icon_state == "[initial_icon_state]_reverse") //so flipping doesn't overwrite an unexpected icon_state (e.g. an admin's)
		icon_state = initial_icon_state

/obj/item/tape/screwdriver_act(mob/living/user, obj/item/tool)
	if(!unspooled)
		return FALSE
	to_chat(user, span_notice("You start winding the tape back in..."))
	if(tool.use_tool(src, user, 120))
		to_chat(user, span_notice("You wind the tape back in."))
		respool()

//Random colour tapes
/obj/item/tape/random
	icon_state = "random_tape"

/obj/item/tape/random/Initialize(mapload)
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple", "greyscale")]"
	. = ..()

/obj/item/tape/dyed
	icon_state = "greyscale"

/obj/item/tape/rats
	storedinfo = list(
		"\[00:01\] This place is a mess, how do people live here?",
		"\[00:04\] It's like this station hasn't been serviced in decades.",
		"\[00:07\] Atleast the people here are kind, except for Ann. The wench. |+I CAN HEAR YOU IN THERE!+|",
		"\[00:08\] +PISS OFF, ANN!+",
		"\[00:42\] |I'll finish this tomorrow.|",
		"\[00:50\] How are there |rats| on a space station this far out? This has to be some kind of scientific wonder.",
		"\[01:00\] |Tom? Would you mind helping me with something in the botanical lab?|",
		"\[01:05\] Yeah, yeah.",
		"\[01:10\] Mary, the station's botanist, is a loon. She \"took care\" of a rat with a |monkey wrench|, who does that?!",
		"\[01:19\] The squeaking outside my room is driving me mad. I may ask Mary for some help with this.",
		"\[01:29\] *Airlock opening*",
		"\[01:33\] Mary? What ar-",
		"\[01:35\] *|CLANG!|*",
		"\[01:37\] *|CLANG!|*",
		"\[01:39\] *|CLANG!|*",
		"\[01:47\] *Feminine panting*",
		"\[01:59\] Mary Ann.",
	)

	timestamp = list(
		1 SECONDS,
		4 SECONDS,
		7 SECONDS,
		8 SECONDS,
		42 SECONDS,
		50 SECONDS,
		1 MINUTES,
		1 MINUTES + 5 SECONDS,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 19 SECONDS,
		1 MINUTES + 29 SECONDS,
		1 MINUTES + 33 SECONDS,
		1 MINUTES + 35 SECONDS,
		1 MINUTES + 37 SECONDS,
		1 MINUTES + 39 SECONDS,
		1 MINUTES + 47 SECONDS,
		1 MINUTES + 59 SECONDS,
	)

// SCP Tapes - Misc

/obj/item/tape/birthday_party
	name = "tape (Birthday Party)"
	desc = "A tape labeled 'Birthday Party'."
	icon_state = "tape_yellow"
	storedinfo = list(
		"\[00:01\] (Sound of balloons being inflated and party music playing softly)",
		"\[00:15\] Mother: Happy birthday, sweetie! Look at all the decorations!",
		"\[00:30\] Child: Mommy, when are my friends coming?",
		"\[00:45\] Mother: They're just running a little late, darling. They'll be here any minute.",
		"\[01:00\] (A long silence, only the faint party music and the mother's nervous humming can be heard.)",
		"\[01:45\] Mother: (Voice strained, almost a whisper) Any minute now... they just hit traffic, that's all.",
		"\[02:30\] Child: (Small, sad voice) But the cake is getting warm.",
		"\[02:45\] Mother: We can put it back in the fridge, sweetie. They'll be here. They promised.",
		"\[03:30\] (Sound of a door creaking open and then closing. A child's faint whimper.)",
		"\[03:45\] Mother: (Sighs, then a forced cheerfulness) Well, more cake for us, right?",
		"\[04:10\] (The audio captures the silence of an empty room, with only the faint rustling of deflated balloons. A single party hat is heard falling to the floor.)",
		"\[04:20\] (A faint, almost imperceptible scratching sound is picked up by the recorder.)"
	)
	timestamp = list(
		1 SECONDS,
		15 SECONDS,
		30 SECONDS,
		45 SECONDS,
		1 MINUTES,
		1 MINUTES + 45 SECONDS,
		2 MINUTES + 30 SECONDS,
		2 MINUTES + 45 SECONDS,
		3 MINUTES + 30 SECONDS,
		3 MINUTES + 45 SECONDS,
		4 MINUTES + 10 SECONDS,
		4 MINUTES + 20 SECONDS
	)

/obj/item/tape/therapy_session
	name = "tape (Therapy Session)"
	desc = "A dust covered recording with the label 'Session-2: Allie'."
	icon_state = "tape_greyscale"
	storedinfo = list(
		"\[00:05\] Patient: I feel like my real mother is calling to me from the woods. It's not my mom, not the one I live with.",
		"\[00:20\] Therapist: Can you elaborate on that feeling? What does this 'real mother' sound like?",
		"\[00:40\] Patient: It's a song... a lullaby. It's so clear when I'm alone. It tells me to come home.",
		"\[01:00\] Therapist: (Clears throat, shuffles papers) And how does this make you feel? Frightened? Comforted?",
		"\[01:15\] Patient: Both. It's... compelling. Like I have to go.",
		"\[01:30\] Patient: (Begins humming a strange, melodic tune, eyes unfocused, swaying slightly)",
		"\[01:45\] Therapist: (Silence, shifting uncomfortably in chair. A faint rustling sound from outside the window.)",
		"\[02:10\] Patient: (Singing in an unknown, lullaby-like language, growing louder and more insistent)",
		"\[02:30\] Therapist: (Voice barely audible) I think we should perhaps... reschedule.",
		"\[02:45\] Patient: (Stops singing abruptly) She's here.",
		"\[02:50\] (A loud thud from outside the room. The singing resumes, now accompanied by a low, guttural growl.)",
		"\[03:10\] (The recording device falls, making a loud clunk. The singing and growling continue, fading slowly as if moving away.)"
	)
	timestamp = list(
		5 SECONDS,
		20 SECONDS,
		40 SECONDS,
		1 MINUTES,
		1 MINUTES + 15 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 45 SECONDS,
		2 MINUTES + 10 SECONDS,
		2 MINUTES + 30 SECONDS,
		2 MINUTES + 45 SECONDS,
		2 MINUTES + 50 SECONDS,
		3 MINUTES + 10 SECONDS
	)

/obj/item/tape/cheese_dance_97
	name = "tape (Cheese Dance '97)"
	desc = "A recording of a very enthusiastic talent show performance."
	icon_state = "tape_red"
	storedinfo = list(
		"\[00:02\] (Polka music begins to play. Something stumbles across what sounds like a small stage—soft thud, then shuffle of feet.)",
		"\[00:10\] (Uncoordinated movements can be heard—fabric rustling, limbs flailing. A few polite claps and scattered laughter from the audience.)",
		"\[00:30\] (Audience cheers swell unnaturally loud, building into a near roar. Chairs scrape and thump as people rise and move in unison.)",
		"\[00:50\] (The cheering synchronizes into a rhythmic chant: 'Cheese! Cheese! Cheese!')",
		"\[01:15\] (The music cuts out abruptly. The chant continues undisturbed, echoing in the sudden silence. Someone breathes shakily.)",
		"\[01:30\] (A soft, frightened whimper is heard, muffled slightly. The audience continues chanting for several seconds before quieting.)",
		"\[01:45\] (A slow, deliberate clap begins—rhythmic, too close to the mic. Nothing else moves.)",
		"\[01:50\] (The mic rattles slightly, possibly brushed or bumped. The single clap continues, echoing in the silence. Recording ends.)"
	)
	timestamp = list(
		2 SECONDS,
		10 SECONDS,
		30 SECONDS,
		50 SECONDS,
		1 MINUTES + 15 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 45 SECONDS,
		1 MINUTES + 50 SECONDS
	)

/obj/item/tape/fish_funeral
	name = "tape (Fish Funeral)"
	desc = "A solemn home video of a goldfish funeral."
	icon_state = "tape_blue"
	storedinfo = list(
		"\[00:03\] Man: We are gathered here today to mourn the loss of Goldie, a truly magnificent aquatic companion.",
		"\[00:15\] Child: (Playing 'Ave Maria' on a recorder, off-key, but with great solemnity)",
		"\[00:30\] Woman: Goldie brought us so much joy in his short, vibrant life. He will be deeply missed.",
		"\[00:45\] (Sound of dirt being shoveled onto a small cardboard casket. The child sniffles loudly.)",
		"\[01:00\] Child: Goodbye, Goldie. You were the best fish ever. (A tear rolls down the child's cheek.)",
		"\[01:10\] Man: Rest in peace, little guy. You're swimming with the angels now.",
		"\[01:15\] (A zoom is heard as a camera moves. A distinct flopping sound is heard from within the box of cardboard.)",
		"\[01:20\] Woman: Did you hear that?",
		"\[01:25\] Child: (Gasps) Goldie!",
		"\[01:30\] (The fish is audibly flopping inside the box, pushing against the cardboard. The dirt on top shifts noisily.)",
		"\[01:35\] Man: (Stammering) W-what in the...?",
		"\[01:40\] (The flopping intensifies, the box begins to vibrate. A faint, wet gurgling sound.)",
		"\[01:45\] (The recorder drops, hearing only faint sounds of flopping and gurgling continue, growing louder.)"
	)
	timestamp = list(
		3 SECONDS,
		15 SECONDS,
		30 SECONDS,
		45 SECONDS,
		1 MINUTES,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 15 SECONDS,
		1 MINUTES + 20 SECONDS,
		1 MINUTES + 25 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 35 SECONDS,
		1 MINUTES + 40 SECONDS,
		1 MINUTES + 45 SECONDS
	)

/obj/item/tape/cereal_argument
	name = "tape (Cereal Argument)"
	desc = "A breakfast argument, focused on a cereal box."
	icon_state = "tape_purple"
	storedinfo = list(
		"\[00:01\] Father: I told you, that was the last box! You know I like to have my cereal in the morning!",
		"\[00:05\] Mother: Well, I didn't see your name on it! And I was hungry!",
		"\[00:10\] Child (whispering): I drew a picture of Mommy on the cereal box...",
		"\[00:20\] Father: We agreed! One box each for the week! This is ridiculous!",
		"\[00:30\] Mother: (Scoffs) You always do this! You're so selfish!",
		"\[00:40\] (A faint, almost imperceptible whisper is picked up in the background. The mic hisses slightly.)",
		"\[00:45\] Child: (Whispering) Mommy Two says you're mean, Daddy.",
		"\[00:50\] Father: (Confused) What was that, sweetie? Who said that?",
		"\[01:00\] Mother: (Hushed) Did... did you hear that?",
		"\[01:10\] (The whispering grows louder—soft, lilting, unintelligible. Something shifts with a papery rasp.)",
		"\[01:20\] Father: (Voice trembling) This isn't funny Melany!.",
		"\[01:30\] (There’s a subtle vibration—cardboard scraping on wood, picked up by the mic.)",
		"\[01:40\] (A high-pitched giggle breaks through the background noise. Tape crackles faintly.)",
		"\[01:45\] (A sudden thud—possibly the recorder falling. Giggling intensifies, followed by a loud, wet crunching sound.)"
	)
	timestamp = list(
		1 SECONDS,
		5 SECONDS,
		10 SECONDS,
		20 SECONDS,
		30 SECONDS,
		40 SECONDS,
		45 SECONDS,
		50 SECONDS,
		1 MINUTES,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 20 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 40 SECONDS,
		1 MINUTES + 45 SECONDS
	)

/obj/item/tape/moms_furniture
	name = "tape (Mom's Furniture Ad)"
	desc = "A surreal local furniture ad."
	icon_state = "tape_white"
	storedinfo = list(
		"\[00:01\] (Upbeat, slightly off-key jingle begins, with a cheerful acoustic guitar and tambourine.)",
		"\[00:05\] Singer: If it rocks, it's from Mom's! Your one-stop shop for comfort and style!",
		"\[00:10\] (Light instrumental continues with friendly background chatter and the faint squeak of a rocking chair.)",
		"\[00:20\] Singer: Quality you can trust, prices you'll love! We've got sofas, tables, and beds galore!",
		"\[00:30\] (A gentle breeze can be heard through open windows. A clock chimes in the distance.)",
		"\[00:40\] Singer: If it rocks, it's from Mom's! (Jingle repeats joyfully.)",
		"\[00:50\] (The sound of laughter, kids playing in the background. Someone softly hums along to the tune.)",
		"\[01:00\] Singer: From Mom's — where your home feels like home!",
		"\[01:10\] (The jingle finishes with a cheerful little flourish. Faint sound of a bell ringing as a door opens.)",
		"\[01:20\] (Friendly voiceover: 'Located just off Route 9. Open 7 days a week!')",
		"\[01:30\] (Fade out with gentle acoustic strumming and one final squeak from a rocking chair.)"
	)
	timestamp = list(
		1 SECONDS,
		5 SECONDS,
		10 SECONDS,
		20 SECONDS,
		30 SECONDS,
		40 SECONDS,
		50 SECONDS,
		1 MINUTES,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 20 SECONDS,
		1 MINUTES + 30 SECONDS
	)

// SCP Tapes - Research

/obj/item/tape/scp_test_001
	name = "tape (SCP Test 001)"
	desc = "A lost SCP test recording, designated 001."
	icon_state = "tape_greyscale"
	storedinfo = list(
		"\[00:01\] Dr. \[REDACTED\]: Test log 001. Subject D-5432 exposed to SCP-███ within containment chamber 7.",
		"\[00:10\] (Sound of a low, resonant hum, growing steadily in intensity. Subject shifts nervously.)",
		"\[00:25\] D-5432: What is that noise? It's... beautiful. Like a choir, but not.",
		"\[00:40\] Dr. \[REDACTED\]: D-5432, report your current state. Any anomalous sensations?",
		"\[00:55\] D-5432: (Giggles uncontrollably, voice unsteady) I can hear the colors! All the colors! They're singing!",
		"\[01:10\] (Humming intensifies, becoming almost painful. Subject begins to twitch. A high-pitched whine overlays the hum.)",
		"\[01:25\] Dr. \[REDACTED\]: Subject is exhibiting signs of extreme euphoria and sensory overload. Recommend immediate termination of exposure.",
		"\[01:40\] (The whine becomes a piercing shriek. Subject collapses, convulsing. The hum reaches a crescendo.)",
		"\[01:50\] (Abrupt silence. Then, a faint, rhythmic clicking sound. Static.)"
	)
	timestamp = list(
		1 SECONDS,
		10 SECONDS,
		25 SECONDS,
		40 SECONDS,
		55 SECONDS,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 25 SECONDS,
		1 MINUTES + 40 SECONDS,
		1 MINUTES + 50 SECONDS
	)

/obj/item/tape/scp_test_002
	name = "tape (SCP Test 002)"
	desc = "A lost SCP test recording, designated 002."
	icon_state = "tape_greyscale"
	storedinfo = list(
		"\[00:01\] Researcher: Test log 002. Observation of SCP-███'s interaction with organic matter. Initiating exposure with porcine tissue sample.",
		"\[00:15\] (Sound of dripping, followed by a wet, tearing noise. Environmental sensors detect a faint, sickly sweet odor.)",
		"\[00:30\] Researcher: Fascinating. The tissue is being... reconfigured. Not consumed, but reshaped.",
		"\[00:45\] (A faint, rhythmic thumping begins, as if something is growing or pulsating.)",
		"\[01:00\] Researcher: It's forming a new structure. Unprecedented. Cellular integrity appears to be changing.",
		"\[01:15\] (Thumping grows louder, accompanied by squelching. Pulsations become more distinct.)",
		"\[01:30\] Researcher: (Voice strained, a hint of fear) It's... it's perceiving me. The structure has developed... sensory awareness.",
		"\[01:40\] (A guttural, wet gasp from the researcher. The thumping becomes frantic.)",
		"\[01:45\] (Sound of a chair scraping, a struggle. Loud, wet tearing followed by a choked scream.)",
		"\[01:50\] (Silence, aside from the persistent thumping and a faint, wet slurping sound. Audio ends abruptly.)"
	)
	timestamp = list(
		1 SECONDS,
		15 SECONDS,
		30 SECONDS,
		45 SECONDS,
		1 MINUTES,
		1 MINUTES + 15 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 40 SECONDS,
		1 MINUTES + 45 SECONDS,
		1 MINUTES + 50 SECONDS
	)

/obj/item/tape/scp_test_003
	name = "tape (SCP Test 003)"
	desc = "A lost SCP test recording, designated 003."
	icon_state = "tape_greyscale"
	storedinfo = list(
		"\[00:01\] Agent \[REDACTED\]: Field recording, SCP-███ containment breach. We're in Sector C, attempting to re-establish perimeter.",
		"\[00:10\] (Intense gunfire and shouting in the background. Explosions shake the area.)",
		"\[00:25\] Agent \[REDACTED\]: We've lost visual on the anomaly! It's too fast! It just phased through the wall!",
		"\[00:40\] (Sound of heavy metal tearing, followed by a distorted, high-pitched roar that seems to vibrate the air.)",
		"\[00:55\] Agent \[REDACTED\]: Fall back! Fall back! It's adapting! It's learning our movements!",
		"\[01:10\] (More frantic gunfire, then a series of wet, sickening impacts. A gurgling sound, then a scream cut short.)",
		"\[01:20\] (Heavy, ragged breathing from Agent \[REDACTED\]. A faint, almost melodic hum begins to emanate from the darkness.)",
		"\[01:25\] Agent \[REDACTED\]: (Whispering, terrified) It knows... it knows where we are. It's playing with us.",
		"\[01:30\] (The humming grows louder, accompanied by a soft, rhythmic tapping. A final, wet crunch, impossibly close to the microphone.)",
		"\[01:35\] (Silence, then a faint, satisfied sigh. Tape cuts out.)"
	)
	timestamp = list(
		1 SECONDS,
		10 SECONDS,
		25 SECONDS,
		40 SECONDS,
		55 SECONDS,
		1 MINUTES + 10 SECONDS,
		1 MINUTES + 20 SECONDS,
		1 MINUTES + 25 SECONDS,
		1 MINUTES + 30 SECONDS,
		1 MINUTES + 35 SECONDS
	)
