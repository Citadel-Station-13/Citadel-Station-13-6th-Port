/*
	These defines are specific to the atom/flags_1 bitmask
*/
#define ALL (~0) //For convenience.
#define NONE 0

//for convenience
#define ENABLE_BITFIELD(variable, flag) (variable |= (flag))
#define DISABLE_BITFIELD(variable, flag) (variable &= ~(flag))
#define CHECK_BITFIELD(variable, flag) (variable & (flag))
#define TOGGLE_BITFIELD(variable, flag) (variable ^= (flag))
#define COPY_SPECIFIC_BITFIELDS(a,b,flags)\
	do{\
		var/_old = a & ~(flags);\
		var/_cleaned = b & (flags);\
		a = _old | _cleaned;\
	} while(0);
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) (((flagvar) & (flags)) == (flags))

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK
///This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define HEAR_1						(1<<3)
///Projectiles will use default chance-based ricochet handling on things with this.
#define DEFAULT_RICOCHET_1			(1<<4)
///Conducts electricity (metal etc.).
#define CONDUCT_1					(1<<5)
///For machines and structures that should not break into parts, eg, holodeck stuff.
#define NODECONSTRUCT_1				(1<<7)
///Atom queued to SSoverlay.
#define OVERLAY_QUEUED_1			(1<<8)
///Item has priority to check when entering or leaving.
#define ON_BORDER_1					(1<<9)
///Prevent clicking things below it on the same turf eg. doors/ fulltile windows.
#define PREVENT_CLICK_UNDER_1		(1<<11)
#define HOLOGRAM_1					(1<<12)
///Prevents mobs from getting chainshocked by teslas and the supermatter.
#define SHOCKED_1 					(1<<13)
///Whether /atom/Initialize() has already run for the object.
#define INITIALIZED_1				(1<<14)
///was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED_1				(1<<15)
/// should not get harmed if this gets caught by an explosion?
#define PREVENT_CONTENTS_EXPLOSION_1 (1<<16)
/// Early returns mob.face_atom()
#define BLOCK_FACE_ATOM_1			(1<<17)

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's greyscaling
#define UPDATE_GREYSCALE (1<<4)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

//turf-only flags
#define NOJAUNT_1 (1<<0)
#define UNUSED_RESERVATION_TURF_1 (1<<1)
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY_1 (1<<2)
/// If blood cultists can draw runes or build structures on this turf
#define CULT_PERMITTED_1 (1<<3)
/// Blocks lava rivers being generated on the turf
#define NO_LAVA_GEN_1 (1<<6)
/// Blocks ruins spawning on the turf
#define NO_RUINS_1 (1<<10)
/// Should this tile be cleaned up and reinserted into an excited group?
#define EXCITED_CLEANUP_1 (1 << 13)

////////////////Area flags\\\\\\\\\\\\\\
/// If it's a valid territory for cult summoning or the CRAB-17 phone to spawn
#define VALID_TERRITORY (1<<0)
/// If blobs can spawn there and if it counts towards their score.
#define BLOBS_ALLOWED (1<<1)
/// If mining tunnel generation is allowed in this area
#define CAVES_ALLOWED (1<<2)
/// If flora are allowed to spawn in this area randomly through tunnel generation
#define FLORA_ALLOWED (1<<3)
/// If mobs can be spawned by natural random generation
#define MOB_SPAWN_ALLOWED (1<<4)
/// If megafauna can be spawned by natural random generation
#define MEGAFAUNA_SPAWN_ALLOWED (1<<5)
/// Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
#define NOTELEPORT (1<<6)
/// Hides area from player Teleport function.
#define HIDDEN_AREA (1<<7)
/// If false, loading multiple maps with this area type will create multiple instances.
#define UNIQUE_AREA (1<<8)
/// If people are allowed to suicide in it. Mostly for OOC stuff like minigames
#define BLOCK_SUICIDE (1<<9)
/// Can the Xenobio management console transverse this area by default?
#define XENOBIOLOGY_COMPATIBLE (1<<10)
/// If Abductors are unable to teleport in with their observation console
#define ABDUCTOR_PROOF (1<<11)
/// If an area should be hidden from power consoles, power/atmosphere alerts, etc.
#define NO_ALERTS (1<<12)

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE		(1<<0)
#define PASSGLASS		(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define PASSCLOSEDTURF	(1<<5)
#define LETPASSTHROW	(1<<6)

//Movement Types
#define GROUND				(1<<0)
#define FLYING				(1<<1)
#define VENTCRAWLING		(1<<2)
#define FLOATING			(1<<3)
///When moving, will Bump()/Cross()/Uncross() everything, but won't be stopped.
#define UNSTOPPABLE			(1<<4)
///Applied if you're crawling around on the ground/resting.
#define CRAWLING			(1<<5)

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //doesn't take damage
#define FREEZE_PROOF	(1<<7) //can't be frozen
#define GOLIATH_RESISTANCE (1<<8) //CIT CHANGE
#define GOLIATH_WEAKNESS (1<<9) //CIT CHANGE

//tesla_zap
#define ZAP_MACHINE_EXPLOSIVE		(1<<0)
#define ZAP_ALLOW_DUPLICATES		(1<<1)
#define ZAP_OBJ_DAMAGE			(1<<2)
#define ZAP_MOB_DAMAGE			(1<<3)
#define ZAP_MOB_STUN			(1<<4)

#define ZAP_DEFAULT_FLAGS ZAP_MOB_STUN | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
#define ZAP_FUSION_FLAGS ZAP_OBJ_DAMAGE | ZAP_MOB_DAMAGE | ZAP_MOB_STUN
#define ZAP_SUPERMATTER_FLAGS NONE

//EMP protection
#define EMP_PROTECT_SELF (1<<0)
#define EMP_PROTECT_CONTENTS (1<<1)
#define EMP_PROTECT_WIRES (1<<2)

// radiation
#define RAD_PROTECT_CONTENTS (1<<0)
#define RAD_NO_CONTAMINATE (1<<1)

//Mob mobility var flags
/// any flag
#define CHECK_MOBILITY(target, flags) CHECK_BITFIELD(target.mobility_flags, flags)
#define CHECK_ALL_MOBILITY(target, flags) CHECK_MULTIPLE_BITFIELDS(target.mobility_flags, flags)

/// can move
#define MOBILITY_MOVE			(1<<0)
/// can, and is, standing up.
#define MOBILITY_STAND			(1<<1)
/// can pickup items
#define MOBILITY_PICKUP			(1<<2)
/// can use items and interact with world objects like opening closets/etc
#define MOBILITY_USE			(1<<3)
/// can use interfaces like consoles
#define MOBILITY_UI				(1<<4)
/// can use storage item
#define MOBILITY_STORAGE		(1<<5)
/// can pull things
#define MOBILITY_PULL			(1<<6)
/// can hold non-nodropped items voluntarily
#define MOBILITY_HOLD			(1<<7)
/// Can resist out of buckling, grabs, cuffs, etc, in the usual order (buckle --> cuffs --> grab)
#define MOBILITY_RESIST			(1<<8)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL | MOBILITY_RESIST)
#define MOBILITY_FLAGS_ANY_INTERACTION (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_UI | MOBILITY_STORAGE)

/// If the thing can reflect light (lasers/energy)
#define RICOCHET_SHINY			(1<<0)
/// If the thing can reflect matter (bullets/bomb shrapnel)
#define RICOCHET_HARD			(1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
	 	x.appearance_flags &= ~KEEP_TOGETHER

//dir macros
///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d)   (d&(EAST|WEST))
///Flips the dir for north/south directions
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d)     (d^(EAST|WEST))
///Turns the dir by 180 degrees
#define DIRFLIP(d)       turn(d, 180)

/// 33554431 (2^24 - 1) is the maximum value our bitflags can reach.
#define MAX_BITFLAG_DIGITS 8
