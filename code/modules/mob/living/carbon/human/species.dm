// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)
GLOBAL_LIST_EMPTY(roundstart_race_names)

/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	///If the game needs to manually check your race to do something not included in a proc here, it will use this.
	var/id
	//This is used if you want to use a different species' limb sprites.
	var/limbs_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	// Default color. If mutant colors are disabled, this is the color that will be used by that race.
	var/default_color = "#FFF"

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE
	var/has_field_of_vision = TRUE

	///Clothing offsets. If a species has a different body than other species, you can offset clothing so they look less weird.
	var/list/offset_features = list(
		OFFSET_UNIFORM = list(0,0),
		OFFSET_ID = list(0,0),
		OFFSET_GLOVES = list(0,0),
		OFFSET_GLASSES = list(0,0),
		OFFSET_EARS = list(0,0),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,0),
		OFFSET_HEAD = list(0,0),
		OFFSET_EYES = list(0,0),
		OFFSET_LIPS = list(0,0),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,0),
		OFFSET_HAIR = list(0,0),
		OFFSET_FHAIR = list(0,0),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,0),
		OFFSET_MUTPARTS = list(0,0)
		)

	///This allows races to have specific hair colors. If null, it uses the H's hair/facial hair colors. If "mutcolor", it uses the H's mutant_color. If "fixedmutcolor", it uses fixedmutcolor
	var/hair_color
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255

	///Does the species use skintones or not? As of now only used by humans.
	var/use_skintones = FALSE
	///If your race bleeds something other than bog standard blood, change this to reagent id. For example, ethereals bleed liquid electricity.
	var/exotic_blood = ""
	///If your race uses a non standard bloodtype (A+, O-, AB-, etc). For example, lizards have L type blood.
	var/exotic_bloodtype = ""
	/// Assume human as the default blood colour, override this default by species subtypes
	var/exotic_blood_color = BLOOD_COLOR_HUMAN
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/reagent_containers/food/snacks/meat/slab/human //What the species drops on gibbing
	var/list/gib_types = list(/obj/effect/gibspawner/human, /obj/effect/gibspawner/human/bodypartless)
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///Bitfield for food types that the species likes, giving them a mood boost. Lizards like meat, for example.
	var/liked_food = NONE
	///Bitfield for food types that the species dislikes, giving them disgust. Humans hate raw food, for example.
	var/disliked_food = GROSS
	///Bitfield for food types that the species absolutely hates, giving them even more disgust than disliked food. Meat is "toxic" to moths, for example.
	var/toxic_food = TOXIC
	///Inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/list/no_equip = list()
	/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
	var/nojumpsuit = FALSE
	var/blacklisted = 0 //Flag to exclude from green slime core species.
	var/dangerous_existence //A flag for transformation spells that tells them "hey if you turn a person into one of these without preperation, they'll probably die!"
	///Affects the speech message, for example: Motharula flutters, "My speech message is flutters!"
	var/say_mod = "says"
	///What languages this species can understand and say. Use a [language holder datum][/datum/language_holder] in this var.
	var/species_language_holder = /datum/language_holder
	/**
	  * Visible CURRENT bodyparts that are unique to a species.
	  * DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK
	  * SHIT UP! Changes to this list for non-species specific bodyparts (ie
	  * cat ears and tails) should be assigned at organ level if possible.
	  * Assoc values are defaults for given bodyparts, also modified by aforementioned organs.
	  * They also allow for faster '[]' list access versus 'in'. Other than that, they are useless right now.
	  * Layer hiding is handled by [/datum/species/proc/handle_mutant_bodyparts] below.
	  */
	var/list/mutant_bodyparts = list()
	///Internal organs that are unique to this race, like a tail.
	var/list/mutant_organs = list()
	///Multiplier for the race's speed. Positive numbers make it move slower, negative numbers make it move faster.
	var/speedmod = 0
	///Percentage modifier for overall defense of the race, or less defense, if it's negative.
	var/armor = 0
	///multiplier for brute damage
	var/brutemod = 1
	///multiplier for burn damage
	var/burnmod = 1
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for money paid at payday
	var/payday_modifier = 1
	///Type of damage attack does. Ethereals attack with burn damage for example.
	var/attack_type = BRUTE	// multiplier for stun duration
	///Lowest possible punch damage this species can give. If this is set to 0, punches will always miss.
	var/punchdamagelow = 1
	///Highest possible punch damage this species can give.
	var/punchdamagehigh = 10
	///Damage at which punches from this race will stun
	var/punchstunthreshold = 10 //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/punchwoundbonus = 0 // additional wound bonus. generally zero.
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///What kind of damage overlays (if any) appear on our species when wounded? If this is "", does not add an overlay.
	var/damage_overlay_type = "human"
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = DWARFISM
	///Sounds to override barefeet walking
	var/list/special_step_sounds
	///Special sound for grabbing
	var/grab_sound
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	///Species-only traits. Can be found in [code/__DEFINES/DNA.dm]
	var/list/species_traits = list(HAS_FLESH,HAS_BONE) //by default they can scar and have bones/flesh unless set to something else
	///Generic traits tied to having the species.
	var/list/inherent_traits = list() //list(TRAIT_ADVANCEDTOOLUSER)
	/// List of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID

	var/list/blacklisted_quirks = list() // Quirks that will be removed upon gaining this species, to be defined by species
	var/list/removed_quirks = list() // Quirks that got removed due to being blacklisted, and will be restored when on_species_loss() is called

	///Punch-specific attack verb.
	var/attack_verb = "punch"
	///
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/attack_sound_override = null

	var/list/mob/living/ignored_by = list()	// list of mobs that will ignore this species
	//Breathing!
	var/obj/item/organ/lungs/mutantlungs = null
	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = "o2"

	//Do NOT remove by setting to null. use OR make a RESPECTIVE TRAIT (removing stomach? add the NOSTOMACH trait to your species)
	//why does it work this way? because traits also disable the downsides of not having an organ, removing organs but not having the trait will make your species die

	///Replaces default brain with a different organ
	var/obj/item/organ/brain/mutant_brain = /obj/item/organ/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/heart/mutant_heart = /obj/item/organ/heart
	///Replaces default lungs with a different organ
	// var/obj/item/organ/lungs/mutantlungs = /obj/item/organ/lungs
	///Replaces default eyes with a different organ
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	///Replaces default ears with a different organ
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	///Replaces default tongue with a different organ
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	///Replaces default liver with a different organ
	var/obj/item/organ/liver/mutantliver = /obj/item/organ/liver
	///Replaces default stomach with a different organ
	var/obj/item/organ/stomach/mutantstomach = /obj/item/organ/stomach
	///Replaces default appendix with a different organ.
	var/obj/item/organ/appendix/mutantappendix = /obj/item/organ/appendix
	///Forces an item into this species' hands. Only an honorary mutantthing because this is not an organ and not loaded in the same way, you've been warned to do your research.
	var/obj/item/mutanthands

	/// CIT SPECIFIC Mutant tail
	var/obj/item/organ/tail/mutanttail = null

	var/override_float = FALSE

	//Citadel snowflake
	var/fixed_mut_color2 = ""
	var/fixed_mut_color3 = ""
	var/whitelisted = 0 		//Is this species restricted to certain players?
	var/whitelist = list() 		//List the ckeys that can use this species, if it's whitelisted.: list("John Doe", "poopface666", "SeeALiggerPullTheTrigger") Spaces & capitalization can be included or ignored entirely for each key as it checks for both.
	var/icon_limbs //Overrides the icon used for the limbs of this species. Mainly for downstream, and also because hardcoded icons disgust me. Implemented and maintained as a favor in return for a downstream's implementation of synths.
	var/species_category

	var/tail_type //type of tail i.e. mam_tail
	var/wagging_type //type of wagging i.e. waggingtail_lizard

	/// Our default override for typing indicator state
	var/typing_indicator_state

	//the ids you can use for your species, if empty, it means default only and not changeable
	var/list/allowed_limb_ids

	//override for the icon path used when setting bodypart overlays. Intended for species that don't fit in the standard 32x32 files.
	var/override_bp_icon
	//the icon state of the eyes this species has
	var/eye_type = "normal"

	///For custom overrides for species ass images
	var/icon/ass_image

///////////
// PROCS //
///////////

/datum/species/New()

	if(!limbs_id)	//if we havent set a limbs id to use, just use our own id
		mutant_bodyparts["limbs_id"] = id //done this way to be non-intrusive to the existing system
	else
		mutant_bodyparts["limbs_id"] = limbs_id
	..()

	//update our mutant bodyparts to include unlocked ones
	mutant_bodyparts += GLOB.unlocked_mutant_parts

/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species(clear = FALSE)
	if(clear)
		GLOB.roundstart_races = list()
		GLOB.roundstart_race_names = list()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = new I
		if(S.check_roundstart_eligible())
			GLOB.roundstart_races |= S.id
			GLOB.roundstart_race_names["[S.name]"] = S.id
			qdel(S)
	if(!GLOB.roundstart_races.len)
		GLOB.roundstart_races += "human"

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Generates a random name for a carbon.
 *
 * This generates a random unique name based on a human's species and gender.
 * Arguments:
 * * gender - The gender that the name should adhere to. Use MALE for male names, use anything else for female names.
 * * unique - If true, ensures that this new name is not a duplicate of anyone else's name currently on the station.
 * * lastname - Does this species' naming system adhere to the last name system? Set to false if it doesn't.
 */
/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male)
	else
		randname = pick(GLOB.first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names)]"

	return randname

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species)
	mutant_bodyparts["limbs_id"] = old_species.mutant_bodyparts["limbs_id"]
	eye_type = old_species.eye_type
	mutanttongue = old_species.mutanttongue
	return

//Please override this locally if you want to define when what species qualifies for what rank if human authority is enforced.
/datum/species/proc/qualifies_for_rank(rank, list/features) //SPECIES JOB RESTRICTIONS
	//if(rank in GLOB.command_positions) Left as an example: The format qualifies for rank takes.
	//	return 0 //It returns false when it runs the proc so they don't get jobs from the global list.
	return 1 //It returns 1 to say they are a-okay to continue.

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * C - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE)
	var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX)
	var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
	var/obj/item/organ/tongue/tongue = C.getorganslot(ORGAN_SLOT_TONGUE)
	var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	var/obj/item/organ/stomach/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/organ/tail/tail = C.getorganslot(ORGAN_SLOT_TAIL)

	var/should_have_brain = TRUE
	var/should_have_heart = !(NOBLOOD in species_traits)
	var/should_have_lungs = !(TRAIT_NOBREATH in inherent_traits)
	var/should_have_appendix = !(TRAIT_NOHUNGER in inherent_traits)
	var/should_have_eyes = TRUE
	var/should_have_ears = TRUE
	var/should_have_tongue = TRUE
	var/should_have_liver = !(NOLIVER in species_traits)
	var/should_have_stomach = !(NOSTOMACH in species_traits)
	var/should_have_tail = mutanttail

	if(brain && (replace_current || !should_have_brain))
		if(!brain.decoy_override)//Just keep it if it's fake
			brain.Remove(TRUE,TRUE)
			QDEL_NULL(brain)
	if(should_have_brain && !brain)
		brain = new mutant_brain()
		brain.Insert(C, TRUE, TRUE)

	if(heart && (!should_have_heart || replace_current))
		heart.Remove(TRUE)
		QDEL_NULL(heart)
	if(should_have_heart && !heart)
		heart = new mutant_heart()
		heart.Insert(C)

	if(lungs && (!should_have_lungs || replace_current))
		lungs.Remove(TRUE)
		QDEL_NULL(lungs)
	if(should_have_lungs && !lungs)
		if(mutantlungs)
			lungs = new mutantlungs()
		else
			lungs = new()
		lungs.Insert(C)

	if(liver && (!should_have_liver || replace_current))
		liver.Remove(TRUE)
		QDEL_NULL(liver)
	if(should_have_liver && !liver)
		if(mutantliver)
			liver = new mutantliver()
		else
			liver = new()
		liver.Insert(C)

	if(stomach && (!should_have_stomach || replace_current))
		stomach.Remove(TRUE)
		QDEL_NULL(stomach)
	if(should_have_stomach && !stomach)
		if(mutantstomach)
			stomach = new mutantstomach()
		else
			stomach = new()
		stomach.Insert(C)

	if(appendix && (!should_have_appendix || replace_current))
		appendix.Remove(TRUE)
		QDEL_NULL(appendix)
	if(should_have_appendix && !appendix)
		appendix = new()
		appendix.Insert(C)

	if(tail && (!should_have_tail || replace_current))
		tail.Remove(TRUE)
		QDEL_NULL(tail)
	if(should_have_tail && !tail)
		tail = new mutanttail()
		tail.Insert(C)

	if(C.get_bodypart(BODY_ZONE_HEAD))
		if(eyes && (replace_current || !should_have_eyes))
			eyes.Remove(TRUE)
			QDEL_NULL(eyes)
		if(should_have_eyes && !eyes)
			eyes = new mutanteyes
			eyes.Insert(C, TRUE)

		if(ears && (replace_current || !should_have_ears))
			ears.Remove(TRUE)
			QDEL_NULL(ears)
		if(should_have_ears && !ears)
			ears = new mutantears
			ears.Insert(C)

		if(tongue && (replace_current || !should_have_tongue))
			tongue.Remove(TRUE)
			QDEL_NULL(tongue)
		if(should_have_tongue && !tongue)
			tongue = new mutanttongue
			tongue.Insert(C)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove()
				QDEL_NULL(I)

	for(var/path in mutant_organs)
		var/obj/item/organ/I = new path()
		I.Insert(C)

/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	// Drop the items the new species can't wear
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	// this needs to be FIRST because qdel calls update_body which checks if we have DIGITIGRADE legs or not and if not then removes DIGITIGRADE from species_traits
	if(C.dna.species.mutant_bodyparts["legs"] && (C.dna.features["legs"] == "Digitigrade" || C.dna.features["legs"] == "Avian"))
		species_traits |= DIGITIGRADE
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(FALSE)

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C,old_species)

	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = exotic_bloodtype

	if(old_species.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				C.put_in_hands(new mutanthands())

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	//lets remove those conflicting quirks
	remove_blacklisted_quirks(C)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in C.diseases)
			A.cure(FALSE)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(NOGENITALS in H.dna.species.species_traits)
			H.give_genitals(TRUE) //call the clean up proc to delete anything on the mob then return.
		if(mutant_bodyparts["meat_type"]) //I can't believe it's come to the meat
			H.type_of_meat = GLOB.meat_types[H.dna.features["meat_type"]]

		if(H.physiology)
			if(mutant_bodyparts["taur"])
				var/datum/sprite_accessory/taur/T = GLOB.taur_list[H.dna.features["taur"]]
				switch(T?.taur_mode)
					if(STYLE_HOOF_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_SHOE
					if(STYLE_PAW_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CLAW
					if(STYLE_SNEK_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CRAWL
					else
						H.physiology.footstep_type = null
			else
				H.physiology.footstep_type = null

		if(H.client && has_field_of_vision && CONFIG_GET(flag/use_field_of_vision))
			H.LoadComponent(/datum/component/field_of_vision, H.field_of_vision_type)

	C.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, TRUE, multiplicative_slowdown = speedmod)

	if(ROBOTIC_LIMBS in species_traits)
		for(var/obj/item/bodypart/B in C.bodyparts)
			B.change_bodypart_status(BODYPART_HYBRID, FALSE, TRUE) // Makes all Bodyparts 'robotic'.

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)

/datum/species/proc/update_species_slowdown(mob/living/carbon/human/H)
	H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, TRUE, multiplicative_slowdown = speedmod)

// EDIT ENDS

/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	if(C.dna.species.exotic_bloodtype)
		if(!new_species.exotic_bloodtype)
			C.dna.blood_type = random_blood_type()
		else
			C.dna.blood_type = new_species.exotic_bloodtype
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(TRUE)
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	// lets restore the quirks that got removed when gaining this species
	restore_quirks(C)

	C.remove_movespeed_modifier(/datum/movespeed_modifier/species)

	if(mutant_bodyparts["meat_type"])
		C.type_of_meat = GLOB.meat_types[C.dna.features["meat_type"]]
	else
		C.type_of_meat = initial(meat)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.default_mutation_genes[location] = C.dna.mutation_index[location]
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		C.dna.default_mutation_genes[new_species.inert_mutation] = C.dna.mutation_index[new_species.inert_mutation]

	if(!new_species.has_field_of_vision && has_field_of_vision && ishuman(C) && CONFIG_GET(flag/use_field_of_vision))
		var/datum/component/field_of_vision/F = C.GetComponent(/datum/component/field_of_vision)
		if(F)
			qdel(F)


	if(ROBOTIC_LIMBS in species_traits)
		for(var/obj/item/bodypart/B in C.bodyparts)
			B.change_bodypart_status(initial(B.status), FALSE, TRUE)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

// shamelessly inspired by antag_datum.remove_blacklisted_quirks()
/datum/species/proc/remove_blacklisted_quirks(mob/living/carbon/C)
	var/mob/living/L = C.mind?.current
	if(istype(L))
		for(var/q in L.roundstart_quirks)
			var/datum/quirk/Q = q
			if(Q.type in blacklisted_quirks)
				qdel(Q)
				removed_quirks += Q.type

// restore any quirks that we removed
/datum/species/proc/restore_quirks(mob/living/carbon/C)
	var/mob/living/L = C.mind?.current
	if(istype(L))
		for(var/q in removed_quirks)
			L.add_quirk(q)


/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return
	if(HAS_TRAIT(H, TRAIT_HUSK))
		return

	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^

	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""

	//for augmented heads
	if(HD.is_robotic_limb(FALSE))
		return

	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask && istype(H.wear_mask))
		var/obj/item/clothing/mask/M = H.wear_mask
		dynamic_fhair_suffix = M.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(M.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hair_style && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hair_styles_list[H.facial_hair_style]
		if(S)
			//List of all valid dynamic_fhair_suffixes
			var/static/list/fextensions
			if(!fextensions)
				var/icon/fhair_extensions = icon('icons/mob/facialhair_extensions.dmi')
				fextensions = list()
				for(var/s in fhair_extensions.IconStates(1))
					fextensions[s] = TRUE
				qdel(fhair_extensions)

			//Is hair+dynamic_fhair_suffix a valid iconstate?
			var/fhair_state = S.icon_state
			var/fhair_file = S.icon
			if(fextensions[fhair_state+dynamic_fhair_suffix])
				fhair_state += dynamic_fhair_suffix
				fhair_file = 'icons/mob/facialhair_extensions.dmi'

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = "#" + H.dna.features["mcolor"]
					else
						facial_overlay.color = "#" + hair_color
				else
					facial_overlay.color = "#" + H.facial_hair_color
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha

			if(OFFSET_FHAIR in H.dna.species.offset_features)
				facial_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FHAIR][1]
				facial_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FHAIR][2]

			standing += facial_overlay

	if(H.head)
		var/obj/item/I = H.head
		if(istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask && istype(H.wear_mask))
		var/obj/item/clothing/mask/M = H.wear_mask
		if(!dynamic_hair_suffix) //head > mask in terms of head hair
			dynamic_hair_suffix = M.dynamic_hair_suffix
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIR_LAYER)
		if(!hair_hidden && !H.getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			if(!(NOBLOOD in species_traits))
				hair_overlay.icon = 'icons/mob/hair.dmi'
				hair_overlay.icon_state = "debrained"

		else if(H.hair_style && (HAIR in species_traits))
			S = GLOB.hair_styles_list[H.hair_style]
			if(S)
				//List of all valid dynamic_hair_suffixes
				var/static/list/extensions
				if(!extensions)
					var/icon/hair_extensions = icon('icons/mob/hair_extensions.dmi') //hehe
					extensions = list()
					for(var/s in hair_extensions.IconStates(1))
						extensions[s] = TRUE
					qdel(hair_extensions)

				//Is hair+dynamic_hair_suffix a valid iconstate?
				var/hair_state = S.icon_state
				var/hair_file = S.icon
				if(extensions[hair_state+dynamic_hair_suffix])
					hair_state += dynamic_hair_suffix
					hair_file = 'icons/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = "#" + H.dna.features["mcolor"]
						else
							hair_overlay.color = "#" + hair_color
					else
						hair_overlay.color = "#" + H.hair_color
				else
					hair_overlay.color = forced_colour
				hair_overlay.alpha = hair_alpha

				if(OFFSET_HAIR in H.dna.species.offset_features)
					hair_overlay.pixel_x += H.dna.species.offset_features[OFFSET_HAIR][1]
					hair_overlay.pixel_y += H.dna.species.offset_features[OFFSET_HAIR][2]

		if(hair_overlay.icon)
			standing += hair_overlay

	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(H, TRAIT_HUSK)))
		// lipstick
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/lips.dmi', "lips_[H.lip_style]", -BODY_LAYER)
			lip_overlay.color = H.lip_color

			if(OFFSET_LIPS in H.dna.species.offset_features)
				lip_overlay.pixel_x += H.dna.species.offset_features[OFFSET_LIPS][1]
				lip_overlay.pixel_y += H.dna.species.offset_features[OFFSET_LIPS][2]

			standing += lip_overlay

		// eyes
		if(!(NOEYES in species_traits))
			var/has_eyes = H.getorganslot(ORGAN_SLOT_EYES)
			if(!has_eyes)
				standing += mutable_appearance('icons/mob/eyes.dmi', "eyes_missing", -BODY_LAYER)
			else
				var/left_state = DEFAULT_LEFT_EYE_STATE
				var/right_state = DEFAULT_RIGHT_EYE_STATE
				if(eye_type in GLOB.eye_types)
					left_state = eye_type + "_left_eye"
					right_state = eye_type + "_right_eye"
				var/mutable_appearance/left_eye = mutable_appearance('icons/mob/eyes.dmi', left_state, -BODY_LAYER)
				var/mutable_appearance/right_eye = mutable_appearance('icons/mob/eyes.dmi', right_state, -BODY_LAYER)
				if((EYECOLOR in species_traits) && has_eyes)
					left_eye.color = "#" + H.left_eye_color
					right_eye.color = "#" + H.right_eye_color
				if(OFFSET_EYES in offset_features)
					left_eye.pixel_x += offset_features[OFFSET_EYES][1]
					left_eye.pixel_y += offset_features[OFFSET_EYES][2]
					right_eye.pixel_x += offset_features[OFFSET_EYES][1]
					right_eye.pixel_y += offset_features[OFFSET_EYES][2]
				standing += left_eye
				standing += right_eye

	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		var/datum/sprite_accessory/taur/TA
		if(mutant_bodyparts["taur"] && H.dna.features["taur"])
			TA = GLOB.taur_list[H.dna.features["taur"]]
		if(!(TA?.hide_legs) && H.socks && !H.hidden_socks && H.get_num_legs(FALSE) >= 2)
			if(H.saved_socks)
				H.socks = H.saved_socks
				H.saved_socks = ""
			var/datum/sprite_accessory/underwear/socks/S = GLOB.socks_list[H.socks]
			if(S)
				var/digilegs = ((DIGITIGRADE in species_traits) && S.has_digitigrade) ? "_d" : ""
				var/mutable_appearance/MA = mutable_appearance(S.icon, "[S.icon_state][digilegs]", -BODY_LAYER)
				if(S.has_color)
					MA.color = "#[H.socks_color]"
				standing += MA

		if(H.underwear && !H.hidden_underwear)
			if(H.saved_underwear)
				H.underwear = H.saved_underwear
				H.saved_underwear = ""
			var/datum/sprite_accessory/underwear/bottom/B = GLOB.underwear_list[H.underwear]
			if(B)
				var/digilegs = ((DIGITIGRADE in species_traits) && B.has_digitigrade) ? "_d" : ""
				var/mutable_appearance/MA = mutable_appearance(B.icon, "[B.icon_state][digilegs]", -BODY_LAYER)
				if(B.has_color)
					MA.color = "#[H.undie_color]"
				standing += MA

		if(H.undershirt && !H.hidden_undershirt)
			if(H.saved_undershirt)
				H.undershirt = H.saved_undershirt
				H.saved_undershirt = ""
			var/datum/sprite_accessory/underwear/top/T = GLOB.undershirt_list[H.undershirt]
			if(T)
				var/state = "[T.icon_state][((DIGITIGRADE in species_traits) && T.has_digitigrade) ? "_d" : ""]"
				var/mutable_appearance/MA
				if(H.dna.species.sexes && H.dna.features["body_model"] == FEMALE)
					MA = wear_alpha_masked_version(state, T.icon, BODY_LAYER, FEMALE_UNIFORM_TOP)
				else
					MA = mutable_appearance(T.icon, state, -BODY_LAYER)
				if(T.has_color)
					MA.color = "#[H.shirt_color]"
				standing += MA

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(H)

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_ADJ_UPPER_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)
	H.remove_overlay(HORNS_LAYER)

	if(!length(mutant_bodyparts))
		return

	var/tauric = mutant_bodyparts["taur"] && H.dna.features["taur"] && H.dna.features["taur"] != "None"

	for(var/mutant_part in mutant_bodyparts)
		var/reference_list = GLOB.mutant_reference_list[mutant_part]
		if(reference_list)
			var/datum/sprite_accessory/S
			var/transformed_part = GLOB.mutant_transform_list[mutant_part]
			if(transformed_part)
				S = reference_list[H.dna.features[transformed_part]]
			else
				S = reference_list[H.dna.features[mutant_part]]
			if(!S || S.is_not_visible(H, tauric))
				bodyparts_to_add -= mutant_part

	//Digitigrade legs are stuck in the phantom zone between true limbs and mutant bodyparts. Mainly it just needs more agressive updating than most limbs.
	var/update_needed = FALSE
	var/not_digitigrade = TRUE
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/O = X
		if(!O.use_digitigrade)
			continue
		not_digitigrade = FALSE
		if(!(DIGITIGRADE in species_traits)) //Someone cut off a digitigrade leg and tacked it on
			species_traits += DIGITIGRADE
		var/should_be_squished = FALSE
		if(H.wear_suit)
			if(!(H.wear_suit.mutantrace_variation & STYLE_DIGITIGRADE) || (tauric && (H.wear_suit.mutantrace_variation & STYLE_ALL_TAURIC))) //digitigrade/taur suits
				should_be_squished = TRUE
		if(H.w_uniform && !H.wear_suit)
			if(!(H.w_uniform.mutantrace_variation & STYLE_DIGITIGRADE))
				should_be_squished = TRUE
		if(O.use_digitigrade == FULL_DIGITIGRADE && should_be_squished)
			O.use_digitigrade = SQUISHED_DIGITIGRADE
			update_needed = TRUE
		else if(O.use_digitigrade == SQUISHED_DIGITIGRADE && !should_be_squished)
			O.use_digitigrade = FULL_DIGITIGRADE
			update_needed = TRUE
	if(update_needed)
		H.update_body_parts()
	if(not_digitigrade && (DIGITIGRADE in species_traits)) //Curse is lifted
		species_traits -= DIGITIGRADE

	if(!bodyparts_to_add)
		return

	var/list/relevant_layers = list()
	var/list/dna_feature_as_text_string = list()

	for(var/bodypart in bodyparts_to_add)
		var/reference_list = GLOB.mutant_reference_list[bodypart]
		if(reference_list)
			var/datum/sprite_accessory/S
			var/transformed_part = GLOB.mutant_transform_list[bodypart]
			if(transformed_part)
				S = reference_list[H.dna.features[transformed_part]]
			else
				S = reference_list[H.dna.features[bodypart]]

			if(!S || S.icon_state == "none")
				continue

			for(var/L in S.relevant_layers)
				LAZYADD(relevant_layers["[L]"], S)
			if(!S.mutant_part_string)
				dna_feature_as_text_string[S] = bodypart

	var/static/list/layer_text = list(
		"[BODY_BEHIND_LAYER]" = "BEHIND",
		"[BODY_ADJ_LAYER]" = "ADJ",
		"[BODY_ADJ_UPPER_LAYER]" = "ADJUP",
		"[BODY_FRONT_LAYER]" = "FRONT",
		"[HORNS_LAYER]" = "HORNS",
		)

	var/g = (H.dna.features["body_model"] == FEMALE) ? "f" : "m"
	var/husk = HAS_TRAIT(H, TRAIT_HUSK)

	for(var/layer in relevant_layers)
		var/list/standing = list()
		var/layertext = layer_text[layer]
		if(!layertext) //shouldn't happen
			stack_trace("invalid layer '[layer]' found in the list of relevant layers on species.handle_mutant_bodyparts().")
			continue
		var/layernum = text2num(layer)
		for(var/bodypart in relevant_layers[layer])
			var/datum/sprite_accessory/S = bodypart
			var/mutable_appearance/accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
			bodypart = S.mutant_part_string || dna_feature_as_text_string[S]

			if(S.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[S.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[S.icon_state]_[layertext]"

			if(S.center)
				accessory_overlay = center_image(accessory_overlay, S.dimension_x, S.dimension_y)

			var/advanced_color_system = (H.dna.features["color_scheme"] == ADVANCED_CHARACTER_COLORING)

			var/mutant_string = S.mutant_part_string
			if(mutant_string == "tailwag") //wagging tails should be coloured the same way as your tail
				mutant_string = "tail"
			var/primary_string = advanced_color_system ? "[mutant_string]_primary" : "mcolor"
			var/secondary_string = advanced_color_system ? "[mutant_string]_secondary" : "mcolor2"
			var/tertiary_string = advanced_color_system ? "[mutant_string]_tertiary" : "mcolor3"
			//failsafe: if there's no value for any of these, set it to white
			if(!H.dna.features[primary_string])
				H.dna.features[primary_string] = advanced_color_system ? H.dna.features["mcolor"] : "FFFFFF"
			if(!H.dna.features[secondary_string])
				H.dna.features[secondary_string] = advanced_color_system ? H.dna.features["mcolor2"] : "FFFFFF"
			if(!H.dna.features[tertiary_string])
				H.dna.features[tertiary_string] = advanced_color_system ? H.dna.features["mcolor3"] : "FFFFFF"

			if(!husk)
				if(!forced_colour)
					switch(S.color_src)
						if(SKINTONE)
							accessory_overlay.color = SKINTONE2HEX(H.skin_tone)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = "#[fixed_mut_color]"
							else
								accessory_overlay.color = "#[H.dna.features[primary_string]]"
						if(MUTCOLORS2)
							if(fixed_mut_color2)
								accessory_overlay.color = "#[fixed_mut_color2]"
							else
								accessory_overlay.color = "#[H.dna.features[primary_string]]"
						if(MUTCOLORS3)
							if(fixed_mut_color3)
								accessory_overlay.color = "#[fixed_mut_color3]"
							else
								accessory_overlay.color = "#[H.dna.features[primary_string]]"

						if(MATRIXED)
							var/list/accessory_colorlist = list()
							if(S.matrixed_sections == MATRIX_RED || S.matrixed_sections == MATRIX_RED_GREEN || S.matrixed_sections == MATRIX_RED_BLUE || S.matrixed_sections == MATRIX_ALL)
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[primary_string]]00")
							else
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("00000000")
							if(S.matrixed_sections == MATRIX_GREEN || S.matrixed_sections == MATRIX_RED_GREEN || S.matrixed_sections == MATRIX_GREEN_BLUE || S.matrixed_sections == MATRIX_ALL)
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[secondary_string]]00")
							else
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("00000000")
							if(S.matrixed_sections == MATRIX_BLUE || S.matrixed_sections == MATRIX_RED_BLUE || S.matrixed_sections == MATRIX_GREEN_BLUE || S.matrixed_sections == MATRIX_ALL)
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[tertiary_string]]00")
							else
								accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("00000000")
							accessory_colorlist += husk ? list(0, 0, 0) : list(0, 0, 0, hair_alpha)
							for(var/index in 1 to accessory_colorlist.len)
								accessory_colorlist[index] /= 255
							accessory_overlay.color = list(accessory_colorlist)

						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = "#[H.dna.features["mcolor"]]"
							else
								accessory_overlay.color = "#[H.hair_color]"
						if(FACEHAIR)
							accessory_overlay.color = "#[H.facial_hair_color]"
						if(EYECOLOR)
							accessory_overlay.color = "#[H.left_eye_color]"
						if(HORNCOLOR)
							accessory_overlay.color = "#[H.dna.features["horns_color"]]"
						if(WINGCOLOR)
							accessory_overlay.color = "#[H.dna.features["wings_color"]]"
				else
					accessory_overlay.color = forced_colour
			else
				if(bodypart == "ears")
					accessory_overlay.icon_state = "m_ears_none_[layertext]"
				if(bodypart == "tail")
					accessory_overlay.icon_state = "m_tail_husk_[layertext]"
				if(S.color_src == MATRIXED)
					var/list/accessory_colorlist = list()
					accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[primary_string]]00")
					accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[secondary_string]]00")
					accessory_colorlist += husk ? ReadRGB("#a3a3a3") : ReadRGB("[H.dna.features[tertiary_string]]00")
					accessory_colorlist += husk ? list(0, 0, 0) : list(0, 0, 0, hair_alpha)
					for(var/index in 1 to accessory_colorlist.len)
						accessory_colorlist[index] /= 255
					accessory_overlay.color = list(accessory_colorlist)

			if(OFFSET_MUTPARTS in H.dna.species.offset_features)
				accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
				accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

			standing += accessory_overlay

			if(S.extra) //apply the extra overlay, if there is one
				var/mutable_appearance/extra_accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
				if(S.gender_specific)
					extra_accessory_overlay.icon_state = "[g]_[bodypart]_extra_[S.icon_state]_[layertext]"
				else
					extra_accessory_overlay.icon_state = "m_[bodypart]_extra_[S.icon_state]_[layertext]"
				if(S.center)
					extra_accessory_overlay = center_image(extra_accessory_overlay, S.dimension_x, S.dimension_y)

				switch(S.extra_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra_accessory_overlay.color = "#[fixed_mut_color]"
						else
							extra_accessory_overlay.color = "#[H.dna.features[secondary_string]]"
					if(MUTCOLORS2)
						if(fixed_mut_color2)
							extra_accessory_overlay.color = "#[fixed_mut_color2]"
						else
							extra_accessory_overlay.color = "#[H.dna.features[secondary_string]]"
					if(MUTCOLORS3)
						if(fixed_mut_color3)
							extra_accessory_overlay.color = "#[fixed_mut_color3]"
						else
							extra_accessory_overlay.color = "#[H.dna.features[secondary_string]]"
					if(HAIR)
						if(hair_color == "mutcolor")
							extra_accessory_overlay.color = "#[H.dna.features["mcolor3"]]"
						else
							extra_accessory_overlay.color = "#[H.hair_color]"
					if(FACEHAIR)
						extra_accessory_overlay.color = "#[H.facial_hair_color]"
					if(EYECOLOR)
						extra_accessory_overlay.color = "#[H.left_eye_color]"

					if(HORNCOLOR)
						extra_accessory_overlay.color = "#[H.dna.features["horns_color"]]"
					if(WINGCOLOR)
						extra_accessory_overlay.color = "#[H.dna.features["wings_color"]]"

				if(OFFSET_MUTPARTS in H.dna.species.offset_features)
					extra_accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
					extra_accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

				standing += extra_accessory_overlay

			if(S.extra2) //apply the extra overlay, if there is one
				var/mutable_appearance/extra2_accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
				if(S.gender_specific)
					extra2_accessory_overlay.icon_state = "[g]_[bodypart]_extra2_[S.icon_state]_[layertext]"
				else
					extra2_accessory_overlay.icon_state = "m_[bodypart]_extra2_[S.icon_state]_[layertext]"
				if(S.center)
					extra2_accessory_overlay = center_image(extra2_accessory_overlay, S.dimension_x, S.dimension_y)

				switch(S.extra2_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra2_accessory_overlay.color = "#[fixed_mut_color]"
						else
							extra2_accessory_overlay.color = "#[H.dna.features[tertiary_string]]"
					if(MUTCOLORS2)
						if(fixed_mut_color2)
							extra2_accessory_overlay.color = "#[fixed_mut_color2]"
						else
							extra2_accessory_overlay.color = "#[H.dna.features[tertiary_string]]"
					if(MUTCOLORS3)
						if(fixed_mut_color3)
							extra2_accessory_overlay.color = "#[fixed_mut_color3]"
						else
							extra2_accessory_overlay.color = "#[H.dna.features[tertiary_string]]"
					if(HAIR)
						if(hair_color == "mutcolor3")
							extra2_accessory_overlay.color = "#[H.dna.features["mcolor"]]"
						else
							extra2_accessory_overlay.color = "#[H.hair_color]"
					if(HORNCOLOR)
						extra2_accessory_overlay.color = "#[H.dna.features["horns_color"]]"
					if(WINGCOLOR)
						extra2_accessory_overlay.color = "#[H.dna.features["wings_color"]]"

				if(OFFSET_MUTPARTS in H.dna.species.offset_features)
					extra2_accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
					extra2_accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

				standing += extra2_accessory_overlay

		H.overlays_standing[layernum] = standing

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_ADJ_UPPER_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)
	H.apply_overlay(HORNS_LAYER)

/*
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return
	outfit_important_for_life= new()
	outfit_important_for_life.equip(human_to_equip)

/* TODO: Snowflake trail marks
// Impliments different trails for species depending on if they're wearing shoes.
/datum/species/proc/get_move_trail(var/mob/living/carbon/human/H)
	if(H.lying)
		return /obj/effect/decal/cleanable/blood/footprints/tracks/body
	if(H.shoes || (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)))
		var/obj/item/clothing/shoes/shoes = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) ? H.wear_suit : H.shoes // suits take priority over shoes
		return shoes.move_trail
	else
		return move_trail */

/datum/species/proc/spec_life(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		H.setOxyLoss(0)
		H.losebreath = 0

		var/takes_crit_damage = !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE)
		if((H.health < H.crit_threshold) && takes_crit_damage)
			H.adjustBruteLoss(1)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/proc/auto_equip(mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE, clothing_check = FALSE, list/return_warning)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	if(clothing_check && (slot in H.check_obscured_slots()))
		if(return_warning)
			return_warning[1] = "<span class='warning'>You are unable to equip that with your current garments in the way!</span>"
		return FALSE

	var/num_arms = H.get_num_arms(FALSE)
	var/num_legs = H.get_num_legs(FALSE)

	switch(slot)
		if(SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(SLOT_WEAR_MASK)
			if(H.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_NECK)
			if(H.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(H.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_SUIT)
			if(H.wear_suit)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_OCLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLOVES)
			if(H.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(num_arms < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_SHOES)
			if(H.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_FEET) )
				return FALSE
			if(num_legs < 2)
				return FALSE
			if(DIGITIGRADE in species_traits)
				if(!is_species(H, /datum/species/lizard/ashwalker))
					H.update_inv_shoes()
				else
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT)
			if(H.belt)
				return FALSE
			if(!CHECK_BITFIELD(I.item_flags, NO_UNIFORM_REQUIRED))
				var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
				if(!H.w_uniform && !nojumpsuit && (!O || !O.is_robotic_limb()))
					if(return_warning)
						return_warning[1] = "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLASSES)
			if(H.glasses)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EYES))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_HEAD)
			if(H.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_EARS)
			if(H.ears)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_UNIFORM)
			if(H.w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_ID)
			if(H.wear_id)
				return FALSE
			if(!CHECK_BITFIELD(I.item_flags, NO_UNIFORM_REQUIRED))
				var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
				if(!H.w_uniform && !nojumpsuit && (!O || !O.is_robotic_limb()))
					if(return_warning)
						return_warning[1] = "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
					return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ID) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_L_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || !O.is_robotic_limb()))
				if(return_warning)
					return_warning[1] = "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
		if(SLOT_R_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || !O.is_robotic_limb()))
				if(return_warning)
					return_warning[1] = "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
			return FALSE
		if(SLOT_S_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_suit)
				if(return_warning)
					return_warning[1] = "<span class='warning'>You need a suit before you can attach this [I.name]!</span>"
				return FALSE
			if(!H.wear_suit.allowed)
				if(return_warning)
					return_warning[1] = "You somehow have a suit with no defined allowed items for suit storage, stop that."
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(return_warning)
					return_warning[1] = "The [I.name] is too big to attach."
				return FALSE
			if( istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed) )
				return TRUE
			return FALSE
		if(SLOT_HANDCUFFED)
			if(H.handcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(num_arms < 2)
				return FALSE
			return TRUE
		if(SLOT_LEGCUFFED)
			if(H.legcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(num_legs < 2)
				return FALSE
			return TRUE
		if(SLOT_IN_BACKPACK)
			if(H.back)
				if(SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message("<span class='notice'>[H] start putting on [I]...</span>", "<span class='notice'>You start putting on [I]...</span>")
	return do_after(H, I.equip_delay_self, target = H)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.update_mutant_bodyparts()

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == exotic_blood && !istype(exotic_blood, /datum/reagent/blood))
		H.AddIntegrationBlood(round(chem.volume, 0.1))
		H.reagents.del_reagent(chem.type)
		return TRUE
	return FALSE

/datum/species/proc/check_weakness(obj/item, mob/living/attacker)
	return FALSE

/////////////
////LIFE////
////////////

/datum/species/proc/handle_digestion(mob/living/carbon/human/H)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT(H, TRAIT_FAT))//I share your pain, past coder.
		if(H.overeatduration < 100)
			to_chat(H, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(H, TRAIT_FAT, OBESITY)
			H.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
	else
		if(H.overeatduration >= 100)
			to_chat(H, "<span class='danger'>You suddenly feel blubbery!</span>")
			ADD_TRAIT(H, TRAIT_FAT, OBESITY)
			H.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (H.nutrition > 0 && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOHUNGER))
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(0.5, 1 - 0.002 * mood.sanity) //0.85 to 0.75

		// Whether we cap off our satiety or move it towards 0
		if(H.satiety > MAX_SATIETY)
			H.satiety = MAX_SATIETY
		else if(H.satiety > 0)
			H.satiety--
		else if(H.satiety < -MAX_SATIETY)
			H.satiety = -MAX_SATIETY
		else if(H.satiety < 0)
			H.satiety++
			if(prob(round(-H.satiety/40)))
				H.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= H.physiology.hunger_mod
		H.adjust_nutrition(-hunger_rate)


	if (H.nutrition > NUTRITION_LEVEL_FULL)
		if(H.overeatduration < 600) //capped so people don't take forever to unfat
			H.overeatduration++
	else
		if(H.overeatduration > 1)
			H.overeatduration -= 2 //doubled the unfat rate

	//metabolism change
	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.metabolism_efficiency = 1
	else if(H.nutrition > NUTRITION_LEVEL_FED && H.satiety > 80)
		if(H.metabolism_efficiency != 1.25 && !HAS_TRAIT(H, TRAIT_NOHUNGER))
			to_chat(H, "<span class='notice'>You feel vigorous.</span>")
			H.metabolism_efficiency = 1.25
	else if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(H.metabolism_efficiency != 0.8)
			to_chat(H, "<span class='notice'>You feel sluggish.</span>")
		H.metabolism_efficiency = 0.8
	else
		if(H.metabolism_efficiency == 1.25)
			to_chat(H, "<span class='notice'>You no longer feel vigorous.</span>")
		H.metabolism_efficiency = 1

	//Hunger slowdown for if mood isn't enabled
	if(CONFIG_GET(flag/disable_human_mood))
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			var/hungry = (500 - H.nutrition) / 5 //So overeat would be 100 and default level would be 80
			if(hungry >= 70)
				H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (hungry / 50))
			else if(isethereal(H))
				var/datum/species/ethereal/E = H.dna.species
				if(E.get_charge(H) <= ETHEREAL_CHARGE_NORMAL)
					H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (1.5 * (1 - E.get_charge(H) / 100)))
			else
				H.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)

	switch(H.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			H.throw_alert("nutrition", /obj/screen/alert/fat)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			H.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("nutrition", /obj/screen/alert/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			H.throw_alert("nutrition", /obj/screen/alert/starving)

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = FALSE
	var/radiation = H.radiation

	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		radiation = 0
		return TRUE

	if(HAS_TRAIT(H, TRAIT_ROBOTIC_ORGANISM))
		return //Robots are hardened against radiation, but suffer system corruption at very high levels.

	if(radiation > RAD_MOB_KNOCKDOWN && prob(RAD_MOB_KNOCKDOWN_PROB))
		if(CHECK_MOBILITY(H, MOBILITY_STAND))
			H.emote("collapse")
		H.DefaultCombatKnockdown(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(H, "<span class='danger'>You feel weak.</span>")

	if(radiation > RAD_MOB_VOMIT && prob(RAD_MOB_VOMIT_PROB))
		H.vomit(10, TRUE)

	if(radiation > RAD_MOB_MUTATE)
		if(prob(1))
			to_chat(H, "<span class='danger'>You mutate!</span>")
			H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
			H.emote("gasp")
			H.domutcheck()

	if(radiation > RAD_MOB_HAIRLOSS)
		if(prob(15) && !(H.hair_style == "Bald") && (HAIR in species_traits))
			to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
			addtimer(CALLBACK(src, .proc/go_bald, H), 50)

/datum/species/proc/go_bald(mob/living/carbon/human/H)
	if(QDELETED(H))	//may be called from a timer
		return
	H.facial_hair_style = "Shaved"
	H.hair_style = "Bald"
	H.update_hair()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_updatehealth(mob/living/carbon/human/H)
	return

/datum/species/proc/spec_fully_heal(mob/living/carbon/human/H)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.health >= 0 && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaked")
		return 1
	else
		var/we_breathe = !HAS_TRAIT(user, TRAIT_NOBREATH)
		var/we_lung = user.getorganslot(ORGAN_SLOT_LUNGS)

		if(we_breathe && we_lung)
			user.do_cpr(target)
		else if(we_breathe && !we_lung)
			to_chat(user, "<span class='warning'>You have no lungs to breathe with, so you cannot peform CPR.</span>")
		else
			to_chat(user, "<span class='notice'>You do not breathe, so you cannot perform CPR.</span>")

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s grab attempt!</span>", target = user, \
			target_message = "<span class='warning'>[target] blocks your grab attempt!</span>")
		return 0
	if(attacker_style && attacker_style.grab_act(user,target))
		return 1
	else
		target.grabbedby(user)
		return 1

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style, attackchain_flags = NONE)
	if(!attacker_style && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return FALSE
	if(IS_STAMCRIT(user)) //CITADEL CHANGE - makes it impossible to punch while in stamina softcrit
		to_chat(user, "<span class='warning'>You're too exhausted.</span>") //CITADEL CHANGE - ditto
		return FALSE //CITADEL CHANGE - ditto
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s attack!</span>", target = user, \
			target_message = "<span class='warning'>[target] blocks your attack!</span>")
		return FALSE

	if(!(attackchain_flags & ATTACK_IS_PARRY_COUNTERATTACK))
		if(HAS_TRAIT(user, TRAIT_PUGILIST))//CITADEL CHANGE - makes punching cause staminaloss but funny martial artist types get a discount
			if(!user.UseStaminaBuffer(1.5, warn = TRUE))
				return
		else if(!user.UseStaminaBuffer(3.5, warn = TRUE))
			return

	if(attacker_style && attacker_style.harm_act(user,target))
		return TRUE
	else

		var/atk_verb = user.dna.species.attack_verb
		if(!(target.mobility_flags & MOBILITY_STAND))
			atk_verb = ATTACK_EFFECT_KICK

		switch(atk_verb)
			if(ATTACK_EFFECT_KICK)
				user.do_attack_animation(target, ATTACK_EFFECT_KICK)
			if(ATTACK_EFFECT_CLAW)
				user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
			if(ATTACK_EFFECT_SMASH)
				user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
			else
				user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

		var/damage = rand(user.dna.species.punchdamagelow, user.dna.species.punchdamagehigh)
		var/punchwoundbonus = user.dna.species.punchwoundbonus
		var/punchedstam = target.getStaminaLoss()
		var/punchedbrute = target.getBruteLoss()

		//CITADEL CHANGES - makes resting and disabled combat mode reduce punch damage, makes being out of combat mode result in you taking more damage
		if(!SEND_SIGNAL(target, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			damage *= 1.2
		if(!CHECK_MOBILITY(user, MOBILITY_STAND))
			damage *= 0.65
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			damage *= 0.8
		//END OF CITADEL CHANGES

		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
		if(HAS_TRAIT(user, TRAIT_PUGILIST))
			affecting = target.get_bodypart(check_zone(user.zone_selected)) // if you're going the based unarmed route you won't miss

		if(!affecting) //Maybe the bodypart is missing? Or things just went wrong..
			affecting = target.get_bodypart(BODY_ZONE_CHEST) //target chest instead, as failsafe. Or hugbox? You decide.

		if(!damage || !affecting)//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, TRUE, -1)
			target.visible_message("<span class='danger'>[user]'s [atk_verb] misses [target]!</span>", \
							"<span class='danger'>You avoid [user]'s [atk_verb]!</span>", "<span class='hear'>You hear a swoosh!</span>", null, COMBAT_MESSAGE_RANGE, null, \
							user, "<span class='warning'>Your [atk_verb] misses [target]!</span>")
			log_combat(user, target, "attempted to punch")
			return FALSE


		var/armor_block = target.run_armor_check(affecting, "melee")
		playsound(target.loc, user.dna.species.attack_sound_override || attack_sound, 25, 1, -1)
		target.visible_message("<span class='danger'>[user] [atk_verb]ed [target]!</span>", \
					"<span class='userdanger'>[user] [atk_verb]ed you!</span>", null, COMBAT_MESSAGE_RANGE, null, \
					user, "<span class='danger'>You [atk_verb]ed [target]!</span>")

		target.set_last_attacker(user)
		user.dna.species.spec_unarmedattacked(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		if(atk_verb == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage + 0.5x stamina damage
			target.apply_damage(damage*1.5, attack_type, affecting, armor_block, wound_bonus = punchwoundbonus)
			target.apply_damage(damage*0.5, STAMINA, affecting, armor_block)
			log_combat(user, target, "kicked")
		else if(HAS_TRAIT(user, TRAIT_MAULER)) // mauler punches deal 1.2x raw damage but nstam
			target.apply_damage(damage*1.2, attack_type, affecting, armor_block, wound_bonus = punchwoundbonus)
			log_combat(user, target, "punched (mauler)")
		else //other attacks deal full raw damage + 2x in stamina damage
			target.apply_damage(damage, attack_type, affecting, armor_block, wound_bonus = punchwoundbonus)
			target.apply_damage(damage*2, STAMINA, affecting, armor_block)
			log_combat(user, target, "punched")

		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			if((punchedstam > 50) && prob(punchedstam*0.5)) //If our punch victim has been hit above the threshold, and they have more than 50 stamina damage, roll for stun, probability of 1% per 2 stamina damage

				target.visible_message("<span class='danger'>[user] knocks [target] down!</span>", \
								"<span class='userdanger'>You're knocked down by [user]!</span>",
								"<span class='hear'>You hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, null,
								user, "<span class='danger'>You knock [target] down!</span>")

				var/knockdown_duration = 40 + (punchedstam + (punchedbrute*0.5))*0.8 - armor_block
				target.DefaultCombatKnockdown(knockdown_duration)
				target.forcesay(GLOB.hit_appends)
				log_combat(user, target, "got a stun punch with their previous punch")

				if(HAS_TRAIT(user, TRAIT_KI_VAMPIRE) && !HAS_TRAIT(target, TRAIT_NOBREATH) && (punchedbrute < 100)) //If we're a ki vampire we also sap them of lifeforce, but only if they're not too beat up. Also living organics only.
					user.adjustBruteLoss(-5)
					user.adjustFireLoss(-5)
					user.adjustStaminaLoss(-20)

					target.adjustCloneLoss(10)
					target.adjustBruteLoss(10)

		else if(!(target.mobility_flags & MOBILITY_STAND))
			target.forcesay(GLOB.hit_appends)

/datum/species/proc/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	// CITADEL EDIT slap mouthy gits and booty
	var/aim_for_mouth = user.zone_selected == "mouth"
	var/target_on_help = target.a_intent == INTENT_HELP
	var/target_aiming_for_mouth = target.zone_selected == "mouth"
	var/target_restrained = target.restrained()
	var/same_dir = (target.dir & user.dir)
	var/aim_for_groin  = user.zone_selected == "groin"
	var/target_aiming_for_groin = target.zone_selected == "groin"

	if(target.check_martial_melee_block()) //END EDIT
		target.visible_message("<span class='warning'>[target] blocks [user]'s disarm attempt!</span>", target = user, \
			target_message = "<span class='warning'>[target] blocks your disarm attempt!</span>")
		return FALSE
	if(IS_STAMCRIT(user))
		to_chat(user, "<span class='warning'>You're too exhausted!</span>")
		return FALSE

	else if(aim_for_mouth && ( target_on_help || target_restrained || target_aiming_for_mouth))
		if(!user.UseStaminaBuffer(3, warn = TRUE))
			return
		playsound(target.loc, 'sound/weapons/slap.ogg', 50, 1, -1)

		target.visible_message(\
			"<span class='danger'>\The [user] slaps [user == target ? "[user.p_them()]self" : "\the [target]"] in the face!</span>",\
			"<span class='notice'>[user] slaps you in the face! </span>",\
			"You hear a slap.", target = user, target_message = "<span class='notice'>You slap [user == target ? "yourself" : "\the [target]"] in the face! </span>")
		user.do_attack_animation(target, ATTACK_EFFECT_FACE_SLAP)
		if (!HAS_TRAIT(target, TRAIT_PERMABONER))
			stop_wagging_tail(target)
		return FALSE
	else if(aim_for_groin && (target == user || target.lying || same_dir) && (target_on_help || target_restrained || target_aiming_for_groin))
		if(target.client?.prefs.cit_toggles & NO_ASS_SLAP)
			to_chat(user,"A force stays your hand, preventing you from slapping \the [target]'s ass!")
			return FALSE
		if(!user.UseStaminaBuffer(3, warn = TRUE))
			return FALSE
		user.do_attack_animation(target, ATTACK_EFFECT_ASS_SLAP)
		target.adjust_arousal(20,"masochism", maso = TRUE)
		if (ishuman(target) && HAS_TRAIT(target, TRAIT_MASO) && target.has_dna() && prob(10))
			target.mob_climax(forced_climax=TRUE, cause = "masochism")
		if (!HAS_TRAIT(target, TRAIT_PERMABONER))
			stop_wagging_tail(target)
		playsound(target.loc, 'sound/weapons/slap.ogg', 50, 1, -1)
		target.visible_message(\
			"<span class='danger'>\The [user] slaps [user == target ? "[user.p_their()] own" : "\the [target]'s"] ass!</span>",\
			"<span class='notice'>[user] slaps your ass! </span>",\
			"You hear a slap.", target = user, target_message = "<span class='notice'>You slap [user == target ? "your own" : "\the [target]'s"] ass! </span>")

		return FALSE

	else
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)

		if(HAS_TRAIT(user, TRAIT_PUGILIST))//CITADEL CHANGE - makes disarmspam cause staminaloss, pugilists can do it almost effortlessly
			if(!user.UseStaminaBuffer(1, warn = TRUE))
				return
		else
			if(!user.UseStaminaBuffer(1, warn = TRUE))
				return

		if(attacker_style && attacker_style.disarm_act(user,target))
			return TRUE

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		//var/randomized_zone = ran_zone(user.zone_selected) CIT CHANGE - comments out to prevent compiling errors
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)
		if(target.pulling == user)
			target.visible_message("<span class='warning'>[user] wrestles out of [target]'s grip!</span>", \
				"<span class='warning'>[user] wrestles out of your grip!</span>", target = user, \
				target_message = "<span class='warning'>You wrestle out of [target]'s grip!</span>")
			target.stop_pulling()
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			log_combat(user, target, "disarmed out of grab from")
			return
		var/randn = rand(1, 100)
		if(SEND_SIGNAL(target, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE)) // CITADEL CHANGE
			randn += -10 //CITADEL CHANGE - being out of combat mode makes it easier for you to get disarmed
		if(!CHECK_MOBILITY(user, MOBILITY_STAND)) //CITADEL CHANGE
			randn += 100 //CITADEL CHANGE - No kosher disarming if you're resting
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE)) //CITADEL CHANGE
			randn += 25 //CITADEL CHANGE - Makes it harder to disarm outside of combat mode
		if(user.pulling == target)
			randn -= 20 //If you have the time to get someone in a grab, you should have a greater chance at snatching the thing in their hand. Will be made completely obsolete by the grab rework but i've got a poor track record for releasing big projects on time so w/e i guess
		if(HAS_TRAIT(user, TRAIT_PUGILIST))
			randn -= 25 //if you are a pugilist, you're slapping that item from them pretty reliably
		if(HAS_TRAIT(target, TRAIT_PUGILIST))
			randn += 25 //meanwhile, pugilists are less likely to get disarmed

		if(randn <= 35)//CIT CHANGE - changes this back to a 35% chance to accomodate for the above being commented out in favor of right-click pushing
			var/obj/item/I = null
			if(target.pulling)
				target.visible_message("<span class='warning'>[user] has broken [target]'s grip on [target.pulling]!</span>", \
					"<span class='warning'>[user] has broken your grip on [target.pulling]!</span>", target = user, \
					target_message = "<span class='warning'>You have broken [target]'s grip on [target.pulling]!</span>")
				target.stop_pulling()
			else
				I = target.get_active_held_item()
				if(target.dropItemToGround(I))
					target.visible_message("<span class='danger'>[user] has disarmed [target]!</span>", \
						"<span class='userdanger'>[user] has disarmed you!</span>", null, COMBAT_MESSAGE_RANGE, null, \
						user, "<span class='danger'>You have disarmed [target]!</span>")
				else
					I = null
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			log_combat(user, target, "disarmed", "[I ? " removing \the [I]" : ""]")
			return


		playsound(target, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		target.visible_message("<span class='danger'>[user] attempted to disarm [target]!</span>", \
						"<span class='userdanger'>[user] attemped to disarm [target]!</span>", null, COMBAT_MESSAGE_RANGE, null, \
						user, "<span class='danger'>You attempted to disarm [target]!</span>")
		log_combat(user, target, "attempted to disarm")


/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style, act_intent, attackchain_flags)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
		if(attacker_style?.pacifism_check && HAS_TRAIT(M, TRAIT_PACIFISM)) // most martial arts are quite harmful, alas.
			attacker_style = null
	switch(act_intent)
		if("help")
			help(M, H, attacker_style)

		if("grab")
			grab(M, H, attacker_style)

		if("harm")
			harm(M, H, attacker_style, attackchain_flags)

		if("disarm")
			disarm(M, H, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H, attackchain_flags = NONE, damage_multiplier = 1)
	var/totitemdamage = H.pre_attacked_by(I, user) * damage_multiplier

	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = H.get_bodypart(BODY_ZONE_CHEST) //If the limb is missing, or something went terribly wrong, just hit the chest instead

	// Allows you to put in item-specific reactions based on species
	if(user != H)
		var/list/block_return = list()
		if(H.mob_run_block(I, totitemdamage, "the [I.name]", ((attackchain_flags & ATTACK_IS_PARRY_COUNTERATTACK)? ATTACK_TYPE_PARRY_COUNTERATTACK : NONE) | ATTACK_TYPE_MELEE, I.armour_penetration, user, affecting.body_zone, block_return) & BLOCK_SUCCESS)
			return 0
		totitemdamage = block_calculate_resultant_damage(totitemdamage, block_return)
	if(H.check_martial_melee_block())
		H.visible_message("<span class='warning'>[H] blocks [I]!</span>")
		return 0

	var/hit_area

	hit_area = affecting.name
	var/def_zone = affecting.body_zone

	var/armor_block = H.run_armor_check(affecting, "melee", "<span class='notice'>Your armor has protected your [hit_area].</span>", "<span class='notice'>Your armor has softened a hit to your [hit_area].</span>",I.armour_penetration)
	armor_block = min(90,armor_block) //cap damage reduction at 90%
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)
	var/Iwound_bonus = I.wound_bonus

	// this way, you can't wound with a surgical tool on help intent if they have a surgery active and are laying down, so a misclick with a circular saw on the wrong limb doesn't bleed them dry (they still get hit tho)
	if((I.item_flags & SURGICAL_TOOL) && user.a_intent == INTENT_HELP && (H.mobility_flags & ~MOBILITY_STAND) && (LAZYLEN(H.surgeries) > 0))
		Iwound_bonus = CANT_WOUND

	var/weakness = H.check_weakness(I, user)
	apply_damage(totitemdamage * weakness, I.damtype, def_zone, armor_block, H, wound_bonus = Iwound_bonus, bare_wound_bonus = I.bare_wound_bonus, sharpness = I.get_sharpness())


	H.send_item_attack_message(I, user, hit_area, affecting, totitemdamage)

	I.do_stagger_action(H, user, totitemdamage)

	if(!totitemdamage)
		return 0 //item force is zero

	var/bloody = 0
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.is_organic_limb(FALSE))
			I.add_mob_blood(H)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				var/turf/location = H.loc
				if(istype(location))
					H.add_splatter_floor(location)
				if(get_dist(user, H) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(H)

		switch(hit_area)
			if(BODY_ZONE_HEAD)
				if(!I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						if(HAS_TRAIT(src, TRAIT_ROBOTIC_ORGANISM))
							H.adjustToxLoss(5, toxins_type = TOX_SYSCORRUPT) //Bonk! - Effectively 5 bonus damage
						else
							H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
						if(H.stat == CONSCIOUS)
							H.visible_message("<span class='danger'>[H] has been knocked senseless!</span>", \
											"<span class='userdanger'>You have been knocked senseless!</span>")
							H.confused = max(H.confused, 20)
							H.adjust_blurriness(10)
						if(prob(10))
							H.gain_trauma(/datum/brain_trauma/mild/concussion)
					else
						H.adjustOrganLoss(ORGAN_SLOT_BRAIN, I.force * 0.2)

					if(H.stat == CONSCIOUS && H != user && prob(I.force + ((100 - H.health) * 0.5))) // rev deconversion through blunt trauma.
						var/datum/antagonist/rev/rev = H.mind.has_antag_datum(/datum/antagonist/rev)
						var/datum/antagonist/gang/gang = H.mind.has_antag_datum(/datum/antagonist/gang && !/datum/antagonist/gang/boss)
						if(rev)
							rev.remove_revolutionary(FALSE, user)
						if(gang)
							H.mind.remove_antag_datum(/datum/antagonist/gang)

				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_mob_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_mob_blood(H)
						H.update_inv_head()
					if(H.glasses && prob(33))
						H.glasses.add_mob_blood(H)
						H.update_inv_glasses()

			if(BODY_ZONE_CHEST)
				if(H.stat == CONSCIOUS && !I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.visible_message("<span class='danger'>[H] has been knocked down!</span>", \
									"<span class='userdanger'>[H] has been knocked down!</span>")
						H.apply_effect(60, EFFECT_KNOCKDOWN, armor_block)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_mob_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_mob_blood(H)
						H.update_inv_w_uniform()

		if(Iforce > 10 || Iforce >= 5 && prob(33))
			H.forcesay(GLOB.hit_appends)	//forcesay checks stat already.
	return TRUE

/datum/species/proc/alt_spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return TRUE
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)
	if(!M.CheckActionCooldown())
		return
	M.DelayNextAction(CLICK_CD_MELEE)

	if(!istype(M)) //sanity check for drones.
		return TRUE
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != H) && M.a_intent != INTENT_HELP && (H.mob_run_block(M, 0, "[M]", ATTACK_TYPE_UNARMED, 0, M, M.zone_selected, null) & BLOCK_SUCCESS))
		log_combat(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>", \
			"<span class='warning'>[M] attempted to touch you!</span>", target = M, \
			target_message = "<span class='warning'>You attempted to touch [H]!</span>")
		return TRUE
	if(M == H)
		althelp(M, H, attacker_style)
		return TRUE
	switch(M.a_intent)
		if(INTENT_DISARM)
			altdisarm(M, H, attacker_style)
			return TRUE
	return FALSE

/datum/species/proc/althelp(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user == target && istype(user))
		if(IS_STAMCRIT(user))
			to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")
			return
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			to_chat(user, "<span class='warning'>You need combat mode to be active to that!</span>")
			return
		if(user.IsKnockdown() || user.IsParalyzed() || user.IsStun())
			to_chat(user, "<span class='warning'>You can't seem to force yourself up right now!</span>")
			return
		if(CHECK_MOBILITY(user, MOBILITY_STAND))
			to_chat(user, "<span class='notice'>You can only force yourself up if you're on the ground.</span>")
			return
		if(!user.UseStaminaBuffer(STAMINA_COST_SHOVE_UP, TRUE))
			return
		user.visible_message("<span class='notice'>[user] forces [p_them()]self up to [p_their()] feet!</span>", "<span class='notice'>You force yourself up to your feet!</span>")
		user.set_resting(FALSE, TRUE)
		playsound(user, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/datum/species/proc/altdisarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(IS_STAMCRIT(user))
		to_chat(user, "<span class='warning'>You're too exhausted.</span>")
		return FALSE
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s shoving attempt!</span>", \
			"<span class='warning'>You block [user]'s shoving attempt!</span>", target = user, \
			target_message = "<span class='warning'>[target] blocks your shoving attempt!</span>")
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user,target))
		return TRUE
	if(!CHECK_MOBILITY(user, MOBILITY_STAND))
		return FALSE
	else
		if(user == target)
			return
		if(!user.UseStaminaBuffer(4, warn = TRUE))
			return
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)

		if(CHECK_MOBILITY(target, MOBILITY_STAND))
			target.adjustStaminaLoss(5)

		if(target.is_shove_knockdown_blocked())
			return

		var/turf/target_oldturf = target.loc
		var/shove_dir = get_dir(user.loc, target_oldturf)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/carbon/human/target_collateral_human
		var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied
		var/targetatrest = !CHECK_MOBILITY(target, MOBILITY_STAND)

		//Thank you based whoneedsspace
		target_collateral_human = locate(/mob/living/carbon/human) in target_shove_turf.contents
		if(target_collateral_human && CHECK_MOBILITY(target_collateral_human, MOBILITY_STAND))
			shove_blocked = TRUE
		else
			target_collateral_human = null
			target.Move(target_shove_turf, shove_dir)
			if(get_turf(target) == target_oldturf)
				shove_blocked = TRUE

		var/append_message = ""
		if(shove_blocked && !target.buckled)
			var/directional_blocked = !target.Adjacent(target_shove_turf)
			if((directional_blocked || !(target_collateral_human || target_shove_turf.shove_act(target, user))) && !targetatrest)
				target.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_SOLID)
				target.visible_message("<span class='danger'>[user.name] shoves [target.name], knocking them down!</span>",
					"<span class='danger'>[user.name] shoves you, knocking you down!</span>", null, COMBAT_MESSAGE_RANGE, null,
					user, "<span class='danger'>You shove [target.name], knocking them down!</span>")
				log_combat(user, target, "shoved", "knocking them down")
			else if(target_collateral_human && !targetatrest)
				target.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_HUMAN)
				target_collateral_human.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_COLLATERAL)
				target.visible_message("<span class='danger'>[user.name] shoves [target.name] into [target_collateral_human.name]!</span>",
					"<span class='danger'>[user.name] shoves you into [target_collateral_human.name]!</span>", null, COMBAT_MESSAGE_RANGE, null,
					user, "<span class='danger'>You shove [target.name] into [target_collateral_human.name]!</span>")
				append_message += ", into [target_collateral_human.name]"

		else
			target.visible_message("<span class='danger'>[user.name] shoves [target.name]!</span>",
				"<span class='danger'>[user.name] shoves you!</span>", null, COMBAT_MESSAGE_RANGE, null,
				user, "<span class='danger'>You shove [target.name]!</span>")
		target.Stagger(SHOVE_STAGGER_DURATION)
		var/obj/item/target_held_item = target.get_active_held_item()
		if(!target.has_status_effect(STATUS_EFFECT_OFF_BALANCE))
			if(target_held_item)
				if(!HAS_TRAIT(target_held_item, TRAIT_NODROP))
					target.visible_message("<span class='danger'>[target.name]'s grip on \the [target_held_item] loosens!</span>",
						"<span class='danger'>Your grip on \the [target_held_item] loosens!</span>", null, COMBAT_MESSAGE_RANGE)
					append_message += ", loosening their grip on [target_held_item]"
				else
					append_message += ", but couldn't loose their grip on [target_held_item]"
		else if(target.has_status_effect(STATUS_EFFECT_OFF_BALANCE))
			if(target_held_item)
				if(shove_blocked)
					if (target.buckled)
						return
					else if(target.dropItemToGround(target_held_item))
						target.visible_message("<span class='danger'>[target.name] drops \the [target_held_item]!!</span>",
							"<span class='danger'>You drop \the [target_held_item]!!</span>", null, COMBAT_MESSAGE_RANGE)
						append_message += ", causing them to drop [target_held_item]"
		target.ShoveOffBalance(SHOVE_OFFBALANCE_DURATION)
		log_combat(user, target, "shoved", append_message)

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone, wound_bonus, bare_wound_bonus, sharpness) // make sure putting wound_bonus here doesn't screw up other signals or uses for this signal
	var/hit_percent = (100-(blocked+armor))/100
	hit_percent = (hit_percent * (100-H.physiology.damage_resistance))/100
	if(!forced && hit_percent <= 0)
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone))
			if(damagetype == STAMINA && istype(def_zone, /obj/item/bodypart/head))
				BP = H.get_bodypart(check_zone(BODY_ZONE_CHEST))
			else
				BP = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			if(damagetype == STAMINA && def_zone == BODY_ZONE_HEAD)
				def_zone = BODY_ZONE_CHEST
			BP = H.get_bodypart(check_zone(def_zone))
		if(!BP)
			BP = H.bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * brutemod * H.physiology.brute_mod
			if(BP)
				if(BP.receive_damage(damage_amount, 0, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness))
					H.update_damage_overlays()
					if(HAS_TRAIT(H, TRAIT_MASO) && prob(damage_amount))
						H.mob_climax(forced_climax=TRUE, cause = "masochism")

			else//no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount)
		if(BURN)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * burnmod * H.physiology.burn_mod
			if(BP)
				if(BP.receive_damage(0, damage_amount, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness))
					H.update_damage_overlays()
			else
				H.adjustFireLoss(damage_amount)
		if(TOX)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.tox_mod
			H.adjustToxLoss(damage_amount)
		if(OXY)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.oxy_mod
			H.adjustOxyLoss(damage_amount)
		if(CLONE)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.clone_mod
			H.adjustCloneLoss(damage_amount)
		if(STAMINA)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.stamina_mod
			if(BP)
				if(damage > 0 ? BP.receive_damage(0, 0, damage_amount) : BP.heal_damage(0, 0, abs(damage * hit_percent * H.physiology.stamina_mod), only_robotic = FALSE, only_organic = FALSE))
					H.update_stamina()
			else
				H.adjustStaminaLoss(damage_amount)
		if(BRAIN)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.brain_mod
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	return 1

/datum/species/proc/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florayield)
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florarevolution)
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	return

/**
  * The human species version of [/mob/living/carbon/proc/get_biological_state]. Depends on the HAS_FLESH and HAS_BONE species traits, having bones lets you have bone wounds, having flesh lets you have burn, slash, and piercing wounds
  */
/datum/species/proc/get_biological_state(mob/living/carbon/human/H)
	. = BIO_INORGANIC
	if(HAS_FLESH in species_traits)
		. |= BIO_JUST_FLESH
	if(HAS_BONE in species_traits)
		. |= BIO_JUST_BONE

/////////////
//BREATHING//
/////////////

/datum/species/proc/breathe(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return TRUE

/datum/species/proc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/loc_temp = H.get_temperature(environment)

	//Body temperature is adjusted in two parts: first there your body tries to naturally preserve homeostasis (shivering/sweating), then it reacts to the surrounding environment
	//Thermal protection (insulation) has mixed benefits in two situations (hot in hot places, cold in hot places)
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		if(loc_temp < H.bodytemperature) //Place is colder than we are
			thermal_protection -= H.get_thermal_protection(loc_temp, TRUE) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(H.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
			else //we're sweating, insulation hinders our ability to reduce heat - and it will reduce the amount of cooling you get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + max((thermal_protection * (loc_temp - H.bodytemperature) + BODYTEMP_NORMAL - H.bodytemperature) / BODYTEMP_COLD_DIVISOR , BODYTEMP_COOLING_MAX)) //Extra calculation for hardsuits to bleed off heat
		else //Place is hotter than we are
			thermal_protection -= H.get_thermal_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(H.bodytemperature < BODYTEMP_NORMAL) //and we're cold, insulation enhances our ability to retain body heat but reduces the heat we get from the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
			else //we're sweating, insulation hinders out ability to reduce heat - but will reduce the amount of heat we get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
		switch((loc_temp - H.bodytemperature)*thermal_protection)
			if(-INFINITY to -50)
				H.throw_alert("tempfeel", /obj/screen/alert/cold, 3)
			if(-50 to -35)
				H.throw_alert("tempfeel", /obj/screen/alert/cold, 2)
			if(-35 to -20)
				H.throw_alert("tempfeel", /obj/screen/alert/cold, 1)
			if(-20 to 0) //This is the sweet spot where air is considered normal
				H.clear_alert("tempfeel")
			if(0 to 15) //When the air around you matches your body's temperature, you'll start to feel warm.
				H.throw_alert("tempfeel", /obj/screen/alert/hot, 1)
			if(15 to 30)
				H.throw_alert("tempfeel", /obj/screen/alert/hot, 2)
			if(30 to INFINITY)
				H.throw_alert("tempfeel", /obj/screen/alert/hot, 3)

	// +/- 50 degrees from 310K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTHEAT))
		//Body temperature is too hot.

		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		H.remove_movespeed_modifier(/datum/movespeed_modifier/cold)

		var/burn_damage
		var/firemodifier = H.fire_stacks / 50
		if (H.on_fire)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0)
		else
			firemodifier = min(firemodifier, 0)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0) // this can go below 5 at log 2.5
		if (burn_damage)
			switch(burn_damage)
				if(0 to 2)
					H.throw_alert("temp", /obj/screen/alert/sweat, 1)
				if(2 to 4)
					H.throw_alert("temp", /obj/screen/alert/sweat, 2)
				else
					H.throw_alert("temp", /obj/screen/alert/sweat, 3)
		burn_damage = burn_damage * heatmod * H.physiology.heat_mod
		if (H.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4) //40% for level 3 damage on humans
			H.emote("scream")
		H.apply_damage(burn_damage, BURN)

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		//Apply cold slowdown
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		switch(H.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)
				H.throw_alert("temp", /obj/screen/alert/shiver, 1)
				H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod*H.physiology.cold_mod, BURN)
			if(120 to 200)
				H.throw_alert("temp", /obj/screen/alert/shiver, 2)
				H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod*H.physiology.cold_mod, BURN)
			else
				H.throw_alert("temp", /obj/screen/alert/shiver, 3)
				H.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod*H.physiology.cold_mod, BURN)

	else
		H.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		H.clear_alert("temp")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.adjustBruteLoss(min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 ) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod)
				H.throw_alert("pressure", /obj/screen/alert/highpressure, 2)
			else
				H.clear_alert("pressure")
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
		else
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else
				H.adjustBruteLoss(LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod)
				H.throw_alert("pressure", /obj/screen/alert/lowpressure, 2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, no_protection = FALSE)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return
	if(H.on_fire)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		//HEAD//
		var/obj/item/clothing/head_clothes = null
		if(H.glasses)
			head_clothes = H.glasses
		if(H.wear_mask)
			head_clothes = H.wear_mask
		if(H.wear_neck)
			head_clothes = H.wear_neck
		if(H.head)
			head_clothes = H.head
		if(head_clothes)
			burning_items += head_clothes
		else if(H.ears)
			burning_items += H.ears

		//CHEST//
		var/obj/item/clothing/chest_clothes = null
		if(H.w_uniform)
			chest_clothes = H.w_uniform
		if(H.wear_suit)
			chest_clothes = H.wear_suit

		if(chest_clothes)
			burning_items += chest_clothes

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		if(H.gloves)
			arm_clothes = H.gloves
		if(H.w_uniform && ((H.w_uniform.body_parts_covered & HANDS) || (H.w_uniform.body_parts_covered & ARMS)))
			arm_clothes = H.w_uniform
		if(H.wear_suit && ((H.wear_suit.body_parts_covered & HANDS) || (H.wear_suit.body_parts_covered & ARMS)))
			arm_clothes = H.wear_suit
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		if(H.shoes)
			leg_clothes = H.shoes
		if(H.w_uniform && ((H.w_uniform.body_parts_covered & FEET) || (H.w_uniform.body_parts_covered & LEGS)))
			leg_clothes = H.w_uniform
		if(H.wear_suit && ((H.wear_suit.body_parts_covered & FEET) || (H.wear_suit.body_parts_covered & LEGS)))
			leg_clothes = H.wear_suit
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/X in burning_items)
			var/obj/item/I = X
			if(!(I.resistance_flags & FIRE_PROOF))
				I.take_damage(H.fire_stacks, BURN, "fire", 0)

		var/thermal_protection = H.easy_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
			H.adjust_bodytemperature(11)
		else
			H.adjust_bodytemperature(BODYTEMP_HEATING_MAX + (H.fire_stacks * 12))
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/H)
	return

////////////
//Stun//
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = stunmod * H.physiology.stun_mod * amount

//////////////
//Space Move//
//////////////

/datum/species/proc/space_move(mob/living/carbon/human/H)
	return 0

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	return 0

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	if(!tail_type || !wagging_type)
		return FALSE
	else
		return mutant_bodyparts[tail_type] || mutant_bodyparts[wagging_type]

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	return mutant_bodyparts[wagging_type]

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)
	if(tail_type && wagging_type)
		if(mutant_bodyparts[tail_type])
			mutant_bodyparts[wagging_type] = mutant_bodyparts[tail_type]
			mutant_bodyparts -= tail_type
			if(tail_type == "tail_lizard") //special lizard thing
				mutant_bodyparts["waggingspines"] = mutant_bodyparts["spines"]
				mutant_bodyparts -= "spines"
			H.update_body()

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)
	if(tail_type && wagging_type)
		if(mutant_bodyparts[wagging_type])
			mutant_bodyparts[tail_type] = mutant_bodyparts[wagging_type]
			mutant_bodyparts -= wagging_type
			if(tail_type == "tail_lizard") //special lizard thing
				mutant_bodyparts["spines"] = mutant_bodyparts["waggingspines"]
				mutant_bodyparts -= "waggingspines"
			H.update_body()
