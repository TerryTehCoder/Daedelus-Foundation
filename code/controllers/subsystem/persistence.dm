#define FILE_RECENT_MAPS "data/RecentMaps.json"

#define KEEP_ROUNDS_MAP 3
#define FILE_SCP216_DISPLACED_ITEMS "data/scp216_displaced_items.json"

#define MAX_AIC_KEYS 3 // Configurable cap for AIC keys per ckey

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///instantiated wall engraving components
	var/list/wall_engravings = list()
	var/list/saved_messages = list()
	var/list/saved_modes = list(1,2,3)
	var/list/saved_maps = list()
	var/list/saved_trophies = list()
	var/list/picture_logging_information = list()
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums
	/// Temporally displaced items from SCP-216
	var/list/displaced_scp216_items = list()
	/// AIC Key hashes
	var/list/aic_keys = list()


/datum/controller/subsystem/persistence/Initialize()
	LoadPoly()
	load_wall_engravings()
	LoadTrophies()
	LoadRecentMaps()
	LoadPhotoPersistence()
	LoadRandomizedRecipes()
	load_custom_outfits()
	LoadDisplacedSCP216Items()
	LoadAICKeys()

	load_adventures()
	return ..()

/datum/controller/subsystem/persistence/proc/collect_data()
	save_wall_engravings()
	CollectTrophies()
	CollectMaps()
	SavePhotoPersistence() //THIS IS PERSISTENCE, NOT THE LOGGING PORTION.
	SaveRandomizedRecipes()
	save_custom_outfits()
	SaveDisplacedSCP216Items()
	SaveAICKeys()

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/poly/P in GLOB.alive_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/load_wall_engravings()
	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < ENGRAVING_PERSISTENCE_VERSION)
		update_wall_engravings(json)

	var/successfully_loaded_engravings = 0

	var/list/viable_turfs = get_area_turfs(/area/station/maintenance, subtypes = TRUE) + get_area_turfs(/area/station/security/prison, subtypes = TRUE)
	var/list/turfs_to_pick_from = list()

	for(var/turf/T as anything in viable_turfs)
		if(!isclosedturf(T))
			continue
		turfs_to_pick_from += T

	var/list/engraving_entries = json["entries"]

	if(engraving_entries.len)
		for(var/iteration in 1 to rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS))
			var/engraving = engraving_entries[rand(1, engraving_entries.len)] //This means repeats will happen for now, but its something I can live with. Just make more engravings!
			if(!islist(engraving))
				stack_trace("something's wrong with the engraving data! one of the saved engravings wasn't a list!")
				continue

			var/turf/closed/engraved_wall = pick(turfs_to_pick_from)

			if(HAS_TRAIT(engraved_wall, TRAIT_NOT_ENGRAVABLE))
				continue

			engraved_wall.AddComponent(/datum/component/engraved, engraving["story"], FALSE, engraving["story_value"])
			successfully_loaded_engravings++
			turfs_to_pick_from -= engraved_wall

	log_world("Loaded [successfully_loaded_engravings] engraved messages on map [SSmapping.config.map_name]")

/datum/controller/subsystem/persistence/proc/save_wall_engravings()
	var/list/saved_data = list()

	saved_data["version"] = ENGRAVING_PERSISTENCE_VERSION
	saved_data["entries"] = list()


	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			saved_data["entries"] = old_json["entries"]

	for(var/datum/component/engraved/engraving in wall_engravings)
		if(!engraving.persistent_save)
			continue
		var/area/engraved_area = get_area(engraving.parent)
		if(!(engraved_area.area_flags & PERSISTENT_ENGRAVINGS))
			continue
		saved_data["entries"] += engraving.save_persistent()

	fdel(json_file)

	WRITE_FILE(json_file, json_encode(saved_data))

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_wall_engravings(json)


	for(var/engraving_entry in json["entries"])
		continue //no versioning yet

	//Save it to the file
	var/json_file = file(ENGRAVING_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json

/datum/controller/subsystem/persistence/proc/LoadTrophies()
	if(fexists("data/npc_saves/TrophyItems.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/TrophyItems.sav")
		var/saved_json
		S >> saved_json
		if(!saved_json)
			return
		saved_trophies = json_decode(saved_json)
		fdel("data/npc_saves/TrophyItems.sav")
	else
		var/json_file = file("data/npc_saves/TrophyItems.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		if(!json)
			return
		saved_trophies = json["data"]
	SetUpTrophies(saved_trophies.Copy())

/datum/controller/subsystem/persistence/proc/LoadRecentMaps()
	var/map_sav = FILE_RECENT_MAPS
	if(!fexists(FILE_RECENT_MAPS))
		return
	var/list/json = json_decode(file2text(map_sav))
	if(!json)
		return
	saved_maps = json["data"]

/datum/controller/subsystem/persistence/proc/SetUpTrophies(list/trophy_items)
	for(var/A in GLOB.trophy_cases)
		var/obj/structure/displaycase/trophy/T = A
		if (T.showpiece)
			continue
		T.added_roundstart = TRUE

		var/trophy_data = pick_n_take(trophy_items)

		if(!islist(trophy_data))
			continue

		var/list/chosen_trophy = trophy_data

		if(!length(chosen_trophy)) //Malformed
			continue

		var/path = text2path(chosen_trophy["path"]) //If the item no longer exist, this returns null
		if(!path)
			continue

		T.showpiece = new /obj/item/showpiece_dummy(T, path)
		T.trophy_message = chosen_trophy["message"]
		T.placer_key = chosen_trophy["placer_key"]
		T.update_appearance()

/datum/controller/subsystem/persistence/proc/GetPhotoAlbums()
	var/album_path = file("data/photo_albums.json")
	if(fexists(album_path))
		return json_decode(file2text(album_path))

/datum/controller/subsystem/persistence/proc/GetPhotoFrames()
	var/frame_path = file("data/photo_frames.json")
	if(fexists(frame_path))
		return json_decode(file2text(frame_path))

/// Removes the identifier of a persitent photo frame from the json.
/datum/controller/subsystem/persistence/proc/RemovePhotoFrame(identifier)
	var/frame_path = file("data/photo_frames.json")
	if(!fexists(frame_path))
		return

	var/frame_json = json_decode(file2text(frame_path))
	frame_json -= identifier

	frame_json = json_encode(frame_json)
	fdel(frame_path)
	WRITE_FILE(frame_path, frame_json)

/datum/controller/subsystem/persistence/proc/LoadPhotoPersistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")
	if(fexists(album_path))
		var/list/json = json_decode(file2text(album_path))
		if(json.len)
			for(var/i in photo_albums)
				var/obj/item/storage/photo_album/A = i
				if(!A.persistence_id)
					continue
				if(json[A.persistence_id])
					A.populate_from_id_list(json[A.persistence_id])

	if(fexists(frame_path))
		var/list/json = json_decode(file2text(frame_path))
		if(json.len)
			for(var/i in photo_frames)
				var/obj/structure/sign/picture_frame/PF = i
				if(!PF.persistence_id)
					continue
				if(json[PF.persistence_id])
					PF.load_from_id(json[PF.persistence_id])

/datum/controller/subsystem/persistence/proc/SavePhotoPersistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")

	var/list/frame_json = list()
	var/list/album_json = list()

	if(fexists(album_path))
		album_json = json_decode(file2text(album_path))
		fdel(album_path)

	for(var/i in photo_albums)
		var/obj/item/storage/photo_album/A = i
		if(!istype(A) || !A.persistence_id)
			continue
		var/list/L = A.get_picture_id_list()
		album_json[A.persistence_id] = L

	album_json = json_encode(album_json)

	WRITE_FILE(album_path, album_json)

	if(fexists(frame_path))
		frame_json = json_decode(file2text(frame_path))
		fdel(frame_path)

	for(var/i in photo_frames)
		var/obj/structure/sign/picture_frame/F = i
		if(!istype(F) || !F.persistence_id)
			continue
		frame_json[F.persistence_id] = F.get_photo_id()

	frame_json = json_encode(frame_json)

	WRITE_FILE(frame_path, frame_json)

/datum/controller/subsystem/persistence/proc/CollectTrophies()
	var/json_file = file("data/npc_saves/TrophyItems.json")
	var/list/file_data = list()
	file_data["data"] = remove_duplicate_trophies(saved_trophies)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/remove_duplicate_trophies(list/trophies)
	var/list/ukeys = list()
	. = list()
	for(var/trophy in trophies)
		var/tkey = "[trophy["path"]]-[trophy["message"]]"
		if(ukeys[tkey])
			continue
		else
			. += list(trophy)
			ukeys[tkey] = TRUE

/datum/controller/subsystem/persistence/proc/SaveTrophy(obj/structure/displaycase/trophy/T)
	if(!T.added_roundstart && T.showpiece)
		var/list/data = list()
		data["path"] = T.showpiece.type
		data["message"] = T.trophy_message
		data["placer_key"] = T.placer_key
		saved_trophies += list(data)

/datum/controller/subsystem/persistence/proc/CollectMaps()
	if(length(saved_maps) > KEEP_ROUNDS_MAP) //Get rid of extras from old configs.
		saved_maps.Cut(KEEP_ROUNDS_MAP+1)
	var/mapstosave = min(length(saved_maps)+1, KEEP_ROUNDS_MAP)
	if(length(saved_maps) < mapstosave) //Add extras if too short, one per round.
		saved_maps += mapstosave
	for(var/i = mapstosave; i > 1; i--)
		saved_maps[i] = saved_maps[i-1]
	saved_maps[1] = SSmapping.config.map_name
	var/json_file = file(FILE_RECENT_MAPS)
	var/list/file_data = list()
	file_data["data"] = saved_maps
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/LoadRandomizedRecipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/json
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = new randomized_type
		var/loaded = FALSE
		if(R.persistent && json)
			var/list/recipe_data = json["[R.type]"]
			if(recipe_data)
				if(R.LoadOldRecipe(recipe_data) && (daysSince(R.created) <= R.persistence_period))
					loaded = TRUE
		if(!loaded) //We do not have information for whatever reason, just generate new one
			if(R.persistent)
				log_game("Resetting persistent [randomized_type] random recipe.")
			R.GenerateRecipe()

		if(!R.HasConflicts()) //Might want to try again if conflicts happened in the future.
			add_chemical_reaction(R)
		else
			log_game("Randomized recipe [randomized_type] resulted in conflicting recipes.")

/datum/controller/subsystem/persistence/proc/SaveRandomizedRecipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/list/file_data = list()

	//asert globchems done
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = get_chemical_reaction(randomized_type) //ew, would be nice to add some simple tracking
		if(R?.persistent)
			var/recipe_data = list()
			recipe_data["timestamp"] = R.created
			recipe_data["required_reagents"] = R.required_reagents
			recipe_data["required_catalysts"] = R.required_catalysts
			recipe_data["required_temp"] = R.required_temp
			recipe_data["is_cold_recipe"] = R.is_cold_recipe
			recipe_data["results"] = R.results
			recipe_data["required_container"] = "[R.required_container]"
			file_data["[R.type]"] = recipe_data

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/load_custom_outfits()
	var/file = file("data/custom_outfits.json")
	if(!fexists(file))
		return
	var/outfits_json = file2text(file)
	var/list/outfits = json_decode(outfits_json)
	if(!islist(outfits))
		return

	for(var/outfit_data in outfits)
		if(!islist(outfit_data))
			continue

		var/outfittype = text2path(outfit_data["outfit_type"])
		if(!ispath(outfittype, /datum/outfit))
			continue
		var/datum/outfit/outfit = new outfittype
		if(!outfit.load_from(outfit_data))
			continue
		GLOB.custom_outfits += outfit

/datum/controller/subsystem/persistence/proc/save_custom_outfits()
	var/file = file("data/custom_outfits.json")
	fdel(file)

	var/list/data = list()
	for(var/datum/outfit/outfit in GLOB.custom_outfits)
		data += list(outfit.get_json_data())

	WRITE_FILE(file, json_encode(data))

/datum/controller/subsystem/persistence/proc/LoadDisplacedSCP216Items()
	var/json_file = file(FILE_SCP216_DISPLACED_ITEMS)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return
	displaced_scp216_items = json["data"]

/datum/controller/subsystem/persistence/proc/SaveDisplacedSCP216Items()
	var/json_file = file(FILE_SCP216_DISPLACED_ITEMS)
	var/list/file_data = list()
	file_data["data"] = displaced_scp216_items
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/LoadAICKeys()
	var/json_file = file("data/aic_keys.json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	var/list/keys_by_ckey = list()

	for(var/key_data in json["data"])
		var/datum/aic_key_data/new_key = new
		if(new_key.load_from_json(key_data))
			if(!is_valid_aic_key_hash(new_key.key_hash))
				warning("Persistence: Loaded AIC key for ckey '[new_key.ckey]' has an invalid hash format: '[new_key.key_hash]'. Skipping.")
				qdel(new_key)
				continue

			if(!keys_by_ckey[new_key.ckey])
				keys_by_ckey[new_key.ckey] = list()
			keys_by_ckey[new_key.ckey] += new_key

	// Apply capping logic after all keys are loaded
	for(var/ckey in keys_by_ckey)
		var/list/player_keys = keys_by_ckey[ckey]
		sortTim(player_keys, GLOBAL_PROC_REF(global_sort_aic_key_data_by_timestamp)) // Sort by timestamp (oldest first)

		while((player_keys.len > MAX_AIC_KEYS))
			var/datum/aic_key_data/oldest_key = player_keys[1]
			warning("Persistence: Capping AIC keys for ckey '[oldest_key.ckey]'. Deleting oldest key: '[oldest_key.key_hash]'.")
			player_keys.Remove(oldest_key)
			qdel(oldest_key)

		aic_keys += player_keys // Add the capped list of keys to the main aic_keys list

/datum/controller/subsystem/persistence/proc/SaveAICKeys()
	var/json_file = file("data/aic_keys.json")
	var/list/file_data = list()
	file_data["data"] = list()

	var/list/keys_by_ckey = list()
	for(var/datum/aic_key_data/key in aic_keys)
		if(!keys_by_ckey[key.ckey])
			keys_by_ckey[key.ckey] = list()
		keys_by_ckey[key.ckey] += key

	// Apply capping logic before saving
	for(var/ckey in keys_by_ckey)
		var/list/player_keys = keys_by_ckey[ckey]
		sortTim(player_keys, GLOBAL_PROC_REF(global_sort_aic_key_data_by_timestamp)) // Sort by timestamp (oldest first)

		while((player_keys.len > MAX_AIC_KEYS))
			var/datum/aic_key_data/oldest_key = player_keys[1]
			warning("Persistence: Capping AIC keys for ckey '[oldest_key.ckey]' before saving. Deleting oldest key: '[oldest_key.key_hash]'.")
			player_keys.Remove(oldest_key)
			qdel(oldest_key)

		for(var/datum/aic_key_data/key in player_keys)
			file_data["data"] += key.save_to_json()

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

// I hate this so much, but I can't get Regex to work in the way I want it to.
/datum/controller/subsystem/persistence/proc/is_valid_aic_key_hash(key_hash)
	if(!istext(key_hash))
		return FALSE

	var/list/parts = splittext(key_hash, "-")
	if(parts.len != 4)
		return FALSE

	if(parts[1] != "AIC")
		return FALSE

	// Part 2: 4 alphanumeric characters (0-9, A-Z)
	var/part2 = parts[2]
	if(length(part2) != 4)
		return FALSE
	for(var/i = 1, i <= length(part2), i++)
		var/char = copytext(part2, i, i + 1)
		if(!((char >= "0" && char <= "9") || (char >= "A" && char <= "Z")))
			return FALSE

	// Part 3: 2 hexadecimal characters (0-9, A-F)
	var/part3 = parts[3]
	if(length(part3) != 2)
		return FALSE
	for(var/i = 1, i <= length(part3), i++)
		var/char = copytext(part3, i, i + 1)
		if(!((char >= "0" && char <= "9") || (char >= "A" && char <= "F")))
			return FALSE

	// Part 4: 2 hexadecimal characters (0-9, A-F)
	var/part4 = parts[4]
	if(length(part4) != 2)
		return FALSE
	for(var/i = 1, i <= length(part4), i++)
		var/char = copytext(part4, i, i + 1)
		if(!((char >= "0" && char <= "9") || (char >= "A" && char <= "F")))
			return FALSE

	return TRUE
