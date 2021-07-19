// suit_type defines
/// Standard RIG meant for hostile environments - so basically hardsuits
#define RIG_TYPE_STANDARD				(1<<0)
/// Powered exoskeletons, armor, etc, aren't meant to be logically "sealed".
#define RIG_TYPE_EXOARMOR				(1<<1)

// Rig zones
#define RIG_ZONE_HEAD	"head"
#define RIG_ZONE_CHEST	"chest"
#define RIG_ZONE_L_ARM	"l_arm"
#define RIG_ZONE_R_ARM	"r_arm"
#define RIG_ZONE_L_LEG	"l_leg"
#define RIG_ZONE_R_LEG	"r_leg"
/// This represents full body modules - these modules will take slots and size from all zones.
#define RIG_ZONE_ALL	"all"

// Rig piece types - only one of each type should exist on a given rig.
// This is a bitfield
/// Head - RIG_ZONE_HEAD translates to this
#define RIG_PIECE_HEAD		(1<<0)
/// Suit - RIG_ZONE_CHEST translates to this
#define RIG_PIECE_SUIT		(1<<1)
/// Gauntlets - RIG_ZONE_L/R_ARM translates to this
#define RIG_PIECE_GAUNTLETS	(1<<2)
/// Boots - RIG_ZONE_L/R_LEG translates to this
#define RIG_PIECE_BOOTS		(1<<3)

// Rig piece applying effects
/// Apply armor
#define RIG_PIECE_APPLY_ARMOR			(1<<0)
/// Apply thermal shielding
#define RIG_PIECE_APPLY_THERMALS		(1<<1)
/// Apply pressure shielding/thickmaterial/similar
#define RIG_PIECE_APPLY_PRESSURE		(1<<2)

// Global list lookup for rig zone to piece bitflag
GLOBAL_LIST_INIT(rig_zone_lookup, list(
	RIG_ZONE_HEAD = RIG_PIECE_HEAD,
	RIG_ZONE_CHEST = RIG_PIECE_SUIT,
	RIG_ZONE_L_ARM = RIG_PIECE_GAUNTLETS,
	RIG_ZONE_R_ARM = RIG_PIECE_GAUNTLETS,
	RIG_ZONE_L_LEG = RIG_PIECE_BOOTS,
	RIG_ZONE_R_LEG = RIG_PIECE_BOOTS
))

// Flags for starting_components
/// Unremovable, but does not go towards any weight/slot/etc limits. Ignores conflicts.
#define RIG_INITIAL_MODULE_INBUILT			(1<<0)


/**
 * Rigsuit balancing paradigm:
 *
 * Slots/sizes act as complexity per piece.
 * Armor, thermal plating, pressure plating are all "RIG_ZONE_ALL" pieces, meaning they cost slots/size on every piece.
 *
 * SIZES:
 * Offensive/defensive capabilities should be balanced via sizes. Heavy armor in addition to any weight penalties have a large size.
 * Weapons will also require larger than average size.
 * Utility modules shouldn't require much size at all - the goal is to make rigs not require backpacks, after all.
 *
 * SLOTS:
 * "Master of all trades" rigsuits are kneecapped by slots.
 * Powerful, primary departmental modules like RCDs, kinetic glaives, chemical injector-synthesizers, and anything as powerful as that should
 * cost enough slots to not allow more than 2-3 per RIG.
 * Smaller time jack of all trade toolsets like the toolset-implant equivalent/power tools, etc, will require a medium amount of slots
 * Misc items like a weak prybar for getting around depowered airlocks will require minimal slots
 *
 * **STORAGE**, once implemented, will require large amounts of size and slots, as it is the equivalent to allowing one to bypass this system entirely while wearing a RIG by carrying their own gear.
 */

// Slots
/// Default slots available per piece
#define DEFAULT_SLOTS_AVAILABLE			20

// Sizes
/// Default max size per piece
#define DEFAULT_SIZE_AVAILABLE			10

// Control flags
/// Default control flags
#define RIG_CONTROL_DEFAULT						ALL
/// Can move the suit
#define RIG_CONTROL_MOVEMENT					(1<<0)
/// Can use hands
#define RIG_CONTROL_HANDS						(1<<1)
/// Can activate/deactivate the rig
#define RIG_CONTROL_ACTIVATION					(1<<2)
/// Can view UI
#define RIG_CONTROL_UI_VIEW						(1<<3)
/// Can control UI other than modules (modules is UI_MODULES)
#define RIG_CONTROL_UI_CONTROL					(1<<4)
/// Can interact with hotbinds
#define RIG_CONTROL_USE_HOTBINDS				(1<<4)
/// Can activate non hotbound modules
#define RIG_CONTROL_UI_MODULES					(1<<5)
/// Can deploy/undeploy pieces
#define RIG_CONTROL_DEPLOY						(1<<6)

// Component types
/// Generic default
#define RIG_COMPONENT_GENERIC					0
/// Item holder components - primarily just deploys items to the user's hands
#define RIG_COMPONENT_ITEM_HOLDER				1
/// Item components - Directly passes either a click, melee attack chain/afterattack/ranged attack chain, or uses an item on a clicked target
#define RIG_COMPONENT_ITEM_DIRECT				2
/// Passive components - No UI or hotbinds possible
#define RIG_COMPONENT_PASSIVE					3
/// Active toggled components
#define RIG_COMPONENT_TOGGLED					4
/// Activate-once components - basically a button. For UI purposes, this can be a list of buttons.
#define RIG_COMPONENT_TRIGGER					5
/// Components that directly receive the next click action
#define RIG_COMPONENT_INTERCEPT_NEXT_CLICK		5
/// Components that hook the rig's action click bind. Middle mouse, ctrl and alt click, etc.
#define RIG_COMPONENT_MOUSE_TRIGGER_HOOK		6

// Component UI types
/// Invisible to UI. Yes, client security is a sham, but we can cross that bridge when we need to.
#define RIG_COMPONENT_UI_HIDDEN					0
/// UI gives name and description. Every other UI option but hidden implies this.
#define RIG_COMPONENT_UI_NONE					1
/// UI that gives a list of buttons, toggles, and selectors.
#define RIG_COMPONENT_UI_GENERIC				2

// Hotbinds
/// Max rig hotbinds
#define RIG_MAX_HOTBINDS						10

// Weight

// Weight amounts on modules/armor/exception
/// No weight, why is this a define.
#define RIGSUIT_WEIGHT_NONE			0
/// Low weight items
#define RIGSUIT_WEIGHT_LOW			10
/// Medium weight items
#define RIGSUIT_WEIGHT_MEDIUM		30
/// High weight items
#define RIGSUIT_WEIGHT_HIGH			50
/// Extremely bulky items
#define RIGSUIT_WEIGHT_EXTREME		70

// Weight thresholds
/// Threshold at which the user is slowed down
#define RIGSUIT_WEIGHT_SLOWDOWN_THRESHOLD	50
/// Divisor for slowdown per weight post threshold
#define RIGSUIT_WEIGHT_SLOWDOWN_DIVISOR		50

// Component conflict types - bitfield.
