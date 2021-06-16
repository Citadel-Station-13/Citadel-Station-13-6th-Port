
/******************************************
*********** Xeno Dorsal Tubes *************
*******************************************/
/datum/sprite_accessory/xeno_dorsal
	icon = 'modular_citadel/icons/mob/xeno_parts_greyscale.dmi'
	mutant_part_string = "xenodorsal"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/xeno_dorsal/is_not_visible(mob/living/carbon/human/H, tauric)
	return (!H.dna.features["xenodorsal"] || H.dna.features["xenodorsal"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT)))

/datum/sprite_accessory/xeno_dorsal/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/xeno_dorsal/down
	name = "Dorsal Down"
	icon_state = "down"

/datum/sprite_accessory/xeno_dorsal/royal
	name = "Royal"
	icon_state = "royal"

/******************************************
************* Xeno Tails ******************
*******************************************/
/datum/sprite_accessory/xeno_tail
	icon = 'modular_citadel/icons/mob/xeno_parts_greyscale.dmi'
	mutant_part_string = "tail"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/xeno_tail/is_not_visible(mob/living/carbon/human/H, tauric)
	return (!H.dna.features["xenotail"] || H.dna.features["xenotail"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))

/datum/sprite_accessory/xeno_tail/none
	name = "None"
	relevant_layers = null

/datum/sprite_accessory/xeno_tail/standard
	name = "Xenomorph Tail"
	icon_state = "xeno"

/******************************************
************* Xeno Heads ******************
*******************************************/
/datum/sprite_accessory/xeno_head
	icon = 'modular_citadel/icons/mob/xeno_parts_greyscale.dmi'
	mutant_part_string = "xhead"
	relevant_layers = list(BODY_ADJ_LAYER)

/datum/sprite_accessory/xeno_head/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return (!H.dna.features["xenohead"] || H.dna.features["xenohead"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/xeno_head/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/xeno_head/hollywood
	name = "hollywood"
	icon_state = "hollywood"

/datum/sprite_accessory/xeno_head/royal
	name = "royal"
	icon_state = "royal"

/datum/sprite_accessory/xeno_head/warrior
	name = "warrior"
	icon_state = "warrior"
