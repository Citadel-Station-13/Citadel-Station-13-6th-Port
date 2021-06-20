/obj/item/banhammer
	desc = "A banhammer."
	name = "banhammer"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "toyhammer"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	force = 1
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	attack_verb = list("banned")
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF

/obj/item/banhammer/suicide_act(mob/user)
		user.visible_message("<span class='suicide'>[user] is hitting [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to ban [user.p_them()]self from life.</span>")
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)
/*
oranges says: This is a meme relating to the english translation of the ss13 russian wiki page on lurkmore.
mrdoombringer sez: and remember kids, if you try and PR a fix for this item's grammar, you are admitting that you are, indeed, a newfriend.
for further reading, please see: https://github.com/tgstation/tgstation/pull/30173 and https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=%2F%2Flurkmore.to%2FSS13&edit-text=&act=url
*/
/obj/item/banhammer/attack(mob/M, mob/user)
	if(user.zone_selected == BODY_ZONE_HEAD)
		M.visible_message("<span class='danger'>[user] are stroking the head of [M] with a bangammer.</span>", "<span class='userdanger'>[user] are stroking your head with a bangammer.</span>", "<span class='hear'>You hear a bangammer stroking a head.</span>") // see above comment
	else
		M.visible_message("<span class='danger'>[M] has been banned FOR NO REISIN by [user]!</span>", "<span class='userdanger'>You have been banned FOR NO REISIN by [user]!</span>", "<span class='hear'>You hear a banhammer banning someone.</span>")
	playsound(loc, 'sound/effects/adminhelp.ogg', 15) //keep it at 15% volume so people don't jump out of their skin too much
	if(user.a_intent != INTENT_HELP)
		return ..(M, user)

/obj/item/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 2
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/sord/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is trying to impale [user.p_them()]self with [src]! It might be a suicide attempt if it weren't so shitty.</span>", \
	"<span class='suicide'>You try to impale yourself with [src], but it's USELESS...</span>")
	return SHAME

/obj/item/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON

/obj/item/claymore/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40, 105)
	AddElement(/datum/element/sword_point)

/obj/item/claymore/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/claymore/purified
	name = "purified longsword"
	desc = "A hastily-purified longsword. While not as holy as it could be, it's still a formidable weapon against those who would rather see you dead."
	force = 25
	block_chance = 0

/obj/item/claymore/highlander //ALL COMMENTS MADE REGARDING THIS SWORD MUST BE MADE IN ALL CAPS
	desc = "<b><i>THERE CAN BE ONLY ONE, AND IT WILL BE YOU!!!</i></b>\nActivate it in your hand to point to the nearest victim."
	flags_1 = CONDUCT_1
	item_flags = DROPDEL //WOW BRO YOU LOST AN ARM, GUESS WHAT YOU DONT GET YOUR SWORD ANYMORE //I CANT BELIEVE SPOOKYDONUT WOULD BREAK THE REQUIREMENTS
	slot_flags = null
	block_chance = 0 //RNG WON'T HELP YOU NOW, PANSY
	light_range = 3
	attack_verb = list("brutalized", "eviscerated", "disemboweled", "hacked", "carved", "cleaved") //ONLY THE MOST VISCERAL ATTACK VERBS
	var/notches = 0 //HOW MANY PEOPLE HAVE BEEN SLAIN WITH THIS BLADE
	var/obj/item/disk/nuclear/nuke_disk //OUR STORED NUKE DISK

/obj/item/claymore/highlander/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)
	START_PROCESSING(SSobj, src)

/obj/item/claymore/highlander/Destroy()
	if(nuke_disk)
		nuke_disk.forceMove(get_turf(src))
		nuke_disk.visible_message("<span class='warning'>The nuke disk is vulnerable!</span>")
		nuke_disk = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/claymore/highlander/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		loc.layer = LARGE_MOB_LAYER //NO HIDING BEHIND PLANTS FOR YOU, DICKWEED (HA GET IT, BECAUSE WEEDS ARE PLANTS)
		H.bleedsuppress = TRUE //AND WE WON'T BLEED OUT LIKE COWARDS
		H.adjustStaminaLoss(-50) //CIT CHANGE - AND MAY HE NEVER SUCCUMB TO EXHAUSTION
	else
		if(!(flags_1 & ADMIN_SPAWNED_1))
			qdel(src)


/obj/item/claymore/highlander/pickup(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>The power of Scotland protects you! You are shielded from all stuns and knockdowns.</span>")
	user.add_stun_absorption("highlander", INFINITY, 1, " is protected by the power of Scotland!", "The power of Scotland absorbs the stun!", " is protected by the power of Scotland!")
	user.ignore_slowdown(HIGHLANDER)

/obj/item/claymore/highlander/dropped(mob/living/user)
	. = ..()
	user.unignore_slowdown(HIGHLANDER)

/obj/item/claymore/highlander/examine(mob/user)
	. = ..()
	. += "It has [!notches ? "nothing" : "[notches] notches"] scratched into the blade."
	if(nuke_disk)
		. += "<span class='boldwarning'>It's holding the nuke disk!</span>"

/obj/item/claymore/highlander/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!QDELETED(target) && target.stat == DEAD && target.mind && target.mind.special_role == "highlander")
		user.fully_heal(admin_revive = FALSE) //STEAL THE LIFE OF OUR FALLEN FOES
		add_notch(user)
		target.visible_message("<span class='warning'>[target] crumbles to dust beneath [user]'s blows!</span>", "<span class='userdanger'>As you fall, your body crumbles to dust!</span>")
		target.dust()

/obj/item/claymore/highlander/attack_self(mob/living/user)
	var/closest_victim
	var/closest_distance = 255
	for(var/mob/living/carbon/human/scot in GLOB.player_list - user)
		if(scot.mind.special_role == "highlander" && (!closest_victim || get_dist(user, closest_victim) < closest_distance))
			closest_victim = scot
	for(var/mob/living/silicon/robot/siliscot in GLOB.player_list - user)
		if(siliscot.mind.special_role == "highlander" && (!closest_victim || get_dist(user, closest_victim) < closest_distance))
			closest_victim = siliscot

	if(!closest_victim)
		to_chat(user, "<span class='warning'>[src] thrums for a moment and falls dark. Perhaps there's nobody nearby.</span>")
		return
	to_chat(user, "<span class='danger'>[src] thrums and points to the [dir2text(get_dir(user, closest_victim))].</span>")

/obj/item/claymore/highlander/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if((attack_type & ATTACK_TYPE_PROJECTILE) && is_energy_reflectable_projectile(object))
		return BLOCK_SUCCESS | BLOCK_SHOULD_REDIRECT | BLOCK_PHYSICAL_EXTERNAL | BLOCK_REDIRECTED
	return ..() //YOU THINK YOUR PUNY LASERS CAN STOP ME?

/obj/item/claymore/highlander/proc/add_notch(mob/living/user) //DYNAMIC CLAYMORE PROGRESSION SYSTEM - THIS IS THE FUTURE
	notches++
	force++
	var/new_name = name
	switch(notches)
		if(1)
			to_chat(user, "<span class='notice'>Your first kill - hopefully one of many. You scratch a notch into [src]'s blade.</span>")
			to_chat(user, "<span class='warning'>You feel your fallen foe's soul entering your blade, restoring your wounds!</span>")
			new_name = "notched claymore"
		if(2)
			to_chat(user, "<span class='notice'>Another falls before you. Another soul fuses with your own. Another notch in the blade.</span>")
			new_name = "double-notched claymore"
			add_atom_colour(rgb(255, 235, 235), ADMIN_COLOUR_PRIORITY)
		if(3)
			to_chat(user, "<span class='notice'>You're beginning to</span> <span class='danger'><b>relish</b> the <b>thrill</b> of <b>battle.</b></span>")
			new_name = "triple-notched claymore"
			add_atom_colour(rgb(255, 215, 215), ADMIN_COLOUR_PRIORITY)
		if(4)
			to_chat(user, "<span class='notice'>You've lost count of</span> <span class='boldannounce'>how many you've killed.</span>")
			new_name = "many-notched claymore"
			add_atom_colour(rgb(255, 195, 195), ADMIN_COLOUR_PRIORITY)
		if(5)
			to_chat(user, "<span class='boldannounce'>Five voices now echo in your mind, cheering the slaughter.</span>")
			new_name = "battle-tested claymore"
			add_atom_colour(rgb(255, 175, 175), ADMIN_COLOUR_PRIORITY)
		if(6)
			to_chat(user, "<span class='boldannounce'>Is this what the vikings felt like? Visions of glory fill your head as you slay your sixth foe.</span>")
			new_name = "battle-scarred claymore"
			add_atom_colour(rgb(255, 155, 155), ADMIN_COLOUR_PRIORITY)
		if(7)
			to_chat(user, "<span class='boldannounce'>Kill. Butcher. <i>Conquer.</i></span>")
			new_name = "vicious claymore"
			add_atom_colour(rgb(255, 135, 135), ADMIN_COLOUR_PRIORITY)
		if(8)
			to_chat(user, "<span class='userdanger'>IT NEVER GETS OLD. THE <i>SCREAMING</i>. THE <i>BLOOD</i> AS IT <i>SPRAYS</i> ACROSS YOUR <i>FACE.</i></span>")
			new_name = "bloodthirsty claymore"
			add_atom_colour(rgb(255, 115, 115), ADMIN_COLOUR_PRIORITY)
		if(9)
			to_chat(user, "<span class='userdanger'>ANOTHER ONE FALLS TO YOUR BLOWS. ANOTHER WEAKLING UNFIT TO LIVE.</span>")
			new_name = "gore-stained claymore"
			add_atom_colour(rgb(255, 95, 95), ADMIN_COLOUR_PRIORITY)
		if(10)
			user.visible_message("<span class='warning'>[user]'s eyes light up with a vengeful fire!</span>", \
			"<span class='userdanger'>YOU FEEL THE POWER OF VALHALLA FLOWING THROUGH YOU! <i>THERE CAN BE ONLY ONE!!!</i></span>")
			user.update_icons()
			new_name = "GORE-DRENCHED CLAYMORE OF [pick("THE WHIMSICAL SLAUGHTER", "A THOUSAND SLAUGHTERED CATTLE", "GLORY AND VALHALLA", "ANNIHILATION", "OBLITERATION")]"
			icon_state = "claymore_gold"
			item_state = "claymore_gold"
			remove_atom_colour(ADMIN_COLOUR_PRIORITY)

	name = new_name
	playsound(user, 'sound/items/screwdriver2.ogg', 50, TRUE)

/obj/item/claymore/highlander/robot //BLOODTHIRSTY BORGS NOW COME IN PLAID
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "claymore_cyborg"
	var/mob/living/silicon/robot/robot

/obj/item/claymore/highlander/robot/Initialize()
	var/obj/item/robot_module/kiltkit = loc
	robot = kiltkit.loc
	if(!istype(robot))
		qdel(src)
	return ..()

/obj/item/claymore/highlander/robot/process()
	loc.layer = LARGE_MOB_LAYER

/obj/item/katana
	name = "katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON

/obj/item/katana/lavaland
	desc = "Woefully underpowered in Lavaland."
	block_chance = 30
	force = 25 //Like a fireaxe but one handed and can block!

/obj/item/katana/cursed
	slot_flags = null

/obj/item/katana/cursed/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/katana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>")
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)
	return(BRUTELOSS)

/obj/item/katana/timestop
	name = "temporal katana"
	desc = "Delicately balanced, this finely-crafted blade hums with barely-restrained potential."
	icon_state = "temporalkatana"
	item_state = "temporalkatana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	block_chance = 0 // oops
	force = 27.5 // oops
	item_flags = ITEM_CAN_PARRY
	block_parry_data = /datum/block_parry_data/bokken/quick_parry/proj

/obj/item/katana/timestop/on_active_parry(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/block_return, parry_efficiency, parry_time)
	if(ishuman(owner))
		var/mob/living/carbon/human/flynn = owner
		flynn.emote("smirk")
	new /obj/effect/timestop/magic(get_turf(owner), 1, 50, list(owner)) // null roddies counter

/obj/item/katana/timestop/suicide_act(mob/living/user) // stolen from hierophant staff
	new /obj/effect/timestop/magic(get_turf(user), 1, 50, list(user)) // free usage for dying
	user.visible_message("<span class='suicide'>[user] poses menacingly with the [src]! It looks like [user.p_theyre()] trying to teleport behind someone!</span>")
	user.say("Heh.. Nothing personnel, kid..", forced = "temporal katana suicide")
	sleep(20)
	if(!user)
		return
	user.visible_message("<span class='hierophant_warning'>[user] vanishes into a cloud of falling dust and burning embers, likely off to style on some poor sod in the distance!</span>")
	playsound(user,'sound/magic/blink.ogg', 75, TRUE)
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/melee/bokken // parrying stick
	name = "bokken"
	desc = "A space-Japanese training sword made of wood and shaped like a katana."
	icon_state = "bokken"
	item_state = "bokken"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 10 //how much harm mode damage we do
	var/stamina_damage_increment = 5 //how much extra damage do we do when in non-harm mode
	throwforce = 10
	damtype = STAMINA
	attack_verb = list("whacked", "smacked", "struck")
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON
	hitsound = 'sound/weapons/woodbonk.ogg'
	var/harm = FALSE // TRUE = brute, FALSE = stam
	var/reinforced = FALSE
	var/burnt = FALSE
	var/burned_in // text you burned in (with a welder)
	var/quick_parry = FALSE // false = default parry, true = really small parry window
	item_flags = ITEM_CAN_PARRY
	block_parry_data = /datum/block_parry_data/bokken
	var/default_parry_data = /datum/block_parry_data/bokken
	var/quick_parry_data = /datum/block_parry_data/bokken/quick_parry
	bare_wound_bonus = 0
	wound_bonus = 0

/datum/block_parry_data/bokken // fucked up parry data, emphasizing quicker, shorter parries
	parry_stamina_cost = 10 // be wise about when you parry, though, else you won't be able to fight enough to make it count
	parry_time_windup = 0
	parry_time_active = 10 // small parry window
	parry_time_spindown = 0
	// parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK		// bokken users can no longer strike while parrying
	parry_time_perfect = 1.5
	parry_time_perfect_leeway = 1
	parry_imperfect_falloff_percent = 7.5
	parry_efficiency_to_counterattack = 120
	parry_efficiency_considered_successful = 65		// VERY generous
	parry_efficiency_perfect = 120
	parry_efficiency_perfect_override = list(
		TEXT_ATTACK_TYPE_PROJECTILE = 30,
	)
	parry_failed_stagger_duration = 3 SECONDS
	parry_data = list(
		PARRY_COUNTERATTACK_MELEE_ATTACK_CHAIN = 2.5, // 10*2.5 = 25, 11*2.5 = 27.5, 12*2.5 = 30, 13*2.5 = 32.5
	)

/datum/block_parry_data/bokken/quick_parry // emphasizing REALLY SHORT PARRIES
	parry_stamina_cost = 8 // still more costly than most parries, but less than a full bokken parry
	parry_time_active = 5 // REALLY small parry window
	parry_time_perfect = 2.5 // however...
	parry_time_perfect_leeway = 2 // the entire time, the parry is perfect
	parry_failed_stagger_duration = 1 SECONDS
	parry_failed_clickcd_duration = 1 SECONDS // more forgiving punishments for missed parries
	// still, don't fucking miss your parries or you're down stamina and staggered to shit

/datum/block_parry_data/bokken/quick_parry/proj
	parry_efficiency_perfect_override = list()

/obj/item/melee/bokken/Initialize()
	. = ..()
	AddElement(/datum/element/sword_point)
	if(!harm) //if initialised in non-harm mode, setup force accordingly
		force = force + stamina_damage_increment

/obj/item/melee/bokken/attack_self(mob/user)
	harm = !harm
	if(harm)
		force -= stamina_damage_increment
		damtype = BRUTE
		attack_verb = list("bashed", "smashed", "attacked")
		bare_wound_bonus = 15 // having your leg smacked by a wooden stick is probably not great for it if it's naked
		wound_bonus = 0
	else
		force += stamina_damage_increment
		damtype = STAMINA
		attack_verb = list("whacked", "smacked", "struck")
		bare_wound_bonus = 0
		wound_bonus = 0
	to_chat(user, "<span class='notice'>[src] is now [harm ? "harmful" : "not quite as harmful"].</span>")

/obj/item/melee/bokken/AltClick(mob/user)
	. = ..()
	quick_parry = !quick_parry
	if(quick_parry)
		block_parry_data = quick_parry_data
	else
		block_parry_data = default_parry_data
	to_chat(user, "<span class='notice'>[src] is now [quick_parry ? "emphasizing shorter parries, forcing you to riposte or be staggered" : "emphasizing longer parries, with a shorter window to riposte but more forgiving parries"].</span>")

/obj/item/melee/bokken/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/pen))
		var/new_name = stripped_input(user, "What do you wish to name [src]?", "New Name", "bokken", 30)
		if(new_name)
			name = new_name
	if(I.tool_behaviour == TOOL_WELDER)
		var/new_burn = stripped_input(user, "What do you wish to burn into [src]?", "Burnt Inscription","", 140)
		if(new_burn)
			burned_in = new_burn
			if(!burnt)
				icon_state += "_burnt"
				item_state += "_burnt"
				burnt = TRUE
			update_icon()
			update_icon_state()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!reinforced)
			if(R.use(1))
				force++
				reinforced = TRUE
				to_chat(user, "<span class='notice'>You slide a metal rod into [src]\'s hilt. It feels a little heftier in your hands.")
		else
			to_chat(user, "<span class='notice'>[src] already has a weight slid into the hilt.")

/obj/item/melee/bokken/examine(mob/user)
	. = ..()
	if(quick_parry)
		. += " [src] is gripped in a way to emphasize quicker parries."
	if(reinforced)
		. += " There's a metal rod shoved into the base."
	if(burnt)
		. += " Burned into the \"blade\" is [burned_in]."

/obj/item/melee/bokken/steelwood
	name = "steelwood bokken"
	desc = "A misnomer of sorts, this is effectively a blunt katana made from steelwood, a dense organic wood derived from steelcaps. Why steelwood? Druids can use it. Duh."
	icon_state = "bokken_steel"
	item_state = "bokken_steel"
	force = 12
	stamina_damage_increment = 3

/obj/item/melee/bokken/waki
	name = "wakizashi bokken"
	desc = "A space-Japanese training sword made of wood and shaped like a wakizashi."
	icon_state = "wakibokken"
	item_state = "wakibokken"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	stamina_damage_increment = 4
	block_parry_data = /datum/block_parry_data/bokken/waki
	default_parry_data = /datum/block_parry_data/bokken/waki
	quick_parry_data = /datum/block_parry_data/bokken/waki/quick_parry

/datum/block_parry_data/bokken/waki // weaker parries than the bigger variant, but cheaper and faster recovery, like quick parry
	parry_stamina_cost = 4
	parry_time_windup = 0
	parry_time_active = 6
	parry_time_spindown = 0
	parry_time_perfect = 1.5
	parry_time_perfect_leeway = 1
	parry_imperfect_falloff_percent = 7.5
	parry_efficiency_to_counterattack = 120
	parry_efficiency_considered_successful = 65
	parry_efficiency_perfect = 120
	parry_efficiency_perfect_override = list(
		TEXT_ATTACK_TYPE_PROJECTILE = 30,
	)
	parry_failed_stagger_duration = 2 SECONDS
	parry_data = list(
		PARRY_COUNTERATTACK_MELEE_ATTACK_CHAIN = 1.5, // 6*1.5 = 9, 7*1.5 = 10.5, 8*1.5 = 12, 9*1.5 = 13.5
	)

/datum/block_parry_data/bokken/waki/quick_parry //For the parry spammer in you
	parry_stamina_cost = 2 // Slam that parry button
	parry_time_active = 2.5
	parry_time_perfect = 1
	parry_time_perfect_leeway = 1
	parry_failed_stagger_duration = 1 SECONDS
	parry_failed_clickcd_duration = 1 SECONDS

/datum/block_parry_data/bokken/waki/quick_parry/proj
	parry_efficiency_perfect_override = list()

/obj/item/melee/bokken/waki/steelwood
	name = "wakizashi steelwood bokken"
	desc = "A misnomer of sorts, this is effectively a blunt wakizashi made from steelwood, a dense organic wood derived from steelcaps. Why steelwood? Druids can use it. Duh."
	icon_state = "wakibokken_steel"
	item_state = "wakibokken_steel"
	force = 8
	stamina_damage_increment = 2

/obj/item/melee/bokken/debug
	name = "funny debug parrying stick"
	desc = "if you see this you've fucked up somewhere my good man"
	block_parry_data = /datum/block_parry_data/bokken/debug
	default_parry_data = /datum/block_parry_data/bokken/debug
	quick_parry_data = /datum/block_parry_data/bokken/quick_parry/debug

/datum/block_parry_data/bokken/debug
	parry_efficiency_perfect_override = list()
	parry_data = list(
		PARRY_COUNTERATTACK_MELEE_ATTACK_CHAIN = 2.5, // 10*2.5 = 25, 11*2.5 = 27.5, 12*2.5 = 30, 13*2.5 = 32.5
		PARRY_DISARM_ATTACKER = TRUE,
		PARRY_KNOCKDOWN_ATTACKER = 10,
		PARRY_STAGGER_ATTACKER = 10,
		PARRY_DAZE_ATTACKER = 10,
		)

/datum/block_parry_data/bokken/quick_parry/debug
	parry_efficiency_perfect_override = list()
	parry_data = list(
		PARRY_COUNTERATTACK_MELEE_ATTACK_CHAIN = 2.5, // 10*2.5 = 25, 11*2.5 = 27.5, 12*2.5 = 30, 13*2.5 = 32.5
		PARRY_DISARM_ATTACKER = TRUE,
		PARRY_KNOCKDOWN_ATTACKER = 10,
		PARRY_STAGGER_ATTACKER = 10,
		PARRY_DAZE_ATTACKER = 10,
		)

/// BOKKEN CRAFTNG PIECES

/obj/item/bokken_blade
	name = "training bokken wooden blade"
	desc = "The blade piece of a bokken katana."
	icon = 'icons/obj/smith.dmi'
	icon_state = "bokken"
	item_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/bokken_steelblade
	name = "training bokken steelwood blade"
	desc = "The blade piece of a steelwood bokken katana."
	icon = 'icons/obj/smith.dmi'
	icon_state = "bokken_steel"
	item_state = "switchblade_ext"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wakibokken_blade
	name = "training bokken wooden wakizashi blade"
	desc = "The blade piece of a bokken wakizashi."
	icon = 'icons/obj/smith.dmi'
	icon_state = "wakibokken"
	item_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wakibokken_steelblade
	name = "training bokken steelwood wakizashi blade"
	desc = "The blade piece of a steelwood bokken katana."
	icon = 'icons/obj/smith.dmi'
	icon_state = "wakibokken_steel"
	item_state = "switchblade_ext"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/bokken_hilt
	name = "training bokken hilt"
	desc = "The hilt piece of a bokken. This hilt is appropriate for any potential blade length or material."
	icon = 'icons/obj/smith.dmi'
	icon_state = "bokken_hilt"
	item_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'

/obj/item/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags_1 = CONDUCT_1
	force = 9
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=75)
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")
	wound_bonus = -10

/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shard))
		var/obj/item/spear/S = new /obj/item/spear

		remove_item_from_storage(user)
		if (!user.transferItemToLoc(I, S))
			return
		S.CheckParts(list(I))
		qdel(src)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")

	else if(istype(I, /obj/item/assembly/igniter) && !(HAS_TRAIT(I, TRAIT_NODROP)))
		var/obj/item/melee/baton/cattleprod/P = new /obj/item/melee/baton/cattleprod

		remove_item_from_storage(user)

		to_chat(user, "<span class='notice'>You fasten [I] to the top of the rod with the cable.</span>")

		qdel(I)
		qdel(src)

		user.put_in_hands(P)
	else
		return ..()


/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day, due to its ease of lodging itself into its victim's body parts."
	icon_state = "throwingstar"
	item_state = "throwingstar"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 2
	throwforce = 10 //10 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = 18 damage on hit due to guaranteed embedding
	throw_speed = 4
	embedding = list("pain_mult" = 4, "embed_chance" = 100, "fall_chance" = 0, "embed_chance_turf_mod" = 15)
	armour_penetration = 40

	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	custom_materials = list(/datum/material/iron=500, /datum/material/glass=500)
	resistance_flags = FIRE_PROOF

/obj/item/throwing_star/stamina
	name = "energy throwing star"
	desc = "An aerodynamic disc designed to cause excruciating pain when stuck inside fleeing targets, hopefully without causing fatal harm."
	icon_state = "energystar"
	item_state = "energystar"
	throwforce = 5
	embedding = list("pain_chance" = 5, "embed_chance" = 100, "fall_chance" = 0, "jostle_chance" = 10, "pain_stam_pct" = 0.8, "jostle_pain_mult" = 3)

/obj/item/throwing_star/toy
	name = "toy throwing star"
	desc = "An aerodynamic disc strapped with adhesive for sticking to people, good for playing pranks and getting yourself killed by security."
	sharpness = SHARP_NONE
	force = 0
	throwforce = 0
	embedding = list("pain_mult" = 0, "jostle_pain_mult" = 0, "embed_chance" = 100, "fall_chance" = 0)

/obj/item/switchblade
	name = "switchblade"
	icon_state = "switchblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharp, concealable, spring-loaded knife."
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	custom_materials = list(/datum/material/iron=12000)
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb = list("stubbed", "poked")
	resistance_flags = FIRE_PROOF
	var/extended = 0

/obj/item/switchblade/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)
	if(extended)
		force = 20
		w_class = WEIGHT_CLASS_NORMAL
		throwforce = 23
		icon_state = "switchblade_ext"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/bladeslice.ogg'
		sharpness = SHARP_EDGED
	else
		force = 3
		w_class = WEIGHT_CLASS_SMALL
		throwforce = 5
		icon_state = "switchblade"
		attack_verb = list("stubbed", "poked")
		hitsound = 'sound/weapons/genhit.ogg'
		sharpness = SHARP_NONE

/obj/item/switchblade/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] own throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "red_phone"
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/phone/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] begins to tie a noose with [src]'s cord! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]'s cord! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/staff
	name = "wizard staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 100
	attack_verb = list("bludgeoned", "whacked", "disciplined")
	resistance_flags = FLAMMABLE

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	resistance_flags = FLAMMABLE

/obj/item/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ectoplasm
	name = "ectoplasm"
	desc = "Spooky."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/ectoplasm/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is inhaling [src]! It looks like [user.p_theyre()] trying to visit the astral plane!</span>")
	return (OXYLOSS)

// /obj/item/ectoplasm/angelic
// 	icon = 'icons/obj/wizard.dmi'
// 	icon_state = "angelplasm"

/obj/item/mounted_chainsaw
	name = "mounted chainsaw"
	desc = "A chainsaw that has replaced your arm."
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 24
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	sharpness = SHARP_EDGED
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	total_mass = TOTAL_MASS_HAND_REPLACEMENT
	tool_behaviour = TOOL_SAW
	toolspeed = 1

/obj/item/mounted_chainsaw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mounted_chainsaw/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/statuebust
	name = "bust"
	desc = "A priceless ancient marble bust, the kind that belongs in a museum." //or you can hit people with it
	icon = 'icons/obj/statue.dmi'
	icon_state = "bust"
	force = 15
	throwforce = 10
	throw_speed = 5
	throw_range = 2
	attack_verb = list("busted")
	var/impressiveness = 45

/obj/item/statuebust/Initialize()
	. = ..()
	AddElement(/datum/element/art, impressiveness)
	// AddComponent(/datum/component/beauty, 1000)

// /obj/item/statuebust/hippocratic
// 	name = "hippocrates bust"
// 	desc = "A bust of the famous Greek physician Hippocrates of Kos, often referred to as the father of western medicine."
// 	icon_state = "hippocratic"
// 	impressiveness = 50

/obj/item/tailclub
	name = "tail club"
	desc = "For the beating to death of lizards with their own tails."
	icon_state = "tailclub"
	force = 14
	throwforce = 1 // why are you throwing a club do you even weapon
	throw_speed = 1
	throw_range = 1
	attack_verb = list("clubbed", "bludgeoned")

/obj/item/melee/chainofcommand/tailwhip
	name = "liz o' nine tails"
	desc = "A whip fashioned from the severed tails of lizards."
	icon_state = "tailwhip"
	item_flags = NONE

/obj/item/melee/chainofcommand/tailwhip/kitty
	name = "cat o' nine tails"
	desc = "A whip fashioned from the severed tails of cats."
	icon_state = "catwhip"

/obj/item/melee/skateboard
	name = "skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	icon_state = "skateboard"
	item_state = "skateboard"
	force = 12
	throwforce = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("smacked", "whacked", "slammed", "smashed")
	///The vehicle counterpart for the board
	var/board_item_type = /obj/vehicle/ridden/scooter/skateboard

/obj/item/melee/skateboard/attack_self(mob/user)
	if(!user.canUseTopic(src, TRUE, FALSE, TRUE))
		return
	var/obj/vehicle/ridden/scooter/skateboard/S = new board_item_type(get_turf(user))//this probably has fucky interactions with telekinesis but for the record it wasn't my fault
	S.buckle_mob(user)
	qdel(src)

/obj/item/melee/skateboard/improvised
	name = "improvised skateboard"
	desc = "A jury-rigged skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	// board_item_type = /obj/vehicle/ridden/scooter/skateboard/improvised

/obj/item/melee/skateboard/pro
	name = "skateboard"
	desc = "An EightO brand professional skateboard. It looks sturdy and well made."
	icon_state = "skateboard2"
	item_state = "skateboard2"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/pro
	custom_premium_price = PAYCHECK_HARD * 5

/obj/item/melee/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	icon_state = "hoverboard_red"
	item_state = "hoverboard_red"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard
	custom_premium_price = PAYCHECK_COMMAND * 5.4 //If I can't make it a meme I'll make it RAD

/obj/item/melee/skateboard/hoverboard/admin
	name = "Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	icon_state = "hoverboard_nt"
	item_state = "hoverboard_nt"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard/admin

/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "There ain't a skull in the league that can withstand a swatter."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 10
	wound_bonus = -10
	throwforce = 12
	attack_verb = list("beat", "smacked")
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 3.5)
	w_class = WEIGHT_CLASS_HUGE
	var/homerun_ready = 0
	var/homerun_able = 0
	total_mass = 2.7 //a regular wooden major league baseball bat weighs somewhere between 2 to 3.4 pounds, according to google
	var/on_sound
	var/on = TRUE // Are we on or off
	var/on_icon_state // What is our sprite when turned on
	var/off_icon_state // What is our sprite when turned off
	var/on_item_state // What is our in-hand sprite when turned on
	var/force_on // Damage when on
	var/force_off // Damage when off
	var/throwforce_on // Damage when on
	var/throwforce_off // Damage when off
	var/weight_class_on // What is the new size class when turned on

/obj/item/melee/baseball_bat/Initialize()
	. = ..()
	if(prob(1))
		name = "cricket bat"
		desc = "You've got red on you."
		icon_state = "baseball_bat_brit"
		item_state = "baseball_bat_brit"

/obj/item/melee/baseball_bat/chaplain
	name = "blessed baseball bat"
	desc = "There ain't a cult in the league that can withstand a swatter."
	force = 14
	throwforce = 14
	obj_flags = UNIQUE_RENAME
	var/chaplain_spawnable = TRUE
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON
	wound_bonus = -5

/obj/item/melee/baseball_bat/chaplain/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, null, FALSE)

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = 1

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		..()
		return
	if(homerun_ready)
		to_chat(user, "<span class='warning'>You're already ready to do a home run!</span>")
		..()
		return
	to_chat(user, "<span class='warning'>You begin gathering strength...</span>")
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, TRUE)
	if(do_after(user, 90, target = src))
		to_chat(user, "<span class='userdanger'>You gather power! Time for a home run!</span>")
		homerun_ready = 1
	..()

/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(homerun_ready)
		user.visible_message("<span class='userdanger'>It's a home run!</span>")
		target.throw_at(throw_target, rand(8,10), 14, user)
		target.ex_act(EXPLODE_HEAVY)
		playsound(get_turf(src), 'sound/weapons/homerun.ogg', 100, TRUE)
		homerun_ready = 0
		return
	else if(!target.anchored)
		var/whack_speed = (prob(60) ? 1 : 4)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)

/obj/item/melee/baseball_bat/ablative
	name = "metal baseball bat"
	desc = "This bat is made of highly reflective, highly armored material."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	force = 12
	throwforce = 15

/obj/item/melee/baseball_bat/ablative/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	//some day this will reflect thrown items instead of lasers
	if(is_energy_reflectable_projectile(object) && (attack_type == ATTACK_TYPE_PROJECTILE))
		var/turf = get_turf(src)
		playsound(turf, pick('sound/weapons/effects/batreflect1.ogg', 'sound/weapons/effects/batreflect2.ogg'), 50, 1)
		return BLOCK_SUCCESS | BLOCK_SHOULD_REDIRECT | BLOCK_PHYSICAL_EXTERNAL | BLOCK_REDIRECTED
	return ..()

/obj/item/melee/baseball_bat/ablative/syndi
	name = "syndicate major league bat"
	desc = "A metal bat made by the syndicate for the major league team."
	force = 18 //Spear damage...
	throwforce = 30

/obj/item/melee/baseball_bat/proc/get_on_description()
	. = list()
	.["local_on"] = "<span class ='warning'>You extend the bat.</span>"
	.["local_off"] = "<span class ='notice'>You collapse the bat.</span>"
	return .

/obj/item/melee/baseball_bat/telescopic
	name = "telescopic baseball bat"
	desc = "A stealthy telescopic bat that can fit in a pocket when collapsed."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baseball_bat_telescopic_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	item_state = null
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 5
	throwforce = 10
	on = FALSE
	on_sound = 'sound/weapons/batonextend.ogg'
	on_icon_state = "baseball_bat_telescopic_1"
	off_icon_state = "baseball_bat_telescopic_0"
	on_item_state = "baseball_bat_telescopic"
	force_on = 15
	force_off = 5
	throwforce_on = 20
	throwforce_off = 10
	weight_class_on = WEIGHT_CLASS_HUGE
	total_mass = TOTAL_MASS_NORMAL_ITEM

/obj/item/melee/baseball_bat/telescopic/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()
	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		item_state = on_item_state
		w_class = weight_class_on
		force = force_on
		throwforce = throwforce_on
		attack_verb = list("beat", "smacked")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		item_state = null //no sprite for concealment even when in hand
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		throwforce = throwforce_off
		attack_verb = list("drubbed", "beaned")
	playsound(src.loc, on_sound, 50, 1)
	add_fingerprint(user)

/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing pests of all sizes."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "flyswatter"
	item_state = "flyswatter"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize()
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/simple_animal/hostile/poison/bees/,
					/mob/living/simple_animal/butterfly,
					/mob/living/simple_animal/cockroach,
					/obj/item/queen_bee,
					/obj/structure/spider/spiderling
	))


/obj/item/melee/flyswatter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(is_type_in_typecache(target, strong_against))
			new /obj/effect/decal/cleanable/insectguts(target.drop_location())
			to_chat(user, "<span class='warning'>You easily splat the [target].</span>")
			if(istype(target, /mob/living/))
				var/mob/living/bug = target
				bug.death(1)
			else
				qdel(target)

/obj/item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT // | HAND_ITEM
	attack_verb = list("bopped")

/obj/item/circlegame/Initialize()
	. = ..()
	var/mob/living/owner = loc
	if(!istype(owner))
		return
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/ownerExamined)

/obj/item/circlegame/Destroy()
	var/mob/owner = loc
	if(istype(owner))
		UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
	return ..()

/obj/item/circlegame/dropped(mob/user)
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE)		//loc will have changed by the time this is called, so Destroy() can't catch it
	// this is a dropdel item.
	return ..()

/// Stage 1: The mistake is made
/obj/item/circlegame/proc/ownerExamined(mob/living/owner, mob/living/sucker)
	SIGNAL_HANDLER

	if(!istype(sucker) || !in_range(owner, sucker))
		return
	addtimer(CALLBACK(src, .proc/waitASecond, owner, sucker), 4)

/// Stage 2: Fear sets in
/obj/item/circlegame/proc/waitASecond(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker) || QDELETED(src) || QDELETED(owner))
		return

	if(owner == sucker) // big mood
		to_chat(owner, "<span class='danger'>Wait a second... you just looked at your own [src.name]!</span>")
		addtimer(CALLBACK(src, .proc/selfGottem, owner), 10)
	else
		to_chat(sucker, "<span class='danger'>Wait a second... was that a-</span>")
		addtimer(CALLBACK(src, .proc/GOTTEM, owner, sucker), 6)

/// Stage 3A: We face our own failures
/obj/item/circlegame/proc/selfGottem(mob/living/owner)
	if(QDELETED(src) || QDELETED(owner))
		return

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.visible_message("<span class='danger'>[owner] shamefully bops [owner.p_them()]self with [owner.p_their()] [src.name].</span>", "<span class='userdanger'>You shamefully bop yourself with your [src.name].</span>", \
		"<span class='hear'>You hear a dull thud!</span>")
	log_combat(owner, owner, "bopped", src.name, "(self)")
	owner.do_attack_animation(owner)
	owner.apply_damage(100, STAMINA)
	owner.Knockdown(10)
	qdel(src)

/// Stage 3B: We face our reckoning (unless we moved away or they're incapacitated)
/obj/item/circlegame/proc/GOTTEM(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker))
		return

	if(QDELETED(src) || QDELETED(owner))
		to_chat(sucker, "<span class='warning'>Nevermind... must've been your imagination...</span>")
		return

	if(!in_range(owner, sucker) || !(owner.mobility_flags & MOBILITY_USE))
		to_chat(sucker, "<span class='notice'>Phew... you moved away before [owner] noticed you saw [owner.p_their()] [src.name]...</span>")
		return

	to_chat(owner, "<span class='warning'>[sucker] looks down at your [src.name] before trying to avert [sucker.p_their()] eyes, but it's too late!</span>")
	to_chat(sucker, "<span class='danger'><b>[owner] sees the fear in your eyes as you try to look away from [owner.p_their()] [src.name]!</b></span>")

	owner.face_atom(sucker)
	if(owner.client)
		owner.client.give_award(/datum/award/achievement/misc/gottem, owner) // then everybody clapped

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.do_attack_animation(sucker)

	if(HAS_TRAIT(owner, TRAIT_HULK))
		owner.visible_message("<span class='danger'>[owner] bops [sucker] with [owner.p_their()] [src.name] much harder than intended, sending [sucker.p_them()] flying!</span>", \
			"<span class='danger'>You bop [sucker] with your [src.name] much harder than intended, sending [sucker.p_them()] flying!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=list(sucker))
		to_chat(sucker, "<span class='userdanger'>[owner] bops you incredibly hard with [owner.p_their()] [src.name], sending you flying!</span>")
		sucker.apply_damage(50, STAMINA)
		sucker.Knockdown(50)
		log_combat(owner, sucker, "bopped", src.name, "(setup- Hulk)")
		var/atom/throw_target = get_edge_target_turf(sucker, owner.dir)
		sucker.throw_at(throw_target, 6, 3, owner)
	else
		owner.visible_message("<span class='danger'>[owner] bops [sucker] with [owner.p_their()] [src.name]!</span>", "<span class='danger'>You bop [sucker] with your [src.name]!</span>", \
			"<span class='hear'>You hear a dull thud!</span>", ignored_mobs=list(sucker))
		sucker.apply_damage(15, STAMINA)
		log_combat(owner, sucker, "bopped", src.name, "(setup)")
		to_chat(sucker, "<span class='userdanger'>[owner] bops you with [owner.p_their()] [src.name]!</span>")
	qdel(src)

/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT // | HAND_ITEM
	attack_verb = list("slapped")
	hitsound = 'sound/effects/snap.ogg'

/obj/item/slapper/attack(mob/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)
	playsound(M, 'sound/weapons/slap.ogg', 50, TRUE, -1)
	user.visible_message("<span class='danger'>[user] slaps [M]!</span>",
	"<span class='notice'>You slap [M]!</span>",\
	"<span class='hear'>You hear a slap.</span>")
	return
/obj/item/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return FALSE
	return TRUE

/obj/item/extendohand
	name = "extendo-hand"
	desc = "Futuristic tech has allowed these classic spring-boxing toys to essentially act as a fully functional hand-operated hand prosthetic."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "extendohand"
	item_state = "extendohand"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 0
	throwforce = 5
	reach = 2
	var/min_reach = 2

/obj/item/extendohand/acme
	name = "\improper ACME Extendo-Hand"
	desc = "A novelty extendo-hand produced by the ACME corporation. Originally designed to knock out roadrunners."

/obj/item/extendohand/attack(atom/M, mob/living/carbon/human/user)
	var/dist = get_dist(M, user)
	if(dist < min_reach)
		to_chat(user, "<span class='warning'>[M] is too close to use [src] on.</span>")
		return
	M.attack_hand(user)

// /obj/item/gohei
// 	name = "gohei"
// 	desc = "A wooden stick with white streamers at the end. Originally used by shrine maidens to purify things. Now used by the station's valued weeaboos."
// 	force = 5
// 	throwforce = 5
// 	hitsound = "swing_hit"
// 	attack_verb_continuous = list("whacks", "thwacks", "wallops", "socks")
// 	attack_verb_simple = list("whack", "thwack", "wallop", "sock")
// 	icon = 'icons/obj/items_and_weapons.dmi'
// 	icon_state = "gohei"
// 	inhand_icon_state = "gohei"
// 	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
// 	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'

//HF blade
/obj/item/vibro_weapon
	icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "vibro sword"
	desc = "A potent weapon capable of cutting through nearly anything. Wielding it in two hands will allow you to deflect gunfire."
	armour_penetration = 100
	block_chance = 40
	force = 20
	throwforce = 20
	throw_speed = 4
	sharpness = SHARP_EDGED
	attack_verb = list("cut", "sliced", "diced")
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/wielded = FALSE // track wielded status on item

/obj/item/vibro_weapon/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/vibro_weapon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 20, 105)
	AddComponent(/datum/component/two_handed, force_multiplier=2, icon_wielded="hfrequency1")
	AddElement(/datum/element/sword_point)

/// triggered on wield of two handed item
/obj/item/vibro_weapon/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/vibro_weapon/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = FALSE

/obj/item/vibro_weapon/update_icon_state()
	icon_state = "hfrequency0"

/obj/item/vibro_weapon/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(wielded)
		final_block_chance *= 2
	if(wielded || !(attack_type & ATTACK_TYPE_PROJECTILE))
		if(prob(final_block_chance))
			if(attack_type & ATTACK_TYPE_PROJECTILE)
				owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
				playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
				block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_DEFLECT
				return BLOCK_SUCCESS | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT | BLOCK_PHYSICAL_EXTERNAL
			else
				owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
				return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL
	return NONE
