/obj/item/melee
	item_flags = NEEDS_PERMIT

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target.check_block())
		target.visible_message("<span class='danger'>[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!</span>",
					"<span class='userdanger'>You block the attack!</span>")
		user.Stun(40)
		return TRUE


/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 14
	throwforce = 10
	reach = 2
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/chainhit.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/melee/chainofcommand/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems made of synthetic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "impaled", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = IS_SHARP
	total_mass = TOTAL_MASS_HAND_REPLACEMENT

/obj/item/melee/synthetic_arm_blade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 80) //very imprecise

/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 18
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = IS_SHARP
	attack_verb = list("slashed", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)
	total_mass = 3.4

/obj/item/melee/sabre/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5) //fast and effective, but as a sword, it might damage the results.

/obj/item/melee/sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/sabre/on_exit_storage(obj/item/storage/S)
	..()
	var/obj/item/storage/belt/sabre/B = S
	if(istype(B))
		playsound(B, 'sound/items/unsheath.ogg', 25, 1)

/obj/item/melee/sabre/on_enter_storage(obj/item/storage/S)
	..()
	var/obj/item/storage/belt/sabre/B = S
	if(istype(B))
		playsound(B, 'sound/items/sheath.ogg', 25, 1)

/obj/item/melee/sabre/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "sabre")

/obj/item/melee/sabre/get_worn_belt_overlay(icon_file)
	return mutable_appearance(icon_file, "-sabre")

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/i = 0
	ADD_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)
	if(iscarbon(user))
		var/mob/living/carbon/Cuser = user
		var/obj/item/bodypart/holding_bodypart = Cuser.get_holding_bodypart_of_item(src)
		var/list/limbs_to_dismember
		var/list/arms = list()
		var/list/legs = list()
		var/obj/item/bodypart/bodypart

		for(bodypart in Cuser.bodyparts)
			if(bodypart == holding_bodypart)
				continue
			if(bodypart.body_part & ARMS)
				arms += bodypart
			else if (bodypart.body_part & LEGS)
				legs += bodypart

		limbs_to_dismember = arms + legs
		if(holding_bodypart)
			limbs_to_dismember += holding_bodypart

		var/speedbase = abs((4 SECONDS) / limbs_to_dismember.len)
		for(bodypart in limbs_to_dismember)
			i++
			addtimer(CALLBACK(src, .proc/suicide_dismember, user, bodypart), speedbase * i)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), (5 SECONDS) * i)
	return MANUAL_SUICIDE

/obj/item/melee/sabre/proc/suicide_dismember(mob/living/user, obj/item/bodypart/affecting)
	if(!QDELETED(affecting) && affecting.dismemberable && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, 1)
		affecting.dismember(BRUTE)
		user.adjustBruteLoss(20)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjustBruteLoss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)

/obj/item/melee/rapier
	name = "plastitanium rapier"
	desc = "A impossibly thin blade made of plastitanium with a tip made of diamond. It looks to be able to cut through any armor."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rapier"
	item_state = "rapier"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 25
	throwforce = 35
	block_chance = 0
	armour_penetration = 100
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	w_class = WEIGHT_CLASS_BULKY
	sharpness = IS_SHARP_ACCURATE //It cant be sharpend cook -_-
	attack_verb = list("slashed", "cut", "pierces", "pokes")
	total_mass = 3.4

/obj/item/melee/rapier/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 20, 65, 0)

/obj/item/melee/rapier/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "rapier")

/obj/item/melee/rapier/get_worn_belt_overlay(icon_file)
	return mutable_appearance(icon_file, "-rapier")

/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	var/cooldown = 13
	var/on = TRUE
	var/last_hit = 0
	var/stun_stam_cost_coeff = 1.25
	var/hardstun_ds = 1
	var/softstun_ds = 0
	var/stam_dmg = 30

/obj/item/melee/classic_baton/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	if(user.getStaminaLoss() >= STAMINA_SOFTCRIT)//CIT CHANGE - makes batons unusuable in stamina softcrit
		to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")//CIT CHANGE - ditto
		return //CIT CHANGE - ditto

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You club yourself over the head.</span>")
		user.Knockdown(60 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		..()
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..() || !iscyborg(target))
			return
	else
		if(last_hit < world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return
			playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
			target.Knockdown(softstun_ds, TRUE, FALSE, hardstun_ds, stam_dmg)
			log_combat(user, target, "stunned", src)
			src.add_fingerprint(user)
			target.visible_message("<span class ='danger'>[user] has knocked down [target] with [src]!</span>", \
				"<span class ='userdanger'>[user] has knocked down [target] with [src]!</span>")
			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			last_hit = world.time + cooldown
			user.adjustStaminaLossBuffered(getweight())//CIT CHANGE - makes swinging batons cost stamina

/obj/item/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 0
	on = FALSE
	total_mass = TOTAL_MASS_NORMAL_ITEM

/obj/item/melee/classic_baton/telescopic/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)

	user.visible_message("<span class='suicide'>[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind.</span>")
	if(!on)
		src.attack_self(user)
	else
		playsound(loc, 'sound/weapons/batonextend.ogg', 50, 1)
		add_fingerprint(user)
	sleep(3)
	if (H && !QDELETED(H))
		if (B && !QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(get_turf(H), H.dna)
		return (BRUTELOSS)

/obj/item/melee/classic_baton/telescopic/attack_self(mob/user)
	on = !on
	if(on)
		to_chat(user, "<span class ='warning'>You extend the baton.</span>")
		icon_state = "telebaton_1"
		item_state = "nullrod"
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		to_chat(user, "<span class ='notice'>You collapse the baton.</span>")
		icon_state = "telebaton_0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "supermatter_sword"
	item_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1
	force_string = "INFINITE"

/obj/item/melee/supermatter_sword/Initialize()
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message("<span class='warning'>[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all.</span>")

/obj/item/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		forceMove(target.loc)
		consume_everything(target)
	else
		var/turf/T = get_turf(src)
		if(!isspaceturf(T))
			shard.consume_turf(T)

/obj/item/melee/supermatter_sword/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(user && target == user)
		user.dropItemToGround(src)
	if(proximity_flag)
		consume_everything(target)

/obj/item/melee/supermatter_sword/throw_impact(target)
	..()
	if(ismob(target))
		var/mob/M
		if(src.loc == M)
			M.dropItemToGround(src)
	consume_everything(target)

/obj/item/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0

/obj/item/melee/supermatter_sword/ex_act(severity, target)
	visible_message("<span class='danger'>The blast wave smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/melee/supermatter_sword/acid_act()
	visible_message("<span class='danger'>The acid smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/melee/supermatter_sword/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>[P] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/melee/supermatter_sword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!</span>")
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Consume()
	else if(!isturf(target))
		shard.Bumped(target)
	else
		shard.consume_turf(target)

/obj/item/melee/supermatter_sword/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon_state = "whip"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/melee/curator_whip/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(ishuman(target) && proximity_flag)
		var/mob/living/carbon/human/H = target
		H.drop_all_held_items()
		H.visible_message("<span class='danger'>[user] disarms [H]!</span>", "<span class='userdanger'>[user] disarmed you!</span>")

/obj/item/melee/roastingstick
	name = "advanced roasting stick"
	desc = "A telescopic roasting stick with a miniature shield generator designed to ensure entry into various high-tech shielded cooking ovens and firepits."
	icon_state = "roastingstick_0"
	item_state = "null"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 0
	attack_verb = list("hit", "poked")
	var/obj/item/reagent_containers/food/snacks/sausage/held_sausage
	var/static/list/ovens
	var/on = FALSE
	var/datum/beam/beam
	total_mass = 2.5

/obj/item/melee/roastingstick/Initialize()
	. = ..()
	if (!ovens)
		ovens = typecacheof(list(/obj/singularity, /obj/machinery/power/supermatter_crystal, /obj/structure/bonfire, /obj/structure/destructible/clockwork/massive/ratvar))

/obj/item/melee/roastingstick/attack_self(mob/user)
	on = !on
	if(on)
		extend(user)
	else
		if (held_sausage)
			to_chat(user, "<span class='warning'>You can't retract [src] while [held_sausage] is attached!</span>")
			return
		retract(user)

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/obj/item/melee/roastingstick/attackby(atom/target, mob/user)
	..()
	if (istype(target, /obj/item/reagent_containers/food/snacks/sausage))
		if (!on)
			to_chat(user, "<span class='warning'>You must extend [src] to attach anything to it!</span>")
			return
		if (held_sausage)
			to_chat(user, "<span class='warning'>[held_sausage] is already attached to [src]!</span>")
			return
		if (user.transferItemToLoc(target, src))
			held_sausage = target
		else
			to_chat(user, "<span class='warning'>[target] doesn't seem to want to get on [src]!</span>")
	update_icon()

/obj/item/melee/roastingstick/attack_hand(mob/user)
	..()
	if (held_sausage)
		user.put_in_hands(held_sausage)
		held_sausage = null
	update_icon()

/obj/item/melee/roastingstick/update_icon()
	. = ..()
	cut_overlays()
	if (held_sausage)
		var/mutable_appearance/sausage = mutable_appearance(icon, "roastingstick_sausage")
		add_overlay(sausage)

/obj/item/melee/roastingstick/proc/extend(user)
	to_chat(user, "<span class ='warning'>You extend [src].</span>")
	icon_state = "roastingstick_1"
	item_state = "nullrod"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/melee/roastingstick/proc/retract(user)
	to_chat(user, "<span class ='notice'>You collapse [src].</span>")
	icon_state = "roastingstick_0"
	item_state = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/roastingstick/handle_atom_del(atom/target)
	if (target == held_sausage)
		held_sausage = null
		update_icon()

/obj/item/melee/roastingstick/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!on)
		return
	if (is_type_in_typecache(target, ovens))
		if (held_sausage && held_sausage.roasted)
			to_chat("Your [held_sausage] has already been cooked.")
			return
		if (istype(target, /obj/singularity) && get_dist(user, target) < 10)
			to_chat(user, "You send [held_sausage] towards [target].")
			playsound(src, 'sound/items/rped.ogg', 50, 1)
			beam = user.Beam(target,icon_state="rped_upgrade",time=100)
		else if (user.Adjacent(target))
			to_chat(user, "You extend [src] towards [target].")
			playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
		else
			return
		if(do_after(user, 100, target = user))
			finish_roasting(user, target)
		else
			QDEL_NULL(beam)
			playsound(src, 'sound/weapons/batonextend.ogg', 50, 1)

/obj/item/melee/roastingstick/proc/finish_roasting(user, atom/target)
	to_chat(user, "You finish roasting [held_sausage]")
	playsound(src,'sound/items/welder2.ogg',50,1)
	held_sausage.add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
	held_sausage.name = "[target.name]-roasted [held_sausage.name]"
	held_sausage.desc = "[held_sausage.desc] It has been cooked to perfection on \a [target]."
	update_icon()

/obj/item/twohanded/required/electrostaff
	icon = 'icons/obj/estaff.dmi'
	icon_state = "electrostaff_3"
	item_state = "electrostaff_3"
	lefthand_file = 'icons/mob/inhands/weapons/estaff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/estaff_righthand.dmi'
	name = "riot suppression electrostaff"
	desc = "A large quarterstaff, with massive silver electrodes mounted at the end."
	force = 1
	damtype = BURN
	w_class = WEIGHT_CLASS_GIGANTIC
	slot_flags = ITEM_SLOT_BACK
	sharpness = FALSE
	force_unwielded = 1
	force_wielded = 1
	throwforce = 1
	throw_speed = 1
	light_range = 7
	light_power = 1
	block_chance = 30
	light_color = LIGHT_COLOR_YELLOW
	materials = list(MAT_METAL=1000)
	hitsound = 'sound/weapons/staff.ogg'
	attack_verb = list("suppresed", "struck", "beaten", "thwacked", "pulped", "shocked")
	total_mass = 5
	var/power = "suppresive"
	var/lethal = FALSE
	var/stun_stam_cost_coeff = 1.25
	var/hardstun_ds = 1
	var/softstun_ds = 2
	var/stam_dmg = 45
	var/obj/item/stock_parts/cell/powersupply
	var/hitcost = 1000



/obj/item/twohanded/required/electrostaff/get_cell()
	return powersupply
	
/obj/item/melee/baton/proc/deductcharge(usedcost)
	if(powersupply)
		. = powersupply.use(usedcost)
		if(active && powersupply.charge < hitcost)
			depower()
		

/obj/item/twohanded/required/electrostaff/examine(mob/living/user)
	. = ..()
	if(active)
		to_chat(user, "<span class='notice'><b>Alt-click</b> to change between suppresive and lethal power levels. The power level is currently <b>[power]</b>, and the cell charge is [round(powersupply.percent())]%.</span>")
	else
		to_chat(user, "The [src] isn't powered!")
		
		
/obj/item/twohanded/required/electrostaff/attack_self(mob/user)
	if(!active && powersupply.charge < hitcost)
		repower(user)
	else
		depower(user)
	playsound(src.loc, 'sound/weapons/Taser.ogg', 10, 1)
	add_fingerprint(user)
	
/obj/item/twohanded/required/electrostaff/AltClick(mob/user)
	if(!active)
		return
	lethal = !lethal
	if(lethal)
		empower(user)
	else
		enervate(user)

	playsound(src.loc, 'sound/weapons/Taser.ogg', 10, 1)
	add_fingerprint(user)

/obj/item/twohanded/required/electrostaff/proc/empower(user)
	to_chat(user, "<span class ='notice'>You twist the handle of [src], and agitated </span><span style = 'color:yellow'><b>yellow</b></span><span class ='notice'> electric bolts spit out from the ends of the staff.</span>")
	icon_state = "electrostaff_0"
	item_state = "electrostaff_0"
	power = "lethal"
	light_color = LIGHT_COLOR_YELLOW
	force = 20
	force_wielded = 20
	throwforce = 20

/obj/item/twohanded/required/electrostaff/proc/enervate(user)
	to_chat(user, "<span class ='notice'>You twist the handle of [src], and angry <b>blue</b> electric bolts spit out from the ends of the staff.</span>")
	icon_state = "electrostaff_1"
	item_state = "electrostaff_1"
	power = "suppressive"
	light_color = LIGHT_COLOR_CYAN
	force = 1
	force_wielded = 1
	throwforce = 1


/obj/item/twohanded/required/electrostaff/proc/repower(mob/user)
	active = TRUE
	to_chat(user, "<span class ='notice'>You activate the [src]'s electrodes!</span>")
	if(lethal)
		empower(user)
	else
		enervate(user)

/obj/item/twohanded/required/electrostaff/proc/depower(mob/user)
	active = FALSE
	to_chat(user, "<span class ='notice'>The [src]'s electrodes lose power!</span>")
	icon_state = "electrostaff_3"
	item_state = "electrostaff_3"
	light_color = null
	force = 0
	force_wielded = 0
	throwforce = 0
	
/obj/item/twohanded/required/electrostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 10 //Ineffective.
	return ..()

/obj/item/twohanded/required/electrostaff/attack(mob/living/target, mob/living/user)
	. = ..()
	deductcharge(hitcost)
	if(!lethal)
		target.Knockdown(softstun_ds, TRUE, FALSE, hardstun_ds, stam_dmg)
		user.adjustStaminaLossBuffered(getweight())
	else
		return

/obj/item/twohanded/required/electrostaff/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(powersupply)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
		else
			if(C.maxcharge < hitcost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			powersupply = C
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(powersupply)
			powersupply.update_icon()
			powersupply.forceMove(get_turf(src))
			powersupply = null
			to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
			depower(user)
	else
		return ..()
