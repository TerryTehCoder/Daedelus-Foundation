/datum/aic_key_data
	var/ckey
	var/aic_name
	var/key_hash
	var/rounds_as_ai = 0
	var/admin_rank = 0
	var/creation_timestamp = 0 // store creation time
	var/login_sound_path // Path to custom login sound for this AIC

/datum/aic_key_data/proc/save_to_json()
	var/list/data = list()
	data["ckey"] = ckey
	data["aic_name"] = aic_name
	data["key_hash"] = key_hash
	data["rounds_as_ai"] = rounds_as_ai
	data["admin_rank"] = admin_rank
	data["creation_timestamp"] = creation_timestamp
	data["login_sound_path"] = login_sound_path
	return data

/datum/aic_key_data/proc/load_from_json(list/json_data)
	if(!islist(json_data))
		return FALSE
	ckey = json_data["ckey"]
	aic_name = json_data["aic_name"]
	key_hash = json_data["key_hash"]
	rounds_as_ai = json_data["rounds_as_ai"] || 0
	admin_rank = json_data["admin_rank"] || 0
	creation_timestamp = json_data["creation_timestamp"] || 0
	login_sound_path = json_data["login_sound_path"]
	return TRUE

// Helper proc for sorting AIC keys by timestamp
/datum/aic_key_data/proc/sort_by_timestamp(datum/aic_key_data/A, datum/aic_key_data/B)
	return A.creation_timestamp - B.creation_timestamp

// Global helper proc for sorting AIC keys by timestamp, used with sortTim
/proc/global_sort_aic_key_data_by_timestamp(datum/aic_key_data/A, datum/aic_key_data/B)
	return A.sort_by_timestamp(B)
