#include "../../world.dm" // For SSticker.round_id

/obj/structure/scp216
	name = "safe"
	desc = "A metalic safe with multiple-dial combination lock."
	icon = 'icons/obj/structures.dmi'

	icon_state = "safe"
	anchored = TRUE
	density = TRUE

	//Config

	///Max items 216 can contain
	var/max_items = 10
	///Chance that items are generated for a code
	var/generate_chance = 75
	///Max amount of items that can be generated for a code
	var/max_items_generated = 9
	///Number of rounds items persist in the safe
	var/rounds_to_persist = 5

	//Mechanics

	///Are we open?
	var/open = FALSE
	///Our currrent code.
	var/current_code = 0
	/// Assoc list of codes in use and items stored in them.
	var/list/all_codes = list() // list(code = list(datum/scp216_stored_item))

	/* Note: If editing, please keep the descending order by groups. More common items should be at the top. */
	// Unsorted
	// Medicine
	// Medical/Surgery tools
	// Tools
	// Power cells
	// Hats
	// Helmets
	// Clothing
	// Armor
	// Melee weapons
	// Ranged weapons
	// Antagonist stuff
	// SCP objects
	// Mobs
	/* TODO: Fix indendation check false-alarming at comments inside lists so we can put these in there */

	/// Weight list of potential atoms that can be generated inside on spawn. Path = Chance.
	var/list/random_items = list(
		/obj/item/a_gift = 600,
		/obj/item/bikehorn = 400,
		/obj/item/bikehorn/airhorn = 300,
		/obj/item/toy/plush/beeplushie = 250,
		/obj/item/instrument/guitar = 80,
		/obj/item/paper/fluff/jobs/cargo/manifest = 100,
		/obj/item/implanter/emp = 50,
		/obj/item/gps = 100,
		/obj/item/tape/birthday_party = 100,
		/obj/item/tape/therapy_session = 80,
		/obj/item/tape/cheese_dance_97 = 15,
		/obj/item/tape/fish_funeral = 40,
		/obj/item/tape/cereal_argument = 70,
		/obj/item/tape/moms_furniture = 60,
		/obj/item/tape/scp_test_001 = 20,
		/obj/item/tape/scp_test_002 = 15,
		/obj/item/tape/scp_test_003 = 10,
//		/obj/item/boombox = 300,
		/obj/item/a_gift/anything = 30,
		/obj/item/circular_saw = 500,
		/obj/item/crowbar = 500,
		/obj/item/multitool = 450,
		/obj/item/crowbar/brace_jack = 300,
		/obj/item/multitool/circuit = 250,
		/obj/item/stock_parts/cell/high = 500,
		/obj/item/stock_parts/cell/super = 450,
		/obj/item/stock_parts/cell/hyper = 400,
		/obj/item/stock_parts/cell/infinite = 5,
		/obj/item/clothing/head/beret = 500,
		/obj/item/clothing/head/bearpelt = 500,
//		/obj/item/clothing/head/beret/sec/corporate/officer = 450,
//		/obj/item/clothing/head/beret/sec/corporate/hos = 400,
//		/obj/item/clothing/head/beret/scp/goc = 300,
		/obj/item/clothing/head/helmet = 500,
//		/obj/item/clothing/head/helmet/ballistic = 500,
		/obj/item/clothing/head/helmet/riot = 500,
		/obj/item/clothing/head/bomb_hood/security = 400,
//		/obj/item/clothing/head/helmet/merc = 300,
		/obj/item/clothing/head/helmet/swat = 250,
		/obj/item/clothing/under/pants/black = 400,
//		/obj/item/clothing/under/rank/guard = 400,
//		/obj/item/clothing/under/rank/ntwork = 400,
//		/obj/item/clothing/under/rank/guard/nanotrasen = 400,
//		/obj/item/clothing/under/rank/ntwork/nanotrasen = 400,
//		/obj/item/clothing/under/suit_jacket/corp/nanotrasen = 400,
//		/obj/item/clothing/under/rank/guard/heph = 400,
//		/obj/item/clothing/under/rank/scientist/zeng = 400,
//		/obj/item/clothing/under/rank/scientist/executive/zeng = 400,
		/obj/item/clothing/under/pants/classicjeans = 400,
		/obj/item/clothing/under/pants/blackjeans = 400,
		/obj/item/clothing/under/pants/jeans = 400,
		/obj/item/clothing/under/pants/youngfolksjeans = 400,
//		/obj/item/clothing/under/casual_pants/baggy/track = 400,
		/obj/item/clothing/under/pants/camo = 350,
//		/obj/item/clothing/under/rank/security = 300,
//		/obj/item/clothing/under/rank/dispatch = 300,
//		/obj/item/clothing/under/rank/warden = 250,
//		/obj/item/clothing/under/rank/warden/corp = 250,
		/obj/item/clothing/under/syndicate = 100,
		/obj/item/clothing/under/syndicate/combat = 100,
//		/obj/item/clothing/under/syndicate/terragov = 100,
		/obj/item/clothing/suit/armor = 500,
//		/obj/item/clothing/suit/armor/pcarrier/medium = 500,
		/obj/item/clothing/suit/armor/riot = 450,
		/obj/item/clothing/suit/armor/bulletproof = 450,
		/obj/item/clothing/suit/armor/laserproof = 450,
		/obj/item/clothing/suit/armor/vest/warden = 450,
//		/obj/item/clothing/suit/armor/swat/officer = 400,
//		/obj/item/clothing/suit/armor/vest/ert = 300,
//		/obj/item/clothing/suit/armor/vest/ert/security = 300,
//		/obj/item/clothing/suit/storage/vest/tactical = 250,
//		/obj/item/clothing/suit/storage/vest/merc = 250,
//		/obj/item/clothing/suit/armor/pcarrier/tan/tactical = 250,
//		/obj/item/excalibur = 20,
//		/obj/item/gun/projectile/pistol = 80,
//		/obj/item/gun/projectile/pistol/military = 60,
//		/obj/item/gun/projectile/automatic = 30,
//		/obj/item/gun/projectile/heavysniper = 5,
		/obj/item/market_uplink = 60,
		/obj/item/multitool/uplink = 60,
		/obj/item/soulstone = 50,
		/obj/item/chameleon = 30,
		/obj/item/assembly/flash/handheld = 20,
//		/obj/item/reagent_containers/pill/scp500 = 10,
//		/obj/item/storage/pill_bottle/scp500 = 1,
		/mob/living/simple_animal/mouse/white = 150,
		/mob/living/simple_animal/pet/dog/corgi = 100,
		/mob/living/simple_animal/slime = 80,
		/mob/living/simple_animal/hostile/carp = 50,
		/mob/living/simple_animal/hostile/asteroid/wolf = 40,
		/mob/living/simple_animal/hostile/asteroid/polarbear
		)

/datum/scp216_stored_item
	var/atom/movable/item
	var/db_id

/obj/structure/scp216/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"safe", //Name
		SCP_SAFE, //Obj Class
		"216", //Numerical Designation
	)

	// Load items from the database
	var/DBQuery/query = SSsql.NewQuery("SELECT id, code, item_path FROM scp216_items WHERE rounds_remaining > 0")
	if(query.Execute())
		while(query.NextRow())
			var/db_id = query.GetRowAssoc()["id"]
			var/code = query.GetRowAssoc()["code"]
			var/item_path = text2path(query.GetRowAssoc()["item_path"])
			if(item_path)
				var/atom/movable/A = new item_path(src)
				if(A)
					var/datum/scp216_stored_item/stored_item = new
					stored_item.item = A
					stored_item.db_id = db_id
					if(!(code in all_codes))
						all_codes[code] = list()
					all_codes[code] += stored_item
	else
		message_admins(span_warning("Failed to load SCP-216 items from database: [query.Error()]"))

/obj/structure/scp216/Destroy()
	LAZYCLEARLIST(all_codes) // Forever gone
	return ..()

/obj/structure/scp216/update_icon()
	..()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/structure/scp216/attackby(obj/item/I, mob/user)
	if(!open)
		return ..()
	InsertItem(user, I, current_code)

/obj/structure/scp216/attack_hand(mob/user)
	if(!user.stat == CONSCIOUS)
		to_chat(user, span_warning("You cannot use the safe while unconscious!"))
		return
	var/text_code = add_leading(num2text(current_code, 7), 7, "0")
	var/dat = "<center>"
	dat += "<a href='?src=\ref[src];open=1'>[open ? "Close" : "Open"] [src]</a><br>"
	dat += "Current code: <a href='?src=\ref[src];change_code=1'>[text_code]</a><br>"
	if(open && (num2text(current_code, 7) in all_codes))
		dat += "<table>"
		for(var/datum/scp216_stored_item/stored_item in all_codes[num2text(current_code, 7)])
			if(!ismob(stored_item.item)) // Don't add mobs to the UI list
				dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[stored_item.item]'>[stored_item.item.name]</a></td></tr>"
		dat += "</table></center>"
	var/datum/browser/popup = new(user, "safe", "Safe", 350, 300)
	popup.set_content(dat)
	popup.open()

/obj/structure/scp216/Topic(href, href_list)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr

	if(href_list["open"])
		to_chat(user, span_notice("You [open ? "close" : "open"] [src]."))
		open = !open
		update_icon()
		// JUMPSCARE!!
		if(open && (num2text(current_code, 7) in all_codes))
			for(var/mob/living/L in all_codes[num2text(current_code, 7)])
				L.forceMove(get_turf(src))
				visible_message(span_danger("[L] falls out of \the [src]!"))
		attack_hand(user)
		return

	if(href_list["change_code"])
		if(open)
			to_chat(user, span_warning("You have to close the safe before changing the code!"))
			return
		var/temp_code = text2num(input(user, "Enter the new code.", "SCP 216") as null|text)
		if(!isnum(temp_code))
			to_chat(user, span_warning("Input a number!"))
			return
		if(temp_code > 9999999)
			to_chat(user, span_warning("The code can be no longer than 7 numbers!"))
			return
		if(temp_code < 0)
			to_chat(user, span_warning("The code can't be lower than zero!"))
			return
		current_code = temp_code
		if(!(num2text(current_code, 7) in all_codes))
			GenerateRandomItemsAt(current_code)
		attack_hand(user)
		return

	if(href_list["retrieve"])
		var/atom/movable/A = locate(href_list["retrieve"])
		var/datum/scp216_stored_item/found_stored_item
		for(var/datum/scp216_stored_item/stored_item in all_codes[num2text(current_code, 7)])
			if(stored_item.item == A)
				found_stored_item = stored_item
				break
		if(!found_stored_item)
			to_chat(user, span_warning("Couldn't find the item."))
			return
		if(!open)
			return
		if(!in_range(src, user))
			return
		RetrieveItem(user, found_stored_item, current_code)

/obj/structure/scp216/proc/GenerateRandomItemsAt(code)
	if(!(num2text(code, 7) in all_codes) || !islist(all_codes[num2text(code, 7)]))
		all_codes[num2text(code, 7)] = list()
	if(!(prob(generate_chance)))
		return
	for(var/i = 1 to rand(1, max_items_generated))
		var/chosen_atom = pick_weight(random_items)
		all_codes[num2text(code, 7)] += new chosen_atom(src)

/obj/structure/scp216/proc/InsertItem(mob/living/carbon/human/user, atom/movable/A, code_loc = 0)
	if(!(num2text(code_loc, 7) in all_codes) || !islist(all_codes[num2text(code_loc, 7)]))
		all_codes[num2text(code_loc, 7)] = list()
	if(length(all_codes[num2text(code_loc, 7)]) >= max_items)
		to_chat(user, span_warning("There is already too many things in there!"))
		return
	if(!user.transferItemToLoc(A, src))
		return

	// Insert into database
	var/DBQuery/query = SSsql.NewQuery("INSERT INTO scp216_items (code, item_path, round_id, rounds_remaining, timestamp) VALUES (:code, :item_path, :round_id, :rounds_remaining, NOW())")
	query.AddParameter("code", num2text(code_loc, 7))
	query.AddParameter("item_path", A.type)
	query.AddParameter("round_id", SSticker.round_id)
	query.AddParameter("rounds_remaining", rounds_to_persist)
	if(!query.Execute())
		CRASH("Failed to insert SCP-216 item into database: [query.Error()]")
	else
		var/datum/scp216_stored_item/stored_item = new
		stored_item.item = A
		stored_item.db_id = query.GetLastInsertId() // Get the new database ID
		all_codes[num2text(code_loc, 7)] += stored_item

	attack_hand(user)

/obj/structure/scp216/proc/RetrieveItem(mob/living/carbon/human/user, datum/scp216_stored_item/stored_item, code_loc = 0)
	if(!stored_item || !stored_item.item || !(stored_item in all_codes[num2text(code_loc, 7)]))
		return
	all_codes[num2text(code_loc, 7)] -= stored_item

	// Delete from database
	if(stored_item.db_id)
		var/DBQuery/query = SSsql.NewQuery("DELETE FROM scp216_items WHERE id = :id")
		query.AddParameter("id", stored_item.db_id)
		if(!query.Execute())
			CRASH("Failed to delete SCP-216 item from database: [query.Error()]")
		stored_item.db_id = null // Clear the database ID

	if(isitem(stored_item.item))
		user.put_in_hands(stored_item.item)
	else // In case we want to get funky and put mobs into it
		stored_item.item.forceMove(get_turf(src))
	qdel(stored_item) // Delete the datum
	attack_hand(user)
