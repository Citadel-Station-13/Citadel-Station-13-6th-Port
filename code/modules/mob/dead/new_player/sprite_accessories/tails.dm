/datum/sprite_accessory/tails
	icon = 'icons/mob/mutant_bodyparts.dmi'
	mutant_part_string = "tail"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/tails/is_not_visible(mob/living/carbon/human/H, tauric)
	return ((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)

/datum/sprite_accessory/tails_animated
	icon = 'icons/mob/mutant_bodyparts.dmi'
	mutant_part_string = "tailwag" //keep this the same, ALWAYS, this is incredibly important for colouring!
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/******************************************
************* Lizard Tails ****************
*******************************************/

/datum/sprite_accessory/tails_animated/lizard/is_not_visible(mob/living/carbon/human/H, tauric)
	return (((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric) || H.dna.species.mutant_bodyparts["tail_lizard"])

//this goes first regardless of alphabetical order
/datum/sprite_accessory/tails/lizard/none
	name = "None"
	icon_state = "None"
	relevant_layers = null

/datum/sprite_accessory/tails_animated/lizard/none
	name = "None"
	icon_state = "None"
	relevant_layers = null

/datum/sprite_accessory/tails/lizard/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/lizard/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails_animated/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/guilmon
	name = "Guilmon"
	icon_state = "guilmon"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/lizard/guilmon
	name = "Guilmon"
	icon_state = "guilmon"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails_animated/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails_animated/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails_animated/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/******************************************
************** Human Tails ****************
*******************************************/

/datum/sprite_accessory/tails/human/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/tails_animated/human/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/tails_animated/human/is_not_visible(mob/living/carbon/human/H, tauric)
	return (((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)|| H.dna.species.mutant_bodyparts["tail_human"])

/datum/sprite_accessory/tails/human/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/bee
	name = "Bee"
	icon_state = "bee"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/bee
	name = "Bee"
	icon_state = "bee"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/cat
	name = "Cat"
	icon_state = "cat"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = HAIR

/datum/sprite_accessory/tails_animated/human/cat
	name = "Cat"
	icon_state = "cat"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = HAIR

/datum/sprite_accessory/tails/human/catbig
	name = "Cat, Big"
	icon_state = "catbig"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/catbig
	name = "Cat, Big"
	icon_state = "catbig"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/twocat
	name = "Cat, Double"
	icon_state = "twocat"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/twocat
	name = "Cat, Double"
	icon_state = "twocat"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/corvid
	name = "Corvid"
	icon_state = "crow"

/datum/sprite_accessory/tails_animated/human/corvid
	name = "Corvid"
	icon_state = "crow"

/datum/sprite_accessory/tails/human/cow
	name = "Cow"
	icon_state = "cow"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/cow
	name = "Cow"
	icon_state = "cow"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails_animated/human/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/human/datashark
	name = "datashark"
	icon_state = "datashark"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/tails_animated/human/datashark
	name = "datashark"
	icon_state = "datashark"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_BLUE

/datum/sprite_accessory/tails/human/eevee
	name = "Eevee"
	icon_state = "eevee"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/eevee
	name = "Eevee"
	icon_state = "eevee"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/fennec
	name = "Fennec"
	icon_state = "fennec"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/fennec
	name = "Fennec"
	icon_state = "fennec"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/fish
	name = "Fish"
	icon_state = "fish"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/fish
	name = "Fish"
	icon_state = "fish"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/fox
	name = "Fox"
	icon_state = "fox"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/fox
	name = "Fox"
	icon_state = "fox"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/horse
	name = "Horse"
	icon_state = "horse"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = HAIR

/datum/sprite_accessory/tails_animated/human/horse
	name = "Horse"
	icon_state = "horse"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = HAIR

/datum/sprite_accessory/tails/human/husky
	name = "Husky"
	icon_state = "husky"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/husky
	name = "Husky"
	icon_state = "husky"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/insect
	name = "Insect"
	icon_state = "insect"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/insect
	name = "Insect"
	icon_state = "insect"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/kitsune
	name = "Kitsune"
	icon_state = "kitsune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/kitsune
	name = "Kitsune"
	icon_state = "kitsune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails_animated/human/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/human/murid
	name = "Murid"
	icon_state = "murid"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_GREEN

/datum/sprite_accessory/tails_animated/human/murid
	name = "Murid"
	icon_state = "murid"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_GREEN

/datum/sprite_accessory/tails/orca
	name = "Orca"
	icon_state = "orca"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/orca
	name = "Orca"
	icon_state = "orca"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/otie
	name = "Otusian"
	icon_state = "otie"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/otie
	name = "Otusian"
	icon_state = "otie"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/rabbit
	name = "Rabbit"
	icon_state = "rabbit"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/rabbit
	name = "Rabbit"
	icon_state = "rabbit"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/ailurus
	name = "Red Panda"
	icon_state = "wah"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/ailurus
	name = "Red Panda"
	icon_state = "wah"
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	color_src = MATRIXED
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/pede
	name = "Scolipede"
	icon_state = "pede"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/pede
	name = "Scolipede"
	icon_state = "pede"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/sergal
	name = "Sergal"
	icon_state = "sergal"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/sergal
	name = "Sergal"
	icon_state = "sergal"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/shark
	name = "Shark"
	icon_state = "shark"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/shark
	name = "Shark"
	icon_state = "shark"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/skunk
	name = "skunk"
	icon_state = "skunk"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails_animated/human/skunk
	name = "skunk"
	icon_state = "skunk"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails/human/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails_animated/human/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/human/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails_animated/human/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/human/straighttail
	name = "Straight Tail"
	icon_state = "straighttail"

/datum/sprite_accessory/tails_animated/human/straighttail
	name = "Straight Tail"
	icon_state = "straighttail"

/datum/sprite_accessory/tails/human/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/tamamo_kitsune
	name = "Tamamo Kitsune Tails" //Tamamo-no-Tiro, let it be known!
	icon_state = "9sune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/tamamo_kitsune
	name = "Tamamo Kitsune Tails"
	icon_state = "9sune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/triple_kitsune
	name = "Triple Kitsune Tails"
	icon_state = "3sune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/human/triple_kitsune
	name = "Triple Kitsune Tails"
	icon_state = "3sune"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/human/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/human/tiger
	name = "Tiger"
	icon_state = "tiger"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails_animated/human/tiger
	name = "Tiger"
	icon_state = "tiger"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails/human/wolf
	name = "Wolf"
	icon_state = "wolf"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/human/wolf
	name = "Wolf"
	icon_state = "wolf"
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	matrixed_sections = MATRIX_RED

/******************************************
************** Furry Tails ****************
*******************************************/

/datum/sprite_accessory/tails/mam_tails
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	recommended_species = list("mammal", "slimeperson", "podweak", "felinid", "insect")
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/tails/mam_tails/none
	name = "None"
	icon_state = "none"
	recommended_species = null
	relevant_layers = null

/datum/sprite_accessory/tails_animated/mam_tails_animated
	color_src = MATRIXED
	icon = 'modular_citadel/icons/mob/mam_tails.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/tails_animated/mam_tails_animated/is_not_visible(mob/living/carbon/human/H, tauric)
	return (((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric) || H.dna.species.mutant_bodyparts["mam_tail"])

/datum/sprite_accessory/tails_animated/mam_tails_animated/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/tails/mam_tails/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/batl
	name = "Bat (Long)"
	icon_state = "batl"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/batl
	name = "Bat (Long)"
	icon_state = "batl"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/bats
	name = "Bat (Short)"
	icon_state = "bats"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/bats
	name = "Bat (Short)"
	icon_state = "bats"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/bee
	name = "Bee"
	icon_state = "bee"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/bee
	name = "Bee"
	icon_state = "bee"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR

/datum/sprite_accessory/tails_animated/mam_tails_animated/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR

/datum/sprite_accessory/tails/mam_tails/catbig
	name = "Cat, Big"
	icon_state = "catbig"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/catbig
	name = "Cat, Big"
	icon_state = "catbig"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/twocat
	name = "Cat, Double"
	icon_state = "twocat"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/twocat
	name = "Cat, Double"
	icon_state = "twocat"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/corvid
	name = "Corvid"
	icon_state = "crow"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/corvid
	name = "Corvid"
	icon_state = "crow"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tail/cow
	name = "Cow"
	icon_state = "cow"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/cow
	name = "Cow"
	icon_state = "cow"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails_animated/mam_tails_animated/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails/mam_tails/eevee
	name = "Eevee"
	icon_state = "eevee"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/eevee
	name = "Eevee"
	icon_state = "eevee"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/fennec
	name = "Fennec"
	icon_state = "fennec"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/fennec
	name = "Fennec"
	icon_state = "fennec"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/fish
	name = "Fish"
	icon_state = "fish"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/fish
	name = "Fish"
	icon_state = "fish"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/fox
	name = "Fox"
	icon_state = "fox"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/fox
	name = "Fox"
	icon_state = "fox"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/hawk
	name = "Hawk"
	icon_state = "hawk"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/hawk
	name = "Hawk"
	icon_state = "hawk"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/horse
	name = "Horse"
	icon_state = "horse"
	color_src = HAIR

/datum/sprite_accessory/tails_animated/mam_tails_animated/horse
	name = "Horse"
	icon_state = "horse"
	color_src = HAIR

/datum/sprite_accessory/tails/mam_tails/husky
	name = "Husky"
	icon_state = "husky"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/husky
	name = "Husky"
	icon_state = "husky"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/insect
	name = "Insect"
	icon_state = "insect"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/insect
	name = "Insect"
	icon_state = "insect"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/kangaroo
	name = "kangaroo"
	icon_state = "kangaroo"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/kangaroo
	name = "kangaroo"
	icon_state = "kangaroo"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/kitsune
	name = "Kitsune"
	icon_state = "kitsune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/kitsune
	name = "Kitsune"
	icon_state = "kitsune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/lab
	name = "Lab"
	icon_state = "lab"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/lab
	name = "Lab"
	icon_state = "lab"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails_animated/mam_tails_animated/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails/mam_tails/murid
	name = "Murid"
	icon_state = "murid"
	matrixed_sections = MATRIX_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/murid
	name = "Murid"
	icon_state = "murid"
	matrixed_sections = MATRIX_GREEN

/datum/sprite_accessory/tails/mam_tails/orca
	name = "Orca"
	icon_state = "orca"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/orca
	name = "Orca"
	icon_state = "orca"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/otie
	name = "Otusian"
	icon_state = "otie"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/otie
	name = "Otusian"
	icon_state = "otie"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/rabbit
	name = "Rabbit"
	icon_state = "rabbit"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/rabbit
	name = "Rabbit"
	icon_state = "rabbit"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/ailurus
	name = "Red Panda"
	icon_state = "wah"
	extra = TRUE
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/ailurus
	name = "Red Panda"
	icon_state = "wah"
	extra = TRUE
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/pede
	name = "Scolipede"
	icon_state = "pede"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/pede
	name = "Scolipede"
	icon_state = "pede"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/sergal
	name = "Sergal"
	icon_state = "sergal"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/sergal
	name = "Sergal"
	icon_state = "sergal"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/shark
	name = "Shark"
	icon_state = "shark"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/shark
	name = "Shark"
	icon_state = "shark"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/shepherd
	name = "Shepherd"
	icon_state = "shepherd"
	matrixed_sections = MATRIX_GREEN_BLUE

/datum/sprite_accessory/tails_animated/mam_tails_animated/shepherd
	name = "Shepherd"
	icon_state = "shepherd"
	matrixed_sections = MATRIX_GREEN_BLUE

/datum/sprite_accessory/tails/mam_tails/skunk
	name = "Skunk"
	icon_state = "skunk"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails_animated/mam_tails_animated/skunk
	name = "Skunk"
	icon_state = "skunk"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails/mam_tails/smooth
	name = "Smooth"
	icon_state = "smooth"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails_animated/mam_tails_animated/smooth
	name = "Smooth"
	icon_state = "smooth"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails_animated/mam_tails_animated/spikes
	name = "Spikes"
	icon_state = "spikes"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails/mam_tails/spikes
	name = "Spikes"
	icon_state = "spikes"
	color_src = MUTCOLORS
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails/mam_tails/straighttail
	name = "Straight Tail"
	icon_state = "straighttail"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/straighttail
	name = "Straight Tail"
	icon_state = "straighttail"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/squirrel
	name = "Squirrel"
	icon_state = "squirrel"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/tamamo_kitsune
	name = "Tamamo Kitsune Tails"
	icon_state = "9sune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/tamamo_kitsune
	name = "Tamamo Kitsune Tails"
	icon_state = "9sune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/triple_kitsune
	name = "Triple Kitsune Tails"
	icon_state = "3sune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails_animated/mam_tails_animated/triple_kitsune
	name = "Triple Kitsune Tails"
	icon_state = "3sune"
	matrixed_sections = MATRIX_RED_GREEN

/datum/sprite_accessory/tails/mam_tails/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails/mam_tails/tiger
	name = "Tiger"
	icon_state = "tiger"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails_animated/mam_tails_animated/tiger
	name = "Tiger"
	icon_state = "tiger"
	matrixed_sections = MATRIX_ALL

/datum/sprite_accessory/tails/mam_tails/wolf
	name = "Wolf"
	icon_state = "wolf"
	matrixed_sections = MATRIX_RED

/datum/sprite_accessory/tails_animated/mam_tails_animated/wolf
	name = "Wolf"
	icon_state = "wolf"
	matrixed_sections = MATRIX_RED
