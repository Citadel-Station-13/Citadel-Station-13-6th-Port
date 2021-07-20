/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = /obj/item/clothing/accessory/talisman
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = /obj/item/clothing/accessory/skullcodpiece
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = /obj/item/clothing/gloves/bracer
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = /obj/item/clothing/suit/hooded/cloak/goliath
	time = 50
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2) //it takes 4 goliaths to make 1 cloak if the plates are skinned
	category = CAT_PRIMAL

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = /obj/item/clothing/suit/hooded/cloak/drake
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/ashdrake = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonebag
	name = "Bone Satchel"
	result = /obj/item/storage/backpack/satchel/bone
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 3,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = /obj/item/spear/bonespear
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = /obj/item/fireaxe/boneaxe
	time = 50
	reqs = list(/obj/item/stack/sheet/bone = 6,
				 /obj/item/stack/sheet/sinew = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonfire
	name = "Bonfire"
	time = 60
	reqs = list(/obj/item/grown/log = 5)
	result = /obj/structure/bonfire
	category = CAT_PRIMAL

/datum/crafting_recipe/headpike
	name = "Spike Head (Glass Spear)"
	time = 65
	reqs = list(/obj/item/spear = 1,
				/obj/item/bodypart/head = 1)
	parts = list(/obj/item/bodypart/head = 1,
			/obj/item/spear = 1)
	result = /obj/structure/headpike
	category = CAT_PRIMAL

/datum/crafting_recipe/headpikebone
	name = "Spike Head (Bone Spear)"
	time = 65
	reqs = list(/obj/item/spear/bonespear = 1,
				/obj/item/bodypart/head = 1)
	parts = list(/obj/item/bodypart/head = 1,
			/obj/item/spear/bonespear = 1)
	result = /obj/structure/headpike/bone
	category = CAT_PRIMAL

/datum/crafting_recipe/quiver
	name = "Quiver"
	result = /obj/item/storage/belt/quiver
	time = 80
	reqs = list(/obj/item/stack/sheet/leather = 3,
				 /obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_bow
	name = "Bone Bow"
	result = /obj/item/gun/ballistic/bow/ashen
	time = 120 // 80+120 = 200
	reqs = list(/obj/item/stack/sheet/bone = 8,
				 /obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/*/datum/crafting_recipe/bow_tablet
	name = "Sandstone Bow Making Manual"
	result = /obj/item/book/granter/crafting_recipe/bone_bow
	time = 200 //Scribing // don't care
	always_availible = FALSE
	reqs = list(/obj/item/stack/rods = 1,
				 /obj/item/stack/sheet/mineral/sandstone = 4)
	category = CAT_PRIMAL*/

/datum/crafting_recipe/rib
	name = "Collosal Rib"
	always_availible = FALSE
	reqs = list(
            /obj/item/stack/sheet/bone = 10,
            /datum/reagent/oil = 5)
	result = /obj/structure/statue/bone/rib
	subcategory = CAT_PRIMAL

/datum/crafting_recipe/skull
	name = "Skull Carving"
	always_availible = FALSE
	reqs = list(
            /obj/item/stack/sheet/bone = 6,
            /datum/reagent/oil = 5)
	result = /obj/structure/statue/bone/skull
	category = CAT_PRIMAL

/datum/crafting_recipe/halfskull
	name = "Cracked Skull Carving"
	always_availible = FALSE
	reqs = list(
            /obj/item/stack/sheet/bone = 3,
            /datum/reagent/oil = 5)
	result = /obj/structure/statue/bone/skull/half
	category = CAT_PRIMAL

/datum/crafting_recipe/boneshovel
	name = "Serrated Bone Shovel"
	always_availible = FALSE
	reqs = list(
            /obj/item/stack/sheet/bone = 4,
            /datum/reagent/oil = 5,
            /obj/item/shovel/spade = 1)
	result = /obj/item/shovel/serrated
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_screwdriver
	name = "Bone Screwdriver"
	result = /obj/item/screwdriver/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_crowbar
	name = "Bone Crowbar"
	result = /obj/item/crowbar/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_cutters
	name = "Bone Wirecutters"
	result = /obj/item/wirecutters/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_wrench
	name = "Bone Wrench"
	result = /obj/item/wrench/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/necropolis_welding
	name = "Necropolis Welding Torch"
	result = /obj/item/weldingtool/experimental/ashwalker
	time = 120
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 2,
				 /obj/item/organ/regenerative_core = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/tribalbelt
	name = "Hunter's Belt"
	result = /obj/item/storage/belt/mining/primitive
	time = 80
	reqs = list(/obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliath_gloves
	name = "Goliath Gloves"
	result = /obj/item/clothing/gloves/tackler/combat/goliath
	time = 80
	reqs = list(/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2,
				/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliath_drapes
	name = "Goliath Drapes"
	result = /obj/item/surgical_drapes/goliath
	time = 80
	reqs = list(/obj/item/stack/sheet/sinew = 1,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/diamond_scalpel
	name = "Diamond Scalpel"
	result = /obj/item/scalpel/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1,
				 /obj/item/stack/sheet/mineral/diamond = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_retractor
	name = "Bone Retractor"
	result = /obj/item/retractor/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/diamond_bonesaw
	name = "Diamond Bonesaw"
	result = /obj/item/circular_saw/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1,
				 /obj/item/organ/regenerative_core = 1,
				 /obj/item/stack/sheet/mineral/diamond = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/femurstat
	name = "Bone Hemostat"
	result = /obj/item/hemostat/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_bonesetter
	name = "Bone Bonersetter"
	result = /obj/item/bonesetter/bone
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/coretery
	name = "Necropolis Cautery"
	result = /obj/item/cautery/ashwalker
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 1,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1,
				 /obj/item/organ/regenerative_core = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_spade
	name = "Bone Spade"
	result = /obj/item/shovel/spade/bone
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 1,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_hatchet
	name = "Bone Hatchet"
	result = /obj/item/hatchet/bone
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 1,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_cultivator
	name = "Bone Cultivator"
	result = /obj/item/cultivator/bone
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_glaive
	name = "Necropolis Glaive"
	result = /obj/item/kinetic_crusher/glaive/bone
	time = 120
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/mineral/wood = 4,
				 /obj/item/stack/sheet/sinew = 4,
				 /obj/item/organ/regenerative_core = 2,
				 /obj/item/stack/sheet/mineral/diamond = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 2,
				 /obj/item/stack/sheet/leather = 2)
	category = CAT_PRIMAL
