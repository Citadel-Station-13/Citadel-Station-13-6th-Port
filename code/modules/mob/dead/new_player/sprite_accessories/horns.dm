/datum/sprite_accessory/horns
	icon = 'icons/mob/mutant_bodyparts.dmi'
	color_src = HORNCOLOR
	mutant_part_string = "horns"
	relevant_layers = list(HORNS_LAYER)

/datum/sprite_accessory/horns/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return (!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/horns/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"
	color_src = MUTCOLORS

/datum/sprite_accessory/horns/antler
	name = "Deer Antlers"
	icon_state = "deer"

/datum/sprite_accessory/horns/guilmon
	name = "Guilmon"
	icon_state = "guilmon"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"
