/**
 * Attachs a component.
 * Will forceMove said component to ourselves regardless of their location.
 *
 * @params
 * C - component to attach
 * force - ignore all can attach safety checks
 * del_conflicting - if forcing attach, conflicting modules will be deleted instead of dropped
 * unremovable - force component to be permanent/internal.
 * default_module - TRUE if it's being attached as part of rig control module Initialize()
 * update - update rig stats.
 */
/obj/item/rig/proc/attach_component(obj/item/rig_component/C, force = FALSE, del_conflicting = TRUE, unremovable = FALSE, default_module = FALSE, update = TRUE)
	var/list/obj/item/rig_component/conflicting = check_component_conflicts(C)
	if(!force && (!C.can_attach(src) || conflicting.len))
		return FALSE
	if(C.host)		// Even if forcing, let's, not somehow attach an attached module to another host.
		return FALSE
	all_components += C
	if(unremovable || C.internal)
		permanent_components += C
		C.internal = TRUE
	C.on_attach(src, default_module)
	C.host = src
	ui_queue_component(C)
	ui_queue_reflists()
	for(var/i in conflicting)
		var/obj/item/rig_component/C = i
		detach_component(C, TRUE, del_conflicting)
	return TRUE

/**
 * Detaches a component.
 *
 * @params
 * C - component to detach
 * force - ignore all can_detach safety checks on the module
 * delete - delete detached module instead of dropping
 * update - update rig stats
 */
/obj/item/rig/proc/detach_component(obj/item/rig_component/C, force = FALSE, delete = FALSE, update = TRUE)
	if(!force && !C.can_detach(src))
		return FALSE
	all_components -= C
	permanent_components -= C
	C.on_detach(src)
	C.host = null
	ui_queue_reflists()
	if(delete)
		qdel(C)
	else
		C.forceMove(drop_location())
	return TRUE

/**
 * Checks for any modules that are conflicting on the current suit with one about to be attached.
 *
 * @return A list of all modules that conflict. Empty if none.
 */
/obj/item/rig/proc/check_component_conflicts(obj/item/rig_component/C)
	. = list()
	var/theirs = C.conflicts_with
	for(var/i in all_components)
		var/obj/item/rig_component/C = i
		if(theirs & C.conflicts_with)
			. += C


/**
 * Updates rig installed armor.
 */
/obj/item/rig/proc/update_armor_module()
	sync_all_pieces()

/**
 * Updates rig installed pressure module.
 */
/obj/item/rig/proc/update_pressure_module()
	sync_all_pieces()
sw
/**
 * Updates rig installed thermal module.
 */
/obj/item/rig/proc/update_thermal_module()
	sync_all_pieces()
