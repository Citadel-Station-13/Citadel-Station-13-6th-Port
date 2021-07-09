/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/max_streak_length = 6
	var/id = "" //ID, used by mind/has_martialartcode\game\objects\items\granters.dm:345:error: user.mind.has_martialart: undefined proccode\game\objects\items\granters.dm:345:error: user.mind.has_martialart: undefined proccode\game\objects\items\granters.dm:345:error: user.mind.has_martialart: undefined proccode\game\objects\items\granters.dm:345:error: user.mind.has_martialart: undefined proccode\game\objects\items\granters.dm:345:error: user.mind.has_martialart: undefined proc
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/help_verb
	var/pacifism_check = TRUE //are the martial arts combos/attacks unable to be used by pacifist.
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
	/// Can we be used to unarmed parry?
	var/can_martial_parry = FALSE
	/// Set this variable to something not null, this'll be the preferred unarmed parry in most cases if [can_martial_parry] is TRUE. YOU MUST RUN [get_block_parry_data(this)] INSTEAD OF DIRECTLY ACCESSING!
	var/datum/block_parry_data/block_parry_data
	var/pugilist = FALSE

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

/datum/martial_art/proc/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		reset_streak(D)
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	return

/datum/martial_art/proc/reset_streak(mob/living/carbon/human/new_target)
	current_target = new_target
	streak = ""

/datum/martial_art/proc/damage_roll(mob/living/carbon/human/A, mob/living/carbon/human/D)
	//Here we roll for our damage to be added into the damage var in the various attack procs. This is changed depending on whether we are in combat mode, lying down, or if our target is in combat mode.
	var/damage = A.rand_good(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
	if(!CHECK_MOBILITY(A, MOBILITY_STAND))
		damage *= 0.7
	return damage

/datum/martial_art/proc/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	if(!istype(H) || !H.mind)
		return FALSE
	if(H.mind.martial_art)
		if(make_temporary)
			if(!H.mind.martial_art.allow_temp_override)
				return FALSE
			store(H.mind.martial_art,H)
		else
			H.mind.martial_art.on_remove(H)
	else if(make_temporary)
		base = H.mind.default_martial_art
	if(help_verb)
		add_verb(H, help_verb)
	H.mind.martial_art = src
	if(pugilist)
		ADD_TRAIT(H, TRAIT_PUGILIST, MARTIAL_ARTIST_TRAIT)
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/M,mob/living/carbon/human/H)
	M.on_remove(H)
	if(M.base) //Checks if M is temporary, if so it will not be stored.
		base = M.base
	else //Otherwise, M is stored.
		base = M

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind || H.mind.martial_art != src)
		return
	on_remove(H)
	if(base)
		base.teach(H)
	else
		var/datum/martial_art/X = H.mind.default_martial_art
		X.teach(H)
	REMOVE_TRAIT(H, TRAIT_PUGILIST, MARTIAL_ARTIST_TRAIT)

/datum/martial_art/proc/on_remove(mob/living/carbon/human/H)
	if(help_verb)
		remove_verb(H, help_verb)
	return

///Gets called when a projectile hits the owner. Returning anything other than BULLET_ACT_HIT will stop the projectile from hitting the mob.
/datum/martial_art/proc/on_projectile_hit(mob/living/carbon/human/A, obj/item/projectile/P, def_zone)
	return BULLET_ACT_HIT
