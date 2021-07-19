/**
 * Base type of rig components.
 */
/obj/item/rig_component
	/// Currently attached rig. Set by rig attach/detach procs.
	var/obj/item/rig/host
	/// Rig component type
	var/component_type = RIG_COMPONENT_GENERIC
	/// UI type. Can be a define or a custom string.
	var/ui_type = RIG_COMPONENT_UI_GENERIC
	/// Weight of this component - this affects stats like power usage and slowdown
	var/weight = RIGSUIT_WEIGHT_NONE
	/// Slots used - a section must have enough slots to support this module
	var/slots = 0
	/// Size used - a section must have enough free space to support this module
	var/size = 0
	/// Prevent the same type of component from being mounted if one's already in ANY of the sections this occupies
	var/prevent_duplicates = TRUE
	/// Rig zones this occupies.
	var/rig_zone = RIG_ZONE_CHEST
	/// Allowed suit types, flags.
	var/allowed_suit_types = ALL
	/// Is this component considered an "abstract component" aka unremovable, can't be used in other suits.
	var/internal = FALSE
	/// Conflict type - this is a bitflag. If any other component has anything in this, there's a conflict.
	var/conflicts_with = NONE

/**
 * Called when being attached to a suit.
 *
 * @return Whether or not we should attach
 */
/obj/item/rig_component/proc/can_attach(obj/item/rig/rig)
	return (rig.suit_types & allowed_suit_types) && !internal

/**
 * Checks if we can be detached.
 *
 * @return Whether or not we can be detached
 */
/obj/item/rig_component/proc/can_detach(obj/item/rig/rig)
	return !internal && !(src in rig.permanent_modules)

/**
 * Called when attached to a suit.
 *
 * @params
 * * rig - The control module being attached into
 * * rig_creation - Being created and attached as part of default modules.
 */
/obj/item/rig_component/proc/on_attach(obj/item/rig/rig, rig_creation = FALSE)
	if(!rig_creation)
		rig.update_weight()

/**
 * Called when detached from a suit.
 *
 * @params
 * * rig - The control module being attached into
 */
/obj/item/rig_component/proc/on_detach(obj/item/rig/rig)
	if(!rig_creation)
		rig.update_weight()

/**
 * UI data for this piece.
 * Static.
 */
/obj/item/rig_component/proc/rig_ui_data(mob/user)
	. = list()
	.["ui"] = ui_type
	.["name"] = name
	.["desc"] = desc

/**
 * UI act on piece
 */
/obj/item/rig_component/proc/rig_ui_act(action, params)
	return

/**
 * Call this to update our UI data. We don't constantly resend data to save performance.
 */
/obj/item/rig_component/proc/update_ui()
	host?.mark_component_ui_dirty(src)


