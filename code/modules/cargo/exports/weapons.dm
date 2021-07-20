// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/makeshift_shield
	cost = 30
	unit_name = "nonstandard shield"
	export_types = list(/obj/item/shield/riot, /obj/item/shield/riot/roman, /obj/item/shield/riot/buckler, /obj/item/shield/makeshift)

/datum/export/weapon/riot_shield
	cost = 50
	unit_name = "riot shield"
	export_types = list(/obj/item/shield/riot, /obj/item/shield/riot/tower)

/datum/export/weapon/riot_shield
	cost = 70
	unit_name = "flash shield"
	export_types = list(/obj/item/shield/riot/flash)

/datum/export/weapon/tele_shield
	cost = 100
	unit_name = "tele shield"
	export_types = list(/obj/item/shield/riot/tele, /obj/item/shield/energy)

/datum/export/weapon/baton
	cost = 100
	unit_name = "stun baton"
	export_types = list(/obj/item/melee/baton)
	exclude_types = list(/obj/item/melee/baton/cattleprod)
	include_subtypes = TRUE

/datum/export/weapon/knife
	cost = 100
	unit_name = "combat knife"
	export_types = list(/obj/item/kitchen/knife/combat)

/datum/export/weapon/taser
	cost = 200
	unit_name = "hybrid taser"
	export_types = list(/obj/item/gun/energy/e_gun/advtaser)

/datum/export/weapon/laser
	cost = 200
	unit_name = "laser gun"
	export_types = list(/obj/item/gun/energy/laser)

/datum/export/weapon/disabler
	cost = 50
	unit_name = "disabler"
	export_types = list(/obj/item/gun/energy/disabler)

/datum/export/weapon/energy_gun
	cost = 200
	unit_name = "energy gun"
	export_types = list(/obj/item/gun/energy/e_gun)

/datum/export/weapon/wt550
	cost = 130
	unit_name = "WT-550 automatic rifle"
	export_types = list(/obj/item/gun/ballistic/automatic/wt550)

/datum/export/weapon/shotgun
	cost = 200
	unit_name = "combat shotgun"
	export_types = list(/obj/item/gun/ballistic/shotgun/automatic/combat)

/datum/export/weapon/flashbang
	cost = 5
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 5
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/grenade/chem_grenade/teargas)

/datum/export/weapon/flash
	cost = 5
	unit_name = "handheld flash"
	export_types = list(/obj/item/assembly/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/restraints/handcuffs)

//////////////
//RND Guns////
//////////////

/datum/export/weapon/lasercarbine
	cost = 120
	unit_name = "laser carbine"
	export_types = list(/obj/item/gun/energy/laser/carbine)
	include_subtypes = TRUE

/datum/export/weapon/teslagun
	cost = 130
	unit_name = "tesla revolver"
	export_types = list(/obj/item/gun/energy/tesla_revolver)

/datum/export/weapon/aeg
	cost = 200 //Endless power
	unit_name = "advanced energy gun"
	export_types = list(/obj/item/gun/energy/e_gun/nuclear)

/datum/export/weapon/deconer
	cost = 600
	unit_name = "decloner"
	export_types = list(/obj/item/gun/energy/decloner)

/datum/export/weapon/ntsniper
	cost = 500
	unit_name = "beam rifle"
	export_types = list(/obj/item/gun/energy/beam_rifle)

/datum/export/weapon/needle_gun
	cost = 50
	unit_name = "syringe revolver"
	export_types = list(/obj/item/gun/syringe/rapidsyringe)

/datum/export/weapon/temp_gun
	cost = 175
	unit_name = "small temperature gun"
	export_types = list(/obj/item/gun/energy/temperature)

/datum/export/weapon/flowergun
	cost = 100
	unit_name = "floral somatoray"
	export_types = list(/obj/item/gun/energy/floragun)

/datum/export/weapon/xraygun
	cost = 300 //Wall hacks
	unit_name = "x ray gun"
	export_types = list(/obj/item/gun/energy/xray)

/datum/export/weapon/ioncarbine
	cost = 200
	unit_name = "ion carbine"
	export_types = list(/obj/item/gun/energy/ionrifle/carbine)

/datum/export/weapon/largeebow
	cost = 500
	unit_name = "crossbow"
	export_types = list(/obj/item/gun/energy/kinetic_accelerator/crossbow/large)

/datum/export/weapon/largebomb
	cost = 20
	unit_name = "large grenade"
	export_types = list(/obj/item/grenade/chem_grenade/large)

/datum/export/weapon/gravworm
	cost = 150
	unit_name = "bluespace weapon"
	export_types = list(/obj/item/gun/energy/wormhole_projector, /obj/item/gun/energy/gravity_gun)

/datum/export/weapon/cryopryo
	cost = 70
	unit_name = "heat based grenade"
	export_types = list(/obj/item/grenade/chem_grenade/pyro, /obj/item/grenade/chem_grenade/cryo)

/datum/export/weapon/advgrenade
	cost = 80
	unit_name = "advanced grenade"
	export_types = list(/obj/item/grenade/chem_grenade/adv_release)

/////////////////
//Ammo and Pins//
/////////////////

/datum/export/weapon/wtammo
	cost = 15
	unit_name = "WT-550 automatic rifle ammo"
	export_types = list(/obj/item/ammo_box/magazine/wt550m9, /obj/item/ammo_box/magazine/wt550m9/wtrubber)

/datum/export/weapon/wtammo/advanced
	cost = 45
	unit_name = "advanced WT-550 automatic rifle ammo"
	export_types = list( /obj/item/ammo_box/magazine/wt550m9/wtap,  /obj/item/ammo_box/magazine/wt550m9/wttx, /obj/item/ammo_box/magazine/wt550m9/wtic)

/datum/export/weapon/mindshield
	cost = 80
	unit_name = "mindshield locked pin"
	export_types = list(/obj/item/firing_pin/implant/mindshield)

/datum/export/weapon/testrange
	cost = 20
	unit_name = "test range pin"
	export_types = list(/obj/item/firing_pin/test_range)

/datum/export/weapon/techslug
	cost = 30
	k_elasticity = 0
	unit_name = "advanced shotgun shell"
	export_types = list(/obj/item/ammo_casing/shotgun/dragonsbreath, /obj/item/ammo_casing/shotgun/meteorslug, /obj/item/ammo_casing/shotgun/pulseslug, /obj/item/ammo_casing/shotgun/frag12, /obj/item/ammo_casing/shotgun/ion, /obj/item/ammo_casing/shotgun/laserslug)

/////////////////////////
//Bow and Arrows/////////
/////////////////////////

/datum/export/weapon/bows
	cost = 450
	unit_name = "bow"
	export_types = list(/obj/item/gun/ballistic/bow)

/datum/export/weapon/arrows
	cost = 150
	unit_name = "arrow"
	export_types = list(/obj/item/ammo_casing/caseless/arrow, /obj/item/ammo_casing/caseless/arrow/bone, /obj/item/ammo_casing/caseless/arrow/ash)

/*/datum/export/weapon/bow_teaching
	cost = 500
	unit_name = "bowyery tablet"
	export_types = list(/obj/item/book/granter/crafting_recipe/bone_bow)*/

/datum/export/weapon/quiver
	cost = 100
	unit_name = "quiver"
	export_types = list(/obj/item/storage/belt/quiver)


/////////////////////////
//The Traitor Sell Outs//
/////////////////////////

/datum/export/weapon/pistol
	cost = 120
	unit_name = "nonstandard sidearm"
	export_types = list(/obj/item/gun/ballistic/automatic/pistol)

/datum/export/weapon/revolver
	cost = 200
	unit_name = "large-caliber revolver"
	export_types = list(/obj/item/gun/ballistic/revolver)
	exclude_types = list(/obj/item/gun/ballistic/revolver/russian, /obj/item/gun/ballistic/revolver/doublebarrel)

/datum/export/weapon/rocketlauncher
	cost = 1000
	unit_name = "PML-9 rocket-propelled grenade launcher"
	export_types = list(/obj/item/gun/ballistic/rocketlauncher)

/datum/export/weapon/antitank
	cost = 300
	unit_name = "anti-tank pistol"
	export_types = list(/obj/item/gun/ballistic/automatic/pistol/antitank/syndicate)

/datum/export/weapon/clownstuff
	cost = 500
	unit_name = "clown combat equipment"
	export_types = list(/obj/item/pneumatic_cannon/pie/selfcharge, /obj/item/shield/energy/bananium, /obj/item/melee/transforming/energy/sword/bananium)

/datum/export/weapon/bulldog
	cost = 400
	unit_name = "drum-fed compact combat shotgun"
	export_types = list(/obj/item/gun/ballistic/automatic/shotgun/bulldog)

/datum/export/weapon/smg
	cost = 350
	unit_name = "C-20r sub-machine gun"
	export_types = list(/obj/item/gun/ballistic/automatic/c20r)

/datum/export/weapon/duelsaber
	cost = 360
	unit_name = "double-bladed energy saber"
	export_types = list(/obj/item/dualsaber)

/datum/export/weapon/esword
	cost = 130
	unit_name = "energy saber"
	export_types = list(/obj/item/melee/transforming/energy/sword/cx/traitor, /obj/item/melee/transforming/energy/sword/saber)

/datum/export/weapon/rapier
	cost = 150
	unit_name = "rapier"
	export_types = list(/obj/item/storage/belt/sabre/rapier)

/datum/export/weapon/flamer
	cost = 20 //welder + some rods cheap
	unit_name = "flamethrower"
	export_types = list(/obj/item/flamethrower)

/datum/export/weapon/gloves
	cost = 90
	unit_name = "anomalous armwraps"
	export_types = list(/obj/item/clothing/gloves/fingerless/pugilist/rapid)

/datum/export/weapon/l6
	cost = 500
	unit_name = "Aussec Armory L6 SAW"
	export_types = list(/obj/item/gun/ballistic/automatic/l6_saw)

/datum/export/weapon/m90
	cost = 400
	unit_name = "M90-gl carbine"
	export_types = list(/obj/item/gun/ballistic/automatic/m90)

/datum/export/weapon/powerglove
	cost = 100
	unit_name = "pneumatic gauntlet"
	export_types = list(/obj/item/melee/powerfist)

/datum/export/weapon/sniper
	cost = 750
	unit_name = "anti-materiel rifle"
	export_types = list(/obj/item/gun/ballistic/automatic/sniper_rifle/syndicate)

/datum/export/weapon/ebow
	cost = 600
	unit_name = "compact energy crossbow"
	export_types = list(/obj/item/gun/energy/kinetic_accelerator/crossbow)

/datum/export/weapon/m10mm
	cost = 10
	unit_name = "10mm magazine"
	export_types = list(/obj/item/ammo_box/magazine/m10mm)
	include_subtypes = TRUE

/datum/export/weapon/dj_a_bomb
	cost = 100
	unit_name = "40mm shell"
	export_types = list(/obj/item/ammo_casing/a40mm)

/datum/export/weapon/point50mags
	cost = 50
	unit_name = ".50 magazine"
	export_types = list(/obj/item/ammo_box/magazine/sniper_rounds)
	include_subtypes = TRUE

/datum/export/weapon/smg_mag
	cost = 45
	unit_name = "SMG/carbine magazine"
	export_types = list(/obj/item/ammo_box/magazine/smgm45, /obj/item/ammo_box/magazine/m556)

/datum/export/weapon/l6sawammo
	cost = 60
	unit_name = "L6 SAW ammo box"
	export_types = list(/obj/item/ammo_box/magazine/mm195x129)
	include_subtypes = TRUE

/datum/export/weapon/rocket
	cost = 120
	unit_name = "rocket"
	export_types = list(/obj/item/ammo_casing/caseless/rocket)
	include_subtypes = TRUE

/datum/export/weapon/ninemmammo
	cost = 20
	unit_name = "9mm ammo magazine"
	export_types = list(/obj/item/ammo_box/magazine/pistolm9mm)

/datum/export/weapon/fletcher_ammo
	cost = 60
	unit_name = "flechette launcher magazine"
	export_types = list(/obj/item/ammo_box/magazine/flechette)
	include_subtypes = TRUE

/datum/export/weapon/dj_a_pizzabomb
	cost = -6000
	unit_name = "undeclared ordinance and subsequent repair costs"
	export_types = list(/obj/item/pizzabox/bomb, /obj/item/sbeacondrop/bomb)

/datum/export/weapon/real_toolbox
	cost = 600
	unit_name = "golden toolbox"
	export_types = list(/obj/item/storage/toolbox/plastitanium/gold_real)

/datum/export/weapon/melee
	cost = 50
	unit_name = "any other melee weapon"
	export_types = list(/obj/item/melee)
	include_subtypes = TRUE

/datum/export/weapon/gun
	cost = 50
	unit_name = "any other weapon"
	export_types = list(/obj/item/gun)
	include_subtypes = TRUE
