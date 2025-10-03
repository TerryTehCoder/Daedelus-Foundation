// Analytics Persistence System
// Tracks performance metrics, efficiency data, and statistical analysis across all other persistence systems

SUBSYSTEM_DEF(analytics_persistence)
	name = "Analytics Persistence"
	wait = 1800 // 3 minutes
	priority = FIRE_PRIORITY_INPUT

	var/datum/analytics_persistence_manager/manager

/datum/analytics_persistence_manager
	var/list/performance_metrics = list() // metric_id -> performance_metric
	var/list/efficiency_data = list() // efficiency_id -> efficiency_data
	var/list/statistical_analysis = list() // analysis_id -> statistical_analysis
	var/list/trend_data = list() // trend_id -> trend_data
	var/list/kpi_records = list() // kpi_id -> kpi_record
	var/list/benchmark_data = list() // benchmark_id -> benchmark_data

	// Global analytics metrics
	var/overall_efficiency = 1.0
	var/performance_score = 100
	var/trend_direction = "STABLE" // IMPROVING, STABLE, DECLINING
	var/data_quality_score = 100
	var/analytics_budget = 200000

/datum/performance_metric
	var/metric_id
	var/metric_name
	var/metric_type
	var/metric_value = 0
	var/target_value = 0
	var/unit_of_measure
	var/measurement_date
	var/measurement_frequency = 24 // Hours
	var/trend_direction = "STABLE"
	var/performance_rating = "AVERAGE" // EXCELLENT, GOOD, AVERAGE, POOR, CRITICAL
	var/list/historical_data = list()
	var/list/contributing_factors = list()

/datum/performance_metric/New(var/metric_id, var/metric_name, var/metric_type, var/unit_of_measure)
	src.metric_id = metric_id
	src.metric_name = metric_name
	src.metric_type = metric_type
	src.unit_of_measure = unit_of_measure
	src.measurement_date = world.time

/datum/efficiency_data
	var/efficiency_id
	var/system_name
	var/efficiency_type
	var/efficiency_value = 1.0
	var/baseline_efficiency = 1.0
	var/peak_efficiency = 1.0
	var/measurement_date
	var/measurement_interval = 3600 // 1 hour in deciseconds
	var/list/efficiency_factors = list()
	var/list/optimization_opportunities = list()
	var/status = "NORMAL" // NORMAL, OPTIMIZED, DEGRADED, CRITICAL

/datum/efficiency_data/New(var/efficiency_id, var/system_name, var/efficiency_type)
	src.efficiency_id = efficiency_id
	src.system_name = system_name
	src.efficiency_type = efficiency_type
	src.measurement_date = world.time

/datum/statistical_analysis
	var/analysis_id
	var/analysis_type
	var/analysis_name
	var/analysis_date
	var/sample_size = 0
	var/confidence_level = 0.95
	var/list/statistical_measures = list()
	var/list/correlation_data = list()
	var/list/regression_data = list()
	var/analysis_notes = ""
	var/analysis_quality = "HIGH" // HIGH, MEDIUM, LOW

/datum/statistical_analysis/New(var/analysis_id, var/analysis_type, var/analysis_name)
	src.analysis_id = analysis_id
	src.analysis_type = analysis_type
	src.analysis_name = analysis_name
	src.analysis_date = world.time

/datum/trend_data
	var/trend_id
	var/trend_name
	var/trend_type
	var/trend_direction = "STABLE"
	var/trend_strength = 0.0
	var/trend_duration = 0
	var/start_date
	var/end_date
	var/list/trend_points = list()
	var/list/trend_indicators = list()
	var/trend_significance = "LOW" // LOW, MEDIUM, HIGH
	var/forecast_accuracy = 0.0

/datum/trend_data/New(var/trend_id, var/trend_name, var/trend_type)
	src.trend_id = trend_id
	src.trend_name = trend_name
	src.trend_type = trend_type
	src.start_date = world.time

/datum/kpi_record
	var/kpi_id
	var/kpi_name
	var/kpi_category
	var/current_value = 0
	var/target_value = 0
	var/previous_value = 0
	var/measurement_date
	var/measurement_period = "DAILY" // HOURLY, DAILY, WEEKLY, MONTHLY
	var/performance_status = "ON_TRACK" // ON_TRACK, AT_RISK, OFF_TRACK, ACHIEVED
	var/list/kpi_history = list()
	var/list/action_items = list()
	var/owner_ckey

/datum/kpi_record/New(var/kpi_id, var/kpi_name, var/kpi_category, var/owner_ckey)
	src.kpi_id = kpi_id
	src.kpi_name = kpi_name
	src.kpi_category = kpi_category
	src.owner_ckey = owner_ckey
	src.measurement_date = world.time

/datum/benchmark_data
	var/benchmark_id
	var/benchmark_name
	var/benchmark_category
	var/current_performance = 0
	var/industry_average = 0
	var/best_in_class = 0
	var/benchmark_date
	var/benchmark_source = "INTERNAL"
	var/list/benchmark_metrics = list()
	var/list/improvement_areas = list()
	var/competitive_position = "AVERAGE" // LEADING, ABOVE_AVERAGE, AVERAGE, BELOW_AVERAGE, LAGGING


/datum/benchmark_data/New(var/benchmark_id, var/benchmark_name, var/benchmark_category)
	src.benchmark_id = benchmark_id
	src.benchmark_name = benchmark_name
	src.benchmark_category = benchmark_category
	src.benchmark_date = world.time

// Subsystem initialization
/datum/controller/subsystem/analytics_persistence/Initialize()
	world.log << "Analytics persistence subsystem initializing..."
	manager = new /datum/analytics_persistence_manager()
	world.log << "Analytics persistence manager created"

	// Load existing analytics data from game systems
	world.log << "Loading existing analytics data..."
	manager.load_existing_analytics_data()

	world.log << "Performance metrics count at initialization: [manager.performance_metrics.len]"
	return ..()

/datum/controller/subsystem/analytics_persistence/fire()
	if(manager)
		manager.process_analytics()

// Load existing analytics data from game systems
/datum/analytics_persistence_manager/proc/load_existing_analytics_data()
	world.log << "Analytics: Loading existing analytics data..."

	// Initialize core performance metrics
	initialize_core_metrics()

	// Initialize efficiency tracking
	initialize_efficiency_tracking()

	// Initialize KPI framework
	initialize_kpi_framework()

	world.log << "Analytics: Core analytics framework initialized"

// Initialize core performance metrics
/datum/analytics_persistence_manager/proc/initialize_core_metrics()
	// Facility efficiency
	var/datum/performance_metric/facility_efficiency = new /datum/performance_metric(
		"FACILITY_EFF",
		"Facility Efficiency",
		"EFFICIENCY",
		"Percentage"
	)
	facility_efficiency.target_value = 85
	performance_metrics["FACILITY_EFF"] = facility_efficiency

	// Security effectiveness
	var/datum/performance_metric/security_effectiveness = new /datum/performance_metric(
		"SECURITY_EFF",
		"Security Effectiveness",
		"EFFECTIVENESS",
		"Percentage"
	)
	security_effectiveness.target_value = 90
	performance_metrics["SECURITY_EFF"] = security_effectiveness

	// Research productivity
	var/datum/performance_metric/research_productivity = new /datum/performance_metric(
		"RESEARCH_PROD",
		"Research Productivity",
		"PRODUCTIVITY",
		"Projects per month"
	)
	research_productivity.target_value = 10
	performance_metrics["RESEARCH_PROD"] = research_productivity

	// Medical response time
	var/datum/performance_metric/medical_response = new /datum/performance_metric(
		"MEDICAL_RESP",
		"Medical Response Time",
		"RESPONSE_TIME",
		"Minutes"
	)
	medical_response.target_value = 5
	performance_metrics["MEDICAL_RESP"] = medical_response

	// Personnel satisfaction
	var/datum/performance_metric/personnel_satisfaction = new /datum/performance_metric(
		"PERSONNEL_SAT",
		"Personnel Satisfaction",
		"SATISFACTION",
		"Score (1-100)"
	)
	personnel_satisfaction.target_value = 75
	performance_metrics["PERSONNEL_SAT"] = personnel_satisfaction

// Initialize efficiency tracking
/datum/analytics_persistence_manager/proc/initialize_efficiency_tracking()
	// Overall facility efficiency
	var/datum/efficiency_data/facility_efficiency = new /datum/efficiency_data(
		"FACILITY_OVERALL",
		"Facility Operations",
		"OVERALL"
	)
	efficiency_data["FACILITY_OVERALL"] = facility_efficiency

	// Security system efficiency
	var/datum/efficiency_data/security_efficiency = new /datum/efficiency_data(
		"SECURITY_SYS",
		"Security Systems",
		"SYSTEM"
	)
	efficiency_data["SECURITY_SYS"] = security_efficiency

	// Research efficiency
	var/datum/efficiency_data/research_efficiency = new /datum/efficiency_data(
		"RESEARCH_SYS",
		"Research Operations",
		"SYSTEM"
	)
	efficiency_data["RESEARCH_SYS"] = research_efficiency

	// Medical efficiency
	var/datum/efficiency_data/medical_efficiency = new /datum/efficiency_data(
		"MEDICAL_SYS",
		"Medical Operations",
		"SYSTEM"
	)
	efficiency_data["MEDICAL_SYS"] = medical_efficiency

// Initialize KPI framework
/datum/analytics_persistence_manager/proc/initialize_kpi_framework()
	// Containment success rate
	var/datum/kpi_record/containment_success = new /datum/kpi_record(
		"CONTAINMENT_SUCCESS",
		"Containment Success Rate",
		"SECURITY",
		"SYSTEM"
	)
	containment_success.target_value = 95
	kpi_records["CONTAINMENT_SUCCESS"] = containment_success

	// Research completion rate
	var/datum/kpi_record/research_completion = new /datum/kpi_record(
		"RESEARCH_COMPLETION",
		"Research Completion Rate",
		"RESEARCH",
		"SYSTEM"
	)
	research_completion.target_value = 80
	kpi_records["RESEARCH_COMPLETION"] = research_completion

	// Medical response time
	var/datum/kpi_record/medical_response_kpi = new /datum/kpi_record(
		"MEDICAL_RESPONSE_KPI",
		"Medical Response Time",
		"MEDICAL",
		"SYSTEM"
	)
	medical_response_kpi.target_value = 5
	kpi_records["MEDICAL_RESPONSE_KPI"] = medical_response_kpi

	// Personnel retention rate
	var/datum/kpi_record/personnel_retention = new /datum/kpi_record(
		"PERSONNEL_RETENTION",
		"Personnel Retention Rate",
		"PERSONNEL",
		"SYSTEM"
	)
	personnel_retention.target_value = 85
	kpi_records["PERSONNEL_RETENTION"] = personnel_retention

// Add performance metric
/datum/analytics_persistence_manager/proc/add_performance_metric(var/metric_name, var/metric_type, var/unit_of_measure)
	var/metric_id = "METRIC_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/performance_metric/metric = new /datum/performance_metric(
		metric_id,
		metric_name,
		metric_type,
		unit_of_measure
	)
	performance_metrics[metric_id] = metric
	return metric

// Add efficiency data
/datum/analytics_persistence_manager/proc/add_efficiency_data(var/system_name, var/efficiency_type)
	var/efficiency_id = "EFF_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/efficiency_data/efficiency = new /datum/efficiency_data(
		efficiency_id,
		system_name,
		efficiency_type
	)
	efficiency_data[efficiency_id] = efficiency
	return efficiency

// Add statistical analysis
/datum/analytics_persistence_manager/proc/add_statistical_analysis(var/analysis_type, var/analysis_name)
	var/analysis_id = "STAT_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/statistical_analysis/analysis = new /datum/statistical_analysis(
		analysis_id,
		analysis_type,
		analysis_name
	)
	statistical_analysis[analysis_id] = analysis
	return analysis

// Add trend data
/datum/analytics_persistence_manager/proc/add_trend_data(var/trend_name, var/trend_type)
	var/trend_id = "TREND_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/trend_data/trend = new /datum/trend_data(
		trend_id,
		trend_name,
		trend_type
	)
	trend_data[trend_id] = trend
	return trend

// Add KPI record
/datum/analytics_persistence_manager/proc/add_kpi_record(var/kpi_name, var/kpi_category, var/owner_ckey)
	var/kpi_id = "KPI_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/kpi_record/kpi = new /datum/kpi_record(
		kpi_id,
		kpi_name,
		kpi_category,
		owner_ckey
	)
	kpi_records[kpi_id] = kpi
	return kpi

// Add benchmark data
/datum/analytics_persistence_manager/proc/add_benchmark_data(var/benchmark_name, var/benchmark_category)
	var/benchmark_id = "BENCH_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/benchmark_data/benchmark = new /datum/benchmark_data(
		benchmark_id,
		benchmark_name,
		benchmark_category
	)
	benchmark_data[benchmark_id] = benchmark
	return benchmark

// Process analytics data
/datum/analytics_persistence_manager/proc/process_analytics()
	// Update performance metrics
	update_performance_metrics()

	// Update efficiency data
	update_efficiency_data()

	// Update statistical analysis
	update_statistical_analysis()

	// Update trend data
	update_trend_data()

	// Update KPI records
	update_kpi_records()

	// Update benchmark data
	update_benchmark_data()

	// Calculate global metrics
	calculate_global_analytics()

	// Save data periodically
	if(world.time % 36000 == 0) // Every hour
		save_analytics_data()

// Update performance metrics
/datum/analytics_persistence_manager/proc/update_performance_metrics()
	for(var/metric_id in performance_metrics)
		var/datum/performance_metric/metric = performance_metrics[metric_id]

		// Simulate metric changes
		if(prob(15)) // 15% chance for change
			var/change = rand(-10, 10)
			metric.metric_value = max(0, metric.metric_value + change)

			// Update performance rating based on target
			var/performance_ratio = metric.metric_value / metric.target_value
			if(performance_ratio >= 1.2)
				metric.performance_rating = "EXCELLENT"
			else if(performance_ratio >= 1.0)
				metric.performance_rating = "GOOD"
			else if(performance_ratio >= 0.8)
				metric.performance_rating = "AVERAGE"
			else if(performance_ratio >= 0.6)
				metric.performance_rating = "POOR"
			else
				metric.performance_rating = "CRITICAL"

		// Store historical data
		metric.historical_data += list(list("date" = world.time, "value" = metric.metric_value))

// Update efficiency data
/datum/analytics_persistence_manager/proc/update_efficiency_data()
	for(var/efficiency_id in efficiency_data)
		var/datum/efficiency_data/efficiency = efficiency_data[efficiency_id]

		// Simulate efficiency changes
		if(prob(10)) // 10% chance for change
			var/change = (rand(-5, 5) / 100.0)
			efficiency.efficiency_value = max(0.1, min(1.0, efficiency.efficiency_value + change))

			// Update status based on efficiency
			if(efficiency.efficiency_value >= 0.9)
				efficiency.status = "OPTIMIZED"
			else if(efficiency.efficiency_value >= 0.7)
				efficiency.status = "NORMAL"
			else if(efficiency.efficiency_value >= 0.5)
				efficiency.status = "DEGRADED"
			else
				efficiency.status = "CRITICAL"

// Update statistical analysis
/datum/analytics_persistence_manager/proc/update_statistical_analysis()
	for(var/analysis_id in statistical_analysis)
		var/datum/statistical_analysis/analysis = statistical_analysis[analysis_id]

		// Simulate analysis updates
		if(prob(5)) // 5% chance for update
			analysis.sample_size += rand(1, 10)
			analysis.analysis_quality = pick("HIGH", "MEDIUM", "LOW")

// Update trend data
/datum/analytics_persistence_manager/proc/update_trend_data()
	for(var/trend_id in trend_data)
		var/datum/trend_data/trend = trend_data[trend_id]

		// Simulate trend changes
		if(prob(8)) // 8% chance for change
			trend.trend_strength = max(0.0, min(1.0, trend.trend_strength + (rand(-10, 10) / 100.0)))

			// Update trend direction based on strength
			if(trend.trend_strength > 0.3)
				trend.trend_direction = "IMPROVING"
			else if(trend.trend_strength < -0.3)
				trend.trend_direction = "DECLINING"
			else
				trend.trend_direction = "STABLE"

// Update KPI records
/datum/analytics_persistence_manager/proc/update_kpi_records()
	for(var/kpi_id in kpi_records)
		var/datum/kpi_record/kpi = kpi_records[kpi_id]

		// Simulate KPI changes
		if(prob(12)) // 12% chance for change
			var/change = rand(-5, 5)
			kpi.previous_value = kpi.current_value
			kpi.current_value = max(0, kpi.current_value + change)

			// Update performance status based on target
			var/performance_ratio = kpi.current_value / kpi.target_value
			if(performance_ratio >= 1.0)
				kpi.performance_status = "ACHIEVED"
			else if(performance_ratio >= 0.8)
				kpi.performance_status = "ON_TRACK"
			else if(performance_ratio >= 0.6)
				kpi.performance_status = "AT_RISK"
			else
				kpi.performance_status = "OFF_TRACK"

		// Store KPI history
		kpi.kpi_history += list(list("date" = world.time, "value" = kpi.current_value))

// Update benchmark data
/datum/analytics_persistence_manager/proc/update_benchmark_data()
	for(var/benchmark_id in benchmark_data)
		var/datum/benchmark_data/benchmark = benchmark_data[benchmark_id]

		// Simulate benchmark updates
		if(prob(3)) // 3% chance for update
			benchmark.current_performance += rand(-2, 2)

			// Update competitive position
			var/performance_ratio = benchmark.current_performance / benchmark.industry_average
			if(performance_ratio >= 1.5)
				benchmark.competitive_position = "LEADING"
			else if(performance_ratio >= 1.2)
				benchmark.competitive_position = "ABOVE_AVERAGE"
			else if(performance_ratio >= 0.8)
				benchmark.competitive_position = "AVERAGE"
			else if(performance_ratio >= 0.6)
				benchmark.competitive_position = "BELOW_AVERAGE"
			else
				benchmark.competitive_position = "LAGGING"

// Calculate global analytics
/datum/analytics_persistence_manager/proc/calculate_global_analytics()
	// Calculate overall efficiency
	var/total_efficiency = 0
	var/efficiency_count = 0
	for(var/efficiency_id in efficiency_data)
		var/datum/efficiency_data/efficiency = efficiency_data[efficiency_id]
		total_efficiency += efficiency.efficiency_value
		efficiency_count++

	if(efficiency_count > 0)
		overall_efficiency = total_efficiency / efficiency_count

	// Calculate performance score
	var/total_performance = 0
	var/metric_count = 0
	for(var/metric_id in performance_metrics)
		var/datum/performance_metric/metric = performance_metrics[metric_id]
		var/performance_ratio = metric.metric_value / metric.target_value
		total_performance += min(100, performance_ratio * 100)
		metric_count++

	if(metric_count > 0)
		performance_score = total_performance / metric_count

	// Calculate trend direction
	var/improving_count = 0
	var/declining_count = 0
	var/stable_count = 0

	for(var/trend_id in trend_data)
		var/datum/trend_data/trend = trend_data[trend_id]
		switch(trend.trend_direction)
			if("IMPROVING")
				improving_count++
			if("DECLINING")
				declining_count++
			if("STABLE")
				stable_count++

	if(improving_count > declining_count && improving_count > stable_count)
		trend_direction = "IMPROVING"
	else if(declining_count > improving_count && declining_count > stable_count)
		trend_direction = "DECLINING"
	else
		trend_direction = "STABLE"

	// Calculate data quality score
	var/total_quality = 0
	var/analysis_count = 0
	for(var/analysis_id in statistical_analysis)
		var/datum/statistical_analysis/analysis = statistical_analysis[analysis_id]
		switch(analysis.analysis_quality)
			if("HIGH")
				total_quality += 100
			if("MEDIUM")
				total_quality += 70
			if("LOW")
				total_quality += 40
		analysis_count++

	if(analysis_count > 0)
		data_quality_score = total_quality / analysis_count

// Save analytics data
/datum/analytics_persistence_manager/proc/save_analytics_data()
	// This would save data to persistent storage
	world.log << "Analytics: Saving analytics data to persistent storage"
