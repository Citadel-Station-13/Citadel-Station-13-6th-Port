/mob/living/carbon/human
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD,RAD_HUD)
	hud_type = /datum/hud/human
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	/// Enable stamina combat
	combat_flags = COMBAT_FLAGS_STAMINA_COMBAT | COMBAT_FLAG_UNARMED_PARRY
	status_flags = CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH|CANSTAGGER
	has_field_of_vision = FALSE //Handled by species.

	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	block_parry_data = /datum/block_parry_data/unarmed/human
	default_block_parry_data = /datum/block_parry_data/unarmed/human
	causes_dirt_buildup_on_floor = TRUE

	//Hair colour and style
	var/hair_color = "000"
	var/hair_style = "Bald"

	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hair_style = "Shaved"

	//Eye colour
	var/left_eye_color = "000"
	var/right_eye_color = "000"

	var/skin_tone = "caucasian1"	//Skin tone

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30		//Player's age

	var/underwear = "Nude"	//Which underwear the player wants
	var/undie_color = "FFFFFF"
	var/undershirt = "Nude" //Which undershirt the player wants
	var/shirt_color = "FFFFFF"
	var/socks = "Nude" //Which socks the player wants
	var/socks_color = "FFFFFF"

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/bleedsuppress = 0 //for stopping bloodloss, eventually this will be limb-based like bleeding

	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/blood_smear = list(BLOOD_STATE_BLOOD = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)

	var/name_override //For temporary visible name changes
	var/genital_override = FALSE //Force genitals on things incase of chems

	var/nameless = FALSE //For drones of both the insectoid and robotic kind. And other types of nameless critters.

	var/custom_species = null

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	var/creamed = FALSE //to use with creampie overlays
	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/slime, /mob/living/simple_animal/parrot, /mob/living/silicon/pai))
	var/lastpuke = 0
	var/account_id
	var/last_fire_update
	var/hardcore_survival_score = 0

	/// When an braindead player has their equipment fiddled with, we log that info here for when they come back so they know who took their ID while they were DC'd for 30 seconds
	var/list/afk_thefts
	tooltips = TRUE

/// Unarmed parry data for human
/datum/block_parry_data/unarmed/human
	parry_respect_clickdelay = TRUE
	parry_stamina_cost = 4
	parry_attack_types = ATTACK_TYPE_UNARMED
	parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK | PARRY_LOCK_ATTACKING

	parry_time_windup = 0
	parry_time_spindown = 1
	parry_time_active = 5

	parry_time_perfect = 1
	parry_time_perfect_leeway = 1
	parry_imperfect_falloff_percent = 20
	parry_efficiency_perfect = 100

	parry_efficiency_considered_successful = 0.01
	parry_efficiency_to_counterattack = 0.01
	parry_max_attacks = 3
	parry_cooldown = 3 SECONDS
	parry_failed_cooldown_duration = 1.5 SECONDS
	parry_failed_stagger_duration = 1 SECONDS
	parry_failed_clickcd_duration = 0.4 SECONDS

	parry_data = list(			// yeah it's snowflake
		"UNARMED_PARRY_STAGGER" = 3 SECONDS,
		"UNARMED_PARRY_PUNCH" = TRUE,
		"UNARMED_PARRY_MININUM_EFFICIENCY" = 90
	)

/mob/living/on_active_parry(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/block_return, parry_efficiency, parry_time)
	var/datum/block_parry_data/D = return_block_parry_datum(block_parry_data)
	. = ..()
	if(!owner.Adjacent(attacker))
		return
	if(parry_efficiency < D.parry_data["UNARMED_PARRY_MINIMUM_EFFICIENCY"])
		return
	visible_message("<span class='warning'>[src] strikes back perfectly at [attacker], staggering them!</span>")
	if(D.parry_data["UNARMED_PARRY_PUNCH"])
		UnarmedAttack(attacker, TRUE, INTENT_HARM, ATTACK_IS_PARRY_COUNTERATTACK | ATTACK_IGNORE_ACTION | ATTACK_IGNORE_CLICKDELAY | NO_AUTO_CLICKDELAY_HANDLING)
	var/mob/living/L = attacker
	if(istype(L))
		L.Stagger(D.parry_data["UNARMED_PARRY_STAGGER"])

/// Unarmed parry data for pugilists
/datum/block_parry_data/unarmed/pugilist
	parry_respect_clickdelay = FALSE
	parry_stamina_cost = 4
	parry_attack_types = ATTACK_TYPE_UNARMED | ATTACK_TYPE_PROJECTILE | ATTACK_TYPE_TACKLE | ATTACK_TYPE_THROWN | ATTACK_TYPE_MELEE
	parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK | PARRY_LOCK_ATTACKING

	parry_time_windup = 0
	parry_time_spindown = 0
	parry_time_active = 5

	parry_time_perfect = 1.5
	parry_time_perfect_leeway = 1.5
	parry_imperfect_falloff_percent = 20
	parry_efficiency_perfect = 100
	parry_efficiency_perfect_override = list(
		TEXT_ATTACK_TYPE_PROJECTILE = 60,
	)

	parry_efficiency_considered_successful = 0.01
	parry_efficiency_to_counterattack = 0.01
	parry_max_attacks = INFINITY
	parry_failed_cooldown_duration =  1.5 SECONDS
	parry_failed_stagger_duration = 1 SECONDS
	parry_cooldown = 0
	parry_failed_clickcd_duration = 0.8

	parry_data = list(			// yeah it's snowflake
		"UNARMED_PARRY_STAGGER" = 3 SECONDS,
		"UNARMED_PARRY_PUNCH" = TRUE,
		"UNARMED_PARRY_MININUM_EFFICIENCY" = 90
	)
