//Coffeepots: for reference, a standard cup is 30u, to allow 20u for sugar/sweetener/milk/creamer
/obj/item/reagent_containers/glass/coffeepot
	name = "coffeepot"
	desc = "A large coffee pot which makes a great gift at the company get-together. Contains 4 standard cups of volume."
	volume = 120
	icon = 'icons/obj/coffee.dmi'
	icon_state = "coffeepot"
	fill_icon_state = "coffeepot"
	fill_icon_thresholds = list(0, 1, 30, 60, 100)

/obj/item/reagent_containers/glass/coffeepot/examine()
	. = ..()
	var/pottemp = src.return_temperature()
	if(pottemp >= 300)
		. += span_bolddanger("\n That's an awfully hot coffee pot!")
	else if(pottemp >= 275)
		. += "\nThe pitcher is warm."
	else
		. += "\nThe pitcher has gone cold."

/obj/item/reagent_containers/glass/coffeepot/bluespace
	name = "bluespace coffeepot"
	desc = "The most advanced coffeepot the science team could cook up: sleek design; graduated lines; connection to a pocket dimension for coffee containment; yep, it's got it all. Contains 8 standard cups."
	volume = 240
	icon_state = "coffeepot_bluespace"
	fill_icon_thresholds = list(0)
