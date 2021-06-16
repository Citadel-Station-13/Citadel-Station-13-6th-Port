
/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes
	var/uni_identity
	var/blood_type
	var/datum/species/species = new /datum/species/human //The type of mutant race the player is if applicable (i.e. potato-man)
	var/list/features = list("FFF", "body_size" = RESIZE_DEFAULT_SIZE) //first value is mutant color
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,
	var/nameless = FALSE
	var/custom_species	//siiiiigh I guess this is important
	var/list/mutations = list()   //All mutations are from now on here
	var/list/temporary_mutations = list() //Temporary changes to the UE
	var/list/previous = list() //For temporary name/ui/ue/blood_type modifications
	var/mob/living/holder
	var/delete_species = TRUE //Set to FALSE when a body is scanned by a cloner to fix #38875
	var/mutation_index[DNA_MUTATION_BLOCKS] //List of which mutations this carbon has and its assigned block
	var/default_mutation_genes[DNA_MUTATION_BLOCKS] //List of the default genes from this mutation to allow DNA Scanner highlighting
	var/stability = 100
	var/scrambled = FALSE //Did we take something like mutagen? In that case we cant get our genes scanned to instantly cheese all the powers.
	var/skin_tone_override //because custom skin tones are not found in the skin_tones global list.

/datum/dna/New(mob/living/new_holder)
	if(istype(new_holder))
		holder = new_holder

/datum/dna/Destroy()
	if(iscarbon(holder))
		var/mob/living/carbon/cholder = holder
		if(cholder.dna == src)
			cholder.dna = null
	holder = null

	if(delete_species)
		QDEL_NULL(species)

	mutations.Cut()					//This only references mutations, just dereference.
	temporary_mutations.Cut()		//^
	previous.Cut()					//^

	return ..()

/datum/dna/proc/transfer_identity(mob/living/carbon/destination, transfer_SE = 0)
	if(!istype(destination))
		return
	var/old_size = destination.dna.features["body_size"]
	destination.dna.unique_enzymes = unique_enzymes
	destination.dna.uni_identity = uni_identity
	destination.dna.blood_type = blood_type
	destination.dna.skin_tone_override = skin_tone_override
	destination.dna.features = features.Copy()
	destination.set_species(species.type, icon_update=0)
	destination.dna.species.say_mod = species.say_mod
	destination.dna.real_name = real_name
	destination.dna.nameless = nameless
	destination.dna.custom_species = custom_species
	destination.dna.temporary_mutations = temporary_mutations.Copy()
	if(ishuman(destination))
		var/mob/living/carbon/human/H = destination
		H.give_genitals(TRUE)//This gives the body the genitals of this DNA. Used for any transformations based on DNA
	if(transfer_SE)
		destination.dna.mutation_index = mutation_index
		destination.dna.default_mutation_genes = default_mutation_genes

	destination.dna.update_body_size(old_size)

	SEND_SIGNAL(destination, COMSIG_CARBON_IDENTITY_TRANSFERRED_TO, src, transfer_SE)

/datum/dna/proc/copy_dna(datum/dna/new_dna)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.mutation_index = mutation_index
	new_dna.default_mutation_genes = default_mutation_genes
	new_dna.uni_identity = uni_identity
	new_dna.blood_type = blood_type
	new_dna.skin_tone_override = skin_tone_override
	new_dna.features = features.Copy()
	new_dna.species = new species.type
	new_dna.species.say_mod = species.say_mod
	new_dna.species.exotic_blood_color = species.exotic_blood_color //it can change from the default value
	new_dna.species.eye_type = species.eye_type
	new_dna.species.limbs_id = species.limbs_id || species.id
	new_dna.real_name = real_name
	new_dna.nameless = nameless
	new_dna.custom_species = custom_species
	new_dna.mutations = mutations.Copy()

//See mutation.dm for what 'class' does. 'time' is time till it removes itself in decimals. 0 for no timer
/datum/dna/proc/add_mutation(mutation, class = MUT_OTHER, time)
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/HM = mutation
		mutation_type = HM.type
	if(get_mutation(mutation_type))
		return
	return force_give(new mutation_type (class, time, copymut = mutation))

/datum/dna/proc/remove_mutation(mutation_type)
	return force_lose(get_mutation(mutation_type))

/datum/dna/proc/check_mutation(mutation_type)
	return get_mutation(mutation_type)

/datum/dna/proc/remove_all_mutations(list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	remove_mutation_group(mutations, classes, mutadone)
	scrambled = FALSE

/datum/dna/proc/remove_mutation_group(list/group, list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	if(!group)
		return
	for(var/datum/mutation/human/HM in group)
		if((HM.class in classes) && !(HM.mutadone_proof && mutadone))
			force_lose(HM)

/datum/dna/proc/generate_uni_identity()
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)

	switch(holder.gender)
		if(MALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_MALE, 4)
		if(FEMALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_FEMALE, 4)
		if(PLURAL)
			L[DNA_GENDER_BLOCK] = construct_block(G_PLURAL, 4)
		else
			L[DNA_GENDER_BLOCK] = construct_block(G_NEUTER, 4)
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		if(!GLOB.hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/hair,GLOB.hair_styles_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list)
		L[DNA_HAIR_STYLE_BLOCK] = construct_block(GLOB.hair_styles_list.Find(H.hair_style), GLOB.hair_styles_list.len)
		L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color)
		if(!GLOB.facial_hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
		L[DNA_FACIAL_HAIR_STYLE_BLOCK] = construct_block(GLOB.facial_hair_styles_list.Find(H.facial_hair_style), GLOB.facial_hair_styles_list.len)
		L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color)
		L[DNA_SKIN_TONE_BLOCK] = construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len)
		L[DNA_LEFT_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.left_eye_color)
		L[DNA_RIGHT_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.right_eye_color)
		L[DNA_COLOR_ONE_BLOCK] = sanitize_hexcolor(features["mcolor"], 6)
		L[DNA_COLOR_TWO_BLOCK] = sanitize_hexcolor(features["mcolor2"], 6)
		L[DNA_COLOR_THREE_BLOCK] = sanitize_hexcolor(features["mcolor3"], 6)
		if(!GLOB.mam_tails_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/mam_tails, GLOB.mam_tails_list)
		L[DNA_MUTANTTAIL_BLOCK] = construct_block(GLOB.mam_tails_list.Find(features["mam_tail"]), GLOB.mam_tails_list.len)
		if(!GLOB.mam_ears_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/ears/mam_ears, GLOB.mam_ears_list)
		L[DNA_MUTANTEAR_BLOCK] = construct_block(GLOB.mam_ears_list.Find(features["mam_ears"]), GLOB.mam_ears_list.len)
		if(!GLOB.mam_body_markings_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_body_markings, GLOB.mam_body_markings_list)
		L[DNA_MUTANTMARKING_BLOCK] = construct_block(GLOB.mam_body_markings_list.Find(features["mam_body_markings"]), GLOB.mam_body_markings_list.len)
		if(!GLOB.taur_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/taur, GLOB.taur_list)
		L[DNA_TAUR_BLOCK] = construct_block(GLOB.taur_list.Find(features["taur"]), GLOB.taur_list.len)

	for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
		if(L[i])
			. += L[i]
		else
			. += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	return .

/datum/dna/proc/generate_dna_blocks()
	var/list/mutations_temp = GLOB.good_mutations + GLOB.bad_mutations + GLOB.not_good_mutations
	if(species && species.inert_mutation)
		var/bonus = GET_INITIALIZED_MUTATION(species.inert_mutation)
		if(bonus)
			mutations_temp += bonus
	if(!LAZYLEN(mutations_temp))
		return
	mutation_index.Cut()
	default_mutation_genes.Cut()
	shuffle_inplace(mutations_temp)
	if(ismonkey(holder))
		mutations |= new RACEMUT(MUT_NORMAL)
		mutation_index[RACEMUT] = GET_SEQUENCE(RACEMUT)
	else
		mutation_index[RACEMUT] = create_sequence(RACEMUT, FALSE)
	default_mutation_genes[RACEMUT] = mutation_index[RACEMUT]
	for(var/i in 2 to DNA_MUTATION_BLOCKS)
		var/datum/mutation/human/M = mutations_temp[i]
		mutation_index[M.type] = create_sequence(M.type, FALSE, M.difficulty)
		default_mutation_genes[M.type] = mutation_index[M.type]
	shuffle_inplace(mutation_index)

//Used to generate original gene sequences for every mutation
/proc/generate_gene_sequence(length=4)
	var/static/list/active_sequences = list("AT","TA","GC","CG")
	var/sequence
	for(var/i in 1 to length*DNA_SEQUENCE_LENGTH)
		sequence += pick(active_sequences)
	return sequence

//Used to create a chipped gene sequence
/proc/create_sequence(mutation, active, difficulty)
	if(!difficulty)
		var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(mutation) //leaves the possibility to change difficulty mid-round
		if(!A)
			return
		difficulty = A.difficulty
	difficulty += rand(-2,4)
	var/sequence = GET_SEQUENCE(mutation)
	if(active)
		return sequence
	while(difficulty)
		var/randnum = rand(1, length(sequence))
		sequence = copytext(sequence, 1, randnum) + "X" + copytext(sequence, randnum+1, length(sequence)+1)
		difficulty--
	return sequence

/datum/dna/proc/generate_unique_enzymes()
	. = ""
	if(istype(holder))
		real_name = holder.real_name
		. += md5(holder.real_name)
	else
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, GLOB.hex_characters)
	return .

/datum/dna/proc/update_ui_block(blocknumber)
	if(!blocknumber || !ishuman(holder))
		return
	var/mob/living/carbon/human/H = holder
	switch(blocknumber)
		if(DNA_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.hair_color))
		if(DNA_FACIAL_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.facial_hair_color))
		if(DNA_SKIN_TONE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len))
		if(DNA_LEFT_EYE_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.left_eye_color))
		if(DNA_RIGHT_EYE_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.right_eye_color))
		if(DNA_GENDER_BLOCK)
			switch(H.gender)
				if(MALE)
					setblock(uni_identity, blocknumber, construct_block(G_MALE, 4))
				if(FEMALE)
					setblock(uni_identity, blocknumber, construct_block(G_FEMALE, 4))
				if(PLURAL)
					setblock(uni_identity, blocknumber, construct_block(G_PLURAL, 4))
				else
					setblock(uni_identity, blocknumber, construct_block(G_NEUTER, 4))
		if(DNA_FACIAL_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.facial_hair_styles_list.Find(H.facial_hair_style), GLOB.facial_hair_styles_list.len))
		if(DNA_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.hair_styles_list.Find(H.hair_style), GLOB.hair_styles_list.len))
		if(DNA_COLOR_ONE_BLOCK)
			sanitize_hexcolor(features["mcolor"], 6)
		if(DNA_COLOR_TWO_BLOCK)
			sanitize_hexcolor(features["mcolor2"], 6)
		if(DNA_COLOR_THREE_BLOCK)
			sanitize_hexcolor(features["mcolor3"], 6)
		if(DNA_MUTANTTAIL_BLOCK)
			construct_block(GLOB.mam_tails_list.Find(features["mam_tail"]), GLOB.mam_tails_list.len)
		if(DNA_MUTANTEAR_BLOCK)
			construct_block(GLOB.mam_ears_list.Find(features["mam_ears"]), GLOB.mam_ears_list.len)
		if(DNA_MUTANTMARKING_BLOCK)
			construct_block(GLOB.mam_body_markings_list.Find(features["mam_body_markings"]), GLOB.mam_body_markings_list.len)
		if(DNA_TAUR_BLOCK)
			construct_block(GLOB.taur_list.Find(features["taur"]), GLOB.taur_list.len)
			if(species.mutant_bodyparts["taur"] && ishuman(holder))
				var/datum/sprite_accessory/taur/T = GLOB.taur_list[features["taur"]]
				switch(T?.taur_mode)
					if(STYLE_HOOF_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_SHOE
					if(STYLE_PAW_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CLAW
					if(STYLE_SNEK_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CRAWL
					else
						H.physiology.footstep_type = null

//Please use add_mutation or activate_mutation instead
/datum/dna/proc/force_give(datum/mutation/human/HM)
	if(holder && HM)
		if(HM.class == MUT_NORMAL)
			set_se(1, HM)
		. = HM.on_acquiring(holder)
		if(.)
			qdel(HM)
		update_instability()

//Use remove_mutation instead
/datum/dna/proc/force_lose(datum/mutation/human/HM)
	if(holder && (HM in mutations))
		set_se(0, HM)
		. = HM.on_losing(holder)
		update_instability(FALSE)
		return

/datum/dna/proc/is_same_as(datum/dna/D)
	if(uni_identity != D.uni_identity || mutation_index != D.mutation_index || real_name != D.real_name || nameless != D.nameless || custom_species != D.custom_species)
		return FALSE
	if(species.type != D.species.type || features != D.features || blood_type != D.blood_type || skin_tone_override != D.skin_tone_override)
		return FALSE
	return TRUE

/datum/dna/proc/update_instability(alert=TRUE)
	stability = 100
	for(var/datum/mutation/human/M in mutations)
		if(M.class == MUT_EXTRA)
			stability -= M.instability * GET_MUTATION_STABILIZER(M)
	if(holder)
		var/message
		if(alert)
			switch(stability)
				if(70 to 90)
					message = "<span class='warning'>You shiver.</span>"
				if(60 to 69)
					message = "<span class='warning'>You feel cold.</span>"
				if(40 to 59)
					message = "<span class='warning'>You feel sick.</span>"
				if(20 to 39)
					message = "<span class='warning'>It feels like your skin is moving.</span>"
				if(1 to 19)
					message = "<span class='warning'>You can feel your cells burning.</span>"
				if(-INFINITY to 0)
					message = "<span class='boldwarning'>You can feel your DNA exploding, we need to do something fast!</span>"
		if(stability <= 0)
			holder.apply_status_effect(STATUS_EFFECT_DNA_MELT)
		if(message)
			to_chat(holder, message)


//used to update dna UI, UE, and dna.real_name.
/datum/dna/proc/update_dna_identity()
	uni_identity = generate_uni_identity()
	unique_enzymes = generate_unique_enzymes()

/datum/dna/proc/initialize_dna(newblood_type, skip_index = FALSE)
	if(newblood_type)
		blood_type = newblood_type
	unique_enzymes = generate_unique_enzymes()
	uni_identity = generate_uni_identity()
	if(!skip_index) //I hate this
		generate_dna_blocks()
	features = random_features(species?.id, holder?.gender)


/datum/dna/stored //subtype used by brain mob's stored_dna

/datum/dna/stored/add_mutation(mutation_name) //no mutation changes on stored dna.
	return

/datum/dna/stored/remove_mutation(mutation_name)
	return

/datum/dna/stored/check_mutation(mutation_name)
	return

/datum/dna/stored/remove_all_mutations(list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	return

/datum/dna/stored/remove_mutation_group(list/group, list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	return

/////////////////////////// DNA MOB-PROCS //////////////////////

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	return

/mob/living/brain/set_species(datum/species/mrace, icon_update = 1)
	if(mrace)
		if(ispath(mrace))
			stored_dna.species = new mrace()
		else
			stored_dna.species = mrace //not calling any species update procs since we're a brain, not a monkey/human


/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	if(mrace && has_dna())
		var/datum/species/new_race
		if(ispath(mrace))
			new_race = new mrace
		else if(istype(mrace))
			new_race = mrace
		else
			return
		dna.species.on_species_loss(src, new_race, pref_load)
		var/datum/species/old_species = dna.species
		dna.species = new_race
		dna.species.on_species_gain(src, old_species, pref_load)
		if(ishuman(src))
			qdel(language_holder)
			var/species_holder = initial(mrace.species_language_holder)
			language_holder = new species_holder(src)
		update_atom_languages()

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	..()
	if(icon_update)
		update_body()
		update_hair()
		update_body_parts()
		update_mutations_overlay()// no lizard with human hulk overlay please.


/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna


/mob/living/carbon/human/proc/hardset_dna(ui, list/mutation_index, newreal_name, newblood_type, datum/species/mrace, newfeatures, list/default_mutation_genes)

	if(newreal_name)
		real_name = newreal_name
		dna.generate_unique_enzymes()

	if(newblood_type)
		dna.blood_type = newblood_type

	if(ui)
		dna.uni_identity = ui
		updateappearance(icon_update=FALSE)

	if(newfeatures)
		var/old_size = dna.features["body_size"]
		dna.features = newfeatures
		dna.update_body_size(old_size)

	if(mrace)
		var/datum/species/newrace = new mrace.type
		newrace.copy_properties_from(mrace)
		set_species(newrace, icon_update=FALSE)

	if(LAZYLEN(mutation_index))
		dna.mutation_index = mutation_index.Copy()
		if(LAZYLEN(default_mutation_genes))
			dna.default_mutation_genes = default_mutation_genes.Copy()
		else
			dna.default_mutation_genes = mutation_index.Copy()
		domutcheck()

	SEND_SIGNAL(src, COMSIG_HUMAN_HARDSET_DNA, ui, mutation_index, newreal_name, newblood_type, mrace, newfeatures)

	if(mrace || newfeatures || ui)
		update_body()
		update_hair()
		update_body_parts()
		update_mutations_overlay()


/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	if(!dna.species)
		var/rando_race = pick(GLOB.roundstart_races)
		dna.species = new rando_race()

//proc used to update the mob's appearance after its dna UI has been changed
/mob/living/carbon/proc/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	if(!has_dna())
		return

	switch(deconstruct_block(getblock(dna.uni_identity, DNA_GENDER_BLOCK), 4))
		if(G_MALE)
			set_gender(MALE, TRUE, forced = TRUE)
		if(G_FEMALE)
			set_gender(FEMALE, TRUE, forced = TRUE)
		if(G_PLURAL)
			set_gender(PLURAL, TRUE, forced = TRUE)
		else
			set_gender(NEUTER, TRUE, forced = TRUE)

/mob/living/carbon/human/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	var/structure = dna.uni_identity
	hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
	facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
	skin_tone = dna.skin_tone_override || GLOB.skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), GLOB.skin_tones.len)]
	left_eye_color = sanitize_hexcolor(getblock(structure, DNA_LEFT_EYE_COLOR_BLOCK))
	right_eye_color = sanitize_hexcolor(getblock(structure, DNA_RIGHT_EYE_COLOR_BLOCK))
	facial_hair_style = GLOB.facial_hair_styles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIR_STYLE_BLOCK), GLOB.facial_hair_styles_list.len)]
	hair_style = GLOB.hair_styles_list[deconstruct_block(getblock(structure, DNA_HAIR_STYLE_BLOCK), GLOB.hair_styles_list.len)]
	if(icon_update)
		update_body()
		update_hair()
		if(mutcolor_update)
			update_body_parts()
		if(mutations_overlay_update)
			update_mutations_overlay()


/mob/proc/domutcheck()
	return

/mob/living/carbon/domutcheck()
	if(!has_dna())
		return

	for(var/mutation in dna.mutation_index)
		if(ismob(dna.check_block(mutation)))
			return //we got monkeyized/humanized, this mob will be deleted, no need to continue.

	update_mutations_overlay()

/datum/dna/proc/check_block(mutation)
	var/datum/mutation/human/HM = get_mutation(mutation)
	if(check_block_string(mutation))
		if(!HM)
			. = add_mutation(mutation, MUT_NORMAL)
		return
	return force_lose(HM)

//Return the active mutation of a type if there is one
/datum/dna/proc/get_mutation(A)
	for(var/datum/mutation/human/HM in mutations)
		if(HM.type == A)
			return HM

/datum/dna/proc/check_block_string(mutation)
	if((LAZYLEN(mutation_index) > DNA_MUTATION_BLOCKS) || !(mutation in mutation_index))
		return 0
	return is_gene_active(mutation)

/datum/dna/proc/is_gene_active(mutation)
	return (mutation_index[mutation] == GET_SEQUENCE(mutation))

/datum/dna/proc/set_se(on=TRUE, datum/mutation/human/HM)
	if(!HM || !(HM.type in mutation_index) || (LAZYLEN(mutation_index) < DNA_MUTATION_BLOCKS))
		return
	. = TRUE
	if(on)
		mutation_index[HM.type] = GET_SEQUENCE(HM.type)
		default_mutation_genes[HM.type] = mutation_index[HM.type]
	else if(GET_SEQUENCE(HM.type) == mutation_index[HM.type])
		mutation_index[HM.type] = create_sequence(HM.type, FALSE, HM.difficulty)
		default_mutation_genes[HM.type] = mutation_index[HM.type]


/datum/dna/proc/activate_mutation(mutation) //note that this returns a boolean and not a new mob
	if(!mutation)
		return FALSE
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/M = mutation
		mutation_type = M.type
	if(!mutation_in_sequence(mutation_type)) //cant activate what we dont have, use add_mutation
		return FALSE
	add_mutation(mutation, MUT_NORMAL)
	return TRUE



/////////////////////////// DNA HELPER-PROCS //////////////////////////////

/proc/getleftblocks(input,blocknumber,blocksize)
	if(blocknumber > 1)
		return copytext_char(input,1,((blocksize*blocknumber)-(blocksize-1)))

/proc/getrightblocks(input,blocknumber,blocksize)
	if(blocknumber < (length(input)/blocksize))
		return copytext_char(input,blocksize*blocknumber+1,length(input)+1)

/proc/getblock(input, blocknumber, blocksize=DNA_BLOCK_SIZE)
	return copytext_char(input, blocksize*(blocknumber-1)+1, (blocksize*blocknumber)+1)

/proc/setblock(istring, blocknumber, replacement, blocksize=DNA_BLOCK_SIZE)
	if(!istring || !blocknumber || !replacement || !blocksize)
		return 0
	return getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)

/datum/dna/proc/mutation_in_sequence(mutation)
	if(!mutation)
		return
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/HM = mutation
		if(HM.type in mutation_index)
			return TRUE
	else if(mutation in mutation_index)
		return TRUE

/mob/living/carbon/proc/randmut(list/candidates, difficulty = 2)
	if(!has_dna())
		return
	var/mutation = pick(candidates)
	. = dna.add_mutation(mutation)

/mob/living/carbon/proc/easy_randmut(quality = POSITIVE + NEGATIVE + MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, exclude_monkey = TRUE)
	if(!has_dna())
		return
	var/list/mutations = list()
	if(quality & POSITIVE)
		mutations += GLOB.good_mutations
	if(quality & NEGATIVE)
		mutations += GLOB.bad_mutations
	if(quality & MINOR_NEGATIVE)
		mutations += GLOB.not_good_mutations
	var/list/possible = list()
	for(var/datum/mutation/human/A in mutations)
		if((!sequence || dna.mutation_in_sequence(A.type)) && !dna.get_mutation(A.type))
			possible += A.type
	if(exclude_monkey)
		possible.Remove(RACEMUT)
	if(LAZYLEN(possible))
		var/mutation = pick(possible)
		. = dna.activate_mutation(mutation)
		if(scrambled)
			var/datum/mutation/human/HM = dna.get_mutation(mutation)
			if(HM)
				HM.scrambled = TRUE
		return TRUE


/mob/living/carbon/proc/randmuti()
	if(!has_dna())
		return
	var/num = rand(1, DNA_UNI_IDENTITY_BLOCKS)
	var/newdna = setblock(dna.uni_identity, num, random_string(DNA_BLOCK_SIZE, GLOB.hex_characters))
	dna.uni_identity = newdna
	updateappearance(mutations_overlay_update=1)

/mob/living/carbon/proc/clean_dna()
	if(!has_dna())
		return
	dna.remove_all_mutations()

/mob/living/carbon/proc/clean_randmut(list/candidates, difficulty = 2)
	clean_dna()
	randmut(candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, probability)
	if(!M.has_dna())
		return 0
	if(se)
		for(var/i=1, i<=DNA_MUTATION_BLOCKS, i++)
			if(prob(probability))
				M.dna.generate_dna_blocks()
		M.domutcheck()
	if(ui)
		for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
			if(prob(probability))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, random_string(DNA_BLOCK_SIZE, GLOB.hex_characters))
		M.updateappearance(mutations_overlay_update=1)
	return 1

//value in range 1 to values. values must be greater than 0
//all arguments assumed to be positive integers
/proc/construct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	if(value < 1)
		value = 1
	value = (value * width) - rand(1,width)
	return num2hex(value, blocksize)

//value is hex
/proc/deconstruct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	value = round(hex2num(value) / width) + 1
	if(value > values)
		value = values
	return value

/////////////////////////// DNA HELPER-PROCS

/mob/living/carbon/human/proc/something_horrible()
	if(!has_dna()) //shouldn't ever happen anyway so it's just in really weird cases
		return
	if(dna.stability > 0)
		return
	var/instability = - dna.stability
	dna.remove_all_mutations()
	dna.stability = 100
	if(prob(max(70 - instability,0)))
		switch(rand(0,3)) //not complete and utter death
			if(0)
				monkeyize()
			if(1)
				gain_trauma(/datum/brain_trauma/severe/paralysis)
			if(2)
				unequip_everything()
				drop_all_held_items()
				corgize()
			if(3)
				to_chat(src, "<span class='notice'>Oh, we actually feel quite alright!</span>")
	else
		switch(rand(0,3))
			if(0)
				unequip_everything()
				drop_all_held_items()
				gib()
			if(1)
				unequip_everything()
				drop_all_held_items()
				dust()
			if(2)
				unequip_everything()
				drop_all_held_items()
				death()
				petrify(INFINITY)
			if(3)
				if(prob(90))
					var/obj/item/bodypart/BP = get_bodypart(pick(BODY_ZONE_CHEST,BODY_ZONE_HEAD))
					if(BP)
						BP.dismember()
					else
						unequip_everything()
						drop_all_held_items()
						gib()
				else
					if(!isdullahan(src))
						AddComponent(/datum/component/dullahan)
					else
						gib()

/datum/dna/proc/update_body_size(old_size)
	if(!holder || features["body_size"] == old_size)
		return
	//new size detected
	holder.resize = features["body_size"] / old_size
	holder.update_transform()
	if(iscarbon(holder))
		var/mob/living/carbon/C = holder
		var/penalty_threshold = CONFIG_GET(number/threshold_body_size_penalty)
		if(features["body_size"] < penalty_threshold && old_size >= penalty_threshold)
			C.maxHealth -= 10 //reduce the maxhealth
			var/slowdown = (1 - round(features["body_size"] / penalty_threshold, 0.1)) * CONFIG_GET(number/body_size_slowdown_multiplier)
			holder.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/small_stride, TRUE, slowdown)
		else
			if(old_size < penalty_threshold && features["body_size"] >= penalty_threshold)
				C.maxHealth  += 10 //give the maxhealth back
				holder.remove_movespeed_modifier(/datum/movespeed_modifier/small_stride) //remove the slowdown


