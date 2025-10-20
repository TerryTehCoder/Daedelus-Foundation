SUBSYSTEM_DEF(facility_persistence)
	name = "Facility Persistence"
	wait = 600 // Check every 10 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	var/datum/facility_persistence_manager/manager

/datum/controller/subsystem/facility_persistence/Initialize()
	manager = new /datum/facility_persistence_manager()
	world.log << "Facility Persistence Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/facility_persistence/fire()
	if(manager)
		manager.process_facility()

// Facility Persistence Manager
/datum/facility_persistence_manager
	var/list/room_states = list()
	var/list/equipment_status = list()
	var/list/security_systems = list()
	var/list/power_grid = list()
	var/list/environmental_conditions = list()
	var/list/containment_chambers = list()
	var/list/research_labs = list()
	var/list/medical_facilities = list()
	var/list/engineering_systems = list()
	var/last_round_id = ""
	var/facility_age = 0
	var/facility_health = 100
	var/maintenance_level = 50
	var/security_level = 1
	var/power_efficiency = 1.0
	var/containment_stability = 100

/datum/facility_persistence_manager/proc/process_facility()
	// Update facility states
	update_room_states()
	update_equipment_status()
	update_security_systems()
	update_power_grid()
	update_environmental_conditions()
	update_containment_chambers()
	update_research_labs()
	update_medical_facilities()
	update_engineering_systems()

	// Calculate overall facility health
	calculate_facility_health()

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_facility_data()

/datum/facility_persistence_manager/proc/update_room_states()
	for(var/area/A in world)
		if(A.type in room_states)
			var/datum/room_state/state = room_states[A.type]
			state.update_state(A)
		else
			var/datum/room_state/new_state = new /datum/room_state(A.type)
			room_states[A.type] = new_state
			new_state.update_state(A)

/datum/facility_persistence_manager/proc/update_equipment_status()
	for(var/obj/machinery/M in world)
		if(M.type in equipment_status)
			var/datum/equipment_status/status = equipment_status[M.type]
			status.update_status(M)
		else
			var/datum/equipment_status/new_status = new /datum/equipment_status(M.type)
			equipment_status[M.type] = new_status
			new_status.update_status(M)

/datum/facility_persistence_manager/proc/update_security_systems()
	for(var/obj/machinery/camera/C in world)
		update_security_component(C, "camera")

	for(var/obj/machinery/door/airlock/A in world)
		update_security_component(A, "airlock")

	for(var/obj/machinery/computer/security/S in world)
		update_security_component(S, "security_console")

/datum/facility_persistence_manager/proc/update_security_component(var/obj/component, var/component_type)
	var/key = "[component_type]_[component.type]"
	if(key in security_systems)
		var/datum/security_component/comp = security_systems[key]
		comp.update_status(component)
	else
		var/datum/security_component/new_comp = new /datum/security_component(component_type, component.type)
		security_systems[key] = new_comp
		new_comp.update_status(component)

/datum/facility_persistence_manager/proc/update_power_grid()
	// Update power grid status
	var/total_power = 0
	var/active_power = 0

	for(var/obj/machinery/power/P in world)
		if(istype(P, /obj/machinery/power/generator))
			total_power += 1000 // Simplified power output
		else if(istype(P, /obj/machinery/power/apc))
			active_power += 100 // Simplified power usage

	power_efficiency = total_power > 0 ? active_power / total_power : 0

/datum/facility_persistence_manager/proc/update_environmental_conditions()
	// Update environmental conditions for each area
	for(var/area/A in world)
		if(A.type in environmental_conditions)
			var/datum/environmental_condition/condition = environmental_conditions[A.type]
			condition.update_condition(A)
		else
			var/datum/environmental_condition/new_condition = new /datum/environmental_condition(A.type)
			environmental_conditions[A.type] = new_condition
			new_condition.update_condition(A)

/datum/facility_persistence_manager/proc/update_containment_chambers()
	// Update SCP containment chamber status
	for(var/area/A in world)
		if(findtext(A.name, "containment") || findtext(A.name, "SCP"))
			if(A.type in containment_chambers)
				var/datum/containment_chamber/chamber = containment_chambers[A.type]
				chamber.update_status(A)
			else
				var/datum/containment_chamber/new_chamber = new /datum/containment_chamber(A.type)
				containment_chambers[A.type] = new_chamber
				new_chamber.update_status(A)

/datum/facility_persistence_manager/proc/update_research_labs()
	// Update research laboratory status
	for(var/area/A in world)
		if(findtext(A.name, "research") || findtext(A.name, "lab"))
			if(A.type in research_labs)
				var/datum/research_lab/lab = research_labs[A.type]
				lab.update_status(A)
			else
				var/datum/research_lab/new_lab = new /datum/research_lab(A.type)
				research_labs[A.type] = new_lab
				new_lab.update_status(A)

/datum/facility_persistence_manager/proc/update_medical_facilities()
	// Update medical facility status
	for(var/area/A in world)
		if(findtext(A.name, "medical") || findtext(A.name, "medbay"))
			if(A.type in medical_facilities)
				var/datum/medical_facility/facility = medical_facilities[A.type]
				facility.update_status(A)
			else
				var/datum/medical_facility/new_facility = new /datum/medical_facility(A.type)
				medical_facilities[A.type] = new_facility
				new_facility.update_status(A)

/datum/facility_persistence_manager/proc/update_engineering_systems()
	// Update engineering system status
	for(var/area/A in world)
		if(findtext(A.name, "engineering") || findtext(A.name, "engine"))
			if(A.type in engineering_systems)
				var/datum/engineering_system/system = engineering_systems[A.type]
				system.update_status(A)
			else
				var/datum/engineering_system/new_system = new /datum/engineering_system(A.type)
				engineering_systems[A.type] = new_system
				new_system.update_status(A)

/datum/facility_persistence_manager/proc/calculate_facility_health()
	var/total_health = 0
	var/component_count = 0

	// Calculate average room health
	for(var/type in room_states)
		var/datum/room_state/state = room_states[type]
		total_health += state.health
		component_count++

	// Calculate average equipment health
	for(var/type in equipment_status)
		var/datum/equipment_status/status = equipment_status[type]
		total_health += status.health
		component_count++

	// Calculate average security system health
	for(var/key in security_systems)
		var/datum/security_component/comp = security_systems[key]
		total_health += comp.health
		component_count++

	if(component_count > 0)
		facility_health = total_health / component_count

	// Update maintenance level based on facility health
	maintenance_level = facility_health

/datum/facility_persistence_manager/proc/save_facility_data()
	var/list/data = list(
		"room_states" = room_states,
		"equipment_status" = equipment_status,
		"security_systems" = security_systems,
		"power_grid" = power_grid,
		"environmental_conditions" = environmental_conditions,
		"containment_chambers" = containment_chambers,
		"research_labs" = research_labs,
		"medical_facilities" = medical_facilities,
		"engineering_systems" = engineering_systems,
		"facility_age" = facility_age,
		"facility_health" = facility_health,
		"maintenance_level" = maintenance_level,
		"security_level" = security_level,
		"power_efficiency" = power_efficiency,
		"containment_stability" = containment_stability
	)

	// Save to JSON file
	var/filename = "data/facility_persistence.json"
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/facility_persistence_manager/proc/load_facility_data()
	var/filename = "data/facility_persistence.json"
	if(fexists(filename))
		var/json_data = file2text(filename)
		var/list/data = json_decode(json_data)

		if(data)
			room_states = data["room_states"] || list()
			equipment_status = data["equipment_status"] || list()
			security_systems = data["security_systems"] || list()
			power_grid = data["power_grid"] || list()
			environmental_conditions = data["environmental_conditions"] || list()
			containment_chambers = data["containment_chambers"] || list()
			research_labs = data["research_labs"] || list()
			medical_facilities = data["medical_facilities"] || list()
			engineering_systems = data["engineering_systems"] || list()
			facility_age = data["facility_age"] || 0
			facility_health = data["facility_health"] || 100
			maintenance_level = data["maintenance_level"] || 50
			security_level = data["security_level"] || 1
			power_efficiency = data["power_efficiency"] || 1.0
			containment_stability = data["containment_stability"] || 100

// Room State Datum
/datum/room_state
	var/room_type
	var/health = 100
	var/damage_level = 0
	var/repair_status = 100
	var/list/modifications = list()
	var/last_inspected = 0
	var/security_level = 1
	var/power_status = 1
	var/air_quality = 100
	var/temperature = 293 // Kelvin
	var/humidity = 50

/datum/room_state/New(var/type)
	room_type = type

/datum/room_state/proc/update_state(var/area/A)
	// Update room state based on current area condition
	if(A)
		// Check for damage
		var/damage = 0
		for(var/turf/T in A)
			if(T.density)
				damage += 0.1 // Simplified damage calculation

		damage_level = damage
		health = max(0, 100 - damage_level * 100)

		// Update power status
		power_status = 1 // Simplified power status

		// Update air quality and temperature (simplified)
		air_quality = max(0, 100 - damage_level * 50)
		temperature = 293 + (damage_level * 20) // Warmer if damaged

// Equipment Status Datum
/datum/equipment_status
	var/equipment_type
	var/health = 100
	var/operational = TRUE
	var/efficiency = 1.0
	var/last_maintenance = 0
	var/maintenance_required = FALSE
	var/list/upgrades = list()
	var/power_consumption = 0
	var/heat_generation = 0

/datum/equipment_status/New(var/type)
	equipment_type = type

/datum/equipment_status/proc/update_status(var/obj/machinery/M)
	if(M)
		// Check if equipment is operational
		operational = TRUE // Simplified operational status

		// Calculate health based on damage
		health = 100 // Simplified health calculation

		// Check if maintenance is required
		maintenance_required = health < 50

		// Calculate efficiency
		efficiency = health / 100

		// Update power consumption (simplified)
		power_consumption = 100 // Simplified power consumption

// Security Component Datum
/datum/security_component
	var/component_type
	var/component_class
	var/health = 100
	var/operational = TRUE
	var/security_level = 1
	var/last_maintenance = 0
	var/list/access_logs = list()
	var/alert_status = 0

/datum/security_component/New(var/type, var/class)
	component_type = type
	component_class = class

/datum/security_component/proc/update_status(var/obj/component)
	if(component)
		// Check if component is operational
		operational = TRUE // Simplified operational status

		// Calculate health
		health = 100 // Simplified health calculation

		// Update security level
		security_level = 1 // Simplified security level

// Environmental Condition Datum
/datum/environmental_condition
	var/area_type
	var/temperature = 293
	var/humidity = 50
	var/air_quality = 100
	var/radiation_level = 0
	var/contamination_level = 0
	var/atmospheric_pressure = 101.325
	var/light_level = 100

/datum/environmental_condition/New(var/type)
	area_type = type

/datum/environmental_condition/proc/update_condition(var/area/A)
	if(A)
		// Update environmental conditions based on area state
		// This is a simplified implementation
		var/damage = 0
		for(var/turf/T in A)
			if(T.density)
				damage += 0.1 // Simplified damage calculation

		// Adjust conditions based on damage
		air_quality = max(0, 100 - damage * 50)
		temperature = 293 + (damage * 20)
		contamination_level = damage * 100

// Containment Chamber Datum
/datum/containment_chamber
	var/area_type
	var/containment_status = "secure"
	var/breach_level = 0
	var/containment_health = 100
	var/list/containment_protocols = list()
	var/last_breach = 0
	var/containment_class = "safe"
	var/containment_effectiveness = 1.0

/datum/containment_chamber/New(var/type)
	area_type = type

/datum/containment_chamber/proc/update_status(var/area/A)
	if(A)
		// Check containment status
		var/damage = 0
		for(var/turf/T in A)
			if(T.density)
				damage += 0.1 // Simplified damage calculation

		containment_health = max(0, 100 - damage * 100)
		breach_level = damage * 100

		// Update containment status
		if(breach_level > 50)
			containment_status = "breached"
		else if(breach_level > 25)
			containment_status = "compromised"
		else
			containment_status = "secure"

		containment_effectiveness = containment_health / 100

// Research Lab Datum
/datum/research_lab
	var/area_type
	var/research_capability = 100
	var/equipment_status = 100
	var/list/active_projects = list()
	var/research_efficiency = 1.0
	var/security_level = 1
	var/containment_level = 1

/datum/research_lab/New(var/type)
	area_type = type

/datum/research_lab/proc/update_status(var/area/A)
	if(A)
		// Calculate research capability based on equipment
		var/equipment_count = 0
		var/operational_equipment = 0

		for(var/obj/machinery/M in A)
			equipment_count++
			if(M) // Simplified operational check
				operational_equipment++

		if(equipment_count > 0)
			equipment_status = (operational_equipment / equipment_count) * 100
			research_capability = equipment_status
			research_efficiency = equipment_status / 100

// Medical Facility Datum
/datum/medical_facility
	var/area_type
	var/medical_capability = 100
	var/equipment_status = 100
	var/supply_level = 100
	var/patient_capacity = 10
	var/current_patients = 0
	var/medical_efficiency = 1.0

/datum/medical_facility/New(var/type)
	area_type = type

/datum/medical_facility/proc/update_status(var/area/A)
	if(A)
		// Calculate medical capability
		var/equipment_count = 0
		var/operational_equipment = 0

		for(var/obj/machinery/M in A)
			if(istype(M, /obj/machinery))
				equipment_count++
				if(M) // Simplified operational check
					operational_equipment++

		if(equipment_count > 0)
			equipment_status = (operational_equipment / equipment_count) * 100
			medical_capability = equipment_status
			medical_efficiency = equipment_status / 100

// Engineering System Datum
/datum/engineering_system
	var/area_type
	var/system_health = 100
	var/operational_status = 100
	var/power_output = 0
	var/efficiency = 1.0
	var/maintenance_required = FALSE
	var/list/connected_systems = list()

/datum/engineering_system/New(var/type)
	area_type = type

/datum/engineering_system/proc/update_status(var/area/A)
	if(A)
		// Calculate system health
		var/damage = 0
		for(var/obj/machinery/M in A)
			if(istype(M, /obj/machinery/power))
				damage += 0.1 // Simplified damage calculation

		system_health = max(0, 100 - damage * 100)
		operational_status = system_health
		efficiency = system_health / 100
		maintenance_required = system_health < 50
