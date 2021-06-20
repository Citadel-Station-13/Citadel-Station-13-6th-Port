/**
  * # Ninja Shoes
  *
  * Space ninja's shoes.  Gives him armor on his feet.
  *
  * Space ninja's ninja shoes.  How mousey.  Gives him slip protection and protection against attacks.
  * Also are temperature resistant.
  *
  */
/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20,"energy" = 30, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/space_ninja/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_SHOES)
		ADD_TRAIT(user, TRAIT_SILENT_STEP, SHOES_TRAIT)

/obj/item/clothing/shoes/space_ninja/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_SILENT_STEP, SHOES_TRAIT)
