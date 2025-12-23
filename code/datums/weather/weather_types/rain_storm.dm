/datum/weather/weather_types/rain_storm
	name = "rain"
	desc = "Cold raindrops pour down from the sky, soaking everything they touch in a thin layer of water. "
	probability = 9000

	telegraph_message = "<span class='warning'>Dark clouds poke through the sky as drops of rain begin to sprinkle down from above..</span>"
	telegraph_duration = 200
	telegraph_overlay = "light_rain"

	weather_message = "<span class='userdanger'><i>The wind picks up as a slow drizzle begins to turn into a downpour!</i></span>"
	weather_overlay = "rain_storm"
	weather_sound = 'sound/weather/rainstorm_loop.ogg'
	weather_duration_lower = 1800 SECONDS
	weather_duration_upper = 3600 SECONDS

	end_duration = 100
	end_message = "<span class='boldannounce'>The downpour dies down, the smell of rainwater lingering in the air.</span>"

	target_trait = ZTRAIT_PLANETARY_ENVIRONMENT

	immunity_type = TRAIT_RAINSTORM_IMMUNE

	barometer_predictable = TRUE
	use_glow = FALSE

/datum/weather/weather_types/rain_storm/weather_act(mob/living/L)
	..()

/datum/weather/weather_types/rain_storm/start()
	. = ..()

	//Unique alerts for old people and SD's
	var/list/impacted_mobs = SSweather.weather_chunking.get_mobs_in_chunks_around_storm(src)
	for(var/mob/living/L in impacted_mobs)
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(H.age > 60)
				if(prob(25))
					to_chat(L, span_warning("You feel an ache in your knee...a storm is coming.."))
					//Probably not my most efficient use of iterating a list, but.. it IS funny.
			if(L.mind && is_captain_job(L.mind.assigned_role))
				to_chat(L, span_warning("A storm is brewing out on the horizon.."))
