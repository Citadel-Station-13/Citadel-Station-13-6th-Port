/obj/item/reactive_armour_shell
	name = "reactive armour shell"
	desc = "An experimental suit of armour, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reactive_armour_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/anomaly_armour_types = list(
		/obj/effect/anomaly/grav	                = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux 	           		= /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/bluespace 	            = /obj/item/clothing/suit/armor/reactive/teleport
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armour_path = anomaly_armour_types[A.anomaly_type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //Lets not cheat the player if an anomaly type doesnt have its own armour coded
		to_chat(user, "You insert [A] into the chest plate, and the armour gently hums to life.")
		new armour_path(get_turf(src))
		qdel(src)
		qdel(A)

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	var/active = 0
	var/reactivearmor_cooldown_duration = 0 //cooldown specific to reactive armor
	var/reactivearmor_cooldown = 0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/hit_reaction_chance = 50
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
	if(active)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
		icon_state = "reactive"
		item_state = "reactive"
	else
		to_chat(user, "<span class='notice'>[src] is now inactive.</span>")
		icon_state = "reactiveoff"
		item_state = "reactiveoff"
	add_fingerprint(user)
	if(user.get_item_by_slot(SLOT_WEAR_SUIT) == src)
		user.update_inv_wear_suit()

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	active = 0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	reactivearmor_cooldown = world.time + 200

/obj/item/clothing/suit/armor/reactive/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(!active)
		return BLOCK_NONE
	return block_action(owner, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, block_return)

/obj/item/clothing/suit/armor/reactive/proc/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	return BLOCK_NONE

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone separated our Research Director from his own head!"
	var/tele_range = 8
	var/rad_amount = 60
	var/rad_amount_before = 120
	reactivearmor_cooldown_duration = 100

/obj/item/clothing/suit/armor/reactive/teleport/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The reactive teleport system is still recharging! It fails to teleport [H]!</span>")
			return
		owner.visible_message("<span class='danger'>The reactive teleport system flings [H] clear of [attack_text], shutting itself off in the process!</span>")
		playsound(get_turf(owner), 'sound/magic/blink.ogg', 100, 1)
		var/list/turfs = new
		var/turf/old = get_turf(src)
		for(var/turf/T in orange(tele_range, H))
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		do_teleport(H, picked, no_effects = TRUE, channel = TELEPORT_CHANNEL_WORMHOLE)
		radiation_pulse(old, rad_amount_before)
		radiation_pulse(src, rad_amount)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_PASSTHROUGH
		return BLOCK_SUCCESS | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT | BLOCK_TARGET_DODGED
	return BLOCK_NONE

//Fire

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "An experimental suit of armor with a reactive sensor array rigged to a flame emitter. For the stylish pyromaniac."

/obj/item/clothing/suit/armor/reactive/fire/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The reactive incendiary armor on [owner] activates, but fails to send out flames as it is still recharging its flame jets!</span>")
			return
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out jets of flame!</span>")
		playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, 1)
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
		owner.fire_stacks = -20
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_INTERNAL
	return BLOCK_NONE

//Stealth

/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	reactivearmor_cooldown_duration = 65
	desc = "An experimental suit of armor that renders the wearer invisible on detection of imminent harm, and creates a decoy that runs away from the owner. You can't fight what you can't see."

/obj/item/clothing/suit/armor/reactive/stealth/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The reactive stealth system on [owner] activates, but is still recharging its holographic emitters!</span>")
			return
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.alpha = 30
		owner.visible_message("<span class='danger'>[owner] is hit by [attack_text] in the chest!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
		spawn(40)
			owner.alpha = initial(owner.alpha)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_INTERNAL
	return BLOCK_NONE

//Tesla

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "An experimental suit of armor with sensitive detectors hooked up to a huge capacitor grid, with emitters strutting out of it. Zap."
	siemens_coefficient = -1
	reactivearmor_cooldown_duration = 20
	var/zap_power = 25000
	var/zap_range = 20
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/legacy = FALSE
	var/legacy_dmg = 30

/obj/item/clothing/suit/armor/reactive/tesla/dropped(mob/user)
	..()
	if(istype(user))
		REMOVE_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/equipped(mob/user, slot)
	..()
	if(slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		ADD_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
			owner.visible_message("<span class='danger'>The tesla capacitors on [owner]'s reactive tesla armor are still recharging! The armor merely emits some sparks.</span>")
			return
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out arcs of lightning!</span>")
		if(!legacy)
			tesla_zap(owner, zap_range, zap_power, zap_flags)
		else
			for(var/mob/living/M in view(7, owner))
				if(M == owner)
					continue
				owner.Beam(M,icon_state="purple_lightning",icon='icons/effects/effects.dmi',time=5)
				M.adjustFireLoss(legacy_dmg)
				playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_INTERNAL
	return NONE

//Repulse

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	reactivearmor_cooldown_duration = 20
	desc = "An experimental suit of armor that violently throws back attackers."

/obj/item/clothing/suit/armor/reactive/repulse/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The repulse generator is still recharging!</span>")
			return 0
		playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], converting the attack into a wave of force!</span>")
		var/turf/T = get_turf(owner)
		var/list/cachedrange = range(T, 7) - owner
		var/safety = 50
		var/list/to_throw = list()
		for(var/mob/living/L in cachedrange)
			if(L.move_resist > MOVE_FORCE_EXTREMELY_STRONG)
				continue
			to_throw += L
		for(var/obj/O in cachedrange)
			if(O.anchored)
				continue
			to_throw += O
		for(var/i in to_throw)
			if(!safety)
				break
			var/atom/movable/AM = i
			var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(AM, T)))
			AM.throw_at(throwtarget,10,1)
			safety--
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_INTERNAL
	return BLOCK_NONE

/obj/item/clothing/suit/armor/reactive/table
	name = "reactive table armor"
	reactivearmor_cooldown_duration = 0
	desc = "If you can't beat the memes, embrace them."
	var/tele_range = 10

/obj/item/clothing/suit/armor/reactive/table/block_action(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(owner.prob_good(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The reactive table armor's fabricators are still on cooldown!</span>")
			return
		owner.visible_message("<span class='danger'>The reactive teleport system flings [H] clear of [attack_text] and slams [H.p_them()] into a fabricated table!</span>")
		owner.visible_message("<font color='red' size='3'>[H] GOES ON THE TABLE!!!</font>")
		owner.DefaultCombatKnockdown(40)
		var/list/turfs = new/list()
		for(var/turf/T in orange(tele_range, H))
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		new /obj/structure/table(get_turf(owner))
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_INTERNAL
	return BLOCK_NONE

/obj/item/clothing/suit/armor/reactive/table/emp_act()
	return
