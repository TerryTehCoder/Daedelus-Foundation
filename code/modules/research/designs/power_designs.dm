////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1 MJ of energy."
	id = "basic_cell"
	build_type = FABRICATOR  | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 50)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/empty
	category = list(DCAT_POWER, DCAT_STOCK_PART)

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10 MJ of energy."
	id = "high_cell"
	build_type = FABRICATOR  | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 60)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high/empty
	category = list(DCAT_POWER, DCAT_STOCK_PART)
	mapload_design_flags = DESIGN_FAB_OMNI | DESIGN_FAB_ENGINEERING

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20 MJ of energy."
	id = "super_cell"
	build_type = FABRICATOR | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 70)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super/empty
	category = list(DCAT_POWER, DCAT_STOCK_PART)
	mapload_design_flags = DESIGN_FAB_OMNI | DESIGN_FAB_ENGINEERING

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30 MJ of energy."
	id = "hyper_cell"
	build_type = FABRICATOR  | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/gold = 150, /datum/material/silver = 150, /datum/material/glass = 80)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper/empty
	category = list(DCAT_POWER, DCAT_STOCK_PART)
	mapload_design_flags = DESIGN_FAB_OMNI | DESIGN_FAB_ENGINEERING

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40 MJ of energy."
	id = "bluespace_cell"
	build_type = FABRICATOR  | MECHFAB
	materials = list(/datum/material/iron = 800, /datum/material/gold = 120, /datum/material/glass = 160, /datum/material/diamond = 160, /datum/material/titanium = 300, /datum/material/bluespace = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace/empty
	category = list(DCAT_POWER, DCAT_STOCK_PART)

/datum/design/inducer
	name = "Inducer"
	desc = "The NT-75 Electromagnetic Power Inducer can wirelessly induce electric charge in an object, allowing you to recharge power cells without having to remove them."
	id = "inducer"
	build_type = FABRICATOR
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000)
	build_path = /obj/item/inducer/sci
	category = list(DCAT_POWER)
	mapload_design_flags = DESIGN_FAB_OMNI | DESIGN_FAB_ENGINEERING

/datum/design/board/port_gen/welding/sparrow
	name = "Machine Board (Sparrow-Grade Generator Board)"
	desc = "The circuit board for a Sparrow-Grade portable welding fuel powered generator."
	id = "sparrow"
	build_path = /obj/item/circuitboard/machine/portgen/sparrow

/datum/design/board/port_gen/coal/falcon
	name = "Machine Board (Falcon-Grade Generator Board)"
	desc = "The circuit board for a Falcon-Grade portable coal generator. Produces toxic fumes!"
	id = "falcon"
	build_path = /obj/item/circuitboard/machine/portgen/falcon

/datum/design/board/port_gen/coal/condor
	name = "Machine Board (Condor-Grade Generator Board)"
	desc = "The circuit board for a Condor-Grade portable coal generator. Twice the power output of a Falcon!"
	id = "condor"
	build_path = /obj/item/circuitboard/machine/portgen/condor

