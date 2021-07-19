/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "ce"

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/hardhat/weldhat/white(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/tank/jetpack/suit(src)
	new /obj/item/cartridge/ce(src)
	new /obj/item/radio/headset/heads/ce(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/areaeditor/blueprints(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/inducer(src)
	new /obj/item/circuitboard/machine/techfab/department/engineering(src)
	new /obj/item/extinguisher/advanced(src)
	new /obj/item/storage/photo_album/CE(src)
	new	/obj/item/storage/lockbox/medal/engineering(src)
	new /obj/item/construction/rcd/loaded/upgraded(src)
	new /obj/item/clothing/suit/hooded/wintercoat/ce(src)
	new /obj/item/clothing/head/beret/ce/white(src)
	new /obj/item/storage/bag/construction(src)
	new /obj/item/storage/bag/material(src)
	new /obj/item/autosurgeon/ce(src)

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/PopulateContents()
	..()
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/inducer(src)
	new /obj/item/inducer(src)
	for(var/i in 1 to 3)
		new /obj/item/storage/toolbox/electrical(src)
	for(var/i in 1 to 3)
		new /obj/item/electronics/apc(src)
	for(var/i in 1 to 3)
		new /obj/item/multitool(src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weldingtool/largetank(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/cartridge/engineering(src)
	new /obj/item/storage/bag/construction(src)
	new /obj/item/storage/bag/material(src)

/obj/structure/closet/secure_closet/atmospherics
	name = "\proper atmospheric technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "atmos"

/obj/structure/closet/secure_closet/atmospherics/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/analyzer(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/holosign_creator/firelock(src) //what if atmos techs could test things they are meant to test, wild, innit?
	new /obj/item/watertank/atmos(src)
	new /obj/item/clothing/suit/fire/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/tray(src)
	new /obj/item/extinguisher/advanced(src)
	new /obj/item/cartridge/atmos(src)
	new /obj/item/storage/bag/construction(src)
	new /obj/item/storage/bag/material(src)

/*
 * Empty lockers
 * Some of the lockers are filled with junk, and sometimes its nice to just fill it with your own set-up for your own map gimmicks.
 */

/obj/structure/closet/secure_closet/engineering_chief/empty

/obj/structure/closet/secure_closet/engineering_chief/empty/PopulateContents()
	return

/obj/structure/closet/secure_closet/engineering_electrical/empty

/obj/structure/closet/secure_closet/engineering_electrical/empty/PopulateContents()
	return

/obj/structure/closet/secure_closet/engineering_welding/empty

/obj/structure/closet/secure_closet/engineering_welding/empty/PopulateContents()
	return

/obj/structure/closet/secure_closet/engineering_personal/empty

/obj/structure/closet/secure_closet/engineering_personal/empty/PopulateContents()
	return

/obj/structure/closet/secure_closet/atmospherics/empty

/obj/structure/closet/secure_closet/atmospherics/empty/PopulateContents()
	return
