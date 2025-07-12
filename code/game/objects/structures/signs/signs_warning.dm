//warning signs


///////DANGEROUS THINGS

/obj/structure/sign/warning
	name = "\improper WARNING sign"
	sign_change_name = "Warning"
	desc = "A warning sign."
	icon_state = "securearea"
	is_editable = TRUE

/obj/structure/sign/warning/securearea
	name = "\improper SECURE AREA sign"
	sign_change_name = "Warning - Secure Area"
	desc = "A warning sign which reads 'SECURE AREA'."
	is_editable = TRUE

/obj/structure/sign/warning/docking
	name = "\improper KEEP CLEAR: DOCKING AREA sign"
	sign_change_name = "Warning - Docking Area"
	desc = "A warning sign which reads 'KEEP CLEAR OF DOCKING AREA'."
	is_editable = TRUE

/obj/structure/sign/warning/biohazard
	name = "\improper BIOHAZARD sign"
	sign_change_name = "Warning - Biohazard"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"
	is_editable = TRUE

/obj/structure/sign/electrical
	icon_state = "electrical"
	desc = "A warning sign which reads: CAUTION, ELECTRICAL HAZARD."

/obj/structure/sign/warning/electricshock
	name = "\improper HIGH VOLTAGE sign"
	sign_change_name = "Warning - High Voltage"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"
	is_editable = TRUE

/obj/structure/sign/warning/vacuum
	name = "\improper HARD VACUUM AHEAD sign"
	sign_change_name = "Warning - Hard Vacuum"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"
	is_editable = TRUE

/obj/structure/sign/warning/vacuum/external
	name = "\improper EXTERNAL AIRLOCK sign"
	sign_change_name = "Warning - External Airlock"
	desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
	layer = MOB_LAYER
	is_editable = TRUE

/obj/structure/sign/warning/deathsposal
	name = "\improper DISPOSAL: LEADS TO SPACE sign"
	sign_change_name = "Warning - Disposals: Leads to Space"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO SPACE'."
	icon_state = "deathsposal"
	is_editable = TRUE

/obj/structure/sign/warning/bodysposal
	name = "\improper DISPOSAL: LEADS TO MORGUE sign"
	sign_change_name = "Warning - Disposals: Leads to Morgue"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO MORGUE'."
	icon_state = "bodysposal"
	is_editable = TRUE

/obj/structure/sign/warning/fire
	name = "\improper DANGER: FIRE sign"
	sign_change_name = "Warning - Fire Hazard"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF
	is_editable = TRUE

/obj/structure/sign/warning/nosmoking
	name = "\improper NO SMOKING sign"
	sign_change_name = "Warning - No Smoking"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"
	resistance_flags = FLAMMABLE
	is_editable = TRUE

/obj/structure/sign/warning/nosmoking/circle
	name = "\improper NO SMOKING sign"
	sign_change_name = "Warning - No Smoking Alt"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"
	is_editable = TRUE

/obj/structure/sign/warning/yessmoking/circle
	name = "\improper YES SMOKING sign"
	sign_change_name = "Warning - Yes Smoking Alt"
	desc = "A warning sign which reads 'YES SMOKING'."
	icon_state = "yessmoking"
	is_editable = TRUE

/obj/structure/sign/warning/radiation
	name = "\improper HAZARDOUS RADIATION sign"
	sign_change_name = "Warning - Radiation"
	desc = "A warning sign alerting the user of potential radiation hazards."
	icon_state = "radiation"
	is_editable = TRUE

/obj/structure/sign/warning/radiation/rad_area
	name = "\improper RADIOACTIVE AREA sign"
	sign_change_name = "Warning - Radioactive Area"
	desc = "A warning sign which reads 'RADIOACTIVE AREA'."
	is_editable = TRUE

/obj/structure/sign/warning/xeno_mining
	name = "\improper DANGEROUS ALIEN LIFE sign"
	sign_change_name = "Warning - Xenos"
	desc = "A sign that warns would-be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"
	is_editable = TRUE

/obj/structure/sign/warning/enginesafety
	name = "\improper ENGINEERING SAFETY sign"
	sign_change_name = "Warning - Engineering Safety Protocols"
	desc = "A sign detailing the various safety protocols when working on-site to ensure a safe shift."
	icon_state = "safety"
	is_editable = TRUE

/obj/structure/sign/warning/explosives
	name = "\improper HIGH EXPLOSIVES sign"
	sign_change_name = "Warning - Explosives"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives"
	is_editable = TRUE

/obj/structure/sign/warning/explosives/alt
	name = "\improper HIGH EXPLOSIVES sign"
	sign_change_name = "Warning - Explosives Alt"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives2"
	is_editable = TRUE

/obj/structure/sign/warning/testchamber
	name = "\improper TESTING AREA sign"
	sign_change_name = "Warning - Testing Area"
	desc = "A sign that warns of high-power testing equipment in the area."
	icon_state = "testchamber"
	is_editable = TRUE

/obj/structure/sign/warning/firingrange
	name = "\improper FIRING RANGE sign"
	sign_change_name = "Warning - Firing Range"
	desc = "A sign reminding you to remain behind the firing line, and to wear ear protection."
	icon_state = "firingrange"
	is_editable = TRUE

/obj/structure/sign/warning/coldtemp
	name = "\improper FREEZING AIR sign"
	sign_change_name = "Warning - Temp: Cold"
	desc = "A sign that warns of extremely cold air in the vicinity."
	icon_state = "cold"
	is_editable = TRUE

/obj/structure/sign/warning/hottemp
	name = "\improper SUPERHEATED AIR sign"
	sign_change_name = "Warning - Temp: Hot"
	desc = "A sign that warns of extremely hot air in the vicinity."
	icon_state = "heat"
	is_editable = TRUE

/obj/structure/sign/warning/gasmask
	name = "\improper CONTAMINATED AIR sign"
	sign_change_name = "Warning - Contaminated Air"
	desc = "A sign that warns of dangerous particulates or gasses in the air, instructing you to wear internals."
	icon_state = "gasmask"
	is_editable = TRUE

/obj/structure/sign/warning/chemdiamond
	name = "\improper REACTIVE CHEMICALS sign"
	sign_change_name = "Warning - Hazardous Chemicals sign"
	desc = "A sign that warns of potentially reactive chemicals nearby, be they explosive, flamable, or acidic."
	icon_state = "chemdiamond"
	is_editable = TRUE

////MISC LOCATIONS

/obj/structure/sign/warning/pods
	name = "\improper ESCAPE PODS sign"
	sign_change_name = "Location - Escape Pods"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"
	is_editable = TRUE

/obj/structure/sign/warning/radshelter
	name = "\improper RADSTORM SHELTER sign"
	sign_change_name = "Location - Radstorm Shelter"
	desc = "A warning sign which reads 'RADSTORM SHELTER'."
	icon_state = "radshelter"
	is_editable = TRUE

/obj/structure/sign/exitonly
	name = "\improper EXIT ONLY sign"
	sign_change_name = "Exit ONly"
	desc = "A sign informing you that you will not be able to re-enter this area without access."
	icon_state = "exitonly"
	is_editable = TRUE

// Bay12 ported signs, could be sorted better.

/obj/structure/sign/warning/lethal_turrets
	name = "\improper LETHAL TURRETS"
	icon_state = "turrets"

/obj/structure/sign/warning/lethal_turrets/New()
	..()
	desc += " Enter at own risk!"

/obj/structure/sign/warning/mail_delivery
	name = "\improper MAIL DELIVERY"
	icon_state = "mail"

/obj/structure/sign/warning/moving_parts
	name = "\improper MOVING PARTS"
	icon_state = "movingparts"

/obj/structure/sign/warning/radioactive
	name = "\improper RADIOACTIVE AREA"
	icon_state = "radiation"

/obj/structure/sign/warning/secure_area
	name = "\improper SECURE AREA"
	icon_state = "securearea"

/obj/structure/sign/warning/server_room
	name = "\improper SERVER ROOM"
	icon_state = "server"

/obj/structure/sign/warning/server_room_old
	name = "\improper SERVER ROOM"
	icon_state = "server_old"

/obj/structure/sign/warning/nosmoking_burned
	name = "\improper NO SMOKING"
	icon_state = "nosmoking2_b"

/obj/structure/sign/warning/nosmoking_burned/Initialize()
	. = ..()
	desc += " It looks charred."

/obj/structure/sign/cryogenic
	icon_state = "cryogenic"
	desc = "A warning sign which reads: CAUTION, POTENTIAL CRYOGENIC HAZARD."

/obj/structure/sign/oxidizer
	icon_state = "oxidizer"
	desc = "A warning sign which reads: CAUTION, FLAMMABLE SUBSTANCE HAZARD."

/obj/structure/sign/memnetic
	icon_state = "memnetic"
	desc = "A warning sign which reads: CAUTION, MEMETIC HAZARD."

/obj/structure/sign/biohazardous
	icon_state = "biohazardous"
	desc = "A warning sign which reads: CAUTION, BIOHAZARD."

/obj/structure/sign/amnesiac
	icon_state = "amnesiac"
	desc = "A warning sign which reads: CAUTION, AMNESTIC HAZARD."

/obj/structure/sign/containers
	icon_state = "containers"
	desc = "A warning sign which reads: CAUTION, PRESSURIZED GAS STORAGE."

/obj/structure/sign/corrosive
	icon_state = "corrosive"
	desc = "A warning sign which reads: CAUTION, CORROSIVE HAZARD."

/obj/structure/sign/explosive
	icon_state = "explosive"
	desc = "A warning sign which reads: CAUTION, EXPLOSIVE HAZARD."

/obj/structure/sign/flamable
	icon_state = "flamable"
	desc = "A warning sign which reads: CAUTION, FLAMABLE HAZARD."

/obj/structure/sign/lasers
	icon_state = "lasers"
	desc = "A warning sign which reads: CAUTION, LASER HAZARD."

/obj/structure/sign/poisonous
	icon_state = "poisonous"
	desc = "A warning sign which reads: CAUTION, POISONOUS HAZARD."

/obj/structure/sign/magnetic
	icon_state = "magnetic"
	desc = "A warning sign which reads: CAUTION, MAGNETICAL HAZARD. NO METAL OBJECTS BEYOND THIS SIGN."

/obj/structure/sign/optics
	icon_state = "optics"
	desc = "A warning sign which reads: CAUTION, OPTICS HAZARD."

/obj/structure/sign/look
	icon_state = "look"
	desc = "A warning sign which reads: CAUTION, LOOK AT ANOMALOUS OBJECT."

/obj/structure/sign/dontlook
	icon_state = "dontlook"
	desc = "A warning sign which reads: CAUTION, DO NOT LOOK AT ANOMALOUS OBJECT."

/obj/structure/sign/warning/fall
	name = "\improper FALL HAZARD"
	icon_state = "falling"

/obj/structure/sign/warning/fire
	name = "\improper DANGER: FIRE"
	icon_state = "fire"

/obj/structure/sign/warning/high_voltage
	name = "\improper HIGH VOLTAGE"
	icon_state = "shock"

/obj/structure/sign/warning/hot_exhaust
	name = "\improper HOT EXHAUST"
	icon_state = "fire"

/obj/structure/sign/warning/compressed_gas
	name = "\improper COMPRESSED GAS"
	icon_state = "hikpa"

/obj/structure/sign/warning/vent_port
	name = "\improper EJECTION/VENTING PORT"

/obj/structure/sign/warning/detailed
	icon_state = "securearea2"

/obj/structure/sign/warning/termination
	name = "\improper TERMINATION LINE"
	desc = "A sign that says. 'Any D-Class Personnel past the red striped line is to be apprehended/terminated for uncompliance unless given permission by tests, or security staff.'"
	icon_state = "securearea2"

/obj/structure/sign/warning/New()
	..()
	desc = "A warning sign which reads '[sanitize(name)]'."

/obj/structure/sign/thera
	icon_state = "thera"
	name = "\improper THERA SAFE ROOM"
	desc = "A detailed sign that reads 'Temporary Housing for Emergency, Radioactive, Atmospheric. This location is unsuitable for extended Habitation. Do not shelter here beyond immediate need.'"

/obj/structure/sign/noidle
	name = "\improper NO IDLING"
	desc = "A warning sign which reads 'NO IDLING!'."
	icon_state = "noidle"

/obj/structure/sign/emergonly
	name = "\improper EMERGENCY ONLY"
	desc = "A warning sign which reads 'EMERGENCY ONLY!'."
	icon_state = "emerg"

/obj/structure/sign/warning/engineering_access
	name = "\improper ENGINEERING ACCESS"
