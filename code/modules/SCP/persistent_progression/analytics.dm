/datum/analytics_tracker
	var/list/performance_data = list()
	var/list/trend_data = list()
	var/list/comparison_data = list()
	var/list/insights = list()
	var/last_analysis_time = 0
	var/analysis_interval = 300 // 5 minutes

/datum/analytics_tracker/proc/track_performance(metric, value, timestamp = world.time)
	if(!performance_data[metric])
		performance_data[metric] = list()

	var/list/metric_data = list(
		"value" = value,
		"timestamp" = timestamp
	)
	performance_data[metric] += metric_data

/datum/analytics_tracker/proc/analyze_trends()
	var/list/trends = list()

	for(var/metric in performance_data)
		var/list/metric_data = performance_data[metric]
		if(metric_data.len >= 2)
			var/trend = calculate_trend(metric_data)
			trends[metric] = trend

	trend_data = trends
	last_analysis_time = world.time

/datum/analytics_tracker/proc/calculate_trend(data_points)
	var/list/values = list()
	for(var/data_point in data_points)
		values += data_point["value"]

	if(values.len < 2)
		return "insufficient_data"

	// Calculate simple trend (increasing, decreasing, stable)
	var/first_half = 0
	var/second_half = 0
	var/midpoint = round(values.len / 2)

	for(var/i = 1; i <= midpoint; i++)
		first_half += values[i]

	for(var/i = midpoint + 1; i <= values.len; i++)
		second_half += values[i]

	var/first_avg = first_half / midpoint
	var/second_avg = second_half / (values.len - midpoint)

	if(second_avg > first_avg * 1.1)
		return "increasing"
	else if(second_avg < first_avg * 0.9)
		return "decreasing"
	else
		return "stable"

/datum/analytics_tracker/proc/generate_insights()
	var/list/new_insights = list()

	// Performance insights
	var/total_exp = get_total_experience()
	var/avg_exp_per_round = get_average_experience_per_round()
	var/survival_rate = get_survival_rate()

	if(total_exp > 10000)
		new_insights += "You're a veteran player with over 10,000 experience!"

	if(avg_exp_per_round > 500)
		new_insights += "You're gaining experience very efficiently!"

	if(survival_rate > 80)
		new_insights += "Excellent survival rate! You're very skilled at staying alive."

	// Trend insights
	for(var/metric in trend_data)
		var/trend = trend_data[metric]
		if(trend == "increasing")
			new_insights += "Your [metric] performance is improving!"
		else if(trend == "decreasing")
			new_insights += "Your [metric] performance has been declining recently."

	insights = new_insights

/datum/analytics_tracker/proc/get_total_experience()
	var/total = 0
	if(performance_data["experience_gained"])
		for(var/data_point in performance_data["experience_gained"])
			total += data_point["value"]
	return total

/datum/analytics_tracker/proc/get_average_experience_per_round()
	var/total_rounds = 0
	if(performance_data["rounds_played"])
		var/list/rounds_list = performance_data["rounds_played"]
		total_rounds = rounds_list.len

	if(total_rounds == 0)
		return 0

	return get_total_experience() / total_rounds

/datum/analytics_tracker/proc/get_survival_rate()
	var/survived = 0
	var/total = 0

	if(performance_data["rounds_survived"])
		var/list/survived_list = performance_data["rounds_survived"]
		survived = survived_list.len

	if(performance_data["rounds_played"])
		var/list/played_list = performance_data["rounds_played"]
		total = played_list.len

	if(total == 0)
		return 0

	return (survived / total) * 100

/datum/analytics_tracker/proc/get_performance_summary()
	var/list/summary = list()

	summary["total_experience"] = get_total_experience()
	summary["average_experience_per_round"] = get_average_experience_per_round()
	summary["survival_rate"] = get_survival_rate()
	var/rounds_count = 0
	if(performance_data["rounds_played"])
		var/list/rounds_list = performance_data["rounds_played"]
		rounds_count = rounds_list.len
	summary["total_rounds"] = rounds_count
	summary["trends"] = trend_data
	summary["insights"] = insights

	return summary

// Player Analytics Manager
/datum/player_analytics_manager
	var/list/player_analytics = list()

/datum/player_analytics_manager/proc/get_player_analytics(ckey)
	if(!player_analytics[ckey])
		player_analytics[ckey] = new /datum/analytics_tracker()
	return player_analytics[ckey]

/datum/player_analytics_manager/proc/track_player_metric(ckey, metric, value, timestamp = world.time)
	var/datum/analytics_tracker/tracker = get_player_analytics(ckey)
	tracker.track_performance(metric, value, timestamp)

/datum/player_analytics_manager/proc/get_player_summary(ckey)
	var/datum/analytics_tracker/tracker = get_player_analytics(ckey)
	tracker.analyze_trends()
	tracker.generate_insights()
	return tracker.get_performance_summary()

/datum/player_analytics_manager/proc/get_global_statistics()
	var/list/global_stats = list()
	var/list/analytics_list = player_analytics
	var/total_players = analytics_list.len
	var/total_experience = 0
	var/total_rounds = 0

	for(var/ckey in player_analytics)
		var/datum/analytics_tracker/tracker = player_analytics[ckey]
		total_experience += tracker.get_total_experience()
		var/rounds_count = 0
		if(tracker.performance_data["rounds_played"])
			var/list/rounds_list = tracker.performance_data["rounds_played"]
			rounds_count = rounds_list.len
		total_rounds += rounds_count

	global_stats["total_players"] = total_players
	global_stats["total_experience"] = total_experience
	global_stats["total_rounds"] = total_rounds
	global_stats["average_experience_per_player"] = total_players > 0 ? total_experience / total_players : 0
	global_stats["average_rounds_per_player"] = total_players > 0 ? total_rounds / total_players : 0

	return global_stats

