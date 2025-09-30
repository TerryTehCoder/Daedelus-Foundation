#define FLUID_EVAPORATION_POINT 3          // Depth a fluid begins self-deleting
#define FLUID_DELETING -1                  // Depth a fluid counts as qdel'd
#define FLUID_SHALLOW 100            // Depth shallow icon is used
#define FLUID_WAIST_DEEP 250               // Depth for waist-deep fluid
#define FLUID_OVER_MOB_HEAD 300
#define FLUID_MID_STILL 350                // Depth for mid-deep fluid
#define FLUID_DEEP 500               // Depth for deep fluid
#define FLUID_DEEPEST 800           // Depth for deepest fluid
#define FLUID_MAX_DEPTH (FLUID_DEEPEST *4) // Arbitrary max value for flooding.
#define FLUID_PUSH_THRESHOLD 20            // Amount of water flow needed to push items.

#define FLUID_MAX_ALPHA 160
#define FLUID_MIN_ALPHA 45

#define SWIM_SPEED_MODIFIER_SHALLOW 0.8    // Speed modifier when wading in shallow fluid
#define SWIM_SPEED_MODIFIER_DEEP 0.4       // Speed modifier when fully swimming

// Signals for fluid components
#define COMSIG_PARENT_FLUID_AMOUNT_CHANGED "fluid_amount_changed" // Emitted by parent when fluid amount changes
#define COMSIG_FLUID_VISUAL_STATE_CHANGED "fluid_visual_state_changed" // Emitted by FluidComponent when visual state changes
#define COMSIG_PARENT_ENTERED_TURF "parent_entered_turf" // Emitted when an atom enters a new turf: (atom/movable/parent_atom, turf/old_loc, turf/new_loc)
#define COMSIG_PARENT_EXITED_TURF "parent_exited_turf" // Emitted when an atom exits a turf: (atom/movable/parent_atom, turf/old_loc, turf/new_loc)
#define COMSIG_FLUID_COMPONENT_DIRTY "fluid_component_dirty" // Emitted by FluidComponent when its fluid amount changes and needs re-evaluation
#define COMSIG_GLOB_FLUID_COMPONENT_DIRTY "glob_fluid_component_dirty" // Emitted globally when any fluid component becomes dirty (needing re-evaluation)
#define COMSIG_FLUID_SIMULATION_READY "fluid_simulation_ready" // Emitted by FluidSimulationSubsystem when initialized

// Signal for fluid source components
#define COMSIG_FLUID_SOURCE_GENERATED "fluid_source_generated" // Emitted by FluidSourceComponent when fluid is generated

// Signals for floodable components
#define COMSIG_FLOODING_STARTED "flooding_started" // Emitted when a turf starts flooding
#define COMSIG_FLOODING_PROGRESS "flooding_progress" // Emitted as fluid level changes
#define COMSIG_FLOODING_COMPLETED "flooding_completed" // Emitted when the turf is fully flooded
#define COMSIG_FLOODING_BREACH_STATE_CHANGED "flooding_breach_state_changed" // Emitted when breach state changes

// Signals for breach components
#define COMSIG_BREACH_CREATED "breach_created" // Emitted when a breach occurs
#define COMSIG_BREACH_REPAIRED "breach_repaired" // Emitted when a breach is fixed
#define COMSIG_BREACH_STATE_CHANGED "breach_state_changed" // Emitted when breach state changes (true/false)

// Signals for movable fluid interaction components
#define COMSIG_FLUID_INTERACTION_ENTERED_FLUID "entered_fluid"
#define COMSIG_FLUID_INTERACTION_EXITED_FLUID "exited_fluid"
#define COMSIG_FLUID_INTERACTION_SWIMMING_STATE_CHANGED "swimming_state_changed"
#define COMSIG_FLUID_INTERACTION_DROWNING_STATE_CHANGED "drowning_state_changed"

#define COMSIG_FLUID_INTERACTION_DROWNING_DAMAGE_TAKEN "drowning_damage_taken"
#define COMSIG_FLUID_INTERACTION_RESTRICTED_STATE_CHANGED "fluid_interaction_restricted_state_changed" // Emitted when waist-deep state changes

#define FLUID_COLD_THRESHOLD 270 // Example: 270K (approx -3C)
#define FLUID_HOT_THRESHOLD 350  // Example: 350K (approx 77C)

#define FLUID_EXPLOSION_KNOCKBACK_MULTIPLIER 2 // Multiplier for explosion knockback in fluid

// Pathfinding cost multipliers - TD
#define FLUID_PATH_COST_SHALLOW_MULTIPLIER 1.5
#define FLUID_PATH_COST_WAIST_DEEP_MULTIPLIER 2.5
#define FLUID_PATH_COST_MID_STILL_MULTIPLIER 3.5
#define FLUID_PATH_COST_DEEP_STILL_MULTIPLIER 5.0
#define FLUID_PATH_COST_DEEPEST_STILL_MULTIPLIER 7.5
#define FLUID_PATH_COST_IMPASSABLE 99999 // A very high number to simulate impassable fluid

// Signals for fluid simulation system
#define COMSIG_FLUID_SIMULATION_TURF_ACTIVE "fluid_simulation_turf_active"
#define COMSIG_FLUID_SIMULATION_TURF_INACTIVE "fluid_simulation_turf_inactive"

// Fluid visual layers
#define SHALLOW_FLUID_LAYER (MOB_LAYER - 0.1) // Slightly below mobs for shallow fluid
#define DEEP_FLUID_LAYER (MOB_LAYER + 0.1)    // Higher layer for deep fluid

// Fluid property multipliers
#define FLUID_VISCOSITY_FLOW_DIVISOR 10 // Divisor for viscosity in flow calculations (e.g., 1 / viscosity * FLUID_VISCOSITY_FLOW_DIVISOR)
#define FLUID_PUSH_VISCOSITY_DIVISOR 10 // Divisor for viscosity when pushing objects
#define FLUID_PUSH_DENSITY_MULTIPLIER 1000 // Multiplier for density when pushing objects (e.g., fluid_density / atom_density * FLUID_PUSH_DENSITY_MULTIPLIER)
#define FLUID_BUOYANCY_THRESHOLD 0.9 // If atom density is less than fluid density * this, it floats
#define FLUID_EXPLOSION_DENSITY_NORMALIZER 1000 // Normalizes fluid density for explosion knockback (e.g., fluid_density / 1000)

// Mob visual offsets and cut_icon dimensions for fluid interaction
#define FLUID_MOB_PIXEL_OFFSET_SHALLOW -4
#define FLUID_MOB_PIXEL_OFFSET_WAIST_DEEP -8
#define FLUID_MOB_PIXEL_OFFSET_DEEP -12
#define FLUID_MOB_PIXEL_OFFSET_DROWNING -16 // Even deeper when drowning

// Assuming a base mob icon size of 32x32 pixels for cut_icon calculations
#define FLUID_MOB_CUT_ICON_SHALLOW "0,0,32,28" // Cuts 4 pixels from bottom
#define FLUID_MOB_CUT_ICON_WAIST_DEEP "0,0,32,24" // Cuts 8 pixels from bottom
#define FLUID_MOB_CUT_ICON_DEEP "0,0,32,20" // Cuts 12 pixels from bottom
#define FLUID_MOB_CUT_ICON_DROWNING "0,0,32,16" // Cuts 16 pixels from bottom

#define FLUID_MOB_FLOAT_AMPLITUDE 1 // Max pixel offset for floating animation
#define FLUID_MOB_FLOAT_SPEED 0.1 // Speed of floating animation (lower is slower)

// Drowning and underwater mechanics
#define SWIM_SPEED_MODIFIER_DROWNING 0.3 // Further reduced speed when drowning
#define MAX_DROWNING_TIME 10 SECONDS // Time before unconscious mob teleports underwater
#define OXY_DAMAGE_UNDERWATER 4 // Oxygen damage per tick when underwater
#define MAX_COLD_EXPOSURE_TIME 60 SECONDS // Time before mob becomes unconscious from cold shock

// Z-level traits
#define Z_TRAIT_UNDERWATER "underwater"
