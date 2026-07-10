/client/proc/bake_weather_coverage()
	set name = "Bake Weather Coverage"
	set category = "Debug"
	set desc = "Manually recalculates and caches the weather coverage data for the current map."

	if(!check_rights(R_DEBUG))
		return

	if(!SSweather)
		to_chat(usr, span_warning("Weather subsystem not found."), confidential = TRUE)
		return

	var/choice = tgui_input_list(usr, "Choose a batch sizing method:", "Bake Weather Coverage", list("Use Dynamic Batch Size", "Specify Custom Batch Size"))
	if(!choice)
		return

	var/custom_batch_size

	if(choice == "Specify Custom Batch Size")
		custom_batch_size = tgui_input_number(usr, "Enter custom batch size:", "Bake Weather Coverage", 100, 1, 10000)
		if(!custom_batch_size)
			return // User cancelled

	to_chat(usr, span_notice("Starting weather coverage baking... This may take a moment."), confidential = TRUE)
	if(SSweather.BakeWeatherCoverage(custom_batch_size))
		to_chat(usr, span_notice("Weather coverage baking complete."), confidential = TRUE)
	else
		to_chat(usr, span_warning("Weather coverage baking failed. Check server logs for details."), confidential = TRUE)
