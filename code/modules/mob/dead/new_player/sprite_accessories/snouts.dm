/datum/sprite_accessory/snouts
	icon = 'icons/mob/mutant_bodyparts.dmi'
	mutant_part_string = "snout"
	relevant_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/snouts/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return ((H.wear_mask && (H.wear_mask.flags_inv & HIDESNOUT)) || (H.head && (H.head.flags_inv & HIDESNOUT)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

//christ this was a mistake, but it's here just in case someone wants to selectively fix -- Pooj
/************* Lizard compatable snoots ***********
/datum/sprite_accessory/snouts/bird
	name = "Beak"
	icon_state = "bird"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/bigbeak
	name = "Big Beak"
	icon_state = "bigbeak"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/bug
	name = "Bug"
	icon_state = "bug"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	extra2 = TRUE
	extra2_color_src = MUTCOLORS3

/datum/sprite_accessory/snouts/elephant
	name = "Elephant"
	icon_state = "elephant"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED
	extra = TRUE
	extra_color_src = MUTCOLORS3

/datum/sprite_accessory/snouts/lcanid
	name = "Mammal, Long"
	icon_state = "lcanid"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/lcanidalt
	name = "Mammal, Long ALT"
	icon_state = "lcanidalt"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/scanid
	name = "Mammal, Short"
	icon_state = "scanid"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/scanidalt
	name = "Mammal, Short ALT"
	icon_state = "scanidalt"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/wolf
	name = "Mammal, Thick"
	icon_state = "wolf"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/wolfalt
	name = "Mammal, Thick ALT"
	icon_state = "wolfalt"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/redpanda
	name = "WahCoon"
	icon_state = "wah"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/rhino
	name = "Horn"
	icon_state = "rhino"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED
	extra = TRUE
	extra = MUTCOLORS3

/datum/sprite_accessory/snouts/rodent
	name = "Rodent"
	icon_state = "rodent"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/husky
	name = "Husky"
	icon_state = "husky"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/otie
	name = "Otie"
	icon_state = "otie"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/pede
	name = "Scolipede"
	icon_state = "pede"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/sergal
	name = "Sergal"
	icon_state = "sergal"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED

/datum/sprite_accessory/snouts/shark
	name = "Shark"
	icon_state = "shark"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'

/datum/sprite_accessory/snouts/toucan
	name = "Toucan"
	icon_state = "toucan"
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	color_src = MATRIXED
*/

/******************************************
************** Mammal Snouts **************
*******************************************/

/datum/sprite_accessory/snouts/mam_snouts
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_snouts.dmi'
	recommended_species = list("mammal", "slimeperson", "insect", "podweak", "lizard")
	relevant_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/snouts/mam_snouts/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return ((H.wear_mask && (H.wear_mask.flags_inv & HIDESNOUT)) || (H.head && (H.head.flags_inv & HIDESNOUT)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/snouts/mam_snouts/none
	name = "None"
	icon_state = "none"
	recommended_species = null
	relevant_layers = null

/datum/sprite_accessory/snouts/mam_snouts/bird
	name = "Beak"
	icon_state = "bird"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/bigbeak
	name = "Big Beak"
	icon_state = "bigbeak"
	matrixed_sections = MATRIX_BLUE

/datum/sprite_accessory/snouts/mam_snouts/bug
	name = "Bug"
	icon_state = "bug"
	color_src = MUTCOLORS
	extra2 = TRUE
	extra2_color_src = MUTCOLORS3

/datum/sprite_accessory/snouts/mam_snouts/elephant
	name = "Elephant"
	icon_state = "elephant"
	extra = TRUE
	extra_color_src = MUTCOLORS3
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/husky
	name = "Husky"
	icon_state = "husky"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/rhino
	name = "Horn"
	icon_state = "rhino"
	extra = TRUE
	extra_color_src = MUTCOLORS3
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/rodent
	name = "Rodent"
	icon_state = "rodent"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/lcanid
	name = "Mammal, Long"
	icon_state = "lcanid"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/lcanidalt
	name = "Mammal, Long ALT"
	icon_state = "lcanidalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/scanid
	name = "Mammal, Short"
	icon_state = "scanid"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/scanidalt
	name = "Mammal, Short ALT"
	icon_state = "scanidalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/scanidalt2
	name = "Mammal, Short ALT 2"
	icon_state = "scanidalt2"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/wolf
	name = "Mammal, Thick"
	icon_state = "wolf"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/wolfalt
	name = "Mammal, Thick ALT"
	icon_state = "wolfalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/otie
	name = "Otie"
	icon_state = "otie"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/round
	name = "Round"
	icon_state = "round"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/pede
	name = "Scolipede"
	icon_state = "pede"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/sergal
	name = "Sergal"
	icon_state = "sergal"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/shark
	name = "Shark"
	icon_state = "shark"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/hshark
	name = "hShark"
	icon_state = "hshark"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/sharp
	name = "Sharp"
	icon_state = "sharp"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/skulldog
	name = "Skulldog"
	icon_state = "skulldog"
	extra = TRUE
	extra_color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/toucan
	name = "Toucan"
	icon_state = "toucan"
	matrixed_sections = MATRIX_RED_BLUE //one single pixel of red. one.

/datum/sprite_accessory/snouts/mam_snouts/redpanda
	name = "WahCoon"
	icon_state = "wah"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/redpandaalt
	name = "WahCoon ALT"
	icon_state = "wahalt"
	matrixed_sections = MATRIX_RED_GREEN

/******************************************
**************** Snouts *******************
*************but higher up*****************/

/datum/sprite_accessory/snouts/mam_snouts/fbird
	name = "Beak (Top)"
	icon_state = "fbird"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/fbigbeak
	name = "Big Beak (Top)"
	icon_state = "fbigbeak"
	matrixed_sections = MATRIX_BLUE

/datum/sprite_accessory/snouts/mam_snouts/fbug
	name = "Bug (Top)"
	icon_state = "fbug"
	color_src = MUTCOLORS
	extra2 = TRUE
	extra2_color_src = MUTCOLORS3

/datum/sprite_accessory/snouts/mam_snouts/felephant
	name = "Elephant (Top)"
	icon_state = "felephant"
	extra = TRUE
	extra_color_src = MUTCOLORS3
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/frhino
	name = "Horn (Top)"
	icon_state = "frhino"
	extra = TRUE
	extra = MUTCOLORS3
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/fhusky
	name = "Husky (Top)"
	icon_state = "fhusky"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/flcanid
	name = "Mammal, Long (Top)"
	icon_state = "flcanid"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/flcanidalt
	name = "Mammal, Long ALT (Top)"
	icon_state = "flcanidalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fscanid
	name = "Mammal, Short (Top)"
	icon_state = "fscanid"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fscanidalt
	name = "Mammal, Short ALT (Top)"
	icon_state = "fscanidalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fscanidalt2
	name = "Mammal, Short ALT 2 (Top)"
	icon_state = "fscanidalt2"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/fwolf
	name = "Mammal, Thick (Top)"
	icon_state = "fwolf"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fwolfalt
	name = "Mammal, Thick ALT (Top)"
	icon_state = "fwolfalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fotie
	name = "Otie (Top)"
	icon_state = "fotie"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/frodent
	name = "Rodent (Top)"
	icon_state = "frodent"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/fround
	name = "Round (Top)"
	icon_state = "fround"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/froundlight
	name = "Round + Light (Top)"
	icon_state = "froundlight"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/fpede
	name = "Scolipede (Top)"
	icon_state = "fpede"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fsergal
	name = "Sergal (Top)"
	icon_state = "fsergal"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/snouts/mam_snouts/fshark
	name = "Shark (Top)"
	icon_state = "fshark"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/snouts/mam_snouts/fsharp
	name = "Sharp (Top)"
	icon_state = "fsharp"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/fsharplight
	name = "Sharp + Light (Top)"
	icon_state = "fsharplight"
	color_src = MUTCOLORS

/datum/sprite_accessory/snouts/mam_snouts/ftoucan
	name = "Toucan (Top)"
	icon_state = "ftoucan"
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/snouts/mam_snouts/fredpanda
	name = "WahCoon (Top)"
	icon_state = "fwah"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/snouts/mam_snouts/fredpanda/alt
	name = "WahCoon ALT (Top)"
	icon_state = "fwahalt"
	matrixed_sections = MATRIX_RED_GREEN
