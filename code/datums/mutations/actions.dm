/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy/genetic
	instability = 10
	energy_coeff = 1

/datum/mutation/human/telepathy/on_acquiring(mob/living/carbon/human/owner)
	. = ..()

/datum/mutation/human/telepathy/on_losing(mob/living/carbon/human/owner)
	. = ..()

/obj/effect/proc_holder/spell/targeted/telepathy/genetic
	magic_check = FALSE

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/human/firebreath/modify()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/S = power
		S.strength = 4 + GET_MUTATION_POWER(src)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 600
	clothes_req = NONE
	antimagic_allowed = TRUE
	range = 20
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "You built up heat in your mouth."
	deactive_msg = "You swallow the flame."
	var/strength = 4

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,"<span class='warning'>Something in front of your mouth caught fire!</span>")
			return FALSE

/obj/effect/proc_holder/spell/aimed/firebreath/cast(list/targets, mob/living/user)
	var/turf/T = user.loc
	if(!isturf(T))
		return FALSE
	firecone(T,user.dir,strength)
	remove_ranged_ability()
	charge_counter = 0
	start_recharge()
	on_deactivation(user)

/proc/firecone(loc,dir,length)
	var/addsides = FALSE
	var/list/turf/recentturf = list(loc)
	for (var/i = 0;i < length;i++)
		var/list/turf/h = list()
		for (var/turf/g in recentturf)
			var/frontturf = get_step(g,dir)
			if (addsides)
				var/rightturf = get_step(frontturf,turn(dir,90))
				var/leftturf = get_step(frontturf,turn(dir,270))
				if (!(rightturf in h))
					h += rightturf
				if (!(leftturf in h))
					h += leftturf
			if (!(frontturf in h))
				h += frontturf
		for (var/turf/j in h)
			if (j.blocks_air)
				h -= j
				continue
			for (var/obj/o in j)
				if (o.CanAtmosPass == ATMOS_PASS_PROC ? !o.CanAtmosPass(loc) : !o.CanAtmosPass)
					h -= j
					continue
		for (var/turf/l in h)
			new /obj/effect/hotspot(l)
			l.hotspot_expose(700,50,1)
		sleep(1)
		recentturf = h
		addsides = !addsides

/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/human/void/on_life()
	if(!isturf(owner.loc))
		return
	if(prob((0.5+((100-dna.stability)/20))) * GET_MUTATION_SYNCHRONIZER(src)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = NONE
	antimagic_allowed = TRUE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = "shout"
	action_icon_state = "void_magnet"
	var/in_use = FALSE //so it doesnt cast while you are already deep innit

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/user = usr)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)

/datum/mutation/human/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>You feel power flow through your hands.</span>"
	text_lose_indication = "<span class='notice'>The energy in your hands subsides.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 400
	antimagic_allowed = TRUE
	clothes_req = NONE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, user, 1, SHOCK_NOSTUN))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 10
			C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
			return ..()
		else
			user.visible_message("<span class='warning'>[user] fails to electrocute [target]!</span>")
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, SHOCK_NOSTUN)
		L.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
		return ..()
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
		return ..()


/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = "<span class='notice'>Smells begin to make more sense...</span>"
	text_lose_indication = "<span class='notice'>Your sense of smell goes back to normal.</span>"
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	synchronizer_coeff = 1
	var/reek = 200

/datum/mutation/human/olfaction/modify()
	if(power)
		var/obj/effect/proc_holder/spell/targeted/olfaction/S = power
		S.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 100
	clothes_req = NONE
	antimagic_allowed = TRUE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	var/sensitivity = 1

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	//can we sniff? is there miasma in the air?
	var/datum/gas_mixture/air = user.loc.return_air()

	if(air.get_moles(GAS_MIASMA))
		user.adjust_disgust(sensitivity * 45)
		to_chat(user, "<span class='warning'>With your overly sensitive nose, you get a whiff of stench and feel sick! Try moving to a cleaner area!</span>")
		return

	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			if(md5(H.dna.uni_identity) in sniffed.fingerprints)
				possible |= H
		if(!length(possible))
			to_chat(user,"<span class='warning'>Despite your best efforts, there are no scents to be found on [sniffed]...</span>")
			return
		tracking_target = input(user, "Choose a scent to remember.", "Scent Tracking") as null|anything in sortNames(possible)
		if(!tracking_target)
			if(!old_target)
				to_chat(user,"<span class='warning'>You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was.</span>")
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,"<span class='notice'>You pick up the scent of [tracking_target]. The hunt begins.</span>")
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not holding anything to smell, and you haven't smelled anything you can track. You smell your skin instead; it's kinda salty.</span>")
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug.</span>")
		return
	if(tracking_target == user)
		to_chat(user,"<span class='warning'>You smell out the trail to yourself. Yep, it's you.</span>")
		return
	if(usr.z < tracking_target.z)
		to_chat(user,"<span class='warning'>The trail leads... way up above you? Huh. They must be really, really far away.</span>")
		return
	else if(usr.z > tracking_target.z)
		to_chat(user,"<span class='warning'>The trail leads... way down below you? Huh. They must be really, really far away.</span>")
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,"<span class='notice'>You consider [tracking_target]'s scent. The trail leads <b>[direction_text].</b></span>")


/datum/mutation/human/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your joints feel loose.</span>"
	instability = 20
	power = /obj/effect/proc_holder/spell/self/self_amputation

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/self_amputation
	name = "Drop a limb"
	desc = "Concentrate to make a random limb pop right off your body."
	clothes_req = NONE
	antimagic_allowed = TRUE
	charge_max = 100
	action_icon_state = "autotomy"

/obj/effect/proc_holder/spell/self/self_amputation/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return

	var/list/parts = list()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.body_part != HEAD && BP.body_part != CHEST)
			if(BP.dismemberable)
				parts += BP
	if(!parts.len)
		to_chat(usr, "<span class='notice'>You can't shed any more limbs!</span>")
		return

	var/obj/item/bodypart/BP = pick(parts)
	BP.dismember(harmless=TRUE)

//spider webs
/datum/mutation/human/webbing
	name = "Webbing Production"
	desc = "Allows the user to lay webbing, and travel through it."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin feels webby.</span>"
	instability = 15
	power = /obj/effect/proc_holder/spell/self/lay_genetic_web

/obj/effect/proc_holder/spell/self/lay_genetic_web
	name = "Lay Web"
	desc = "Drops a web. Only you will be able to traverse your web easily, making it pretty good for keeping you safe."
	clothes_req = NONE
	antimagic_allowed = TRUE
	charge_max = 4 SECONDS //the same time to lay a web
	action_icon = 'icons/mob/actions/actions_genetic.dmi'
	action_icon_state = "lay_web"

/obj/effect/proc_holder/spell/self/lay_genetic_web/cast(list/targets, mob/user = usr)
	var/failed = FALSE
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You can't lay webs here!</span>")
		failed = TRUE
	var/turf/T = get_turf(user)
	var/obj/structure/spider/stickyweb/W = locate() in T
	var/obj/structure/arachnid/W2 = locate() in T
	if(W || W2)
		to_chat(user, "<span class='warning'>There's already a web here!</span>")
		failed = TRUE
	if(failed)
		revert_cast(user)
		return FALSE

	user.visible_message("<span class='notice'>[user] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to lay a web.</span>")
	if(!do_after(user, 4 SECONDS, target = T))
		to_chat(user, "<span class='warning'>Your web spinning was interrupted!</span>")
		return
	else
		new /obj/structure/spider/stickyweb/genetic(T, user)


/datum/mutation/human/tongue_spike
	name = "Tongue Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as a deadly weapon."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your feel like you can throw your voice.</span>"
	instability = 15
	power = /obj/effect/proc_holder/spell/self/tongue_spike

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/tongue_spike
	name = "Launch spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it and dealing damage until they remove it."
	clothes_req = NONE
	antimagic_allowed = TRUE
	charge_max = 100
	action_icon = 'icons/mob/actions/actions_genetic.dmi'
	action_icon_state = "spike"
	var/spike_path = /obj/item/hardened_spike

/obj/effect/proc_holder/spell/self/tongue_spike/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return
	var/obj/item/organ/tongue/tongue
	for(var/org in C.internal_organs)
		if(istype(org, /obj/item/organ/tongue))
			tongue = org
			break

	if(!tongue)
		to_chat(C, "<span class='notice'>You don't have a tongue to shoot!</span>")
		return

	tongue.Remove(C, special = TRUE)
	var/obj/item/hardened_spike/spike = new spike_path(get_turf(C), C)
	tongue.forceMove(spike)
	spike.throw_at(get_edge_target_turf(C,C.dir), 14, 4, C)

/obj/item/hardened_spike
	name = "biomass spike"
	desc = "Hardened biomass, shaped into a spike. Very pointy!"
	icon_state = "tonguespike"
	force = 2
	throwforce = 15 //15 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math
	throw_speed = 4
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 100, "embedded_fall_chance" = 0)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	var/mob/living/carbon/human/fired_by
	/// if we missed our target
	var/missed = TRUE

/obj/item/hardened_spike/Initialize(mapload, firedby)
	. = ..()
	fired_by = firedby
	addtimer(CALLBACK(src, .proc/checkembedded), 5 SECONDS)

/obj/item/hardened_spike/proc/checkembedded()
	if(missed)
		unembedded()

/obj/item/hardened_spike/embedded(atom/target)
	if(isbodypart(target))
		missed = FALSE

/obj/item/hardened_spike/unembedded()
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] cracks and twists, changing shape!</span>")
	for(var/i in contents)
		var/obj/o = i
		o.forceMove(T)
	qdel(src)

/datum/mutation/human/tongue_spike/chem
	name = "Chem Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as biomass, allowing a long range transfer of chemicals."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your feel like you can really connect with people by throwing your voice.</span>"
	instability = 15
	locked = TRUE
	power = /obj/effect/proc_holder/spell/self/tongue_spike/chem
	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/tongue_spike/chem
	name = "Launch chem spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it for a very small amount of damage. While the other person has the spike embedded, you can transfer your chemicals to them."
	action_icon_state = "spikechem"
	spike_path = /obj/item/hardened_spike/chem

/obj/item/hardened_spike/chem
	name = "chem spike"
	desc = "Hardened biomass, shaped into... something."
	icon_state = "tonguespikechem"
	throwforce = 2 //2 + 2 (WEIGHT_CLASS_SMALL) * 0 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math again but very low or smthin
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 100, "embedded_fall_chance" = 0, "embedded_pain_chance" = 0, "embedded_ignore_throwspeed_threshold" = TRUE) //never hurts once it's in you
	var/been_places = FALSE
	var/datum/action/innate/send_chems/chems

/obj/item/hardened_spike/chem/embedded(mob/living/carbon/human/embedded_mob)
	if(been_places)
		return
	been_places = TRUE
	chems = new
	chems.transfered = embedded_mob
	chems.spikey = src
	to_chat(fired_by, "<span class='notice'>Link established! Use the \"Transfer Chemicals\" ability to send your chemicals to the linked target!</span>")
	chems.Grant(fired_by)

/obj/item/hardened_spike/chem/unembedded()
	to_chat(fired_by, "<span class='warning'>Link lost!</span>")
	QDEL_NULL(chems)
	..()

/datum/action/innate/send_chems
	icon_icon = 'icons/mob/actions/actions_genetic.dmi'
	background_icon_state = "bg_spell"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "spikechemswap"
	name = "Transfer Chemicals"
	desc = "Send all of your reagents into whomever the chem spike is embedded in. One use."
	var/obj/item/hardened_spike/chem/spikey
	var/mob/living/carbon/human/transfered

/datum/action/innate/send_chems/Activate()
	if(!ishuman(transfered) || !ishuman(owner))
		return
	var/mob/living/carbon/human/transferer = owner

	to_chat(transfered, "<span class='warning'>You feel a tiny prick!</span>")
	transferer.reagents.trans_to(transfered, transferer.reagents.total_volume, 1, 1, 0)

	var/obj/item/bodypart/L = spikey.checkembedded()

	//this is where it would deal damage, if it transfers chems it removes itself so no damage
	spikey.forceMove(get_turf(L))
	transfered.visible_message("<span class='notice'>[spikey] falls out of [transfered]!</span>")

/datum/mutation/human/nv
	name = "Night Vision"
	desc = "The user of this genome can see well in the dark."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your eyes feel different...</span>"
	instability = 40
	locked = TRUE
	power = /obj/effect/proc_holder/spell/self/nvtoggle

/obj/effect/proc_holder/spell/self/nvtoggle
	name = "Night Vision"
	desc = "Focus really hard to adjust your eyesight."
	clothes_req = NONE
	antimagic_allowed = TRUE
	charge_max = 100
	active = FALSE
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "ling_augmented_eyesight"

/obj/effect/proc_holder/spell/self/nvtoggle/cast(mob/living/carbon/human/user)
	. = ..()
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if(!active)
			ADD_TRAIT(user, TRAIT_TRUE_NIGHT_VISION, GENETIC_MUTATION)
			E.flash_protect = -2 //Adjust the user's eyes' flash protection
			to_chat(user, "You adjust your eyes to see better in the dark.")
			active = TRUE //Defined in code/modules/spells/spell.dm
		else
			REMOVE_TRAIT(user, TRAIT_TRUE_NIGHT_VISION, GENETIC_MUTATION)
			E.flash_protect = 0 //Adjust the user's eyes' flash protection
			to_chat(user, "You adjust your eyes to be less sensitive again.")
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "You don't have eyes!")



	return 1
