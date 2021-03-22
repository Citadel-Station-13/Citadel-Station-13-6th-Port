/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female, roundstart = FALSE, skip_prototype = TRUE)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()

	for(var/path in typesof(prototype))
		if(path == prototype && skip_prototype)
			continue
		if(roundstart)
			var/datum/sprite_accessory/P = path
			if(initial(P.locked))
				continue
		var/datum/sprite_accessory/D = new path()

		if(D.icon_state)
			L[D.name] = D
		else
			L += D.name

		switch(D.gender)
			if(MALE)
				male += D.name
			if(FEMALE)
				female += D.name
			else
				male += D.name
				female += D.name
	return L

/datum/sprite_accessory
	var/icon			//the icon file the accessory is located in
	var/icon_state		//the icon_state of the accessory
	var/name			//the preview name of the accessory
	var/gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations
	var/gender_specific //Something that can be worn by either gender, but looks different on each
	var/color_src = MUTCOLORS	//Currently only used by mutantparts so don't worry about hair and stuff. This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	var/locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects
	var/dimension_x = 32
	var/dimension_y = 32
	var/center = FALSE	//Should we center the sprite?
	var/list/relevant_layers //list of layers that this accessory uses. As of now only used in species.handle_mutant_bodyparts(), but that's where most sprite accessories are anyway.
	var/mutant_part_string //Also used in species.handle_mutant_bodyparts() to generate the overlay icon state.
	var/alpha_mask_state
	var/matrixed_sections = MATRIX_NONE //if color_src is MATRIXED, how many sections does it have? 1-3

	//Special / holdover traits for Citadel specific sprites.
	var/extra = FALSE
	var/extra_color_src = MUTCOLORS2						//The color source for the extra overlay.
	var/extra2 = FALSE
	var/extra2_color_src = MUTCOLORS3

	//for snowflake/donor specific sprites
	var/list/ckeys_allowed

	//For soft-restricting markings to species IDs
	var/list/recommended_species

/datum/sprite_accessory/proc/is_not_visible(var/mob/living/carbon/human/H, var/tauric) //return if the accessory shouldn't be shown
	return FALSE

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	var/has_color = FALSE
	var/has_digitigrade = FALSE
	var/body_parts_covered = NONE
