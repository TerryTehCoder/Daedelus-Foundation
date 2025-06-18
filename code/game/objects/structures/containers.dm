//Crates ported from TG, which were themselves ported from TGCM

/obj/structure/shipping_container
	name = "shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is blank, offering no clue as to its contents."
	icon = 'icons/obj/containers.dmi'
	icon_state = "blackgeneric"
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/shipping_container/Initialize(mapload)
	. = ..()

/*

/obj/structure/shipping_container/example
	name = "\improper Example Company shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Example Company, and is probably carrying (things the company would carry)"
	icon_state = "redgeneric"

*/

//Containers with the SCP logo stuck on them

/obj/structure/shipping_container/scp
	name = "\improper Foundation shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one has no logos, and could be carrying anything."
	icon_state = "greygeneric"

/obj/structure/shipping_container/scp/greyengi
	name = "\improper Engineering shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one is from the engineering department, and is probably carrying engineering supplies."
	icon_state = "greyengi"

/obj/structure/shipping_container/scp/greylogi
	name = "\improper Logistics shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one is from the logistics department, and is probably carrying external supplies."
	icon_state = "greylogi"

/obj/structure/shipping_container/scp/yellowscp
	name = "\improper Yellow shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one has a generic foundation logo emblazened on the side, and could be carrying anything."
	icon_state = "yellowscp"

/obj/structure/shipping_container/scp/yellowmanu
	name = "\improper Manufacturing shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one is from the manufacturing department, and is probably carrying machinery."
	icon_state = "yellowmanufacturing"

/obj/structure/shipping_container/scp/bluemed
	name = "\improper Medical shipping container"
	desc = "A standard-measure foundation shipping container for bulk transport of goods. This one is from the medical department, and is probably carrying medical supplies."
	icon_state = "bluemed"

//Generic containers

/obj/structure/shipping_container/generic
	name = "\improper Grey shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one has no logos, and could be carrying anything."
	icon_state = "greygeneric"

/obj/structure/shipping_container/generic/darkblue
	name = "\improper Dark blue shipping container"
	icon_state = "darkbluegeneric"

/obj/structure/shipping_container/generic/lightblue
	name = "\improper Light blue shipping container"
	icon_state = "lightbluegeneric"

/obj/structure/shipping_container/generic/darkgreen
	name = "\improper Dark green shipping container"
	icon_state = "darkgreengeneric"

/obj/structure/shipping_container/generic/yellow
	name = "\improper Yellow shipping container"
	icon_state = "yellowgeneric"

/obj/structure/shipping_container/generic/red
	name = "\improper Red shipping container"
	icon_state = "redgeneric"

/obj/structure/shipping_container/generic/black
	name = "\improper Black shipping container"
	icon_state = "blackgeneric"

/obj/structure/shipping_container/generic/grey
	name = "\improper Grey shipping container"
	icon_state = "greygeneric"

/obj/structure/shipping_container/generic/blue
	name = "\improper Blue shipping container"
	icon_state = "bluegeneric"

/obj/structure/shipping_container/generic/altblack
	name = "\improper Black shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one has no logos, and could be carrying anything. The color scheme seems different from the others."
	icon_state = "altblackgeneric"

/obj/structure/shipping_container/generic/orange
	name = "\improper Orange shipping container"
	icon_state = "orangegeneric"

/obj/structure/shipping_container/generic/darkorange
	name = "\improper Dark orange shipping container"
	icon_state = "darkorangegeneric"
