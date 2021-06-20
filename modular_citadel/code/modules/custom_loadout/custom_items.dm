//For custom items.

// Unless there's a digitigrade version make sure you add mutantrace_variation = NONE to all clothing/under and shoes - Pooj
// Digitigrade stuff is uniform_digi.dmi and digishoes.dmi in icons/mob

/obj/item/clothing/neck/cloak/inferno
	name = "Kiara's Cloak"
	desc = "The design on this seems a little too familiar."
	icon = 'icons/obj/custom.dmi'
	icon_state = "infcloak"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "infcloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/neck/petcollar/inferno
	name = "Kiara's Collar"
	desc = "A soft black collar that seems to stretch to fit whoever wears it."
	icon = 'icons/obj/custom.dmi'
	icon_state = "infcollar"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "infcollar"
	tagname = null

/obj/item/clothing/accessory/medal/steele
	name = "Insignia Of Steele"
	desc = "An intricate pendant given to those who help a key member of the Steele Corporation."
	icon = 'icons/obj/custom.dmi'
	icon_state = "steele"
	medaltype = "medal-silver"

/obj/item/toy/darksabre
	name = "Kiara's Sabre"
	desc = "This blade looks as dangerous as its owner."
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "darksabre"
	item_state = "darksabre"
	lefthand_file = 'modular_citadel/icons/mob/inhands/stunsword_left.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/stunsword_right.dmi'
	attack_verb = list("attacked", "struck", "hit")

/obj/item/toy/darksabre/get_belt_overlay()
	return mutable_appearance('icons/obj/custom.dmi', "darksheath-darksabre")

/obj/item/toy/darksabre/get_worn_belt_overlay(icon_file)
	return mutable_appearance(icon_file, "darksheath-darksabre")

/obj/item/storage/belt/sabre/darksabre
	name = "Ornate Sheathe"
	desc = "An ornate and rather sinister looking sabre sheathe."
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "darksheath"
	item_state = "darksheath"
	fitting_swords = list(/obj/item/toy/darksabre)
	starting_sword = /obj/item/toy/darksabre

/obj/item/clothing/suit/armor/vest/darkcarapace
	name = "Dark Armor"
	desc = "A dark, non-functional piece of armor sporting a red and black finish."
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "darkcarapace"
	item_state = "darkcarapace"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	mutantrace_variation = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)


/obj/item/lighter/gold
	name = "\improper Engraved Zippo"
	desc = "A shiny and relatively expensive zippo lighter. There's a small etched in verse on the bottom that reads, 'No Gods, No Masters, Only Man.'"
	icon = 'icons/obj/custom.dmi'
	icon_state = "gold_zippo"
	item_state = "gold_zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE

/obj/item/clothing/neck/scarf/zomb
	name = "A special scarf"
	icon = 'icons/obj/custom.dmi'
	icon_state = "zombscarf"
	desc = "A fashionable collar"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/suit/toggle/labcoat/mad/red
	name = "\improper The Mad's labcoat"
	desc = "An oddly special looking coat."
	icon = 'icons/obj/custom.dmi'
	icon_state = "labred"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "labred"
	mutantrace_variation = NONE

/obj/item/clothing/suit/toggle/labcoat/labredblack
	name = "Black and Red Coat"
	desc = "An oddly special looking coat."
	icon = 'icons/obj/custom.dmi'
	icon_state = "labredblack"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "labredblack"
	mutantrace_variation = NONE

/obj/item/toy/plush/carrot
	name = "carrot plushie"
	desc = "While a normal carrot would be good for your eyes, this one seems a bit more for hugging then eating."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "carrot"
	item_state = "carrot"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("slapped")
	resistance_flags = FLAMMABLE
	squeak_override = list('sound/items/bikehorn.ogg'= 1)

/obj/item/clothing/neck/cloak/carrot
	name = "carrot cloak"
	desc = "A cloak in the shape and color of a carrot!"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "carrotcloak"
	item_state = "carrotcloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/storage/backpack/satchel/carrot
	name = "carrot satchel"
	desc = "An satchel that is designed to look like an carrot"
	icon = 'icons/obj/custom.dmi'
	icon_state = "satchel_carrot"
	item_state = "satchel_carrot"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/storage/backpack/satchel/carrot/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/toysqueak1.ogg'=1), 50)

/obj/item/toy/plush/tree
	name = "christmass tree plushie"
	desc = "A festive plush that squeeks when you squeeze it!"
	icon = 'icons/obj/custom.dmi'
	icon_state = "pine_c"
	item_state = "pine_c"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("slapped")
	resistance_flags = FLAMMABLE
	squeak_override = list('sound/misc/server-ready.ogg'= 1)

/obj/item/clothing/neck/cloak/festive
	name = "Celebratory Cloak of Morozko"
	desc = " It probably will protect from snow, charcoal or elves."
	icon = 'icons/obj/custom.dmi'
	icon_state = "festive"
	item_state = "festive"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/mask/luchador/zigfie
	name = "Alboroto Rosa mask"
	icon = 'icons/obj/custom.dmi'
	icon_state = "lucharzigfie"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "lucharzigfie"

/obj/item/clothing/head/hardhat/reindeer/fluff
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose - Sponsored by PWR Game(tm)"
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	hat_type = "reindeer"
	flags_inv = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	brightness_on = 0 //luminosity when on
	dynamic_hair_suffix = ""

/obj/item/clothing/head/santa/fluff
	name = "santa's hat"
	desc = "On the first day of christmas my employer gave to me! - From Vlad with Salad"
	icon_state = "santahatnorm"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head/santa

//Removed all of the space flags from this suit so it utilizes nothing special.
/obj/item/clothing/suit/space/santa/fluff
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0

/obj/item/clothing/mask/hheart
	name = "The Hollow heart"
	desc = "Sometimes things are too much to hide."
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "hheart"
	item_state = "hheart"
	flags_inv = HIDEFACE|HIDEFACIALHAIR

/obj/item/clothing/suit/trenchcoat/green
	name = "Reece's Great Coat"
	desc = "You would swear this was in your nightmares after eating too many veggies."
	icon = 'icons/obj/custom.dmi'
	icon_state = "hos-g"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "hos-g"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	mutantrace_variation = NONE

/obj/item/reagent_containers/food/drinks/flask/russian
	name = "russian flask"
	desc = "Every good russian spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon = 'icons/obj/custom.dmi'
	icon_state = "russianflask"
	volume = 60

/obj/item/clothing/mask/gas/stalker
	name = "S.T.A.L.K.E.R. mask"
	desc = "Smells like reactor four."
	icon = 'icons/obj/custom.dmi'
	item_state = "stalker"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "stalker"

/obj/item/reagent_containers/food/drinks/flask/steel
	name = "The End"
	desc = "A plain steel flask, sealed by lock and key. The front is inscribed with The End."
	icon = 'icons/obj/custom.dmi'
	icon_state = "steelflask"
	volume = 60

/obj/item/clothing/neck/petcollar/stripe //don't really wear this though please c'mon seriously guys
	name = "collar"
	desc = "It's a collar..."
	icon = 'icons/obj/custom.dmi'
	icon_state = "petcollar-stripe"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "petcollar-stripe"
	tagname = null

/obj/item/clothing/under/costume/singer/yellow/custom
	name = "bluish performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon = 'icons/obj/custom.dmi'
	icon_state = "singer"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "singer"
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = 0
	mutantrace_variation = NONE

/obj/item/clothing/shoes/sneakers/pink
	icon = 'icons/obj/custom.dmi'
	icon_state = "pink"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "pink"
	mutantrace_variation = NONE

/obj/item/clothing/neck/tie/bloodred
	name = "Blood Red Tie"
	desc = "A neosilk clip-on tie. This one has a black S on the tipping and looks rather unique."
	icon = 'icons/obj/custom.dmi'
	icon_state = "bloodredtie"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/clothing/suit/puffydress
	name = "Puffy Dress"
	desc = "A formal puffy black and red Victorian dress."
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "puffydress"
	item_state = "puffydress"
	body_parts_covered = CHEST|GROIN|LEGS
	mutantrace_variation = NONE

/obj/item/clothing/suit/vermillion
	name = "vermillion clothing"
	desc = "Some clothing."
	icon_state = "vermillion"
	item_state = "vermillion"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/under/sweater/black/naomi
	name = "worn black sweater"
	mutantrace_variation = NONE
	desc = "A well-loved sweater, showing signs of several cleanings and re-stitchings. And a few stains. Is that cat fur?"

/obj/item/clothing/neck/petcollar/naomi
	name = "worn pet collar"
	desc = "A pet collar that looks well used."

/obj/item/clothing/neck/cloak/green
	name = "Generic Green Cloak"
	desc = "This cloak doesn't seem too special."
	icon = 'icons/obj/custom.dmi'
	icon_state = "wintergreencloak"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "wintergreencloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/head/paperhat
	name = "paperhat"
	desc = "A piece of paper folded into neat little hat."
	icon_state = "paperhat"
	item_state = "paperhat"

/obj/item/clothing/suit/toggle/labcoat/mad/techcoat
	name = "Techomancers Labcoat"
	desc = "An oddly special looking coat."
	icon = 'icons/obj/custom.dmi'
	icon_state = "rdcoat"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "rdcoat"
	mutantrace_variation = NONE

/obj/item/custom/leechjar
	name = "Jar of Leeches"
	desc = "A dubious cure-all. The cork seems to be sealed fairly well, and the glass impossible to break."
	icon = 'icons/obj/custom.dmi'
	icon_state = "leechjar"
	item_state = "leechjar"

/obj/item/clothing/neck/devilwings
	name = "Strange Wings"
	desc = "These strange wings look like they once attached to something... or someone...? Whatever the case, their presence makes you feel uneasy.."
	icon = 'icons/obj/custom.dmi'
	icon_state = "devilwings"
	mob_overlay_icon = 'modular_citadel/icons/mob/clothing/devilwings64x64.dmi'
	item_state = "devilwings"
	worn_x_dimension = 64
	worn_y_dimension = 34

/obj/item/clothing/neck/flagcape
	name = "Flag Cape"
	desc = "A truly patriotic form of heroic attire."
	icon = 'icons/obj/custom.dmi'
	resistance_flags = FLAMMABLE
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "flagcape"
	item_state = "flagcape"

/obj/item/clothing/shoes/lucky
	name = "Lucky Jackboots"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	desc = "Comfy Lucky Jackboots with the word Luck on them."
	item_state = "luckyjack"
	icon_state = "luckyjack"
	mutantrace_variation = NONE

/obj/item/clothing/under/custom/lunasune
	name = "Divine Robes"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	desc = "Heavenly robes of the kitsune Luna Pumpkin,you can feel radiance coming from them."
	item_state = "Divine_robes"
	icon_state = "Divine_robes"
	mutantrace_variation = NONE

/obj/item/clothing/under/custom/leoskimpy
	name = "Leon's Skimpy Outfit"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	desc =  "A rather skimpy outfit."
	item_state = "shark_cloth"
	icon_state = "shark_cloth"
	mutantrace_variation = NONE

/obj/item/clothing/under/custom/mimeoveralls
	name = "Mime's Overalls"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	desc = "A less-than-traditional mime's attire, completed by a set of dorky-looking overalls."
	item_state = "moveralls"
	icon_state = "moveralls"
	mutantrace_variation = NONE

/obj/item/clothing/suit/hooded/cloak/zuliecloak
	name = "Project: Zul-E"
	desc = "A standard version of a prototype cloak given out by Nanotrasen higher ups. It's surprisingly thick and heavy for a cloak despite having most of it's tech stripped. It also comes with a bluespace trinket which calls it's accompanying hat onto the user. A worn inscription on the inside of the cloak reads 'Fleuret' ...the rest is faded away."
	icon_state = "zuliecloak"
	item_state = "zuliecloak"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/zuliecloak
	body_parts_covered = CHEST|GROIN|ARMS
	slot_flags = SLOT_WEAR_SUIT | ITEM_SLOT_NECK //it's a cloak. it's cosmetic. so why the hell not? what could possibly go wrong?
	mutantrace_variation = NONE

/obj/item/clothing/head/hooded/cloakhood/zuliecloak
	name = "NT Special Issue"
	desc = "This hat is unquestionably the best one, bluespaced to and from CentComm. It smells of Fish and Tea with a hint of antagonism"
	icon_state = "zuliecap"
	item_state = "zuliecap"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	flags_inv = HIDEEARS|HIDEHAIR
	mutantrace_variation = NONE

/obj/item/clothing/suit/blackredgold
	name = "Multicolor Coat"
	desc = "An oddly special looking coat with black, red, and gold"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "redgoldjacket"
	item_state = "redgoldjacket"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	mutantrace_variation = NONE

/obj/item/clothing/suit/kimono
	name = "Blue Kimono"
	desc = "A traditional kimono, this one is blue with purple flowers."
	icon_state = "kimono"
	item_state = "kimono"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	mutantrace_variation = NONE

/obj/item/clothing/suit/commjacket
	name = "Dusty Commisar's Cloak"
	desc = "An Imperial Commisar's Coat, straight from the frontline of battle, filled with dirt, bulletholes, and dozens of little pockets. Alongside a curious golden eagle sitting on it's left breast, the marking '200th Venoland' is clearly visible on the inner workings of the coat. It certainly holds an imposing flair, however."
	icon_state = "commjacket"
	item_state = "commjacket"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	mutantrace_variation = NONE

/obj/item/clothing/under/custom/mw2_russian_para
	name = "Russian Paratrooper Jumper"
	desc = "A Russian made old paratrooper jumpsuit, has many pockets for easy storage of gear from a by gone era. As bulky as it looks, its shockingly light!"
	icon_state = "mw2_russian_para"
	item_state = "mw2_russian_para"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/gloves/longblackgloves
	name = "Luna's Gauntlets"
	desc = "These gloves seem to have a coating of slime fluid on them, you should possibly return them to their rightful owner."
	icon_state = "longblackgloves"
	item_state = "longblackgloves"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/clothing/under/custom/trendy_fit
	name = "Trendy Fitting Clothing"
	desc = "An outfit straight from the boredom of space, its the type of thing only someone trying to entertain themselves on the way to their next destination would wear."
	icon_state = "trendy_fit"
	item_state = "trendy_fit"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/head/blueberet
	name = "Atmos Beret"
	desc = "A fitted beret designed to be worn by Atmos Techs."
	icon_state = "blueberet"
	item_state = "blueberet"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	dynamic_hair_suffix = ""

/obj/item/clothing/head/flight
	name = "flight goggles"
	desc = "Old style flight goggles with a leather cap attached."
	icon_state = "flight-g"
	item_state = "flight-g"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/clothing/neck/necklace/onion
	name = "Onion Necklace"
	desc = "A string of onions sequenced together to form a necklace."
	icon = 'icons/obj/custom.dmi'
	icon_state = "onion"
	item_state = "onion"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/clothing/under/custom/mikubikini
	name = "starlight singer bikini"
	desc = " "
	icon_state = "mikubikini"
	item_state = "mikubikini"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/suit/mikujacket
	name = "starlight singer jacket"
	desc = " "
	icon_state = "mikujacket"
	item_state = "mikujacket"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/head/mikuhair
	name = "starlight singer hair"
	desc = " "
	icon_state = "mikuhair"
	item_state = "mikuhair"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE
	flags_inv = HIDEHAIR

/obj/item/clothing/gloves/mikugloves
	name = "starlight singer gloves"
	desc = " "
	icon_state = "mikugloves"
	item_state = "mikugloves"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/shoes/sneakers/mikuleggings
	name = "starlight singer leggings"
	desc = " "
	icon_state = "mikuleggings"
	item_state = "mikuleggings"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/toy/plush/mammal/dog/fritz
	icon = 'icons/obj/custom.dmi'
	icon_state = "fritz"
	item_state = "fritz"
	attack_verb = list("barked", "boofed", "shotgun'd")
	obj_flags = UNIQUE_RENAME
	unique_reskin = list("Goodboye" = "fritz", "Badboye" = "fritz_bad")
	mutantrace_variation = NONE

/obj/item/clothing/neck/cloak/polychromic/polyce
	name = "polychromic embroidered cloak"
	desc = "A fancy cloak embroidered with polychromatic thread in a pattern that reminds one of the wielders of unlimited power."
	icon_state = "polyce"
	poly_colors = list("#808080", "#8CC6FF", "#FF3535")

/obj/item/clothing/under/custom/customskirt
	name = "unzipped atmos skirt"
	desc = "atmos jumpsuit skirt with the top half zipped down and wrapped around the waist."
	icon_state = "atmos_skirt"
	item_state = "atmos_skirt"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'

/obj/item/clothing/head/halo
	name = "transdimensional halo"
	desc = "An oddly shaped halo that magically hovers above the head."
	icon_state = "halo"
	item_state = "halo"
	icon = 'icons/mob/clothing/custom_w.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	dynamic_hair_suffix = ""

/obj/item/clothing/under/custom/vest
	name = "vest"
	desc = "A vest with a shirt underlining it."
	icon_state = "vest"
	item_state = "vest"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = STYLE_DIGITIGRADE

/obj/item/clothing/suit/custom/exo
	name = "Full ExoFrame"
	desc = "A suit specially designed for those who live and breath hardware with custom tooled robotic manipulators for working with precision even on the most hazardous of jobs."
	icon_state = "frame"
	item_state = "frame"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/clothing/neck/petcollar/donorchoker
	name = "NT Choker"
	desc = "NT property since January 21st,  2562."
	icon = 'icons/obj/custom.dmi'
	icon_state = "choker"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	item_state = "choker"

/obj/item/clothing/mask/breath/mmask
	name = "Strange Metal Mask"
	desc = "An odd metal mask."
	icon = 'icons/obj/custom.dmi'
	item_state = "mmask"
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	icon_state = "mmask"

/obj/item/clothing/under/smaiden
	name = "shrine maiden outfit"
	desc = "Seems questionably tight for religious purposes."
	icon_state = "smaiden"
	item_state = "smaiden"
	icon = 'icons/obj/custom.dmi'
	mob_overlay_icon = 'icons/mob/clothing/custom_w.dmi'
	mutantrace_variation = NONE

/obj/item/coin/red
	name = "red pokerchip"
	desc = "A red pokerchip."
	icon_state = "c_red"
	item_state = "c_red"
	icon = 'icons/obj/custom.dmi'

/obj/item/coin/blue
	name = "blue pokerchip"
	desc = "A blue pokerchip."
	icon_state = "c_nlue"
	item_state = "c_blue"
	icon = 'icons/obj/custom.dmi'

/obj/item/coin/green
	name = "green pokerchip"
	desc = "A green pokerchip."
	icon_state = "c_green"
	item_state = "c_green"
	icon = 'icons/obj/custom.dmi'

/obj/item/coin/black
	name = "black pokerchip"
	desc = "A black pokerchip."
	icon_state = "c_black"
	item_state = "c_black"
	icon = 'icons/obj/custom.dmi'

/obj/item/storage/box/pockerchips
	name = "tray of pocker chips"
	desc = "A tray of green, red, blue, and black pocker chips."
	icon_state = "c_holder"
	icon = 'icons/obj/custom.dmi'
	illustration=null

/obj/item/storage/box/pokerchips/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/coin/red(src)
	for(var/i in 1 to 10)
		new /obj/item/coin/blue(src)
	for(var/i in 1 to 15)
		new /obj/item/coin/black(src)
	for(var/i in 1 to 20)
		new /obj/item/coin/green(src)