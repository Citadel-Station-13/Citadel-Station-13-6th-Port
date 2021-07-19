/**
 * Rig armor plating base.
 * Simply just for holding armor values/weight.
 * Rigsuits handle the actual attachment/calculation.
 */
/obj/item/rig_component/armor
	name = "unnamed armor module"
	desc = "Suspicious."
	rig_zone = RIG_ZONE_ALL
	/// Armor datum to apply to the rigsuit's pieces, for cases of user protection.
	var/datum/armor/user_protection = list("melee" = 10, "laser" = 10, "bullet" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 10, "acid" = 100, "wound" = 10)
	/// Armor datum to apply for cases of rigsuit damage. If null, defaults to user_protection.
	var/datum/armor/rig_protection
	/// Siemens coefficient - conductivity. Defaults to fully nonconductive, more on that later in rigsuits.
	var/conductivity = 0

/obj/item/rig_component/armor/Initialize(mapload)
	. = ..()
	if(islist(user_protection))
		user_protection = getArmor(arglist(user_protection))
	if(islist(rig_protection))
		rig_protection = getArmor(arglist(rig_protection))
	if(!user_protection)
		user_protection = getArmor()
	if(!rig_protection)
		rig_protection = user_protection

/obj/item/rig_component/armor/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_armor_module()
