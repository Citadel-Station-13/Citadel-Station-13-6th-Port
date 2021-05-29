/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'


/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/M, mob/living/user)
	if(M.mob_run_block(src, 0, "[M]'s [name]", ATTACK_TYPE_MELEE, 0, user, ran_zone(user.zone_selected), null) & BLOCK_SUCCESS)
		playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
		return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.DefaultCombatKnockdown(100)
	M.apply_effect(EFFECT_STUTTER, 5)

	M.visible_message("<span class='danger'>[user] prods [M] with [src]!</span>", \
					"<span class='userdanger'>[user] prods you with [src]!</span>")

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

	log_combat(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = 0 //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE//Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged&&shockallowed == 1)
			if(mode < 3)
				mode++
			else
				mode = 0
		else if(mode < 1)
			mode++
		else
			mode = 0
	switch(mode)
		if(0)
			to_chat(user, "Power reset. Hugs!")
		if(1)
			to_chat(user, "Power increased!")
		if(2)
			to_chat(user, "BZZT. Electrifying arms...")
		if(3)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user, params)
	if(M == user)
		return
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(isanimal(M))
					var/list/modifiers = params2list(params)
					if (user.a_intent != INTENT_HARM && !LAZYACCESS(modifiers, "right"))
						M.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
					return
				if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message("<span class='notice'>[user] playfully boops [M] on the head!</span>", \
									"<span class='notice'>You playfully boop [M] on the head!</span>")
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
				else if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get [M.p_them()] up!</span>", \
										"<span class='notice'>You shake [M] trying to get [M.p_them()] up!</span>")
					else
						user.visible_message("<span class='notice'>[user] hugs [M] to make [M.p_them()] feel better!</span>", \
								"<span class='notice'>You hug [M] to make [M.p_them()] feel better!</span>")
					if(M.resting && !(M.combat_flags & COMBAT_FLAG_HARD_STAMCRIT))
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message("<span class='notice'>[user] pets [M]!</span>", \
							"<span class='notice'>You pet [M]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get [M.p_them()] up!</span>", \
										"<span class='notice'>You shake [M] trying to get [M.p_them()] up!</span>")
					else if(user.zone_selected == BODY_ZONE_HEAD)
						user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
										"<span class='warning'>You bop [M] on the head!</span>")
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message("<span class='warning'>[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable...</span>", \
								"<span class='warning'>You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable...</span>")
					if(!CHECK_MOBILITY(M, MOBILITY_STAND) && !(M.combat_flags & COMBAT_FLAG_HARD_STAMCRIT))
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
							"<span class='warning'>You bop [M] on the head!</span>")
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		if(2)
			if(scooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M)||ismonkey(M))
						M.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES)
						user.visible_message("<span class='userdanger'>[user] electrocutes [M] with [user.p_their()] touch!</span>", \
							"<span class='danger'>You electrocute [M] with your touch!</span>")
					else
						if(!iscyborg(M))
							M.adjustFireLoss(10)
							user.visible_message("<span class='userdanger'>[user] shocks [M]!</span>", \
								"<span class='danger'>You shock [M]!</span>")
						else
							user.visible_message("<span class='userdanger'>[user] shocks [M]. It does not seem to have an effect</span>", \
								"<span class='danger'>You shock [M] to no effect.</span>")
					playsound(loc, 'sound/effects/sparks2.ogg', 50, TRUE, -1)
					user.cell.charge -= 500
					scooldown = world.time + 20
		if(3)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message("<span class='userdanger'>[user] crushes [M] in [user.p_their()] grip!</span>", \
							"<span class='danger'>You crush [M] in your grip!</span>")
					else
						user.visible_message("<span class='userdanger'>[user] crushes [M]!</span>", \
								"<span class='danger'>You crush [M]!</span>")
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
					M.adjustBruteLoss(15)
					user.cell.charge -= 300
					ccooldown = world.time + 10

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	var/mode = "draw"
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/cell_charger, /obj/machinery/recharger, /obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port))
	var/static/list/charge_items = typecacheof(list(/obj/item/stock_parts/cell, /obj/item/gun/energy))

/obj/item/borg/charger/update_icon_state()
	icon_state = "charger_[mode]"
	return ..()

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "draw")
		mode = "charge"
	else
		mode = "draw"
	to_chat(user, "<span class='notice'>You toggle [src] to \"[mode]\" mode.</span>")
	update_appearance()

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user))
		return
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target
			if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
				to_chat(user, "<span class='warning'>[M] is unpowered!</span>")
				return

			to_chat(user, "<span class='notice'>You connect to [M]'s power line...</span>")
			while(do_after(user, 15, target = M, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			to_chat(user, "<span class='notice'>You stop charging yourself.</span>")

		else if(is_type_in_list(target, charge_items))
			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, "<span class='warning'>[target] has no power port!</span>")
					return

			if(!cell.charge)
				to_chat(user, "<span class='warning'>[target] has no power!</span>")


			to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

			while(do_after(user, 15, target = target, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if(!cell || !target)
					return

				if(cell != target && cell.loc != target)
					return

				var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge-user.cell.charge)
				if(!cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
				target.update_appearance()

			to_chat(user, "<span class='notice'>You stop charging yourself.</span>")

	else if(is_type_in_list(target, charge_items))
		var/obj/item/stock_parts/cell/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/stock_parts/cell) in target
		if(!cell)
			to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
			return

		if(istype(target, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = target
			if(!E.can_charge)
				to_chat(user, "<span class='warning'>[target] has no power port!</span>")
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, "<span class='warning'>[target] is already charged!</span>")

		to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

		while(do_after(user, 15, target = target, progress = 0))
			if(!user || !user.cell || mode != "charge")
				return

			if(!cell || !target)
				return

			if(cell != target && cell.loc != target)
				return

			var/draw = min(user.cell.charge, cell.chargerate*0.5, cell.maxcharge-cell.charge)
			if(!user.cell.use(draw))
				break
			if(!cell.give(draw))
				break
			target.update_appearance()

		to_chat(user, "<span class='notice'>You stop charging [target].</span>")

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	var/cooldown = 0

/obj/item/harmalarm/emag_act(mob/user)
	. = ..()
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<font color='red'>You short out the safeties on [src]!</font>")
	else
		to_chat(user, "<font color='red'>You reset the safeties on [src]!</font>")
	return TRUE

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if(cooldown > world.time)
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 1200)
			to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			"<span class='userdanger'>The siren pierces your hearing and confuses you!</span>", \
			"<span class='danger'>The siren pierces your hearing!</span>")
		for(var/mob/living/carbon/M in get_hearers_in_view(9, user))
			if(M.get_ear_protection() == FALSE)
				M.confused += 6
		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/effects/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		user.log_message("used a Cyborg Harm Alarm in [AREACOORD(user)]", LOG_ATTACK)
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R.connected_ai, "<br><span class='notice'>NOTICE - Peacekeeping 'HARM ALARM' used by: [user]</span><br>")

		return

	if(safety == FALSE)
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/C in get_hearers_in_view(9, user))
			var/bang_effect = C.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					C.confused += 5
					C.stuttering += 10
					C.Jitter(10)
				if(2)
					C.DefaultCombatKnockdown(40)
					C.confused += 10
					C.stuttering += 15
					C.Jitter(25)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		cooldown = world.time + 600
		user.log_message("used an emagged Cyborg Harm Alarm in [AREACOORD(user)]", LOG_ATTACK)

#define DISPENSE_LOLLIPOP_MODE 1
#define THROW_LOLLIPOP_MODE 2
#define THROW_GUMBALL_MODE 3
#define DISPENSE_ICECREAM_MODE 4

/obj/item/borg/lollipop
	name = "treat fabricator"
	desc = "Reward humans with various treats. Toggle in-module to switch between dispensing and high velocity ejection modes."
	icon_state = "lollipop"
	var/candy = 30
	var/candymax = 30
	var/charge_delay = 10
	var/charging = FALSE
	var/mode = DISPENSE_LOLLIPOP_MODE

	var/firedelay = 0
	var/hitspeed = 2
	var/hitdamage = 0
	var/emaggedhitdamage = 3

/obj/item/borg/lollipop/clown
	emaggedhitdamage = 0

/obj/item/borg/lollipop/equipped()
	. = ..()
	check_amount()

/obj/item/borg/lollipop/dropped(mob/user)
	. = ..()
	check_amount()

/obj/item/borg/lollipop/proc/check_amount()	//Doesn't even use processing ticks.
	if(charging)
		return
	if(candy < candymax)
		addtimer(CALLBACK(src, .proc/charge_lollipops), charge_delay)
		charging = TRUE

/obj/item/borg/lollipop/proc/charge_lollipops()
	candy++
	charging = FALSE
	check_amount()

/obj/item/borg/lollipop/proc/dispense(atom/A, mob/user)
	if(candy <= 0)
		to_chat(user, "<span class='warning'>No treats left in storage!</span>")
		return FALSE
	var/turf/T = get_turf(A)
	if(!T || !istype(T) || !isopenturf(T))
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(O.density)
			return FALSE

	var/obj/item/reagent_containers/food/snacks/L
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			L = new /obj/item/reagent_containers/food/snacks/lollipop(T)
		if(DISPENSE_ICECREAM_MODE)
			L = new /obj/item/reagent_containers/food/snacks/icecream(T)
			var/obj/item/reagent_containers/food/snacks/icecream/I = L
			I.add_ice_cream("vanilla")
			I.desc = "Eat the ice cream."

	var/into_hands = FALSE
	if(ismob(A))
		var/mob/M = A
		into_hands = M.put_in_hands(L)

	candy--
	check_amount()

	if(into_hands)
		user.visible_message("<span class='notice'>[user] dispenses a treat into the hands of [A].</span>", "<span class='notice'>You dispense a treat into the hands of [A].</span>", "<span class='italics'>You hear a click.</span>")
	else
		user.visible_message("<span class='notice'>[user] dispenses a treat.</span>", "<span class='notice'>You dispense a treat.</span>", "<span class='italics'>You hear a click.</span>")

	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	return TRUE

/obj/item/borg/lollipop/proc/shootL(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, "<span class='warning'>Not enough lollipops left!</span>")
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/lollipop/A = new /obj/item/ammo_casing/caseless/lollipop(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.pixels_per_second = TILES_TO_PIXELS(20)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	A.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message("<span class='warning'>[user] blasts a flying lollipop at [target]!</span>")
	check_amount()

/obj/item/borg/lollipop/proc/shootG(atom/target, mob/living/user, params)	//Most certainly a good idea.
	if(candy <= 0)
		to_chat(user, "<span class='warning'>Not enough gumballs left!</span>")
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/gumball/A = new /obj/item/ammo_casing/caseless/gumball(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.pixels_per_second = TILES_TO_PIXELS(20)
	A.BB.color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	playsound(src.loc, 'sound/weapons/bulletflyby3.ogg', 50, 1)
	A.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message("<span class='warning'>[user] shoots a high-velocity gumball at [target]!</span>")
	check_amount()

/obj/item/borg/lollipop/afterattack(atom/target, mob/living/user, proximity, click_params)
	. = ..()
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(12))
			to_chat(user, "<span class='warning'>Not enough power.</span>")
			return FALSE
		if(R.emagged)
			hitdamage = emaggedhitdamage
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE, DISPENSE_ICECREAM_MODE)
			if(!proximity)
				return FALSE
			dispense(target, user)
		if(THROW_LOLLIPOP_MODE)
			shootL(target, user, click_params)
		if(THROW_GUMBALL_MODE)
			shootG(target, user, click_params)
	hitdamage = initial(hitdamage)

/obj/item/borg/lollipop/attack_self(mob/living/user)
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			mode = THROW_LOLLIPOP_MODE
			to_chat(user, "<span class='notice'>Module is now throwing lollipops.</span>")
		if(THROW_LOLLIPOP_MODE)
			mode = THROW_GUMBALL_MODE
			to_chat(user, "<span class='notice'>Module is now blasting gumballs.</span>")
		if(THROW_GUMBALL_MODE)
			mode = DISPENSE_ICECREAM_MODE
			to_chat(user, "<span class='notice'>Module is now dispensing ice cream.</span>")
		if(DISPENSE_ICECREAM_MODE)
			mode = DISPENSE_LOLLIPOP_MODE
			to_chat(user, "<span class='notice'>Module is now dispensing lollipops.</span>")
	..()

#undef DISPENSE_LOLLIPOP_MODE
#undef THROW_LOLLIPOP_MODE
#undef THROW_GUMBALL_MODE
#undef DISPENSE_ICECREAM_MODE

/obj/item/ammo_casing/caseless/gumball
	name = "Gumball"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/item/projectile/bullet/reusable/gumball
	click_cooldown_override = 2


/obj/item/projectile/bullet/reusable/gumball
	name = "gumball"
	desc = "Oh noes! A fast-moving gumball!"
	icon_state = "gumball"
	ammo_type = /obj/item/reagent_containers/food/snacks/gumball/cyborg
	nodamage = TRUE

/obj/item/projectile/bullet/reusable/gumball/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/reagent_containers/food/snacks/gumball/S = new ammo_type(T)
		S.color = color
		dropped = TRUE

/obj/item/ammo_casing/caseless/lollipop	//NEEDS RANDOMIZED COLOR LOGIC.
	name = "Lollipop"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/item/projectile/bullet/reusable/lollipop
	click_cooldown_override = 2

/obj/item/projectile/bullet/reusable/lollipop
	name = "lollipop"
	desc = "Oh noes! A fast-moving lollipop!"
	icon_state = "lollipop_1"
	ammo_type = /obj/item/reagent_containers/food/snacks/lollipop/cyborg
	var/color2 = rgb(0, 0, 0)
	nodamage = TRUE

/obj/item/projectile/bullet/reusable/lollipop/New()
	var/obj/item/reagent_containers/food/snacks/lollipop/S = new ammo_type(src)
	color2 = S.headcolor
	var/mutable_appearance/head = mutable_appearance('icons/obj/projectiles.dmi', "lollipop_2")
	head.color = color2
	add_overlay(head)

/obj/item/projectile/bullet/reusable/lollipop/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/reagent_containers/food/snacks/lollipop/S = new ammo_type(T)
		S.change_head_color(color2)
		dropped = TRUE

#define PKBORG_DAMPEN_CYCLE_DELAY 20

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "\improper Hyperkinetic Dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. <span class='boldnotice'>Projects a field that drains power per second while active, that will weaken and slow damaging projectiles inside its field.</span> Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield"
	var/maxenergy = 1500
	var/energy = 1500
	var/energy_recharge = 7.5
	var/energy_recharge_cyborg_drain_coefficient = 0.4
	var/cyborg_cell_critical_percentage = 0.05
	var/mob/living/silicon/robot/host = null
	var/datum/proximity_monitor/advanced/dampening_field
	var/projectile_damage_coefficient = 0.5
	var/projectile_damage_tick_ecost_coefficient = 2	//Lasers get half their damage chopped off, drains 50 power/tick. Note that fields are processed 5 times per second.
	var/projectile_speed_coefficient = 1.5		//Higher the coefficient slower the projectile.
	var/projectile_tick_speed_ecost = 15
	var/list/obj/item/projectile/tracked
	var/image/projectile_effect
	var/field_radius = 3
	var/active = FALSE
	var/cycle_delay = 0

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize()
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")
	tracked = list()
	icon_state = "shield0"
	START_PROCESSING(SSfastprocess, src)
	host = loc

/obj/item/borg/projectile_dampen/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if(cycle_delay > world.time)
		to_chat(user, "<span class='boldwarning'>[src] is still recycling its projectors!</span>")
		return
	cycle_delay = world.time + PKBORG_DAMPEN_CYCLE_DELAY
	if(!active)
		if(!user.has_buckled_mobs())
			activate_field()
		else
			to_chat(user, "<span class='warning'>[src]'s safety cutoff prevents you from activating it due to living beings being ontop of you!</span>")
	else
		deactivate_field()
	update_icon()
	to_chat(user, "<span class='boldnotice'>You [active? "activate":"deactivate"] [src].</span>")

/obj/item/borg/projectile_dampen/update_icon_state()
	icon_state = "[initial(icon_state)][active]"

/obj/item/borg/projectile_dampen/proc/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	dampening_field = make_field(/datum/proximity_monitor/advanced/peaceborg_dampener, list("current_range" = field_radius, "host" = src, "projector" = src))
	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.module.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	QDEL_NULL(dampening_field)
	visible_message("<span class='warning'>\The [src] shuts off!</span>")
	for(var/P in tracked)
		restore_projectile(P)
	active = FALSE

	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.module.allow_riding = TRUE

/obj/item/borg/projectile_dampen/proc/get_host()
	if(istype(host))
		return host
	else
		if(iscyborg(host.loc))
			return host.loc
	return null

/obj/item/borg/projectile_dampen/dropped(mob/user)
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/equipped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/on_mob_death()
	deactivate_field()
	. = ..()

/obj/item/borg/projectile_dampen/process()
	process_recharge()
	process_usage()
	update_location()

/obj/item/borg/projectile_dampen/proc/update_location()
	if(dampening_field)
		dampening_field.HandleMove()

/obj/item/borg/projectile_dampen/proc/process_usage()
	var/usage = 0
	for(var/I in tracked)
		var/obj/item/projectile/P = I
		if(!P.stun && P.nodamage)	//No damage
			continue
		usage += projectile_tick_speed_ecost
		usage += (tracked[I] * projectile_damage_tick_ecost_coefficient)
	energy = clamp(energy - usage, 0, maxenergy)
	if(energy <= 0)
		deactivate_field()
		visible_message("<span class='warning'>[src] blinks \"ENERGY DEPLETED\".</span>")

/obj/item/borg/projectile_dampen/proc/process_recharge()
	if(!istype(host))
		if(iscyborg(host.loc))
			host = host.loc
		else
			energy = clamp(energy + energy_recharge, 0, maxenergy)
			return
	if(host.cell && (host.cell.charge >= (host.cell.maxcharge * cyborg_cell_critical_percentage)) && (energy < maxenergy))
		host.cell.use(energy_recharge*energy_recharge_cyborg_drain_coefficient)
		energy += energy_recharge

/obj/item/borg/projectile_dampen/proc/dampen_projectile(obj/item/projectile/P, track_projectile = TRUE)
	if(tracked[P])
		return
	if(track_projectile)
		tracked[P] = P.damage
	P.damage *= projectile_damage_coefficient
	P.pixels_per_second *= projectile_speed_coefficient
	P.add_overlay(projectile_effect)

/obj/item/borg/projectile_dampen/proc/restore_projectile(obj/item/projectile/P)
	tracked -= P
	P.damage *= (1/projectile_damage_coefficient)
	P.pixels_per_second *= (1/projectile_speed_coefficient)
	P.cut_overlay(projectile_effect)

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "\proper X-ray vision"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	sight_mode = BORGXRAY

/obj/item/borg/sight/xray/truesight_lens
	name = "truesight lens"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "truesight_lens"

/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"


/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"

/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"

/obj/item/borg/sight/hud/med/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health(src)
	return


/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"

/obj/item/borg/sight/hud/sec/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/security(src)
	return


/**********************************************************************
						Grippers oh god oh fuck
***********************************************************************/

/obj/item/weapon/gripper
	name = "engineering gripper"
	desc = "A simple grasping tool for interacting with various engineering related items, such as circuits, gas tanks, conveyer belts and more. Alt click to drop instead of use."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	item_flags = NOBLUDGEON

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/circuitboard,
		/obj/item/light,
		/obj/item/electronics,
		/obj/item/tank,
		/obj/item/conveyor_switch_construct,
		/obj/item/stack/conveyor,
		/obj/item/wallframe,
		/obj/item/vending_refill,
		/obj/item/stack/sheet,
		/obj/item/stack/tile,
		/obj/item/stack/rods,
		/obj/item/stock_parts
		)
	//Basically a blacklist for any subtypes above we dont want
	var/list/cannot_hold = list(
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/plasteel
		)

	var/obj/item/wrapped = null // Item currently being held.

//Used to interact with UI's of held items, such as gas tanks and airlock electronics.
/obj/item/weapon/gripper/AltClick(mob/user)
	if(wrapped)
		wrapped.forceMove(get_turf(wrapped))
		to_chat(user, "<span class='notice'>You drop the [wrapped].</span>")
		wrapped = null
	return ..()

/obj/item/weapon/gripper/pre_attack(var/atom/target, var/mob/living/silicon/robot/user, proximity, params)

	if(!proximity)
		return

	if(!wrapped)
		for(var/obj/item/thing in src.contents)
			wrapped = thing
			break

	if(wrapped) //Already have an item.
		//Temporary put wrapped into user so target's attackby() checks pass.
		wrapped.loc = user

		//Pass the attack on to the target. This might delete/relocate wrapped.
		var/resolved = target.attackby(wrapped,user)
		if(!resolved && wrapped && target)
			wrapped.afterattack(target,user,1)
		//If wrapped was neither deleted nor put into target, put it back into the gripper.
		if(wrapped && user && (wrapped.loc == user))
			wrapped.loc = src
		else
			wrapped = null
			return

	else if(istype(target,/obj/item))
		var/obj/item/I = target
		var/grab = 0

		for(var/typepath in can_hold)
			if(istype(I,typepath))
				grab = 1
				for(var/badpath in cannot_hold)
					if(istype(I,badpath))
						if(!user.emagged)
							grab = 0
							continue

		//We can grab the item, finally.
		if(grab)
			to_chat(user, "<span class='notice'>You collect \the [I].</span>")
			I.loc = src
			wrapped = I
			return
		else
			to_chat(user, "<span class='danger'>Your gripper cannot hold \the [target].</span>")

/obj/item/weapon/gripper/mining
	name = "shelter capsule deployer"
	desc = "A simple grasping tool for carrying and deploying shelter capsules. Alt click to drop instead of use."
	icon_state = "gripper_mining"
	can_hold = list(
		/obj/item/survivalcapsule
		)

/obj/item/weapon/gripper/medical
	name = "medical gripper"
	desc = "A simple grasping tool for interacting with medical equipment, such as beakers, blood bags, chem bags and more. Alt click to drop instead of use."
	icon_state = "gripper_medical"
	can_hold = list(
		/obj/item/storage/bag/bio,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/blood
		)

/obj/item/gun/energy/plasmacutter/cyborg
	name = "cyborg plasma cutter"
	desc = "A basic variation of the plasma cutter, compressed into a cyborg chassis. Less effective than normal plasma cutters."
	force = 15
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/weak)
	can_charge = FALSE
	selfcharge = EGUN_SELFCHARGE_BORG
	cell_type = /obj/item/stock_parts/cell/secborg
	charge_delay = 5

/obj/item/cyborg_clamp
	name = "cyborg loading clamp"
	desc = "Equipment for supply cyborgs. Lifts objects and loads them into cargo. Will not carry living beings."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	tool_behaviour = TOOL_RETRACTOR
	item_flags = NOBLUDGEON
	flags_1 = NONE
	var/cargo_capacity = 8
	var/cargo = list()

/obj/item/cyborg_clamp/attack(mob/M, mob/user, def_zone)
	return

/obj/item/cyborg_clamp/afterattack(atom/movable/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return FALSE
	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(contents.len < cargo_capacity)
				user.visible_message("[user] lifts [target] and starts to load it into its cargo compartment.")
				O.anchored = TRUE
				if(do_mob(user, O, 20))
					for(var/mob/chump in target.GetAllContents())
						to_chat(user, "<span class='warning'>Error: Living entity detected in [target]. Cannot load.</span>")
						O.anchored = initial(O.anchored)
						return
					for(var/obj/item/disk/nuclear/diskie in target.GetAllContents())
						to_chat(user, "<span class='warning'>Error: Nuclear class authorization device detected in [target]. Cannot load.</span>")
						O.anchored = initial(O.anchored)
						return
					if(contents.len < cargo_capacity) //check both before and after
						cargo += O
						O.forceMove(src)
						O.anchored = FALSE
						to_chat(user, "<span class='notice'>[target] successfully loaded.</span>")
						playsound(loc, 'sound/effects/bin_close.ogg', 50, 0)
					else
						to_chat(user, "<span class='warning'>Not enough room in cargo compartment! Maximum of [cargo_capacity] objects!</span>")
						O.anchored = initial(O.anchored)
						return
				else
					O.anchored = initial(O.anchored)
			else
				to_chat(user, "<span class='warning'>Not enough room in cargo compartment! Maximum of [cargo_capacity] objects!</span>")
		else
			to_chat(user, "<span class='warning'>[target] is firmly secured!</span>")

/obj/item/cyborg_clamp/attack_self(mob/user)
	var/obj/chosen_cargo = input(user, "Drop what?") as null|anything in cargo
	if(!chosen_cargo)
		return
	chosen_cargo.forceMove(get_turf(chosen_cargo))
	cargo -= chosen_cargo
	user.visible_message("[user] unloads [chosen_cargo] from its cargo.")
	playsound(loc, 'sound/effects/bin_close.ogg', 50, 0)

/obj/item/cyborg_clamp/Destroy()
	for(var/atom/movable/target in cargo)
		target.forceMove(get_turf(src))
	playsound(loc, 'sound/effects/bin_close.ogg', 50, 0)
	return ..()

/obj/item/card/id/miningborg
	name = "mining point card"
	desc = "A robotic ID strip used for claiming and transferring mining points. Must be held in an active slot to transfer points."
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	icon_state = "data_1"


/**********************************************************************
						Dogborg stuff
***********************************************************************/
///Mere cosmetic dogborg items, remnants of what were once the most annoying cyborg modules.
/obj/item/dogborg_tongue
	name = "synthetic tongue"
	desc = "Useful for slurping mess off the floor before affectionally licking the crew members in the face."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "synthtongue"
	hitsound = 'sound/effects/attackblob.ogg'
	desc = "For giving affectionate kisses."
	item_flags = NOBLUDGEON

/obj/item/dogborg_tongue/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !isliving(target))
		return
	var/mob/living/silicon/robot/R = user
	var/mob/living/L = target
	if(L.ckey && !(L.client?.prefs.vore_flags & LICKABLE))
		to_chat(R, "<span class='danger'>ERROR ERROR: Target not lickable. Aborting display-of-affection subroutine.</span>")
		return

	if(check_zone(R.zone_selected) == "head")
		R.visible_message("<span class='warning'>\the [R] affectionally licks \the [L]'s face!</span>", "<span class='notice'>You affectionally lick \the [L]'s face!</span>")
		playsound(R, 'sound/effects/attackblob.ogg', 50, 1)
	else
		R.visible_message("<span class='warning'>\the [R] affectionally licks \the [L]!</span>", "<span class='notice'>You affectionally lick \the [L]!</span>")
		playsound(R, 'sound/effects/attackblob.ogg', 50, 1)

/obj/item/dogborg_nose
	name = "boop module"
	desc = "The BOOP module"
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "nose"
	flags_1 = CONDUCT_1|NOBLUDGEON
	force = 0

/obj/item/dogborg_nose/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	do_attack_animation(target, null, src)
	user.visible_message("<span class='notice'>[user] [pick("nuzzles", "pushes", "boops")] \the [target.name] with their nose!</span>")
