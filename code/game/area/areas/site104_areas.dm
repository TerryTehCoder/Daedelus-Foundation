/*Elevators

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
	lift_announce_str = "" //Can we have no announcement?
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
	name = "Site-104"
	has_gravity = TRUE

/area/site104/surface
	name = "Surface"
	icon_state = "space"
	requires_power = 0
	outdoors = TRUE
	ambientsounds = list(
	'sounds/ambience/Site104/BoatHorn.ogg',
	'sounds/ambience/Site104/BuoyBell.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls1.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls2.ogg',
	'sounds/ambience/Site104/WindyChains.ogg'
	)

	ambient_buzz = 'sounds/ambience/Site104/OutsideAmbience.ogg'

/area/site104/surface/opendeck
	name = "Weather Deck"
	ambientsounds = list(
	'sounds/ambience/Site104/BoatHorn.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls1.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls1.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls2.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls2.ogg',
	'sounds/ambience/Site104/WindyChains.ogg',
	'sounds/ambience/Site104/WindyChains.ogg',

	// We have no weighted ambience pick, and I don't want to touch ambi code and get yelled at ):
	'sounds/ambience/Site104/Machinery/HydraulicPress.ogg',
	'sounds/ambience/Site104/Machinery/HydraulicPress.ogg',
	'sounds/ambience/Site104/Machinery/GenericPumpMotor.ogg',
	'sounds/ambience/Site104/Machinery/GenericPumpMotor.ogg',
	'sounds/ambience/Site104/Machinery/GasDecom.ogg',
	'sounds/ambience/Site104/Machinery/GasDecom.ogg',
	'sounds/ambience/Site104/Machinery/ForkliftBeepDistant.ogg',
	'sounds/ambience/Site104/Machinery/ForkliftBeepDistant.ogg',
	'sounds/ambience/Site104/Weather/DistantThunder.ogg',
	'sounds/ambience/Site104/BuoyBell.ogg',
	'sounds/ambience/Site104/BuoyBell.ogg'
	)

/area/site104/surface/northmaintplat
	name = "North-Rig Maintenance Platform"

/area/site104/surface/engineeringmaintplat
	name = "Engineering External Maintenance Platform"

/area/site104/surface/dredges
	name = "The Dredges"

/area/site104/surface/aiauxaccessplat
	name = "Auxillary A.I.C Housing Access Catwalk"

/area/site104/surface/aiextmaintenancering
	name = "A.I.C Housing External Maintenance Ring"

/area/site104/surface/miningdecknorthaccess
	name = "Mining Deck External Maintenance Platform"

/area/site104/surface/portforetensionlegext
	name = "Port Fore Tension Leg Platform"

/area/site104/surface/portafttensionlegext
	name = "Port Aft Tension Leg Platform"

/area/site104/surface/starboardforetensionlegext
	name = "Starboard Fore Tension Leg Platform"

/area/site104/surface/starboardafttensionlegext
	name = "Starboard Aft Tension Leg Platform"

/area/site104/surface/aichousingsecofficemaintplat
	name = "A.I.C Housing Security Office Maintenance Platform"

//Maintenance Areas

/area/site104/maintenance/interior
	name = "Site-104 Maintenance"
	ambientsounds = list('sounds/ambience/Site104/RigMetalStress')

	//Deck-1

/area/site104/maintenance/interior/northrigdeck1starboard
	name = "North Rig Deck-1 Starboard Maintenance"

/area/site104/maintenance/interior/engimaints
	name = "North Rig Deck-1 Port Maintenance"

/area/site104/logistics/mining/miningmaints
	name = "Mining Floor Maintenance"

/area/site104/maintenance/interior/southrigdeck1starboard
	name = "South Rig Deck-1 Starboard Maintenance"

/area/site104/maintenance/interior/southrigdeck1starboardaft
	name = "South Rig Deck-1 Starboard Aft Maintenance"

	//Deck-2

/area/site104/maintenance/interior/northrigdeck2port
	name = "North Rig Deck-2 Port Maintenance"

/area/site104/maintenance/interior/northrigdeck2starboard
	name = "North Rig Deck-2 Starboard Maintenance"

/area/site104/maintenance/interior/southrigdeck2portfore
	name = "South Rig Deck-2 Port Fore Maintenance"

/area/site104/maintenance/interior/southrigdeck2starboardfore
	name = "South Rig Deck-2 Starboard Fore Maintenance"

/area/site104/maintenance/interior/southrigdeck2portaft
	name = "South Rig Deck-2 Port Aft Maintenance"

	//Deck-3

/area/site104/maintenance/interior/southrigdeck3port
	name = "South Rig Deck-3 Port Maintenance"

/area/site104/maintenance/interior/northrigd3starboard
	name = "North Rig Deck-3 Starboard Maintenance"

/area/site104/maintenance/interior/northrigd3aft
	name = "North Rig Deck-3 Aft Maintenance"

/area/site104/maintenance/interior/northrigdeck3port
	name = "North Rig Deck-3 Port Maintenance"

//Engineering Areas North Rig

/area/site104/engineering/reactor
	name = "Antiquated Reactor"

/area/site104/engineering/powerbay
	name = "Power Bay"

/area/site104/engineering/workshop
	name = "Workshop"
	ambientsounds = list(
	'sounds/ambience/Site104/BoatHorn.ogg',
	'sounds/ambience/Site104/BuoyBell.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls1.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls2.ogg',
	'sounds/ambience/Site104/WindyChains.ogg'
	)

	ambient_buzz = 'sounds/ambience/Site104/OutsideAmbience.ogg'
	ambient_buzz_vol = 40

/area/site104/engineering/lockers
	name = "Engineering Lockers"

/area/site104/engineering/hallway
	name = "Engineering Hallway"

/area/site104/engineering/securestorage
	name = "Secure Storage"

/area/site104/engineering/atmospherics
	name = "Atmospherics"

/area/site104/engineering/engicontrol
	name = "Marine Control"

/area/site104/engineering/warehouse
	name = "Engineering Warehouse"
	ambientsounds = list(
	'sounds/ambience/Site104/BoatHorn.ogg',
	'sounds/ambience/Site104/BuoyBell.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls1.ogg',
	'sounds/ambience/Site104/Wildlife/Seagulls2.ogg',
	'sounds/ambience/Site104/WindyChains.ogg'
	)

	ambient_buzz = 'sounds/ambience/Site104/OutsideAmbience.ogg'
	ambient_buzz_vol = 35

/area/site104/engineering/entranceairlock
	name = "Engineering Entrance Airlock"

/area/site104/engineering/auxillaryairlock
	name = "Engineering Auxillary Entrance Airlock"

/area/site104/engineering/stairwell
	name = "Engineering Stairwell"

/area/site104/engineering/generalstorage
	name = "Engineering General Storage"

/area/site104/engineering/portforetensionlegint
	name = "Port Fore Tension Leg"

/area/site104/engineering/portafttensionlegint
	name = "Port Aft Tension Leg"

/area/site104/engineering/starboardforetensionlegint
	name = "Starboard Fore Tension Leg"

/area/site104/engineering/starboardafttensionlegint
	name = "Starboard Aft Tension Leg"

/area/site104/engineering/janitorialcloset
	name = "Engineering Janitorial Closet"

/area/site104/engineering/auxillaryrelaytowerbridge
	name = "Auxillary Relay Tower Bridge"

// Relay tower starts on Deck-2
/area/site104/engineering/relaytower1
	name = "Auxillary Relay Tower Deck-2"

/area/site104/engineering/relaytower2
	name = "Auxillary Relay Tower Deck-3"

/area/site104/engineering/relaytower3
	name = "Auxillary Relay Tower Deck-4"

/area/site104/engineering/relaytower4
	name = "Auxillary Relay Tower Deck-5"

/area/site104/engineering/relaytower5
	name = "Auxillary Relay Tower Deck-6"

/area/site104/engineering/holding
	name = "Engineering Temporary Holding"

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

/area/site104/logistics/olddrillsite
	name = "Old Drill Site"

/area/site104/logistics/boilerplant
	name = "Old Boiler Plant"

/area/site104/logistics/gasfilt
	name = "Old Gas Filtration Plant"

/area/site104/logistics/personnellogi
	name = "Old Processing Center Personnel Logistics"

/area/site104/logistics/personnellogistorage
	name = "Old Processing Center Personnel Logistics Storage"

/area/site104/logistics/boilercontrol
	name = "Boiler Control Center"

/area/site104/logistics/personnellogisec
	name = "Processing Security Center"

/area/site104/logistics/shaleshakers
	name = "Shale Shakers"

/area/site104/logistics/flarestack
	name = "Flare Stack"

/area/site104/logistics/projectyard
	name = "Logistics Project Yard"

/area/site104/logistics/projectyardcontrol
	name = "Logistics Yard Monitoring Station"

//South Rig Logistics


	//Mining
/area/site104/logistics/mining/miningentranceoffice
	name = "Mining Deck Registration Office"

/area/site104/logistics/mining/miningentrancehall
	name = "Mining Deck Entrance Hall"

/area/site104/logistics/mining/miningoversight
	name = "Mining Operations Center"

/area/site104/logistics/mining/miningstagingarea
	name = "Mining Operations Staging"

/area/site104/logistics/mining/storagearea
	name = "Mining Operations Holding"

	//Boiler Floor

/area/site104/logistics/mining/porthabcorridor
	name = "Boiler Floor Port Habitation Corridor"

/area/site104/logistics/mining/starboardhabcorridor
	name = "Boiler Floor Port Habitation Corridor"

/area/site104/logistics/mining/dorm1
	name = "Boiler Dorm #1"

/area/site104/logistics/mining/dorm2
	name = "Boiler Dorm #2"

/area/site104/logistics/mining/dorm3
	name = "Boiler Dorm #3"

/area/site104/logistics/mining/dorm4
	name = "Boiler Dorm #4"

/area/site104/logistics/mining/dorm5
	name = "Boiler Dorm #5"

/area/site104/logistics/mining/dorm6
	name = "Boiler Dorm #6"

/area/site104/logistics/mining/dorm7
	name = "Boiler Dorm #7"

/area/site104/logistics/mining/janitorialcloset
	name = "Boiler Floor Custodial Closet"

/area/site104/logistics/mining/incinerator
	name = "The Boiler Furnace"

/area/site104/logistics/mining/boilercorridor
	name = "Boiler Floor"

/area/site104/logistics/mining/emergencyshowers
	name = "Boiler Floor Emergency Showers"

/area/site104/logistics/mining/toolstorage
	name = "Boiler Floor Tool Closet"

/area/site104/logistics/mining/furnaceoversight
	name = "Furnace Oversight"

/area/site104/logistics/mining/boilerflooroversight
	name = "Boiler Floor Monitoring"

/area/site104/logistics/mining/boilerfloorent
	name = "Boiler Floor Entrance Corridor"

/area/site104/logistics/mining/dczloadingaccess
	name = "Boiler Floor Loading Access"

//North Rig Deck-1 General

/area/site104/northrig/eogstorage
	name = "External Operations Gear Storage"


//North Rig Deck-2 General

/area/site104/northrig/stairwell
	name = "North Rig Deck-2 Stairwell"

/area/site104/northrig/deck2hallway
	name = "North Rig Deck 2 Hallway"

/area/site104/northrig/deck2janitorial
	name = "North Rig - Deck 2 Janitorial Closet"

/area/site104/northrig/blackoutsheltera
	name = "Blackout Shelter A"

/area/site104/northrig/deck2secofficeextplatairlock // What in the world was I thinking with these names..
	name = "A.I.C Security Office External Platform Airlock"

/area/site104/northrig/deck2accessairlock
	name = "North Rig Primary Weatherdeck Access"

//North Rig Deck-3 General

/area/site104/northrig/hallway
	name = "North Rig Deck-3 Central Hall"

//South Rig Habitations

/area/site104/southrig/habelevatorhall
	name = "Acommodations Elevator Access"

/area/site104/southrig/habgym
	name = "Acommodations Gymnasium"

/area/site104/southrig/recroom
	name = "Acommodations Rec Room"

/area/site104/southrig/treeloop
	name = "Acommodations Tree Loop"

/area/site104/southrig/temptransstorage
	name = "Acommodations Temporary Transfer Holding Storage"

/area/site104/southrig/acommodationsjunc
	name = "Acommodations Hub Junction"

/area/site104/southrig/acommodationsjuncsec
	name = "Acommodations Hub Security office"

/area/site104/southrig/kitchen
	name = "Acoommodations Kitchen"

/area/site104/southrig/kitchencoldroom
	name = "Kitchen Coldroom"

/area/site104/southrig/acommodationsauxcommunestorage
	name = "Acommodations Auxillary Communal Storage"

/area/site104/southrig/acommodationslaundry
	name = "Acommodations Communal Laundry"

/area/site104/southrig/habcustodialcloset
	name = "Acommodations Custodial Closet"

/area/site104/southrig/habwastedisposalcenter
	name = "Acommodations Waste Disposal Center"

/area/site104/southrig/antiquatedsecurity
	name = "Antiquated Security Storage"

/area/site104/southrig/d2extaccessjunc
	name = "Acommodations External Access Corridor"

/area/site104/southrig/acommodationweatherdeckairlock
	name = "Acommodations Weather Deck Airlock"

//Substations

/area/site104/engineering/researchsub
	name = "Research Substation"

/area/site104/engineering/logisub
	name = "Logistics Substation"

/area/site104/aihousing/substation
	name = "A.I.C Housing Substation"

/area/site104/engineering/engisub
	name = "Engineering Substation"

/area/site104/engineering/medisub
	name = "Medical Substation"

/area/site104/engineering/northrigd2sub
	name = "North Rig Deck 2 Substation"

/area/site104/engineering/miningsub
	name = "Mining Deck Substation"

/area/site104/engineering/operatingsub
	name = "Operating Theater Substation"

/area/site104/engineering/habsub
	name = "Habitation Substation"

/area/site104/engineering/ezsecsub
	name = "Acommodations Security Substation"

/area/site104/engineering/lczsub
	name = "Light Containment Zone Substation"

/area/site104/engineering/hczsub
	name = "Heavy Containment Zone Substation"

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

//Medical Division

/area/site104/medical/lobby
	name = "Medical Lobby"

/area/site104/medical/morgue
	name = "Morgue"

/area/site104/medical/storagebay
	name = "Medical Supply Bay"

/area/site104/medical/chemistry
	name = "Pharmaceutical Laboratory"

/area/site104/medical/treatmentcenter
	name = "Treatment Center"

/area/site104/medical/or1
	name = "Operating Room #1"

/area/site104/medical/or2
	name = "Operating Room #2"

/area/site104/medical/equipstorage
	name = "Medical Equipment Storage"

/area/site104/medical/medicalreception
	name = "Medical Reception"

/area/site104/medical/securityjunction
	name = "Medical Security Junction"

/area/site104/medical/assistdirectoroffice
	name = "Assistant Medical Directors Office"

//AIC Housing Areas

/area/site104/aihousing/interiorsanctum
	name = "Interior A.I.C Housing"

/area/site104/aihousing/aimaincore
	name = "A.I.C Main Core"

/area/site104/aihousing/control1
	name = "A.I.C Housing Control Center 1"

/area/site104/aihousing/control2
	name = "A.I.C Housing Control Center 2"

/area/site104/aihousing/entrancehall
	name = "South A.I.C Housing Hallway"

/area/site104/aihousing/northhall
	name = "North A.I.C Housing Hallway"

/area/site104/aihousing/entrancehall
	name = "A.I.C Complex Entrance Corridor"

/area/site104/aihousing/itcenter
	name = "A.I.C Housing Server Center"

/area/site104/aihousing/dronefab
	name = "A.I.C Housing Drone Fabrication Bay"

/area/site104/aihousing/dronefab
	name = "A.I.C Housing Drone Fabrication Bay"

/area/site104/aihousing/entrancesecurityoffice
	name = "A.I.C Access Security Office"

/area/site104/aihousing/entrancesecurityofficeholding
	name = "A.I.C Access Security Office Holding"

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

/area/site104/cryogenics/commandsecuritycenter
	name = "Command Cryogenics Security Office"

// Heavy Containment Zone

/area/site104/hcz
	name = "Heavy Containment Zone"
	requires_power = 0

/area/site104/hcz/equipmentwarehouse
	name = "Heavy Containment Warehouse A0"
