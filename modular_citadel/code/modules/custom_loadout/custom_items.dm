
//For custom items.

/obj/item/custom/ceb_soap
	name = "Cebutris' Soap"
	desc = "A generic bar of soap that doesn't really seem to work right."
	gender = PLURAL
	icon = 'icons/obj/custom.dmi'
	icon_state = "cebu"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = NOBLUDGEON_1

/obj/item/soap/cebu //real versions, for admin shenanigans. Adminspawn only
	desc = "A bright blue bar of soap that smells of wolves"
	icon = 'icons/obj/custom.dmi'
	icon_state = "cebu"

/obj/item/soap/cebu/fast //speedyquick cleaning version. Still not as fast as Syndiesoap. Adminspawn only.
	cleanspeed = 15


/*Inferno707*/

/obj/item/clothing/neck/cloak/inferno
	name = "Kiara's Cloak"
	desc = "The design on this seems a little too familiar."
	icon = 'icons/obj/custom.dmi'
	icon_state = "infcloak"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "infcloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/neck/petcollar/inferno
	name = "Kiara's Collar"
	desc = "A soft black collar that seems to stretch to fit whoever wears it."
	icon = 'icons/obj/custom.dmi'
	icon_state = "infcollar"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "infcollar"
	item_color = null
	tagname = null

/obj/item/clothing/accessory/medal/steele
	name = "Insignia Of Steele"
	desc = "An intricate pendant given to those who help a key member of the Steele Corporation."
	icon = 'icons/obj/custom.dmi'
	icon_state = "steele"
	item_color = "steele"
	medaltype = "medal-silver"

/*DirtyOldHarry*/

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


/*Zombierobin*/

/obj/item/clothing/neck/scarf/zomb //Default white color, same functionality as beanies.
	name = "A special scarf"
	icon = 'icons/obj/custom.dmi'
	icon_state = "zombscarf"
	desc = "A fashionable collar"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_color = "zombscarf"
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/suit/toggle/labcoat/mad/red
	name = "\improper The Mad's labcoat"
	desc = "An oddly special looking coat."
	icon = 'icons/obj/custom.dmi'
	icon_state = "labred"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "labred"


/obj/item/clothing/suit/toggle/labcoat/labredblack
	name = "Black and Red Coat"
	desc = "An oddly special looking coat."
	icon = 'icons/obj/custom.dmi'
	icon_state = "labredblack"
	icon_override = 'icons/mob/custom_w.dmi'
	item_state = "labredblack"


/*Improvedname*/

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
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
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
	icon_override = 'icons/mob/custom_w.dmi'

/obj/item/storage/backpack/satchel/carrot/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/toysqueak1.ogg'=1), 50)

/*PLACEHOLDER*/

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
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS


/*Zigfie*/

/obj/item/clothing/mask/luchador/zigfie
	name = "Alboroto Rosa mask"
	icon = 'icons/obj/custom.dmi'
	icon_state = "lucharzigfie"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "lucharzigfie"


/*PLACEHOLDER*/

/obj/item/clothing/head/hardhat/reindeer/fluff
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose - Sponsored by PWR Game(tm)"
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	item_color = "reindeer"
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

/obj/item/clothing/mask/sexymime
	name = "The Hollow heart"
	desc = "Sometimes things are too much to hide."
	icon = 'icons/obj/custom.dmi'
	icon_override = 'icons/mob/custom_w.dmi'
	icon_state = "sexymime"
	item_state = "sexymime"
	flags_inv = HIDEFACE|HIDEFACIALHAIR


/*Brian*/

/obj/item/clothing/suit/trenchcoat/green
	name = "Reece's Great Coat"
	desc = "You would swear this was in your nightmares after eating too many veggies."
	icon = 'icons/obj/custom.dmi'
	icon_state = "hos-g"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "hos-g"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS


/*Slomek*/
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
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	icon_state = "stalker"


/*Sylas*/
/obj/item/clothing/neck/petcollar/stripe //don't really wear this though please c'mon seriously guys
	name = "collar"
	desc = "It's a collar..."
	icon = 'icons/obj/custom.dmi'
	icon_state = "petcollar-stripe"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "petcollar-stripe"
	tagname = null


/*PLACEHOLDER*/
/obj/item/clothing/under/singery/custom
	name = "bluish performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon = 'icons/obj/custom.dmi'
	icon_state = "singer"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "singer"
	item_color = "singer"
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = 0


/obj/item/clothing/shoes/sneakers/pink
	icon = 'icons/obj/custom.dmi'
	icon_state = "pink"
	alternate_worn_icon = 'icons/mob/custom_w.dmi'
	item_state = "pink"

/obj/item/clothing/neck/tie/bloodred
	name = "Blood Red Tie"
	desc = "A neosilk clip-on tie. This one has a black S on the tipping and looks rather unique."
	icon = 'icons/obj/custom.dmi'
	icon_state = "bloodredtie"
	icon_override = 'icons/mob/custom_w.dmi'

/obj/item/clothing/suit/puffydress
	name = "Puffy Dress"
	desc = "A formal puffy black and red Victorian dress."
	icon = 'icons/obj/custom.dmi'
	icon_override = 'icons/mob/custom_w.dmi'
	icon_state = "puffydress"
	item_state = "puffydress"
	body_parts_covered = CHEST|GROIN|LEGS


/*Fractious*/

/obj/item/clothing/suit/vermillion
	name = "vermillion clothing"
	desc = "Some clothing."
	icon_state = "vermillion"
	item_state = "vermillion"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	icon = 'icons/obj/custom.dmi'
	alternate_worn_icon = 'icons/mob/custom_w.dmi'

/*TechnicalMagi*/
/obj/item/clothing/under/bb_sweater/black/naomi
	name = "worn black sweater"
	desc = "A well-loved sweater, showing signs of several cleanings and re-stitchings. And a few stains. Is that cat fur?"

/obj/item/clothing/neck/petcollar/naomi
	name = "worn pet collar"
	desc = "a pet collar that looks well used."

/obj/item/clothing/neck/petcollar/naomi/examine(mob/user)
	. = ..()
	if(usr.ckey != "technicalmagi")
		to_chat(user, "There's something odd about the it. You probably shouldn't wear it...")//warn people not to wear it if they're not Naomi, lest they become as crazy as she is

/obj/item/clothing/neck/petcollar/naomi/equipped()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/neck/petcollar/naomi/dropped()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/neck/petcollar/naomi/process()
	var/mob/living/carbon/human/H
	if(ishuman(loc))
		H = loc
	if(!H)
		return
	else if(H.get_item_by_slot(slot_neck) == src)
		if(H.arousalloss < H.max_arousal / 3)
			H.arousalloss = H.max_arousal / 3
		if(prob(5) && H.hallucination < 15)
			H.hallucination += 10
