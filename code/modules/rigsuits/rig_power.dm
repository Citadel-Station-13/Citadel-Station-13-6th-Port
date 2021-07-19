/**
 * RIG Power System
 *
 * RIGsuits run on and draw power from their
 */

/**
 * Standard proc to get cell
 */
/obj/item/rig/get_cell()
	return cell

/**
 * Gets charge percent
 */
/obj/item/rig/proc/power_percent()
	if(!cell)
		return 0
	return cell.percent()

/**
 * Uses cell charge
 */
/obj/item/rig/proc/use_power(amount)
	if(!cell)
		return 0
	return cell.use(amount)

/**
 * Gives cell charge
 */
/obj/item/rig/proc/give_power(amount)
	if(!cell)
		return 0
	return cell.give(amount)
