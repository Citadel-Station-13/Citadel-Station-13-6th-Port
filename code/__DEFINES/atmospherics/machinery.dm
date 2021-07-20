//MULTIPIPES
//IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH.
#define PIPE_LAYER_MIN 1
#define PIPE_LAYER_MAX 5
#define PIPE_LAYER_DEFAULT 3
/// Total pipe layers. KEEP THIS UP TO DATE.
#define PIPE_LAYER_TOTAL 5
#define PIPE_LAYER_P_X 5
#define PIPE_LAYER_P_Y 5
#define PIPE_LAYER_LCHANGE 0.05

#define PIPE_ALL_LAYER				(1<<0)	//intended to connect with all layers, check for all instead of just one.
#define PIPE_ONE_PER_TURF				(1<<1) 	//can only be built if nothing else with this flag is on the tile already.
#define PIPE_DEFAULT_LAYER_ONLY		(1<<2)	//can only exist at PIPE_LAYER_DEFAULT
#define PIPE_CARDINAL_AUTONORMALIZE	(1<<3)	//north/south east/west doesn't matter, auto normalize on build.
/// We've joined to pipe network + fully initialized. This can be true even if we're queued for a rebuild.
#define PIPE_NETWORK_JOINED			(1<<4)
/// We're queued for a pipenet rebuild.
#define PIPE_REBUILD_QUEUED			(1<<5)

// CheckLocationConflict return values
/// Can fit there
#define PIPE_LOCATION_CLEAR			0
/// Another one per turf object is on it
#define PIPE_LOCATION_TILE_HOGGED	1
/// Normal conflict
#define PIPE_LOCATION_DIR_CONFLICT	2

//HELPERS
#define PIPE_LAYER_SHIFT(T, PipingLayer) \
	if(T.dir & (NORTH|SOUTH)) {									\
		T.pixel_x = (PipingLayer - PIPE_LAYER_DEFAULT) * PIPE_LAYER_P_X;\
	}																		\
	if(T.dir & (WEST|EAST)) {										\
		T.pixel_y = (PipingLayer - PIPE_LAYER_DEFAULT) * PIPE_LAYER_P_Y;\
	}

#define PIPE_LAYER_DOUBLE_SHIFT(T, PipingLayer) \
	T.pixel_x = (PipingLayer - PIPE_LAYER_DEFAULT) * PIPE_LAYER_P_X;\
	T.pixel_y = (PipingLayer - PIPE_LAYER_DEFAULT) * PIPE_LAYER_P_Y;

// Balancing - overall
/// Pump rate in L/s at which pumps "give up"
#define ATMOSMECH_FUTILE_PUMP_RATE				0.1
/// Global multiplier for pumping efficiency - higher means less power is needed to pump.
#define ATMOSMECH_GLOBAL_EFFICIENCY_MULTIPLIER	1

// Balancing - defaults
/// Maximum pressure things can pressurize to
#define ATMOSMECH_PUMP_PRESSURE					100000
/// Maximum transfer rate in L/s things can move air at
#define ATMOSMECH_PUMP_RATE						200
/// Moles at which pumping is instant
#define ATMOSMECH_INSTANT_PUMP_MOLES			0.5
/// Pressure at which pumping is instant
#define ATMOSMECH_INSTANT_PUMP_PRESSURE			0.5
/// Default power rating of machinery
#define ATMOSMECH_POWER_RATING					45000

// Balancing - overrides

//used for device_type vars
#define UNARY		1
#define BINARY 		2
#define TRINARY		3
#define QUATERNARY	4
