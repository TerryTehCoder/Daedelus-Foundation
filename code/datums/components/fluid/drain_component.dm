// A component that drains fluid from its parent turf each tick.
// You could attach it to something like your own drain, or get more creative,
// up to you.

/datum/component/drain
	var/drain_rate = 100 // Amount of fluid drained per tick (or per second, depending on subsystem wait)
	var/datum/fluid/drained_fluid_type // If specified, only drains this fluid type. Null drains any.

/datum/component/drain/Initialize()
	. = ..()
	// This component will be processed by the ComponentFluidSimulationSubsystem
	// when its parent turf is active with fluid.
	// No direct signal registration needed here, as the subsystem will query for it.

/datum/component/drain/Destroy()
	. = ..()

/datum/component/drain/proc/drain_fluid(datum/component/fluid/fluid_comp, delta_time)
	if (!fluid_comp || fluid_comp.fluid_amount <= FLUID_DELETING)
		return

	if (drained_fluid_type && fluid_comp.fluid_type != drained_fluid_type)
		return

	var/amount_to_drain = drain_rate * delta_time
	fluid_comp.removeFluid(amount_to_drain)
