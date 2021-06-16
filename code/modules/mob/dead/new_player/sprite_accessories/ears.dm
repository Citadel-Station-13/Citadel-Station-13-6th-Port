/datum/sprite_accessory/ears
	icon = 'icons/mob/mutant_bodyparts.dmi'
	mutant_part_string = "ears"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/ears/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return (!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/ears/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/******************************************
*************** Human Ears ****************
*******************************************/

/datum/sprite_accessory/ears/human/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/bear
	name = "Bear"
	icon_state = "bear"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/human/bigwolf
	name = "Big Wolf"
	icon_state = "bigwolf"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/human/bigwolfinner
	name = "Big Wolf (ALT)"
	icon_state = "bigwolfinner"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/human/bigwolfdark //ignore alphabetical sort here for ease-of-use
	name = "Dark Big Wolf"
	icon_state = "bigwolfdark"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/human/bigwolfinnerdark
	name = "Dark Big Wolf (ALT)"
	icon_state = "bigwolfinnerdark"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/bunny
	name = "Bunny"
	icon_state = "bunny"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/bunnyalt
	name = "Bunny (Vegas)"
	icon_state = "bunnyalt"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/human/cow
	name = "Cow"
	icon_state = "cow"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/human/curled
	name = "Curled Horn"
	icon_state = "horn1"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MUTCOLORS3

/datum/sprite_accessory/ears/lab
	name = "Dog, Floppy"
	icon_state = "lab"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/lablight
	name = "Dog, Floppy (Light)"
	icon_state = "lablight"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/eevee
	name = "Eevee"
	icon_state = "eevee"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/human/elephant
	name = "Elephant"
	icon_state = "elephant"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/human/elf
	name = "Elf"
	icon_state = "elf"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = SKINTONE

/datum/sprite_accessory/ears/fennec
	name = "Fennec"
	icon_state = "fennec"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/fish
	name = "Fish"
	icon_state = "fish"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/fox
	name = "Fox"
	icon_state = "fox"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/jellyfish
	name = "Jellyfish"
	icon_state = "jellyfish"
	color_src = HAIR

/datum/sprite_accessory/ears/murid
	name = "Murid"
	icon_state = "murid"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/human/otie
	name = "Otusian"
	icon_state = "otie"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/rabbit
	name = "Rabbit (Lop-eared)"
	icon_state = "rabbit"
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/rabbitalt
	name = "Rabbit (Straight-eared)"
	icon_state = "rabbitalt"
	color_src = MATRIXED
	matrixed_sections = MATRIX_ALL
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'

/datum/sprite_accessory/ears/human/pede
	name = "Scolipede"
	icon_state = "pede"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/human/sergal
	name = "Sergal"
	icon_state = "sergal"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/human/skunk
	name = "skunk"
	icon_state = "skunk"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/wolf
	name = "Wolf"
	icon_state = "wolf"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	matrixed_sections = MATRIX_RED_BLUE

/******************************************
*************** Furry Ears ****************
*******************************************/

/datum/sprite_accessory/ears/mam_ears
	icon = 'modular_citadel/icons/mob/mam_ears.dmi'
	color_src = MATRIXED
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/ears/mam_ears/is_not_visible(mob/living/carbon/human/H, tauric, ignore_head = FALSE)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	return (!H.dna.features["mam_ears"] || H.dna.features["mam_ears"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || (!ignore_head && (!HD || HD.is_robotic_limb(FALSE))))

/datum/sprite_accessory/ears/mam_ears/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/ears/mam_ears/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/bat
	name = "Bat"
	icon_state = "bat"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/bear
	name = "Bear"
	icon_state = "bear"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/bigwolf
	name = "Big Wolf"
	icon_state = "bigwolf"
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/mam_ears/bigwolfinner
	name = "Big Wolf (ALT)"
	icon_state = "bigwolfinner"
	extra = TRUE
	extra_color_src = NONE
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/bigwolfdark //alphabetical sort ignored here for ease-of-use
	name = "Dark Big Wolf"
	icon_state = "bigwolfdark"
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/mam_ears/bigwolfinnerdark
	name = "Dark Big Wolf (ALT)"
	icon_state = "bigwolfinnerdark"
	extra = TRUE
	extra_color_src = NONE
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/bunny
	name = "Bunny"
	icon_state = "bunny"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/bunnyalt
	name = "Bunny (Vegas)"
	icon_state = "bunnyalt"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/cat
	name = "Cat"
	icon_state = "cat"
	icon = 'icons/mob/mutant_bodyparts.dmi'
	color_src = HAIR
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/mam_ears/catbig
	name = "Cat, Big"
	icon_state = "catbig"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/cow
	name = "Cow"
	icon_state = "cow"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/curled
	name = "Curled Horn"
	icon_state = "horn1"
	color_src = MUTCOLORS3

/datum/sprite_accessory/ears/mam_ears/deer
	name = "Deer"
	icon_state = "deer"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/eevee
	name = "Eevee"
	icon_state = "eevee"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/elf
	name = "Elf"
	icon_state = "elf"
	color_src = MUTCOLORS3

/datum/sprite_accessory/ears/mam_ears/elephant
	name = "Elephant"
	icon_state = "elephant"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/fennec
	name = "Fennec"
	icon_state = "fennec"
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/mam_ears/fish
	name = "Fish"
	icon_state = "fish"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/fox
	name = "Fox"
	icon_state = "fox"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/husky
	name = "Husky"
	icon_state = "wolf"
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/ears/mam_ears/jellyfish
	name = "Jellyfish"
	icon_state = "jellyfish"
	color_src = HAIR

/datum/sprite_accessory/ears/mam_ears/kangaroo
	name = "kangaroo"
	icon_state = "kangaroo"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/lab
	name = "Dog, Floppy"
	icon_state = "lab"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/lablight
	name = "Dog, Floppy (Light)"
	icon_state = "lablight"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/ears/mam_ears/murid
	name = "Murid"
	icon_state = "murid"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/otie
	name = "Otusian"
	icon_state = "otie"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/rabbit
	name = "Rabbit (Lop-eared)"
	icon_state = "rabbit"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/rabbitalt
	name = "Rabbit (Straight-eared)"
	icon_state = "rabbitalt"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/ears/mam_ears/pede
	name = "Scolipede"
	icon_state = "pede"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/sergal
	name = "Sergal"
	icon_state = "sergal"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/skunk
	name = "skunk"
	icon_state = "skunk"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/ears/mam_ears/wolf
	name = "Wolf"
	icon_state = "wolf"
	matrixed_sections = MATRIX_RED_BLUE
