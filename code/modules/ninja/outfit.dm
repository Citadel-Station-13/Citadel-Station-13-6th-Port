/datum/outfit/ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/color/black/trackless
	suit = /obj/item/clothing/suit/space/space_ninja
	glasses = /obj/item/clothing/glasses/night/syndicate
	mask = /obj/item/clothing/mask/gas/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	l_pocket = /obj/item/grenade/plastic/c4/ninja
	r_pocket = /obj/item/hypospray/mkii/CMO/combat
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = SLOT_S_STORE
	belt = /obj/item/energy_katana
	implants = list(/obj/item/implant/explosive)


/datum/outfit/ninja/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	if(istype(H.wear_suit, suit))
		var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
		if(istype(H.belt, belt))
			S.energyKatana = H.belt
