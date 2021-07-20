SUBSYSTEM_DEF(traumas)
	name = "Traumas"
	flags = SS_NO_FIRE
	var/list/phobia_types
	var/list/phobia_words
	var/list/phobia_mobs
	var/list/phobia_objs
	var/list/phobia_turfs
	var/list/phobia_species

#define PHOBIA_FILE "phobia.json"

/datum/controller/subsystem/traumas/Initialize()
	//phobia types is to pull from randomly for brain traumas, e.g. conspiracies is for special assignment only
	phobia_types = list("spiders", "space", "security", "clowns", "greytide", "lizards",
						"skeletons", "snakes", "robots", "doctors", "authority", "the supernatural",
						"aliens", "strangers", "birds", "falling", "anime", "mimes", "cats", "syndicate",
						"eye"
						)

	phobia_words = list("spiders"   = strings(PHOBIA_FILE, "spiders"),
						"space"     = strings(PHOBIA_FILE, "space"),
						"security"  = strings(PHOBIA_FILE, "security"),
						"clowns"    = strings(PHOBIA_FILE, "clowns"),
						"greytide"  = strings(PHOBIA_FILE, "greytide"),
						"lizards"   = strings(PHOBIA_FILE, "lizards"),
						"skeletons" = strings(PHOBIA_FILE, "skeletons"),
						"snakes"	= strings(PHOBIA_FILE, "snakes"),
						"robots"	= strings(PHOBIA_FILE, "robots"),
						"doctors"	= strings(PHOBIA_FILE, "doctors"),
						"authority"	= strings(PHOBIA_FILE, "authority"),
						"the supernatural"	= strings(PHOBIA_FILE, "the supernatural"),
						"aliens"	= strings(PHOBIA_FILE, "aliens"),
						"strangers"	= strings(PHOBIA_FILE, "strangers"),
						"conspiracies" = strings(PHOBIA_FILE, "conspiracies"),
						"birds" = strings(PHOBIA_FILE, "birds"),
						"falling" = strings(PHOBIA_FILE, "falling"),
						"anime" = strings(PHOBIA_FILE, "anime"),
						"mimes" = strings(PHOBIA_FILE, "mimes"),
						"cats" = strings(PHOBIA_FILE, "cats"),
						"syndicate"= strings(PHOBIA_FILE, "syndicate"),
						"eye" = strings(PHOBIA_FILE, "eye")
						)

	phobia_mobs = list("spiders"  = typecacheof(list(/mob/living/simple_animal/hostile/poison/giant_spider)),
					   "security" = typecacheof(list(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209)),
					   "lizards"  = typecacheof(list(/mob/living/simple_animal/hostile/lizard)),
					   "skeletons" = typecacheof(list(/mob/living/simple_animal/hostile/skeleton)),
					   "snakes"   = typecacheof(list(/mob/living/simple_animal/hostile/retaliate/poison/snake)),
					   "robots"   = typecacheof(list(/mob/living/silicon/robot, /mob/living/silicon/ai,
					   /mob/living/simple_animal/drone, /mob/living/simple_animal/bot, /mob/living/simple_animal/hostile/swarmer, /mob/living/simple_animal/bot/honkbot)),
					   "doctors"   = typecacheof(list(/mob/living/simple_animal/bot/medbot)),
					   "the supernatural"   = typecacheof(list(/mob/living/simple_animal/hostile/construct,
					   /mob/living/simple_animal/hostile/clockwork, /mob/living/simple_animal/drone/cogscarab,
					   /mob/living/simple_animal/revenant, /mob/living/simple_animal/hostile/construct/shade)),
					   "aliens"   = typecacheof(list(/mob/living/carbon/alien, /mob/living/simple_animal/slime)),
					   "conspiracies" = typecacheof(list(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209, /mob/living/simple_animal/drone,
					   /mob/living/simple_animal/pet/penguin)),
					   "birds" = typecacheof(list(/mob/living/simple_animal/parrot, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
					   /mob/living/simple_animal/pet/penguin)),
					   "anime" = typecacheof(list(/mob/living/simple_animal/hostile/guardian)),
					   "cats"= typecacheof(list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/hostile/cat_butcherer)),
					   "syndicate" = typecacheof(list(/mob/living/simple_animal/hostile/syndicate, /mob/living/simple_animal/hostile/viscerator, /mob/living/simple_animal/hostile/carp/cayenne, /mob/living/silicon/robot/modules/syndicate)),
					   "eye" = typecacheof(list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher, /mob/living/simple_animal/hostile/carp/eyeball))
					   )


	phobia_objs = list("snakes" = typecacheof(list(/obj/item/rod_of_asclepius)),

					"spiders"   = typecacheof(list(/obj/structure/spider)),

					"security"  = typecacheof(list(/obj/item/clothing/under/rank/security/officer, /obj/item/clothing/under/rank/security/warden,
											 	 /obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/security/detective,
												 /obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs,
												 /obj/machinery/door/airlock/security, /obj/effect/hallucination/simple/securitron)),

					"clowns" = typecacheof(list(/obj/item/clothing/under/rank/civilian/clown, /obj/item/clothing/shoes/clown_shoes,
												 /obj/item/clothing/mask/gas/clown_hat, /obj/item/instrument/bikehorn,
												 /obj/item/pda/clown, /obj/item/grown/bananapeel)),

					"greytide"  = typecacheof(list(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod,
												 /obj/item/spear, /obj/item/clothing/mask/gas)),

					"lizards"   = typecacheof(list(/obj/item/toy/plush/lizardplushie, /obj/item/reagent_containers/food/snacks/kebab/tail,
												 /obj/item/organ/tail/lizard, /obj/item/reagent_containers/food/drinks/bottle/lizardwine)),

					"skeletons" = typecacheof(list(/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,
												 /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton,
												 /obj/effect/decal/remains/human)),
					"conspiracies" = typecacheof(list(/obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/security/head_of_security,
												 /obj/item/clothing/under/rank/engineering/chief_engineer, /obj/item/clothing/under/rank/medical/chief_medical_officer,
												 /obj/item/clothing/under/rank/civilian/head_of_personnel, /obj/item/clothing/under/rank/rnd/research_director,
												 /obj/item/clothing/under/rank/security/head_of_security/grey, /obj/item/clothing/under/rank/security/head_of_security/alt,
												 /obj/item/clothing/under/rank/rnd/research_director/alt, /obj/item/clothing/under/rank/rnd/research_director/turtleneck,
												 /obj/item/clothing/under/rank/captain/parade, /obj/item/clothing/under/rank/security/head_of_security/parade, /obj/item/clothing/under/rank/security/head_of_security/parade/female,
												 /obj/item/clothing/head/helmet/abductor, /obj/item/clothing/suit/armor/abductor/vest, /obj/item/abductor/baton,
												 /obj/item/storage/belt/military/abductor, /obj/item/gun/energy/alien, /obj/item/abductor/silencer,
												 /obj/item/abductor/gizmo, /obj/item/clothing/under/rank/centcom/officer,
												 /obj/item/clothing/suit/space/hardsuit/ert, /obj/item/clothing/suit/space/hardsuit/ert/sec,
												 /obj/item/clothing/suit/space/hardsuit/ert/engi, /obj/item/clothing/suit/space/hardsuit/ert/med,
												 /obj/item/clothing/suit/space/hardsuit/deathsquad, /obj/item/clothing/head/helmet/space/hardsuit/deathsquad,
												 /obj/machinery/door/airlock/centcom)),
					"robots"   = typecacheof(list(/obj/machinery/computer/upload, /obj/item/aiModule/, /obj/machinery/recharge_station,
						/obj/item/aicard, /obj/item/deactivated_swarmer, /obj/effect/mob_spawn/swarmer)),

					"doctors"   = typecacheof(list(/obj/item/clothing/under/rank/medical/doctor, /obj/item/clothing/under/rank/medical/chemist,
						/obj/item/clothing/under/rank/medical/doctor/nurse, /obj/item/clothing/under/rank/medical/chief_medical_officer,
						/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/pill/, /obj/item/reagent_containers/hypospray,
						/obj/item/storage/firstaid, /obj/item/storage/pill_bottle, /obj/item/healthanalyzer,
						/obj/structure/sign/departments/medbay, /obj/machinery/door/airlock/medical, /obj/machinery/sleeper,
						/obj/machinery/dna_scannernew, /obj/machinery/atmospherics/component/unary/cryo_cell, /obj/item/surgical_drapes,
						/obj/item/retractor, /obj/item/hemostat, /obj/item/cautery, /obj/item/surgicaldrill, /obj/item/scalpel, /obj/item/circular_saw,
						/obj/item/clothing/suit/bio_suit/plaguedoctorsuit, /obj/item/clothing/head/plaguedoctorhat, /obj/item/clothing/mask/gas/plaguedoctor)),

					"authority"   = typecacheof(list(/obj/item/clothing/under/rank/captain,  /obj/item/clothing/under/rank/civilian/head_of_personnel,
						/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/rnd/research_director,
						/obj/item/clothing/under/rank/medical/chief_medical_officer, /obj/item/clothing/under/rank/engineering/chief_engineer,
						/obj/item/clothing/under/rank/centcom/officer, /obj/item/clothing/under/rank/centcom/commander,
						/obj/item/melee/classic_baton/telescopic, /obj/item/card/id/silver, /obj/item/card/id/gold,
						/obj/item/card/id/captains_spare, /obj/item/card/id/centcom, /obj/machinery/door/airlock/command)),

					"the supernatural"  = typecacheof(list(/obj/structure/destructible/cult, /obj/item/tome,
						/obj/item/melee/cultblade, /obj/item/cult_bastard, /obj/item/restraints/legcuffs/bola/cult,
						/obj/item/clothing/suit/cultrobes, /obj/item/clothing/suit/space/hardsuit/cult,
						/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/head/hooded/cult_hoodie, /obj/effect/rune,
						/obj/item/stack/sheet/runed_metal, /obj/machinery/door/airlock/cult, /obj/singularity/narsie,
						/obj/item/soulstone,
						/obj/structure/destructible/clockwork, /obj/item/clockwork, /obj/item/clothing/suit/armor/clockwork,
						/obj/item/clothing/glasses/judicial_visor, /obj/effect/clockwork/sigil/, /obj/item/stack/tile/brass,
						/obj/machinery/door/airlock/clockwork,
						/obj/item/clothing/suit/wizrobe, /obj/item/clothing/head/wizard, /obj/item/spellbook, /obj/item/staff,
						/obj/item/clothing/suit/space/hardsuit/shielded/wizard, /obj/item/clothing/suit/space/hardsuit/wizard,
						/obj/item/gun/magic/staff, /obj/item/gun/magic/wand,
						/obj/item/nullrod, /obj/item/clothing/under/rank/civilian/chaplain)),

					"aliens"   = typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/item/organ/body_egg/alien_embryo,
						/obj/structure/alien, /obj/item/toy/toy_xeno,
						/obj/item/clothing/suit/armor/abductor, /obj/item/abductor, /obj/item/gun/energy/alien,
						/obj/item/abductor/baton, /obj/item/radio/headset/abductor, /obj/item/scalpel/alien, /obj/item/hemostat/alien,
						/obj/item/retractor/alien, /obj/item/circular_saw/alien, /obj/item/surgicaldrill/alien, /obj/item/cautery/alien,
						/obj/item/clothing/head/helmet/abductor, /obj/structure/bed/abductor, /obj/structure/table_frame/abductor,
						/obj/structure/table/abductor, /obj/structure/table/optable/abductor, /obj/structure/closet/abductor, /obj/item/organ/heart/gland,
						/obj/machinery/abductor, /obj/item/crowbar/abductor, /obj/item/screwdriver/abductor, /obj/item/weldingtool/abductor,
						/obj/item/wirecutters/abductor, /obj/item/wrench/abductor, /obj/item/stack/sheet/mineral/abductor)),

					"birds" = typecacheof(list(/obj/item/clothing/mask/gas/plaguedoctor, /obj/item/reagent_containers/food/snacks/cracker,
						/obj/item/clothing/suit/chickensuit, /obj/item/clothing/head/chicken,
						/obj/item/clothing/suit/toggle/owlwings, /obj/item/clothing/under/costume/owl, /obj/item/clothing/mask/gas/owl_mask,
						/obj/item/clothing/under/costume/griffin, /obj/item/clothing/shoes/griffin, /obj/item/clothing/head/griffin,
						/obj/item/clothing/head/helmet/space/freedom, /obj/item/clothing/suit/space/freedom)),

					"anime" = typecacheof(list(/obj/item/clothing/under/costume/schoolgirl, /obj/item/katana, /obj/item/reagent_containers/food/snacks/sashimi, /obj/item/reagent_containers/food/snacks/chawanmushi,
					   /obj/item/reagent_containers/food/drinks/bottle/sake, /obj/item/throwing_star, /obj/item/clothing/head/kitty/genuine, /obj/item/clothing/suit/space/space_ninja,
					   /obj/item/clothing/mask/gas/space_ninja, /obj/item/clothing/shoes/space_ninja, /obj/item/clothing/gloves/space_ninja, /obj/item/vibro_weapon,
					   /obj/item/nullrod/scythe/vibro, /obj/item/energy_katana, /obj/item/toy/katana, /obj/item/nullrod/claymore/katana, /obj/structure/window/paperframe, /obj/structure/mineral_door/paperframe)),

					"mimes" = typecacheof(list(/obj/item/pda/mime, /obj/item/clothing/under/rank/civilian/mime, /obj/item/clothing/mask/gas/mime,
						/obj/item/clothing/head/frenchberet, /obj/item/clothing/suit/suspenders, /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
						/obj/item/storage/backpack/mime, /obj/item/reagent_containers/food/snacks/grown/banana/mime,
						/obj/item/grown/bananapeel/mimanapeel, /obj/item/cartridge/virus/mime, /obj/item/clothing/shoes/sneakers/mime,
						/obj/item/bedsheet/mime, /obj/item/reagent_containers/food/snacks/burger/mime, /obj/item/clothing/head/beret,
						/obj/item/toy/figure/mime, /obj/item/toy/crayon/mime, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced, /obj/mecha/combat/reticence)),

					"cats" = typecacheof(list(/obj/item/organ/ears/cat, /obj/item/organ/tail/cat, /obj/item/laser_pointer, /obj/item/toy/cattoy, /obj/item/clothing/head/kitty,
						/obj/item/clothing/head/collectable/kitty, /obj/item/melee/chainofcommand/tailwhip/kitty, /obj/item/stack/sheet/animalhide/cat)),

					"syndicate" = typecacheof(list(/obj/item/stack/tile/mineral/plastitanium, /obj/machinery/computer/shuttle/syndicate, /obj/machinery/computer/shuttle/syndicate/recall, /obj/machinery/computer/shuttle/syndicate/drop_pod, /obj/machinery/computer/camera_advanced/shuttle_docker/syndicate, /obj/machinery/recharge_station,
						/obj/machinery/porta_turret/syndicate, /obj/structure/closet/syndicate, /obj/machinery/suit_storage_unit/syndicate, /obj/item/clothing/under/syndicate, /obj/item/folder/syndicate, /obj/item/documents/syndicate, /obj/item/clothing/glasses/phantomthief/syndicate, /obj/item/antag_spawner/nuke_ops, /obj/item/storage/box/syndicate,
						/obj/structure/fluff/empty_sleeper/syndicate, /obj/item/implant/radio/syndicate, /obj/item/clothing/head/helmet/space/syndicate, /obj/machinery/nuclearbomb/syndicate, /obj/item/grenade/syndieminibomb, /obj/item/storage/backpack/duffelbag/syndie, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver,
						/obj/item/gun/ballistic/automatic/shotgun/bulldog, /obj/item/gun/ballistic/automatic/c20r, /obj/item/gun/ballistic/automatic/m90, /obj/item/gun/ballistic/automatic/l6_saw, /obj/item/storage/belt/grenade/full, /obj/item/gun/ballistic/automatic/sniper_rifle/syndicate, /obj/item/gun/energy/kinetic_accelerator/crossbow,
						/obj/item/melee/transforming/energy/sword/saber, /obj/item/dualsaber, /obj/item/melee/powerfist, /obj/item/storage/box/syndie_kit, /obj/item/grenade/spawnergrenade/manhacks, /obj/item/grenade/chem_grenade/bioterrorfoam, /obj/item/reagent_containers/spray/chemsprayer/bioterror, /obj/item/ammo_box/magazine/m10mm,
						/obj/item/ammo_box/magazine/pistolm9mm, /obj/item/ammo_box/a357, /obj/item/ammo_box/magazine/m12g, /obj/item/ammo_box/magazine/mm195x129, /obj/item/antag_spawner/nuke_ops, /obj/mecha/combat/gygax/dark, /obj/mecha/combat/marauder/mauler, /obj/item/soap/syndie, /obj/item/gun/syringe/syndicate, /obj/item/cartridge/virus/syndicate,
						/obj/item/cartridge/virus/frame, /obj/item/chameleon, /obj/item/storage/box/syndie_kit/cutouts, /obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/card/emag, /obj/item/storage/toolbox/syndicate, /obj/item/storage/book/bible/syndicate, /obj/item/encryptionkey/binary, /obj/item/encryptionkey/syndicate, /obj/item/aiModule/syndicate,
						/obj/item/clothing/shoes/magboots/syndie, /obj/item/powersink, /obj/item/sbeacondrop, /obj/item/sbeacondrop/bomb, /obj/item/syndicatedetonator, /obj/item/shield/energy, /obj/item/assault_pod, /obj/item/slimepotion/slime/sentience/nuclear, /obj/item/stack/telecrystal, /obj/item/jammer, /obj/item/codespeak_manual/unlimited,
						/obj/item/toy/cards/deck/syndicate, /obj/item/storage/secure/briefcase/syndie, /obj/item/storage/fancy/cigarettes/cigpack_syndicate, /obj/item/toy/syndicateballoon, /obj/item/clothing/gloves/fingerless/pugilist/rapid, /obj/item/paper/fluff/ruins/thederelict/syndie_mission, /obj/item/organ/cyberimp/eyes/hud/security/syndicate, /obj/item/clothing/head/HoS/syndicate,
						/obj/machinery/computer/pod/old/syndicate, /obj/machinery/vending/medical/syndicate_access, /obj/item/mmi/syndie, /obj/item/target/syndicate, /obj/machinery/vending/cigarette/syndicate, /obj/item/robot_module/syndicate, /obj/item/clothing/mask/gas/syndicate, /obj/machinery/power/singularity_beacon/syndicate, /obj/item/clothing/head/syndicatefake,
						/obj/item/radio/headset/syndicate, /obj/item/gun/ballistic/automatic/pistol/antitank/syndicate, /obj/item/pda/syndicate, /obj/item/clothing/suit/armor/vest/capcarapace/syndicate, /obj/item/gun/ballistic/automatic/flechette, /obj/item/ammo_box/magazine/flechette, /obj/item/clothing/suit/toggle/lawyer/black/syndie, /obj/item/melee/transforming/energy/sword/cx/traitor,
						/obj/structure/sign/poster/contraband/syndicate_pistol, /obj/structure/sign/poster/contraband/syndicate_recruitment, /obj/item/bedsheet/syndie, /obj/item/borg/upgrade/syndicate, /obj/item/tank/jetpack/oxygen/harness, /obj/item/firing_pin/implant/pindicate, /obj/item/reagent_containers/glass/bottle/traitor, /obj/item/storage/belt/military,
						/obj/item/shockpaddles/syndicate, /obj/item/clothing/mask/cigarette/syndicate, /obj/item/toy/plush/nukeplushie)),

					"eye" = typecacheof(list(/obj/item/organ/eyes, /obj/item/reagent_containers/syringe))
						)

	phobia_turfs = list("space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)),
						"the supernatural" = typecacheof(list(/turf/open/floor/clockwork, /turf/closed/wall/clockwork,
						/turf/open/floor/plasteel/cult, /turf/closed/wall/mineral/cult)),
						"aliens" = typecacheof(list(/turf/open/floor/plating/abductor, /turf/open/floor/plating/abductor2,
						/turf/open/floor/mineral/abductor, /turf/closed/wall/mineral/abductor)),
						"falling" = typecacheof(list(/turf/open/chasm, /turf/open/floor/fakepit)),
						"syndicate" = typecacheof(list(/turf/closed/wall/mineral/plastitanium, /turf/open/floor/mineral/plastitanium, /turf/open/floor/plasteel/shuttle/red/syndicate))
						)

	phobia_species = list("lizards" = typecacheof(list(/datum/species/lizard)),
						  "skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
						  "conspiracies" = typecacheof(list(/datum/species/abductor, /datum/species/lizard, /datum/species/synth, /datum/species/corporate)),
						  "robots" = typecacheof(list(/datum/species/android, /datum/species/synth)),
						  "the supernatural" = typecacheof(list(/datum/species/golem/clockwork, /datum/species/golem/runic)),
						  "aliens" = typecacheof(list(/datum/species/abductor, /datum/species/jelly, /datum/species/pod, /datum/species/shadow)),
						  "anime" = typecacheof(list(/datum/species/human/felinid)),
						  "cats" = typecacheof(list(/datum/species/human/felinid)),
						  "syndicate" = typecacheof(list(/datum/species/corporate, /datum/species/zombie/infectious)),
						  "arachnid" = typecacheof(list(/datum/species/arachnid))
						 )

	return ..()

#undef PHOBIA_FILE
