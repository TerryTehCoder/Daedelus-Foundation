/mob/living/carbon/human/proc/show_persistent_progress()
    set name = "Show Persistent Progress"
    set category = "IC.Persistent"

    if(!mind || !mind.persistent_data)
        to_chat(src, span_warning("No persistent data found."))
        return

    var/datum/persistent_player_data/data = mind.persistent_data
    var/datum/persistent_class/class = mind.get_current_class()
    var/datum/persistent_faction/faction = mind.get_current_faction()
    var/list/rank_info = mind.get_rank_progress()

    var/dat = "<h2>Your Persistent Progress</h2>"
    dat += "<h3>Current Status</h3>"
    dat += "<b>Class:</b> [class ? class.class_name : "Unknown"]<br>"
    dat += "<b>Faction:</b> [faction ? faction.faction_name : "Unknown"]<br>"
    dat += "<b>Rank:</b> [rank_info["rank_name"]] (Level [rank_info["current_rank"]])<br>"
    dat += "<b>Total Experience:</b> [data.total_experience]<br>"
    dat += "<b>Rounds Played:</b> [data.rounds_played]<br>"

    if(class)
        dat += "<b>Progress to Next Rank:</b> [rank_info["progress"]]%<br>"
        if(rank_info["exp_needed"] > 0)
            dat += "<b>Experience Needed:</b> [rank_info["exp_needed"]]<br>"

    dat += "<h3>Class Information</h3>"
    if(class)
        dat += "<b>Description:</b> [class.class_description]<br>"
        dat += "<b>Experience Multiplier:</b> [class.experience_multiplier]x<br>"
        dat += "<b>Max Rank:</b> [class.max_rank]<br>"

        dat += "<h4>Available Ranks</h4>"
        for(var/rank_level = 0; rank_level <= class.max_rank; rank_level++)
            var/rank_name = class.get_rank_name(rank_level)
            var/rank_requirement = class.get_rank_requirement(rank_level)
            var/rank_color = class.get_rank_color(rank_level)
            var/status = rank_level <= rank_info["current_rank"] ? "✓" : "✗"
            dat += "<span style='color: [rank_color]'>[status] [rank_name] - [rank_requirement] exp</span><br>"

    dat += "<h3>Faction Information</h3>"
    if(faction)
        dat += "<b>Description:</b> [faction.faction_description]<br>"
        dat += "<b>Experience Multiplier:</b> [faction.experience_multiplier]x<br>"
        dat += "<b>Available Classes:</b> "
        for(var/class_id in faction.faction_classes)
            var/datum/persistent_class/faction_class = SSpersistent_progression.get_class(class_id)
            if(faction_class)
                dat += "[faction_class.class_name], "
        dat = copytext(dat, 1, -2) + "<br>"

    dat += "<h3>Unlocked Items</h3>"
    if(data.unlocked_items.len > 0)
        for(var/item in data.unlocked_items)
            dat += "- [item]<br>"
    else
        dat += "No items unlocked yet.<br>"

    dat += "<h3>Unlocked Titles</h3>"
    if(data.unlocked_titles.len > 0)
        for(var/title in data.unlocked_titles)
            dat += "- [title]<br>"
    else
        dat += "No titles unlocked yet.<br>"

    dat += "<h3>Achievements</h3>"
    if(data.achievements.len > 0)
        for(var/achievement in data.achievements)
            dat += "- [achievement]<br>"
    else
        dat += "No achievements unlocked yet.<br>"

    dat += "<h3>Recent Experience</h3>"
    var/count = 0
    for(var/list/source_data in data.experience_sources)
        if(count >= 5) // Show last 5
            break
        dat += "- [source_data["reason"]]: [source_data["amount"]] exp<br>"
        count++

    if(count == 0)
        dat += "No experience gained yet.<br>"

    var/datum/browser/popup = new(usr, "persistent_progress", "Your Progress", 600, 800)
    popup.set_content(dat)
    popup.open()

/mob/living/carbon/human/proc/change_persistent_class()
    set name = "Change Class"
    set category = "IC.Persistent"

    if(!mind || !mind.persistent_data)
        to_chat(src, span_warning("No persistent data found."))
        return

    var/datum/persistent_faction/faction = mind.get_current_faction()
    if(!faction)
        to_chat(src, span_warning("No faction found."))
        return

    var/list/available_classes = list()
    for(var/class_id in faction.faction_classes)
        var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
        if(class)
            available_classes["[class.class_name] - [class.class_description]"] = class_id

    if(available_classes.len == 0)
        to_chat(src, span_warning("No classes available for your faction."))
        return

    var/selected_class = input("Select a new class", "Change Class") as null|anything in available_classes
    if(!selected_class)
        return

    var/class_id = available_classes[selected_class]
    var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

    var/confirm = alert("Are you sure you want to change your class to [class.class_name]? Your rank will be reset to 0.", "Confirm Class Change", "Yes", "No")
    if(confirm != "Yes")
        return

    if(mind.change_class(class_id))
        to_chat(src, span_notice("Successfully changed your class to [class.class_name]!"))
    else
        to_chat(src, span_warning("Failed to change class."))

/mob/living/carbon/human/proc/change_persistent_faction()
    set name = "Change Faction"
    set category = "IC.Persistent"

    if(!mind || !mind.persistent_data)
        to_chat(src, span_warning("No persistent data found."))
        return

    var/list/available_factions = list()
    for(var/faction_id in SSpersistent_progression.factions)
        var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
        if(faction && (mind.persistent_data.current_class_id in faction.faction_classes))
            available_factions["[faction.faction_name] - [faction.faction_description]"] = faction_id

    if(available_factions.len == 0)
        to_chat(src, span_warning("No factions available for your class."))
        return

    var/selected_faction = input("Select a new faction", "Change Faction") as null|anything in available_factions
    if(!selected_faction)
        return

    var/faction_id = available_factions[selected_faction]
    var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)

    var/confirm = alert("Are you sure you want to change your faction to [faction.faction_name]?", "Confirm Faction Change", "Yes", "No")
    if(confirm != "Yes")
        return

    if(mind.change_faction(faction_id))
        to_chat(src, span_notice("Successfully changed your faction to [faction.faction_name]!"))
    else
        to_chat(src, span_warning("Failed to change faction."))

/mob/living/carbon/human/proc/show_available_classes()
    set name = "Show Available Classes"
    set category = "IC.Persistent"

    var/dat = "<h2>Available Classes</h2>"

    for(var/class_id in SSpersistent_progression.classes)
        var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
        if(class)
            dat += "<h3>[class.class_name]</h3>"
            dat += "<b>Description:</b> [class.class_description]<br>"
            dat += "<b>Experience Multiplier:</b> [class.experience_multiplier]x<br>"
            dat += "<b>Max Rank:</b> [class.max_rank]<br>"
            dat += "<b>Available Factions:</b> "

            var/list/compatible_factions = list()
            for(var/faction_id in SSpersistent_progression.factions)
                var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
                if(faction && (class_id in faction.faction_classes))
                    compatible_factions += faction.faction_name

            dat += compatible_factions.Join(", ") + "<br>"

            dat += "<b>Ranks:</b><br>"
            for(var/rank_level = 0; rank_level <= class.max_rank; rank_level++)
                var/rank_name = class.get_rank_name(rank_level)
                var/rank_requirement = class.get_rank_requirement(rank_level)
                var/rank_color = class.get_rank_color(rank_level)
                dat += "<span style='color: [rank_color]'>- [rank_name] - [rank_requirement] exp</span><br>"

            dat += "<br>"

    var/datum/browser/popup = new(usr, "available_classes", "Available Classes", 600, 800)
    popup.set_content(dat)
    popup.open()

/mob/living/carbon/human/proc/show_available_factions()
    set name = "Show Available Factions"
    set category = "IC.Persistent"

    var/dat = "<h2>Available Factions</h2>"

    for(var/faction_id in SSpersistent_progression.factions)
        var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
        if(faction)
            dat += "<h3>[faction.faction_name]</h3>"
            dat += "<b>Description:</b> [faction.faction_description]<br>"
            dat += "<b>Experience Multiplier:</b> [faction.experience_multiplier]x<br>"
            dat += "<b>Available Classes:</b><br>"

            for(var/class_id in faction.faction_classes)
                var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
                if(class)
                    dat += "- [class.class_name]: [class.class_description]<br>"

            dat += "<br>"

    var/datum/browser/popup = new(usr, "available_factions", "Available Factions", 600, 800)
    popup.set_content(dat)
    popup.open()
