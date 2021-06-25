/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	sight = 0
	see_in_dark = 2
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD,NANITE_HUD,DIAG_NANITE_FULL_HUD,RAD_HUD)
	pressure_resistance = 10
	has_field_of_vision = TRUE

	typing_indicator_enabled = TRUE

	var/last_click_move = 0 // Stores the previous next_move value.

	var/resize = 1 //Badminnery resize
	var/lastattacker = null
	var/lastattackerckey = null

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0		//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0		//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/staminaloss = 0		//Stamina damage, or exhaustion. You recover it slowly naturally, and are knocked down if it gets too high. Holodeck and hallucinations deal this.
	var/crit_threshold = HEALTH_THRESHOLD_CRIT // when the mob goes from "normal" to crit

	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

	// Combat - Blocking/Parrying system
	/// Our block_parry_data for unarmed blocks/parries. Currently only used for parrying, as unarmed block isn't implemented yet. YOU MUST RUN [get_block_parry_data(this)] INSTEAD OF DIRECTLY ACCESSING!
	var/datum/block_parry_data/block_parry_data = /datum/block_parry_data		// defaults to *something* because [combat_flags] dictates whether or not we can unarmed block/parry.
	/// Default
	var/datum/block_parry_data/default_block_parry_data = /datum/block_parry_data
	/// If we're a pugilist
	var/datum/block_parry_data/pugilist_block_parry_data = /datum/block_parry_data/unarmed/pugilist
	// Blocking
	/// The item the user is actively blocking with if any.
	var/obj/item/active_block_item
	// Parrying
	/// Whether or not the user is in the middle of an active parry. Set to [UNARMED_PARRY], [ITEM_PARRY], [MARTIAL_PARRY] if parrying.
	var/parrying = FALSE
	/// The itme the user is currently parrying with, if any.
	var/obj/item/active_parry_item
	/// world.time of parry action start
	var/parry_start_time = 0
	/// Current parry effect.
	var/obj/effect/abstract/parry/parry_visual_effect
	/// world.time of last parry end
	var/parry_end_time_last = 0
	/// Successful parries within the current parry cycle. It's a list of efficiency percentages.
	var/list/successful_parries

	var/confused = 0	//Makes the mob move in random directions.

	var/hallucination = 0 //Directly affects how long a mob will hallucinate for

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.
	var/timeofdeath = 0

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = FALSE //FALSE is off, INCORPOREAL_MOVE_BASIC is normal, INCORPOREAL_MOVE_SHADOW is for ninjas
								 //and INCORPOREAL_MOVE_JAUNT is blocked by holy water/salt
	/// Do we make floors dirty as we move?
	var/causes_dirt_buildup_on_floor = FALSE

	var/list/roundstart_quirks = list()

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/now_pushing = null //used by living/Bump() and living/PushAM() to prevent potential infinite loop.

	var/cameraFollow = null

	var/tod = null // Time of death

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/bloodcrawl = 0 //0 No blood crawling, BLOODCRAWL for bloodcrawling, BLOODCRAWL_EAT for crawling+mob devour
	var/holder = null //The holder for blood crawling
	var/limb_destroyer = 0 //1 Sets AI behavior that allows mobs to target and dismember limbs with their basic attack.

	var/mob_size = MOB_SIZE_HUMAN
	var/mob_biotypes = MOB_ORGANIC
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..
	var/has_limbs = 0 //does the mob have distinct limbs?(arms,legs, chest,head)

	var/list/pipes_shown = list()
	var/last_played_vent

	var/smoke_delay = 0 //used to prevent spam with smoke reagent reaction on mob.

	var/bubble_icon = "default" //what icon the mob uses for speechbubbles
	var/health_doll_icon //if this exists AND the normal sprite is bigger than 32x32, this is the replacement icon state (because health doll size limitations). the icon will always be screen_gen.dmi

	var/last_bumped = 0
	var/unique_name = 0 //if a mob's name should be appended with an id when created e.g. Mob (666)

	var/list/butcher_results = null //these will be yielded from butchering with a probability chance equal to the butcher item's effectiveness
	var/list/guaranteed_butcher_results = null //these will always be yielded from butchering
	var/butcher_difficulty = 0 //effectiveness prob. is modified negatively by this amount; positive numbers make it more difficult, negative ones make it easier

	var/hellbound = 0 //People who've signed infernal contracts are unrevivable.

	var/list/weather_immunities = list()

	var/stun_absorption = null //converted to a list of stun absorption sources this mob has when one is added

	var/blood_volume = 0 //how much blood the mob has
	var/integrating_blood = 0 //this is the variable you want to affect if you want to give the mob blood, this will slowly turn into normal blood, preventing some cheesyness, use AddIntegrationBlood() instead of modifying directly
	var/blood_ratio = 1 //How much blood the mob needs, in terms of ratio (i.e 1.2 will require BLOOD_VOLUME_NORMAL of 672) DO NOT GO ABOVE 3.55 Well, actually you can but, then they can't get enough blood.
	var/obj/effect/proc_holder/ranged_ability //Any ranged ability the mob has, as a click override

	var/see_override = 0 //0 for no override, sets see_invisible = see_override in silicon & carbon life process via update_sight()

	var/list/status_effects //a list of all status effects the mob has
	var/druggy = 0

	//Speech
	var/stuttering = 0
	var/slurring = 0
	var/cultslurring = 0
	var/clockcultslurring = 0
	var/derpspeech = 0

	var/list/implants = null

	var/datum/riding/riding_datum

	var/last_words	//used for database logging

	var/list/obj/effect/proc_holder/abilities = list()

	var/radiation = 0 //If the mob is irradiated.
	var/ventcrawl_layer = PIPING_LAYER_DEFAULT
	var/losebreath = 0

	//List of active diseases
	var/list/diseases = list() // list of all diseases in a mob
	var/list/disease_resistances = list()

	var/drag_slowdown = TRUE //Whether the mob is slowed down when dragging another prone mob

	var/rotate_on_lying = FALSE

	/// Next world.time when we can get the "you can't move while buckled to [thing]" message.
	var/buckle_message_cooldown = 0

	//// CITADEL STATION COMBAT ////
	/// See __DEFINES/combat.dm
	var/combat_flags = COMBAT_FLAGS_SPRINT_EXEMPT
	/// Next world.time when we will show a visible message on entering combat mode voluntarily again.
	var/combatmessagecooldown = 0

	var/incomingstammult = 1

	//Sprint buffer---
	var/sprint_buffer = 42					//Tiles
	var/sprint_buffer_max = 42
	var/sprint_buffer_regen_ds = 0.3		//Tiles per world.time decisecond
	var/sprint_buffer_regen_last = 0		//last world.time this was regen'd for math.
	var/sprint_stamina_cost = 0.70			//stamina loss per tile while insufficient sprint buffer.
	//---End

	// Stamina Buffer---
	/// Our stamina buffer
	var/stamina_buffer
	/// Stamina buffer regen modifier
	var/stamina_buffer_regen_mod = 1
	/// Last time stamina buffer regen was done
	var/stamina_buffer_regen_last = 0
	/// Last time we used stamina buffer
	var/stamina_buffer_last_use = 0
