/**
 * Rigsuit control module a la baystation
 * Holds most of the data for rigsuits.
 * Pieces are attached via /datum/component/rig_piece
 *
 * Rig zones:
 * Zones consist of head, chest, left/right arms/legs, for a total of 6 zones.
 * They have no correlation to the actual rig pieces.
 *
 * Concepts:
 * ### RIG PIECES
 * Items considered part of the suit. They have one or more type of piece_type, which determines their damage zones/module support/etc. Only one piece of a certain type may exist on a rig.
 * They are not currently replaceable.
 *
 * ### RIG COMPONENTS
 * All attachable modules and integral components are considered components.
 * Some rigs only support certain types of components.
 *
 * ### INTEGRAL COMPONENTS
 * Integral components consist of:
 * - armor
 * - pressure shielding
 * - thermal shielding
 * They define a rig's basic stats, that are applied to every part of the suit.
 *
 * ### MODULES
 * Addon components that provide functionality.
 * They're what you think when you think of rigsuit modularity, on something like baycode.
 */
/obj/item/rig
	name = "blank rigsuit control module"
	desc = "Coders fucked up, if you can see this."
	/**
	 * BASIC VARIABLES
	 */
	/// The current user we're on.
	var/mob/living/wearer
	/// Are we currently activated?
	var/activated = FALSE
	/// What the user can control.
	var/wearer_control_flags = RIG_CONTROL_DEFAULT
	/// Suit types
	var/suit_types = RIG_TYPE_STANDARD
	/// Innate activation/deactivation delay. Unaffected by movement.
	var/cycle_delay = 5 SECONDS
	/// List of modules to attach. = RIG_INITIAL_MODULE_INBUILT association to force attach and permanently attach, **as well as make weightless, ignoring conflicts, and not cost complexity/size.**
	var/list/obj/item/rig_component/starting_components = list()
	/// Innate conflict list - if any component has anythign in this list, it'll conflict even if there's no components like it, regardless of allowed suit types.
	var/innate_component_conflicts
	/// Installed power cell. Set a typepath to have it start with one.
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high/plus
	/// Conventionally removable power cell?
	var/removable_cell = TRUE
	/// Installed air tank, used both for internals and for propulsion.
	var/obj/item/tank/tank = /obj/item/tank/internals/oxygen
	/// Starting power level, if any. Null for full.
	var/starting_charge

	/**
	 * RIG PIECES - Stuff that's physically put on or deployed by the user.
	 * Traditionally just stuff like suit + gloves/boots, but this modular system allows for much more than that in the future.
	 * Plus, this is a shitty replacement to something like interfaces, which BYOND doesn't have.
	 */
	/// List of rig piece components that are our physical parts. This is generated at runtime, and is associated to the physical item.
	var/list/datum/component/rig_piece/piece_components
	/// List of physical rig pieces. At runtime, this is associated to the component, allowing for two way lookup.
	var/list/obj/item/rig_pieces
	/// Rig piece type to rig piece.
	var/list/rig_pieces_by_type

	/**
	 * INTEGRAL COMPONENTS
	 * All rigs have these slots.
	 */
	/// Installed armor.
	var/obj/item/rig_component/armor/installed_armor
	/// Installed pressure shielding.
	var/obj/item/rig_component/pressure_shielding/installed_pressure_shielding
	/// Installed thermal protection.
	var/obj/item/rig_component/thermal_shielding/installed_thermal_shielding
	/**
	 * MODULES
	 * Attachable modules.
	 */
	/// The list of all installed modules.
	var/list/obj/item/rig_component/module/modules

	/**
	 * INTRINSICS - Innate
	 * Tracks rig initial stats.
	 */
	/// Innate magpulse? Null for none, otherwise number for slowdown.
	var/innate_magpulse = 3
	/// Innate headlamp? Null for none, otherwise number for light_range. 0 to disable.
	var/innate_headlamp = 5
	/// Innate lamp? Helmet not required, centered on rig control unit. 0 to disable.
	var/innate_lamp = 0
	/// Innate weight
	var/innate_weight = 0

	/**
	 * INTRINSICS - Operating
	 * Tracks current stats that are cached/calculated as needed.
	 */
	/// Current weight - updated by component attach/detach
	var/weight = 0
	/// Magpulse functionality - synced to boots if applicable
	var/magpulse = 3
	/// Headlamp functionality - synced to helmet if applicable
	var/headlamp = 5
	/// Lamp functionality - synced to control unit directly.
	var/lamp = 5

	/**
	 * Remote control
	 */
	/// Mobs with remote control associated to their control flags
	var/list/mob/remote_controllers
	/// Default control flags for remote control
	var/default_remote_control_flags = RIG_CONTROL_DEFAULT
	/// Incoming damage multiplier if the true wearer/user is unconscious
	var/rig_unconscious_damage_penalty = 1.5
	/// Incoming damage multiplier if the true wearer/user is dead OR does not exist (pilotless control)
	var/rig_dead_damage_penalty = 3
	/// EXPERIMENTAL - Unmanned piloting, marks the rig as being worn by a fake human user.
	var/fakeuser = FALSE
	/// EXPERIMENTAL - Remote control is forced the pilot to stand, regardless of status
	var/force_user_standing = FALSE

	/**
	 * Hotbinds
	 */
	/// List of hotbind datums that are configured.
	var/list/datum/rig_hotbind/hotbinds

	/**
	 * UI
	 */
	/// List of components awaiting rig_ui_data update
	var/list/obj/item/rig_component/ui_components_queued
	/// List of pieces awaiting rig_ui_data update. Uses components.
	var/list/datum/component/rig_piece/ui_pieces_queued
	/// timerid for ui update queuing.
	var/ui_update_queued
	/// Need to update module list.
	var/ui_refs_changed = FALSE

/obj/item/rig/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell
	if(ispath(tank))
		tank = new tank
	initialize_pieces()
	initialize_components()
	update_intrinsics()
	update_weight()
	update_integrals()

/obj/item/rig/Destroy()
	retract_all()
	if(wearer)
		deactivate()
	wipe_components()
	wipe_pieces()
	QDEL_NULL(tank)
	QDEL_NULL(cell)
	return ..()

/obj/item/rig/dropped(mob/user, silent)
	// Retract all pieces
	retract_all()
	// Immediately deactivate
	deactivate()
	return ..()

/obj/item/rig/Moved(atom/OldLoc, Dir)
	. = ..()
	if(activated && (loc != wearer))
		retract_all()
		deactivate()
