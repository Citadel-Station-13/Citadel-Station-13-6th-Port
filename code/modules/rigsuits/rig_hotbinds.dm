/**
 * Hotbind datums
 * Targets a specific component and sends an action and param to its on_hotbind_activation().
 */
/datum/rig_hotbind
	/// Rig this is host for
	var/obj/item/rig/rig
	/// Component this is targeting
	var/obj/item/rig_component/component
	/// Command string to send
	var/command
	/// Parameter to send
	var/parameter
	/// Our action button
	var/datum/action/action

/datum/rig_hotbind/New(objitem/rig/rig, obj/item/rig_component/component, action, parameter, icon, icon_state, activated)
	src.rig = rig
	src.component = component
	src.command = command
	src.parameter = parameter
	create_action(icon, icon_state)
	update_action(activated)

/datum/rig_hotbind/proc/create_action(icon/I, icon_state)

/**
 * Updates the action button's toggled status if needed, using returned value from
 */
/datum/rig_hotbind/proc/update_action(activation)
	if(isnull(activation))
		return

/datum/rig_hotbind/proc/on_trigger(mob/user)
	if(!(rig.get_control_flags(user) & RIG_CONTROL_USE_HOTBINDS))
		return FALSE
	update_action(component.on_hotbind(user, command, parameter))
