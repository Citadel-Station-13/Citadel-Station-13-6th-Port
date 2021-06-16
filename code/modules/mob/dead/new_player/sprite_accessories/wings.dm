//Angel Wings

/datum/sprite_accessory/wings/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/wings/is_not_visible(mob/living/carbon/human/H, tauric)
	return (!H.dna.features["wings"] || H.dna.features["wings"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/wings.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/wings_open/is_not_visible(mob/living/carbon/human/H, tauric)
	return (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception)) || H.dna.species.mutant_bodyparts["wings"])

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings
	icon = 'icons/mob/wings.dmi'
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

// Decorative wings

/datum/sprite_accessory/deco_wings
	icon = 'icons/mob/wings.dmi'
	color_src = WINGCOLOR
	mutant_part_string = "insect_wings"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/deco_wings/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/deco_wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)

//nonmoth wings

/datum/sprite_accessory/deco_wings/bat
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/deco_wings/bee
	name = "Bee"
	icon_state = "bee"

/datum/sprite_accessory/deco_wings/bee2
	name = "Small Bee"
	icon_state = "beewings"

/datum/sprite_accessory/deco_wings/dragon
	name = "Dragon"
	icon_state = "dragon"

/datum/sprite_accessory/deco_wings/dragonfly
	name = "Dragonfly"
	icon_state = "dragonfly"

/datum/sprite_accessory/deco_wings/fairy
	name = "Fairy"
	icon_state = "fairy"

/datum/sprite_accessory/deco_wings/featheredwing
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/deco_wings/featheredwingmedium
	name = "Medium Feathered"
	icon_state = "feathered3"

/datum/sprite_accessory/deco_wings/featheredwinglarge
	name = "Large Feathered"
	icon_state = "feathered2"

/datum/sprite_accessory/deco_wings/harpywings
	name = "Harpy"
	icon_state = "harpywings"

/datum/sprite_accessory/deco_wings/roboticwing
	name = "Robotic"
	icon_state = "drago"

/datum/sprite_accessory/deco_wings/succubusblack
	name = "Succubus Black"
	icon_state = "succubusblack"

/datum/sprite_accessory/deco_wings/succubuspurple
	name = "Succubus Purple"
	icon_state = "succubuspurple"

/datum/sprite_accessory/deco_wings/succubusred
	name = "Succubus Red"
	icon_state = "succubusred"

/datum/sprite_accessory/deco_wings/xenobackplate
	name = "Xenomorph Backplate"
	icon_state = "snagbackplate"

//moth wings

/datum/sprite_accessory/deco_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/deco_wings/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/deco_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/deco_wings/featherymoth
	name = "Feathery Moth Wings"
	icon_state = "featherymoth"

/datum/sprite_accessory/deco_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/deco_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/deco_wings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/deco_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/deco_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/deco_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/deco_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/deco_wings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/deco_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/deco_wings/plasmafire
	name = "Plasma Fire"
	icon_state = "plasmafire"

/datum/sprite_accessory/deco_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/deco_wings/punished
	name = "Burnt Off"
	icon_state = "punished"

/datum/sprite_accessory/deco_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/deco_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/deco_wings/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/deco_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/deco_wings/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/deco_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/deco_wings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

//INSECT WINGS

/datum/sprite_accessory/insect_wings
	icon = 'icons/mob/wings.dmi'
	color_src = WINGCOLOR
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

//non insect wings
/datum/sprite_accessory/deco_wings/bat
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/insect_wings/bee
	name = "Bee"
	icon_state = "bee"

/datum/sprite_accessory/insect_wings/bee2
	name = "Small Bee"
	icon_state = "beewings"

/datum/sprite_accessory/insect_wings/dragon
	name = "Dragon"
	icon_state = "dragon"

/datum/sprite_accessory/insect_wings/dragonfly
	name = "Dragonfly"
	icon_state = "dragonfly"

/datum/sprite_accessory/insect_wings/fairy
	name = "Fairy"
	icon_state = "fairy"

/datum/sprite_accessory/insect_wings/featheredwing
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/insect_wings/featheredwingmedium
	name = "Medium Feathered"
	icon_state = "feathered3"

/datum/sprite_accessory/insect_wings/featheredwinglarge
	name = "Large Feathered"
	icon_state = "feathered2"

/datum/sprite_accessory/insect_wings/harpywings
	name = "Harpy"
	icon_state = "harpywings"

/datum/sprite_accessory/insect_wings/roboticwing
	name = "Robotic"
	icon_state = "drago"

/datum/sprite_accessory/insect_wings/succubusblack
	name = "Succubus Black"
	icon_state = "succubusblack"

/datum/sprite_accessory/insect_wings/succubuspurple
	name = "Succubus Purple"
	icon_state = "succubuspurple"

/datum/sprite_accessory/insect_wings/succubusred
	name = "Succubus Red"
	icon_state = "succubusred"

/datum/sprite_accessory/insect_wings/xenobackplate
	name = "Xenomorph Backplate"
	icon_state = "snagbackplate"

//moth wings

/datum/sprite_accessory/insect_wings/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/insect_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/insect_wings/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/insect_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/insect_wings/featherymoth
	name = "Feathery Moth Wings"
	icon_state = "featherymoth"

/datum/sprite_accessory/insect_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/insect_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/insect_wings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/insect_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/insect_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/insect_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/insect_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/insect_wings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/insect_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/insect_wings/plasmafire
	name = "Plasma Fire"
	icon_state = "plasmafire"

/datum/sprite_accessory/insect_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/insect_wings/punished
	name = "Burnt Off"
	icon_state = "punished"

/datum/sprite_accessory/insect_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/insect_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/insect_wings/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/insect_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/insect_wings/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/insect_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/insect_wings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

//insect markings
/datum/sprite_accessory/insect_markings // Extra markings for insects ported from tg.
	icon = 'icons/mob/insect_markings.dmi'
	color_src = null
	relevant_layers = list(BODY_ADJ_LAYER)

/datum/sprite_accessory/insect_markings/none
	name = "None"
	icon_state = "none"
	relevant_layers = null

/datum/sprite_accessory/insect_markings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/insect_markings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/insect_markings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/insect_markings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/insect_markings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/insect_markings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/insect_markings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/insect_markings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/insect_markings/punished
	name = "Punished"
	icon_state = "punished"

/datum/sprite_accessory/insect_markings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/insect_markings/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/insect_markings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/insect_markings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/insect_markings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

//DONATOR WINGS

/datum/sprite_accessory/deco_wings/eyestalks
	name = "gazer eyestalks"
	icon_state = "eyestalks"
	//ckeys_allowed = list("liquidfirefly","seiga") //At request.

/datum/sprite_accessory/insect_wings/eyestalks
	name = "gazer eyestalks"
	icon_state = "eyestalks"
	//ckeys_allowed = list("liquidfirefly","seiga") //At request.
