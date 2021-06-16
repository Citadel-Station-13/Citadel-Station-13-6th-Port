/datum/sprite_accessory/frills
	icon = 'icons/mob/mutant_bodyparts.dmi'
	relevant_layers = list(BODY_ADJ_LAYER)
	mutant_part_string = "frills"

/datum/sprite_accessory/frills/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return (!H.dna.features["frills"] || H.dna.features["frills"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/frills/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"
