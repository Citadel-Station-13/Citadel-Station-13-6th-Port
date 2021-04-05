/obj/item/melee/transforming/energy
	hitsound_on = 'sound/weapons/blade1.ogg'
	heat = 3500
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 3
	var/sword_color
	total_mass = 0.4 //Survival flashlights typically weigh around 5 ounces.

/obj/item/melee/transforming/energy/Initialize()
	. = ..()
	total_mass_on = (total_mass_on ? total_mass_on : (w_class_on * 0.75))
	if(active)
		if(sword_color)
			icon_state = "sword[sword_color]"
		set_light(brightness_on)
		START_PROCESSING(SSobj, src)

/obj/item/melee/transforming/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/transforming/energy/suicide_act(mob/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message("<span class='suicide'>[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/transforming/energy/get_sharpness()
	return active * sharpness

/obj/item/melee/transforming/energy/process()
	open_flame()

/obj/item/melee/transforming/energy/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(.)
		if(active)
			if(sword_color)
				icon_state = "sword[sword_color]"
			START_PROCESSING(SSobj, src)
			set_light(brightness_on)
		else
			STOP_PROCESSING(SSobj, src)
			set_light(0)

/obj/item/melee/transforming/energy/get_temperature()
	return active * heat

/obj/item/melee/transforming/energy/ignition_effect(atom/A, mob/user)
	if(!active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [C.p_their()] nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)

/obj/item/melee/transforming/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon_state = "axe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	w_class_on = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1
	armour_penetration = 100
	attack_verb_off = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	light_color = "#40ceff"
	total_mass = null

/obj/item/melee/transforming/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 3
	throwforce = 5
	hitsound = "swing_hit" //it starts deactivated
	attack_verb_off = list("tapped", "poked")
	throw_speed = 3
	throw_range = 5
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 75, "impact_pain_mult" = 10)
	armour_penetration = 35
	item_flags = NEEDS_PERMIT | ITEM_CAN_PARRY
	block_parry_data = /datum/block_parry_data/energy_sword
	var/list/possible_colors = list("red" = LIGHT_COLOR_RED, "blue" = LIGHT_COLOR_LIGHT_CYAN, "green" = LIGHT_COLOR_GREEN, "purple" = LIGHT_COLOR_LAVENDER)

/datum/block_parry_data/energy_sword
	parry_time_windup = 0
	parry_time_active = 25
	parry_time_spindown = 0
	// we want to signal to players the most dangerous phase, the time when automatic counterattack is a thing.
	parry_time_windup_visual_override = 1
	parry_time_active_visual_override = 3
	parry_time_spindown_visual_override = 12
	parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK		// esword users can attack while
	parry_time_perfect = 2.5		// first ds isn't perfect
	parry_time_perfect_leeway = 1.5
	parry_imperfect_falloff_percent = 5
	parry_efficiency_to_counterattack = 100
	parry_efficiency_considered_successful = 65		// VERY generous
	parry_efficiency_perfect = 100
	parry_failed_stagger_duration = 4 SECONDS
	parry_cooldown = 0.5 SECONDS

/obj/item/melee/transforming/energy/sword/Initialize(mapload)
	. = ..()
	set_sword_color()

/obj/item/melee/transforming/energy/sword/proc/set_sword_color()
	if(LAZYLEN(possible_colors))
		light_color = possible_colors[pick(possible_colors)]

/obj/item/melee/transforming/energy/sword/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(active)
		AddElement(/datum/element/sword_point)
	else
		RemoveElement(/datum/element/sword_point)

/obj/item/melee/transforming/energy/sword/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(!active)
		return NONE
	return ..()

/obj/item/melee/transforming/energy/sword/on_active_parry(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/block_return, parry_efficiency, parry_time)
	. = ..()
	if(parry_efficiency >= 80)		// perfect parry
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_RETURN_TO_SENDER
		. |= BLOCK_SHOULD_REDIRECT

/obj/item/melee/transforming/energy/sword/cyborg
	sword_color = "red"
	light_color = "#ff0000"
	possible_colors = null
	var/hitcost = 50

/obj/item/melee/transforming/energy/sword/cyborg/attack(mob/M, var/mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		return ..()

/obj/item/melee/transforming/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	sword_color = null //stops icon from breaking when turned on.
	hitcost = 75 //Costs more than a standard cyborg esword
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	light_color = "#40ceff"
	tool_behaviour = TOOL_SAW
	toolspeed = 0.7

/obj/item/melee/transforming/energy/sword/cyborg/saw/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	return NONE

#define ESWORD_SWORD 0
#define ESWORD_SABER 1
#define ESWORD_KATANA 2

/obj/item/melee/transforming/energy/sword/saber
	possible_colors = list("red" = LIGHT_COLOR_RED, "blue" = LIGHT_COLOR_LIGHT_CYAN, "green" = LIGHT_COLOR_GREEN, "purple" = LIGHT_COLOR_LAVENDER)
	unique_reskin = list("Sword" = "sword1", "Saber" = "esaber1", "Katana" = "samurai1")
	var/hacked = FALSE
	var/bladetype = ESWORD_SWORD

/obj/item/melee/transforming/energy/sword/saber/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(.)
		if(active)
			if(sword_color)
				switch(bladetype)
					if(ESWORD_SWORD)
						icon_state = "sword[sword_color]"
					if(ESWORD_SABER)
						icon_state = "esaber[sword_color]"
					if(ESWORD_KATANA)
						icon_state = "samurai[sword_color]"
		else
			switch(bladetype)
				if(ESWORD_SWORD)
					icon_state = "sword0"
				if(ESWORD_SABER)
					icon_state = "esaber0"
				if(ESWORD_KATANA)
					icon_state = "samurai0"

/obj/item/melee/transforming/energy/sword/saber/reskin_obj(mob/M)
	. = ..()
	if(!active)
		if(icon_state == "sword1")
			icon_state = "sword0"
			bladetype = ESWORD_SWORD
		if(icon_state == "esaber1")
			icon_state = "esaber0"
			bladetype = ESWORD_SABER
		if(icon_state == "samurai1")
			icon_state = "samurai0"
			bladetype = ESWORD_KATANA
	if(active)
		switch(bladetype)
			if(ESWORD_SWORD)
				icon_state = "sword[sword_color]"
			if(ESWORD_SABER)
				icon_state = "esaber[sword_color]"
			if(ESWORD_KATANA)
				icon_state = "samurai[sword_color]"

/obj/item/melee/transforming/energy/sword/saber/set_sword_color(var/color_forced)
	if(color_forced) // wow i really do not like this at fucking all holy SHIT
		if(color_forced == "red")
			sword_color = "red"
			light_color = LIGHT_COLOR_RED
		else if(color_forced == "blue")
			sword_color = "blue"
			light_color = LIGHT_COLOR_LIGHT_CYAN
		else if(color_forced == "green")
			sword_color = "green"
			light_color = LIGHT_COLOR_GREEN
		else if(color_forced == "purple")
			sword_color = "purple"
			light_color = LIGHT_COLOR_LAVENDER
	else if(LAZYLEN(possible_colors))
		sword_color = pick(possible_colors)
		light_color = possible_colors[sword_color]
	return

/obj/item/melee/transforming/energy/sword/saber/process()
	. = ..()
	if(hacked)
		var/set_color = pick(possible_colors)
		light_color = possible_colors[set_color]
		update_light()

/obj/item/melee/transforming/energy/sword/saber/red/Initialize(mapload)
	. = ..()
	set_sword_color("red")

/obj/item/melee/transforming/energy/sword/saber/blue/Initialize(mapload)
	. = ..()
	set_sword_color("blue")

/obj/item/melee/transforming/energy/sword/saber/green/Initialize(mapload)
	. = ..()
	set_sword_color("green")

/obj/item/melee/transforming/energy/sword/saber/purple/Initialize(mapload)
	. = ..()
	set_sword_color("purple")

/obj/item/melee/transforming/energy/sword/saber/proc/select_sword_color(mob/user) /// this is for the radial
	if(!istype(user) || user.incapacitated())
		return

	var/static/list/options = list(
			"red" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "swordred-blade"),
			"blue" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "swordblue-blade"),
			"green" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "swordgreen-blade"),
			"purple" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "swordpurple-blade")
			)

	var/choice = show_radial_menu(user, src, options, custom_check = FALSE, radius = 36, require_near = TRUE)

	if(src && choice && !user.incapacitated() && in_range(user,src))
		set_sword_color(choice)
		to_chat(user, "<span class='notice'>[src] is now [choice].</span>")

/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(user.a_intent == INTENT_DISARM)
			if(!active)
				to_chat(user, "<span class='warning'>COLOR_SET</span>")
				hacked = FALSE
				select_sword_color(user)
				return
			else
				to_chat(user, "<span class='notice'>Turn it off first - getting that close to an active sword is not a great idea.</span>")
				return
		if(!hacked)
			hacked = TRUE
			sword_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")
			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span> <span class='notice'>If you wanted to reset the color, though, try a <b>disarming</b> intent while it's off.</span>")
	else
		return ..()

#undef ESWORD_SWORD
#undef ESWORD_SABER
#undef ESWORD_KATANA

/obj/item/melee/transforming/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state_on = "cutlass1"
	light_color = "#ff0000"
	possible_colors = null

/obj/item/melee/transforming/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30 //Normal attacks deal esword damage
	hitsound = 'sound/weapons/blade1.ogg'
	active = 1
	throwforce = 1 //Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY//So you can't hide it in your pocket or some such.
	var/datum/effect_system/spark_spread/spark_system
	sharpness = SHARP_EDGED

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/transforming/energy/blade/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/transforming/energy/blade/transform_weapon(mob/living/user, supress_message_text)
	return

/obj/item/melee/transforming/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	item_state = "lightblade"

/*/////////////////////////////////////////////////////////////////////////
/////////////		The TRUE Energy Sword		///////////////////////////
*//////////////////////////////////////////////////////////////////////////

/obj/item/melee/transforming/energy/sword/cx
	name = "non-eutactic blade"
	desc = "The Non-Eutactic Blade utilizes a hardlight blade that is dynamically 'forged' on demand to create a deadly sharp edge that is unbreakable."
	icon_state = "cxsword_hilt"
	item_state = "cxsword"
	force = 3
	force_on = 21
	throwforce = 5
	throwforce_on = 20
	hitsound = "swing_hit" //it starts deactivated
	hitsound_on = 'sound/weapons/nebhit.ogg'
	attack_verb_off = list("tapped", "poked")
	throw_speed = 3
	throw_range = 5
	sharpness = SHARP_EDGED
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 20, "embedded_fall_chance" = 60)
	armour_penetration = 10
	block_chance = 35
	light_color = "#37FFF7"
	actions_types = list()

/obj/item/melee/transforming/energy/sword/cx/Initialize()
	icon_state_on = icon_state
	return ..()

/obj/item/melee/transforming/energy/sword/cx/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/melee/transforming/energy/sword/cx/alt_pre_attack(atom/A, mob/living/user, params)	//checks if it can do right click memes
	altafterattack(A, user, TRUE, params)
	return TRUE

/obj/item/melee/transforming/energy/sword/cx/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	update_icon()

/obj/item/melee/transforming/energy/sword/cx/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? 'sound/weapons/nebon.ogg' : 'sound/weapons/neboff.ogg', 65, 1)
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")


/obj/item/melee/transforming/energy/sword/cx/update_overlays()
	. = ..()
	var/mutable_appearance/blade_overlay = mutable_appearance(icon, "cxsword_blade")
	var/mutable_appearance/gem_overlay = mutable_appearance(icon, "cxsword_gem")

	if(light_color)
		blade_overlay.color = light_color
		gem_overlay.color = light_color

	. += gem_overlay

	if(active)
		. += blade_overlay

/obj/item/melee/transforming/energy/sword/cx/AltClick(mob/living/user)
	. = ..()
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return TRUE

	if(alert("Are you sure you want to recolor your blade?", "Confirm Repaint", "Yes", "No") == "Yes")
		var/energy_color_input = input(usr,"","Choose Energy Color",light_color) as color|null
		if(energy_color_input)
			light_color = sanitize_hexcolor(energy_color_input, desired_format=6, include_crunch=1)
		update_icon()
		update_light()
	return TRUE

/obj/item/melee/transforming/energy/sword/cx/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to recolor it.</span>"

/obj/item/melee/transforming/energy/sword/cx/worn_overlays(isinhands, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(active)
		if(isinhands)
			var/mutable_appearance/blade_inhand = mutable_appearance(icon_file, "cxsword_blade")
			blade_inhand.color = light_color
			. += blade_inhand

//Broken version. Not a toy, but not as strong.
/obj/item/melee/transforming/energy/sword/cx/broken
	name = "misaligned non-eutactic blade"
	desc = "The Non-Eutactic Blade utilizes a hardlight blade that is dynamically 'forged' on demand to create a deadly sharp edge that is unbreakable. This one seems to have a damaged handle and misaligned components, causing the blade to be unstable at best"
	force_on = 15 //As strong a survival knife/bone dagger

/obj/item/melee/transforming/energy/sword/cx/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/melee/transforming/energy/sword/cx/traitor))
		return
	else if(istype(W, /obj/item/melee/transforming/energy/sword/cx))
		if(HAS_TRAIT(W, TRAIT_NODROP) || HAS_TRAIT(src, TRAIT_NODROP))
			to_chat(user, "<span class='warning'>\the [HAS_TRAIT(src, TRAIT_NODROP) ? src : W] is stuck to your hand, you can't attach it to \the [HAS_TRAIT(src, TRAIT_NODROP) ? W : src]!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You combine the two light swords, making a single supermassive blade! You're cool.</span>")
			new /obj/item/dualsaber/hypereutactic(user.drop_location())
			qdel(W)
			qdel(src)
	else
		return ..()

////////		Tatortot NEB		/////////////// (same stats as regular esword)
/obj/item/melee/transforming/energy/sword/cx/traitor
	name = "\improper Dragon's Tooth Sword"
	desc = "The Dragon's Tooth sword is a blackmarket modification of a Non-Eutactic Blade, \
			which utilizes a hardlight blade that is dynamically 'forged' on demand to create a deadly sharp edge that is unbreakable. \
			It appears to have a wooden grip and a shaved down guard."
	icon_state = "cxsword_hilt_traitor"
	force_on = 30
	armour_penetration = 35
	embedding = list("embedded_pain_multiplier" = 10, "embed_chance" = 75, "embedded_fall_chance" = 0, "embedded_impact_pain_multiplier" = 10)
	block_chance = 50
	hitsound_on = 'sound/weapons/blade1.ogg'
	light_color = "#37F0FF"

/obj/item/melee/transforming/energy/sword/cx/traitor/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, 1)
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")
