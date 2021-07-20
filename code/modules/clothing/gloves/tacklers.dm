/obj/item/clothing/gloves/tackler
	name = "gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon_state = "tackle"
	item_state = "tackle"
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	//custom_premium_price = PRICE_EXPENSIVE
	/// For storing our tackler datum so we can remove it after
	var/datum/component/tackler
	/// See: [/datum/component/tackler/var/stamina_cost]
	var/tackle_stam_cost = 25
	/// See: [/datum/component/tackler/var/base_knockdown]
	var/base_knockdown = 1 SECONDS
	/// See: [/datum/component/tackler/var/range]
	var/tackle_range = 4
	/// See: [/datum/component/tackler/var/min_distance]
	var/min_distance = 0
	/// See: [/datum/component/tackler/var/speed]
	var/tackle_speed = 1
	/// See: [/datum/component/tackler/var/skill_mod]
	var/skill_mod = 1

/obj/item/clothing/gloves/tackler/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		tackler = H.AddComponent(/datum/component/tackler, stamina_cost=tackle_stam_cost, base_knockdown = base_knockdown, range = tackle_range, speed = tackle_speed, skill_mod = skill_mod, min_distance = min_distance)

/obj/item/clothing/gloves/tackler/dropped(mob/user)
	. = ..()
	if(tackler)
		qdel(tackler)

/obj/item/clothing/gloves/tackler/dolphin
	name = "dolphin gloves"
	desc = "Sleek, aerodynamic gripper gloves that are less effective at actually performing takedowns, but more effective at letting the user sail through the hallways and cause accidents."
	icon_state = "tackledolphin"
	item_state = "tackledolphin"

	tackle_stam_cost = 15
	base_knockdown = 0.5 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = -2

/obj/item/clothing/gloves/tackler/combat
	name = "gorilla gloves"
	desc = "Premium quality combative gloves, heavily reinforced to give the user an edge in close combat tackles, though they are more taxing to use than normal gripper gloves. Fireproof to boot!"
	icon_state = "combat"
	item_state = "blackgloves"

	tackle_stam_cost = 35
	base_knockdown = 1.5 SECONDS
	tackle_range = 5
	skill_mod = 3

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	strip_mod = 1.2 // because apparently black gloves had this

/obj/item/clothing/gloves/tackler/combat/goliath
	name = "goliath gloves"
	desc = "Rudimentary combat gloves. To be fair, Goliaths are really good at grappling... Also, they're fireproof."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goligloves"
	item_state = "goligloves"

	tackle_stam_cost = 25
	base_knockdown = 1 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = 1

/obj/item/clothing/gloves/tackler/combat/insulated
	name = "guerrilla gloves"
	desc = "Superior quality combative gloves, good for performing tackle takedowns as well as absorbing electrical shocks."
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_mod = 1.5 // and combat gloves had this??

/obj/item/clothing/gloves/tackler/combat/insulated/infiltrator
	name = "insidious guerrilla gloves"
	desc = "Specialized combat gloves for carrying people around. Transfers tactical kidnapping and tackling knowledge to the user via the use of nanochips."
	icon_state = "infiltrator"
	item_state = "infiltrator"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/carrytrait = TRAIT_QUICKER_CARRY

/obj/item/clothing/gloves/tackler/combat/insulated/infiltrator/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_GLOVES)
		ADD_TRAIT(user, carrytrait, GLOVE_TRAIT)

/obj/item/clothing/gloves/tackler/combat/insulated/infiltrator/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, carrytrait, GLOVE_TRAIT)

/obj/item/clothing/gloves/tackler/rocket
	name = "rocket gloves"
	desc = "The ultimate in high risk, high reward, perfect for when you need to stop a criminal from fifty feet away or die trying. Banned in most Spinward gridiron football and rugby leagues."
	icon_state = "tacklerocket"
	item_state = "tacklerocket"

	tackle_stam_cost = 50
	base_knockdown = 2 SECONDS
	tackle_range = 10
	min_distance = 7
	tackle_speed = 6
	skill_mod = 7

/obj/item/clothing/gloves/tackler/offbrand
	name = "improvised gripper gloves"
	desc = "Ratty looking fingerless gloves wrapped with sticky tape. Beware anyone wearing these, for they clearly have no shame and nothing to lose."
	icon_state = "fingerless"
	item_state = "fingerless"

	tackle_stam_cost = 30
	base_knockdown = 1.75 SECONDS
	min_distance = 2
	skill_mod = -1
