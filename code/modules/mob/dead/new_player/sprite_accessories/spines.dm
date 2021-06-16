/datum/sprite_accessory/spines
	icon = 'icons/mob/mutant_bodyparts.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER)
	mutant_part_string = "spines"

/datum/sprite_accessory/spines/is_not_visible(var/mob/living/carbon/human/H, var/tauric)
	return (!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR))

/datum/sprite_accessory/spines_animated
	icon = 'icons/mob/mutant_bodyparts.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER)

/datum/sprite_accessory/spines_animated/is_not_visible(mob/living/carbon/human/H, tauric)
	return ((!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || H.dna.species.mutant_bodyparts["tail"])

/datum/sprite_accessory/spines/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/spines_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/spines/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines_animated/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines_animated/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines_animated/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines_animated/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines_animated/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"
