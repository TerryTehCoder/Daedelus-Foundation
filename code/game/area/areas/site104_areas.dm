/datum/map/site53

	post_round_safe_areas = list (
		/area/centcom,
		/area/site53/surface/bunker,
		)

//Elevators

/*
Comment these out for now, while I port everything else over.

/area/turbolift/site104/logilift1
	name = "lift (Deck 1 - Engineering)"
	lift_floor_label = "Engineering Deck"
	lift_floor_name = "Engineering Deck"
	lift_announce_str = "Arriving at Engineering Deck."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/logilift2
	name = "lift (Deck 2 - Logistics)"
	lift_floor_label = "Deck-2"
	lift_floor_name = "Logistics Deck"
	lift_announce_str = "Arriving at Logistics Depo."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/logilift3
	name = "lift (Deck 3 - Logistics Upper)"
	lift_floor_label = "Deck-3"
	lift_floor_name = "Logistics Upper"
	lift_announce_str = "Arriving at Upper Logistics Depo."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/logilift4
	name = "lift (Deck 4 - Heavy Containment Loading Dock)"
	lift_floor_label = "Deck-4"
	lift_floor_name = "Heavy Containment Loading Dock"
	lift_announce_str = "Arriving at Deck 4, Heavy Containment Loading Dock."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/logilift5
	name = "lift (Deck 5 - Helipad Maintenance)"
	lift_floor_label = "Deck-5"
	lift_floor_name = "Helipad Maintenance"
	lift_announce_str = "Arriving at Helipad Maintenance."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/logilift6
	name = "lift (Deck 6 - Logistics Helipad)"
	lift_floor_label = "Deck-6"
	lift_floor_name = "Logistics Helipad"
	lift_announce_str = "Arriving at Logistics Helipad."
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/decklift1
	name = "Weather Deck"
	lift_floor_label = "Floor-1"
	lift_floor_name = "Main Weather Deck"
	lift_announce_str = "Now arriving... weather deck" //Can we have no announcement?
	requires_power = 0
	dynamic_lighting = 1

/area/turbolift/site104/decklift2
	name = "Weather Deck"
	lift_floor_label = "Floor-2"
	lift_floor_name = "Upper Weather Deck"
	lift_announce_str = "" //Can we have no announcement?
	requires_power = 0
	dynamic_lighting = 1

*/

//Surface Areas

/area/site104
	base_turf = /turf/unsimulated/open

/area/site104/surface
	name = "Open Air"
	requires_power = 0
	dynamic_lighting = 1
	ambience = list('sounds/ambience/Site104/BoatHorn.ogg', 'sounds/ambience/Site104/Wildlife/Seagulls1.ogg', 'sounds/ambience/Site104/Wildlife/Seagulls2.ogg')

/area/site104/surface/opendeck
	name = "Weather Deck"
	sound_env = HANGAR
	forced_ambience = list('sounds/ambience/Site104/DeckAmbience.ogg') //Ahh, the sound of the ocean waves and the creaking metal beneath our feet...

//Maintenance Areas

/area/site104/maintenance/interior
	name = "Site-104 Maintenance"
	ambience = list('sounds/ambience/Site104/RigMetalStress.ogg')


	//Deck-1

/area/site104/maintenance/interior/deck1starboard
	name = "North Rig Deck-1 Starboard Maintenance"

/area/site104/maintenance/interior/engimaints
	name = "North Rig Deck-1 Port Maintenance"

/area/site104/maintenance/exterior
	name = "Under-Rig"

	//Deck-2

/area/site104/maintenance/interior/deck2port
	name = "North Rig Deck-2 Port Maintenance"

/area/site104/maintenance/interior/deck2starboard
	name = "North Rig Deck-2 Starboard Maintenance"

	//Deck-3

/area/site104/maintenance/interior/deck3port
	name = "Deck-3 Port Maintenance"

//Engineering Areas North Rig

/area/site104/engineering/reactor
	name = "R-UST Reactor"

/area/site104/engineering/powerbay
	name = "Power Bay"

/area/site104/engineering/workshop
	name = "Workshop"

/area/site104/engineering/lockers
	name = "Engineering Lockers"

/area/site104/engineering/hallway
	name = "Engineering Hallway"

/area/site104/engineering/securestorage
	name = "Secure Storage"

/area/site104/engineering/atmospherics
	name = "Atmospherics"

/area/site104/engineering/engicontrol
	name = "Engineering Control"

//North-Rig Logistics

/area/site104/logistics/lobby
	name = "Logistics Lobby"

/area/site104/logistics/office
	name = "Logistics Office"

/area/site104/logistics/warehouse
	name = "Interior Warehouse"

/area/site104/logistics/equipment
	name = "Logistics Equipment Storage"

/area/site104/logistics/coldroom
	name = "Logistics Cold Storage"

/area/site104/logistics/breakroom
	name = "Logistics Breakroom"

/area/site104/logistics/deliveryoffice
	name = "Delivery Office"

/area/site104/logistics/garage
	name = "Tug Train Garage"

/area/site104/logistics/looffice
	name = "Logistics Officer's office"

/area/site104/logistics/cargoelevator
	name = "Logistics Helipad Elevator"

/area/site104/logistics/salvagebay
	name = "Logistics Interior Salvage Depo"

/area/site104/logistics/stairwell
	name = "Logistics Stairwell"

//North Rig Deck-1 General

/area/site104/northrig/eogstorage
	name = "External Operations Gear Storage"


//North Rig Deck-2 General

/area/site104/northrig/stairwell
	name = "North Rig Deck-2 Stairwell"

//North Rig Deck-3 General

/area/site104/northrig/hallway
	name = "North Rig Deck-3 Central Hall"

//Substations

/area/site104/engineering/researchsub
	name = "Research Substation"

/area/site104/engineering/logisub
	name = "Logistics Substation"

//Research Division

/area/site104/research/lobby
	name = "Research Lobby"

/area/site104/research/lab
	name = "RnD Lab"

/area/site104/research/assistantrd
	name = "Assistant RD's Office"

/area/site104/research/srofficea
	name = "Senior Researcher Office A"

/area/site104/research/srofficeb
	name = "Senior Researcher Office B"

/area/site104/research/srofficec
	name = "Senior Researcher Office C"

/area/site104/research/psionicsoffice
	name = "Psionics Office"

/area/site104/research/mechlab
	name = "Mechanical Laboratory"

/area/site104/research/mechbay
	name = "Mech Bay"

/area/site104/research/xenobotany
	name = "Xenobotany Laboratory"

/area/site104/research/breakroom
	name = "Research Breakroom"

/area/site104/research/xenobiology
	name = "Xenobiology Laboratory"

/area/site104/research/anomalylab
	name = "Anomaly Laboratory"

/area/site104/maintenance/northrigstarboard
	name = "North Rig Starboard Maintenance"

/area/site104/maintenance/northrigaft
	name = "North Rig Aft Maintenance"

/area/site104/utilities/marinecontrol
	name = "Marine Control"

/area/site104/utilities/marinecontrol/reception
	name = "Marine Control Reception"

/area/site104/utilities/marinecontrol/breakroom
	name = "Marine Control Breakroom"

/area/site104/utilities/marinecontrol/equipment
	name = "Marine Control Equipment Storage"

/area/site104/utilities/marinecontrol/northserverfarm
	name = "North Server Farm"

/area/site104/utilities/marinecontrol/southserverfarm
	name = "South Server Farm"

//AIC Housing Areas

/area/site104/aihousing/interiorsanctum
	name = "Interior A.I.C Housing"

/area/site104/aihousing/aimaincore
	name = "A.I.C Main Core"

/area/site104/aihousing/control1
	name = "A.I.C Housing Control Center 1"

/area/site104/aihousing/entrancehall
	name = "South A.I.C Housing Hallway"

/area/site104/aihousing/northhall
	name = "North A.I.C Housing Hallway"

/area/site104/aihousing/itcenter
	name = "A.I.C Housing Server Center"

/area/site104/aihousing/substation
	name = "A.I.C Housing Substation"

/area/site104/aihousing/dronefab
	name = "A.I.C Housing Drone Fabrication Bay"

//Cryogenics Bay

/area/site104/cryogenics
	name = "Cryogenics Laboratory"

/area/site104/cryogenics/monitoring
	name = "Cryogenics Laboratory Observation"

/area/site104/cryogenics/bay
	name = "Cryogenics Laboratory Storage Bay"
	requires_power = 0

/area/site104/cryogenics/bay/b1
	name = "Cryogenics Bay 1"

/area/site104/cryogenics/bay/b2
	name = "Cryogenics Bay 2"

/area/site104/cryogenics/bay/b3
	name = "Cryogenics Bay 3"

/area/site104/cryogenics/bay/b4
	name = "Cryogenics Bay 4"

/area/site104/cryogenics/bay/commandbay
	name = "Cryogenics Command Bay"
