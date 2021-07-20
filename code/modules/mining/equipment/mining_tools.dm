/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=2000) //one sheet, but where can you make them?
	tool_behaviour = TOOL_MINING
	toolspeed = 1
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/digrange = 1

/obj/item/pickaxe/attack_self(mob/user)
	if(initial(digrange) > 0)
		if(digrange == 0)
			digrange = initial(digrange)
			toolspeed = initial(toolspeed)
			to_chat(user, "<span class='notice'>You increase the tools dig range, decreasing its mining speed.</span>")
		else
			digrange = 0
			toolspeed = toolspeed/2
			to_chat(user, "<span class='notice'>You decrease the tools dig range, increasing its mining speed.</span>")
	else
		to_chat(user, "<span class='notice'>Tool does not have a configureable dig range.</span>")

/obj/item/pickaxe/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins digging into [user.p_their()] chest!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message("<span class='suicide'>[user] couldn't do it!</span>")
	return SHAME

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	force = 10
	throwforce = 7
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=1000)

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	toolspeed = 0.5 //mines faster than a normal pickaxe, bought from mining vendor
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	force = 17
	custom_materials = list(/datum/material/silver=4000)

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	toolspeed = 0.3
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	force = 19
	custom_materials = list(/datum/material/diamond=4000)

/obj/item/pickaxe/rosegold
	name = "rose gold pickaxe"
	icon_state = "rgpickaxe"
	item_state = "rgpickaxe"
	toolspeed = 0.1
	desc = "A pickaxe with a light rose gold head and some red glowing runes. Extremely robust at cracking rock walls and digging up dirt."
	force = 19
	custom_materials = list(/datum/material/gold=4000)
	digrange = 3

/obj/item/pickaxe/plasteel
	name = "plasteel-tipped pickaxe"
	icon_state = "titaxe"
	toolspeed = 0.5
	desc = "A pickaxe with a plasteel pick head. Less robust at cracking rock walls and digging up dirt than the titanium pickaxe, but better at cracking open skulls."
	force = 19
	custom_materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)

/obj/item/pickaxe/titanium
	name = "titanium-tipped pickaxe"
	icon_state = "psteelaxe"
	toolspeed = 0.3
	desc = "A pickaxe with a titanium pick head. Extremely robust at cracking rock walls and digging up dirt, but less than the plasteel pickaxe at cracking open skulls."
	force = 17
	custom_materials = list(/datum/material/titanium=4000)

/obj/item/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	slot_flags = ITEM_SLOT_BELT
	toolspeed = 0.6 //available from roundstart, faster than a pickaxe.
	usesound = 'sound/weapons/drill.ogg'
	hitsound = 'sound/weapons/drill.ogg'
	desc = "An electric mining drill for the especially scrawny."

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags_1 = NONE
	toolspeed = 0.5

/obj/item/pickaxe/drill/cyborg/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	toolspeed = 0.4
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP_1 flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	toolspeed = 0.4
	digrange = 2

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	w_class = WEIGHT_CLASS_HUGE
	toolspeed = 0.2 //the epitome of powertools. extremely fast mining, laughs at puny walls
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."
	digrange = 2

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 8
	tool_behaviour = TOOL_SHOVEL
	toolspeed = 0.1 //Can only dig ash and thats about it, out classed by the picks and drills no more!
	usesound = 'sound/effects/shovel_dig.ogg'
	throwforce = 4
	item_state = "shovel"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=350)
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	sharpness = SHARP_EDGED

/obj/item/shovel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 150, 40) //it's sharp, so it works, but barely.

/obj/item/shovel/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins digging their own grave!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message("<span class='suicide'>[user] couldn't do it!</span>")
	return SHAME

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	toolspeed = 0.5
	force = 5
	throwforce = 7
	custom_materials = list(/datum/material/iron=50)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/spade/bone
	name = "bone spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade_bone"
	toolspeed = 0.75

/obj/item/shovel/serrated
	name = "serrated bone shovel"
	desc = "A wicked tool that cleaves through dirt just as easily as it does flesh. The design was styled after ancient lavaland tribal designs."
	icon_state = "shovel_bone"
	item_state = "shovel_bone"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	force = 15
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	attack_verb = list("slashed", "impaled", "stabbed", "sliced")
	sharpness = SHARP_EDGED
