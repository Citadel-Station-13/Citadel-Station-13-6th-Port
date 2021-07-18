#define SUMMON_POSSIBILITIES 3

/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	threat = 3
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	job_rank = ROLE_CULTIST
	var/ignore_implant = FALSE
	var/make_team = TRUE
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team
	var/neutered = FALSE			//can not use round ending, gibbing, converting, or similar things with unmatched round impact
	var/ignore_eligibility_checks = FALSE
	var/ignore_holy_water = FALSE

/datum/antagonist/cult/neutered
	name = "Neutered Cultist"
	neutered = TRUE

/datum/antagonist/cult/neutered/traitor
	name = "Traitor Cultist"
	ignore_eligibility_checks = TRUE
	ignore_holy_water = TRUE
	show_in_roundend = FALSE
	make_team = FALSE

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team && make_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(make_team && !istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
//ambition start
	if(cult_team)
		objectives |= cult_team.objectives
//ambition end

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	QDEL_NULL(vote)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(. && !ignore_implant && !ignore_eligibility_checks)
		. = is_convertable_to_cult(new_owner.current,cult_team)

/datum/antagonist/cult/greet()
	to_chat(owner, "<span class='userdanger'>You are a member of the cult!</span>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	if(give_equipment)
		equip_cultist(TRUE)
	SSticker.mode.cult += owner // Only add after they've been given objectives
	SSticker.mode.update_cult_icons_added(owner)
	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color="#960000")

	if(cult_team?.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image


/datum/antagonist/cult/proc/equip_cultist(metal=TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	if (owner.assigned_role == "Clown")
		to_chat(owner, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
		H.dna.remove_mutation(CLOWNMUT)
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(owner, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")


/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots, critical = TRUE)
	if(!where)
		to_chat(mob, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return 0
	else
		to_chat(mob, "<span class='danger'>You have a [item_name] in your [where].</span>")
		if(where == "backpack")
			SEND_SIGNAL(mob.back, COMSIG_TRY_STORAGE_SHOW, mob)
		return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction |= "cult"
	current.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	if(!cult_team?.cult_master)
		vote.Grant(current)
	communion.Grant(current)
	if(ishuman(current))
		magic.Grant(current)
	current.throw_alert("bloodsense", /obj/screen/alert/bloodsense)
	if(cult_team?.cult_risen)
		cult_team.rise(current)
		if(cult_team.cult_ascendent)
			cult_team.ascend(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "cult"
	current.remove_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	vote.Remove(current)
	communion.Remove(current)
	magic.Remove(current)
	current.clear_alert("bloodsense")
	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
		H.left_eye_color = eyes?.left_eye_color || initial(H.left_eye_color)
		H.right_eye_color = eyes?.right_eye_color || initial(H.right_eye_color)
		H.dna?.update_ui_block(DNA_LEFT_EYE_COLOR_BLOCK)
		H.dna?.update_ui_block(DNA_RIGHT_EYE_COLOR_BLOCK)
		REMOVE_TRAIT(H, TRAIT_CULT_EYES, "valid_cultist")
		H.update_body()
		H.cut_overlays()
		H.regenerate_icons()

/datum/antagonist/cult/on_removal()
	SSticker.mode.cult -= owner
	SSticker.mode.update_cult_icons_removed(owner)
	if(!silent)
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!</span>", null, null, null, owner.current)
		to_chat(owner.current, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant.</span>")
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color="#960000")
	if(cult_team?.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image
	. = ..()

/datum/antagonist/cult/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has cult'ed [new_owner.current].")
	log_admin("[key_name(admin)] has cult'ed [new_owner.current].")

/datum/antagonist/cult/admin_remove(mob/user)
	message_admins("[key_name_admin(user)] has decult'ed [owner.current].")
	log_admin("[key_name(user)] has decult'ed [owner.current].")
	SSticker.mode.remove_cultist(owner,silent=TRUE) //disgusting

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src,.proc/admin_give_dagger)
	.["Dagger and Metal"] = CALLBACK(src,.proc/admin_give_metal)

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(FALSE))
		to_chat(admin, "<span class='danger'>Spawning dagger failed!</span>")

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(TRUE))
		to_chat(admin, "<span class='danger'>Spawning runed metal failed!</span>")

/datum/antagonist/cult/master
	ignore_implant = TRUE
	show_in_antagpanel = FALSE //Feel free to add this later
	var/datum/action/innate/cult/master/finalreck/reckoning = new
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new

/datum/antagonist/cult/master/Destroy()
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/master/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	set_antag_hud(current, "cultmaster")

/datum/antagonist/cult/master/greet()
	to_chat(owner.current, "<span class='cultlarge'>You are the cult's Master</span>. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>.")
	to_chat(owner.current, "Use these abilities to direct the cult to victory at any cost.")

/datum/antagonist/cult/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(!cult_team.reckoning_complete)
		reckoning.Grant(current)
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_action_buttons_icon()
	current.apply_status_effect(/datum/status_effect/cult_master)
	if(cult_team?.cult_risen)
		cult_team.rise(current)
		if(cult_team.cult_ascendent)
			cult_team.ascend(current)

/datum/antagonist/cult/master/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	reckoning.Remove(current)
	bloodmark.Remove(current)
	throwing.Remove(current)
	current.update_action_buttons_icon()
	current.remove_status_effect(/datum/status_effect/cult_master)

	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		H.left_eye_color = initial(H.left_eye_color)
		H.right_eye_color = initial(H.right_eye_color)
		H.dna?.update_ui_block(DNA_LEFT_EYE_COLOR_BLOCK)
		H.dna?.update_ui_block(DNA_RIGHT_EYE_COLOR_BLOCK)
		REMOVE_TRAIT(H, TRAIT_CULT_EYES, "valid_cultist")
		H.cut_overlays()
		H.regenerate_icons()

/datum/team/cult
	name = "Cult"

	var/blood_target
	var/image/blood_target_image
	var/blood_target_reset_timer

	var/cult_vote_called = FALSE
	var/mob/living/cult_master
	var/reckoning_complete = FALSE
	var/cult_risen = FALSE
	var/cult_ascendent = FALSE

/datum/team/cult/New()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/team/cult/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/team/cult/process()
	if(SSticker.current_state == GAME_STATE_FINISHED)
		return
	var/datum/objective/sacrifice/sac_objective = locate() in objectives
	if(!sac_objective || sac_objective.check_completion())
		return
	var/datum/mind/sacrificial = sac_objective.get_target()
	var/mob/living/sac_current = sacrificial.current
	if(!sacrificial || !sac_current) //target is gone for good but not sacrified.
		sort_sacrifice(TRUE)
		return
	if(QDELETED(sac_objective.target_current) || sac_objective.target_current != sac_current) //target is now a different mob (monkey, simple mob)
		sac_objective.sac_image = sac_current.get_sac_image()
		sac_objective.target_current = sac_current
		sac_objective.update_explanation_text()

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(iscultist(M))
				++cultplayers
			else
				++alive
	if(!alive)
		return
	var/ratio = cultplayers/alive
	if(ratio > CULT_RISEN && !cult_risen)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/i_see_you2.ogg')
				to_chat(B.current, "<span class='cultlarge'>The veil weakens as your cult grows, your eyes begin to glow...")
				addtimer(CALLBACK(src, .proc/rise, B.current), 200)
		cult_risen = TRUE

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, "<span class='cultlarge'>Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")
				addtimer(CALLBACK(src, .proc/ascend, B.current), 200)
		cult_ascendent = TRUE


/datum/team/cult/proc/rise(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		H.left_eye_color = "f00"
		H.right_eye_color = "f00"
		H.dna?.update_ui_block(DNA_LEFT_EYE_COLOR_BLOCK)
		H.dna?.update_ui_block(DNA_RIGHT_EYE_COLOR_BLOCK)
		ADD_TRAIT(H, TRAIT_CULT_EYES, "valid_cultist")
		H.update_body()

/datum/team/cult/proc/ascend(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
		var/istate = pick("halo1","halo2","halo3","halo4","halo5","halo6")
		H.add_overlay(mutable_appearance('icons/effects/32x64.dmi', istate, -ANTAG_LAYER))

/datum/team/cult/proc/setup_objectives()
	//SAC OBJECTIVE , todo: move this to objective internals
	sort_sacrifice()
	//SUMMON OBJECTIVE
	var/datum/objective/eldergod/summon_objective = new()
	summon_objective.team = src
	objectives += summon_objective

/datum/team/cult/proc/sort_sacrifice(replacement = FALSE)

	var/list/target_candidates = list()

	var/datum/objective/sacrifice/sac_objective = locate() in GLOB.objectives
	if(!sac_objective)
		sac_objective = new
		sac_objective.team = src

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && !is_convertable_to_cult(player) && player.stat != DEAD)
			target_candidates += player.mind

	if(!length(target_candidates))
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && player.stat != DEAD)
				target_candidates += player.mind

	listclearnulls(target_candidates)
	if(!LAZYLEN(target_candidates))
		message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. Proceeding to next stage!")
		sac_objective.sacced = TRUE
		return
	var/datum/mind/new_target = pick(target_candidates)
	if(replacement)
		for(var/datum/mind/H in members)
			if(H.current)
				to_chat(H.current, "<span class='danger'>Nar'Sie</span> murmurs, <span class='cultlarge'>[sac_objective.target] is beyond your reach. Sacrifice [new_target] instead...</span></span>")
	sac_objective.target = new_target
	sac_objective.target_current = new_target.current
	sac_objective.update_explanation_text()

	sac_objective.sac_image = sac_objective.target_current.get_sac_image()
	objectives += sac_objective

/mob/proc/get_sac_image()
	var/icon/reshape = icon(icon, icon_state, SOUTH)
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	return reshape

/mob/living/carbon/human/get_sac_image()
	var/datum/job/sacjob = SSjob.GetJob(mind.assigned_role)
	var/datum/preferences/sacface = client.prefs
	var/icon/reshape = get_flat_human_icon(null, sacjob, sacface, list(SOUTH))
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	return reshape

/datum/objective/sacrifice
	var/sacced = FALSE
	var/sac_image
	var/mob/living/target_current

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/update_explanation_text()
	if(target)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking a Sacrifice rune with [target.p_them()] on it and three acolytes around it."
	else
		explanation_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(GLOB.sortedAreas - summon_spots)
		if(summon && is_station_level(summon.z) && (summon.area_flags & VALID_TERRITORY))
			summon_spots += summon
		sanity++
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon Nar'Sie by invoking the rune 'Summon Nar'Sie'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	return summoned || completed

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE
	return TRUE

/datum/team/cult/roundend_report()
	var/list/parts = list()

	if(check_cult_victory())
		parts += "<span class='greentext big'>The cult has succeeded! Nar'Sie has snuffed out another torch in the void!</span>"
	else
		parts += "<span class='redtext big'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>"

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.completable)
				var/completion = objective.check_completion()
				if(completion >= 1)
					parts += "<B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'><B>Success!</B></span>"
				else if(completion <= 0)
					parts += "<B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				else
					parts += "<B>Objective #[count]</B>: [objective.explanation_text] <span class='yellowtext'>[completion*100]%</span>"
			else
				parts += "<B>Objective #[count]</B>: [objective.explanation_text]"
			count++

	if(members.len)
		parts += "<span class='header'>The cultists were:</span>"
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/cult/is_gamemode_hero()
	return SSticker.mode.name == "cult"
