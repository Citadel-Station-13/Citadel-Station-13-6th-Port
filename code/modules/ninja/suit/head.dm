/**
  * # Ninja Hood
  *
  * Space ninja's hood.  Provides armor and blocks AI tracking.
  *
  * A hood that only exists as a part of space ninja's starting kit.  Provides armor equal of space ninja's suit and disallows an AI to track the wearer.
  *
  */
/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20,"energy" = 30, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	blockTracking = TRUE//Roughly the only unique thing about this helmet.
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/space_ninja/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
