/obj/item/robot_module
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1

	var/borghealth = 100

	var/list/basic_modules = list() //a list of paths, converted to a list of instances on New()
	var/list/emag_modules = list() //ditto
	var/list/ratvar_modules = list() //ditto ditto
	var/list/modules = list() //holds all the usable modules
	var/list/added_modules = list() //modules not inherient to the robot module, are kept when the module changes
	var/list/storages = list()

	var/cyborg_base_icon = "robot" //produces the icon for the borg and, if no special_light_key is set, the lights
	var/special_light_key //if we want specific lights, use this instead of copying lights in the dmi

	var/moduleselect_icon = "nomod"

	var/can_be_pushed = FALSE
	var/magpulsing = FALSE
	var/clean_on_move = FALSE

	var/did_feedback = FALSE

	var/hat_offset = -3

	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	var/ride_allow_incapacitated = FALSE
	var/allow_riding = TRUE
	var/canDispose = FALSE // Whether the borg can stuff itself into disposal

	var/sleeper_overlay
	var/icon/cyborg_icon_override
	var/has_snowflake_deadsprite
	var/cyborg_pixel_offset
	var/moduleselect_alternate_icon
	var/dogborg = FALSE

/obj/item/robot_module/Initialize()
	. = ..()
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i
	for(var/i in ratvar_modules)
		var/obj/item/I = new i(src)
		ratvar_modules += I
		ratvar_modules -= i

/obj/item/robot_module/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	ratvar_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	return ..()

/obj/item/robot_module/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in modules)
		O.emp_act(severity)
	..()

/obj/item/robot_module/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_module/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/R = loc
	for(var/m in get_usable_modules())
		if(!(m in R.held_items))
			. += m

/obj/item/robot_module/proc/get_or_create_estorage(var/storage_type)
	for(var/datum/robot_energy_storage/S in storages)
		if(istype(S, storage_type))
			return S

	return new storage_type(src)

/obj/item/robot_module/proc/add_module(obj/item/I, nonstandard, requires_rebuild)
	rad_flags |= RAD_NO_CONTAMINATE
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I

		if(is_type_in_list(S, list(/obj/item/stack/sheet/metal, /obj/item/stack/rods, /obj/item/stack/tile/plasteel)))
			if(S.custom_materials?.len && S.custom_materials[SSmaterials.GetMaterialRef(/datum/material/iron)])
				S.cost = S.custom_materials[SSmaterials.GetMaterialRef(/datum/material/iron)] * 0.25
			S.source = get_or_create_estorage(/datum/robot_energy_storage/metal)

		else if(istype(S, /obj/item/stack/sheet/glass))
			S.cost = 500
			S.source = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/G = S
			G.source = get_or_create_estorage(/datum/robot_energy_storage/metal)
			G.glasource = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/medical))
			S.cost = 250
			S.source = get_or_create_estorage(/datum/robot_energy_storage/medical)

		else if(istype(S, /obj/item/stack/cable_coil))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/wire)

		else if(istype(S, /obj/item/stack/marker_beacon))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/beacon)

		else if(istype(S, /obj/item/stack/packageWrap))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/wrapping_paper)

		if(S && S.source)
			S.set_custom_materials(null)
			S.is_cyborg = 1

	if(I.loc != src)
		I.forceMove(src)
	modules += I
	ADD_TRAIT(I, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += I
	if(requires_rebuild)
		rebuild_modules()
	return I

//Adds flavoursome dogborg items to dogborg variants without mechanical benefits
/obj/item/robot_module/proc/dogborg_equip()
	has_snowflake_deadsprite = TRUE
	cyborg_pixel_offset = -16
	hat_offset = INFINITY
	basic_modules += new /obj/item/dogborg_nose(src)
	basic_modules += new /obj/item/dogborg_tongue(src)
	var/obj/item/dogborg/sleeper/K9/flavour/I = new(src)
	if(istype(src, /obj/item/robot_module/engineering))
		I.icon_state = "decompiler"
	if(istype(src, /obj/item/robot_module/security))
		I.icon_state = "sleeperb"
	if(istype(src, /obj/item/robot_module/medical))
		I.icon_state = "sleeper"
	if(istype(src, /obj/item/robot_module/butler))
		I.icon_state = "servicer"
		if(cyborg_base_icon == "scrubpup")
			I.icon_state = "compactor"
	basic_modules += I
	rebuild_modules()

/obj/item/robot_module/proc/remove_module(obj/item/I, delete_after)
	basic_modules -= I
	modules -= I
	emag_modules -= I
	ratvar_modules -= I
	added_modules -= I
	rebuild_modules()
	if(delete_after)
		qdel(I)

/obj/item/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in get_usable_modules())
		if(istype(I, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/F = I
			F.times_used = 0
			F.crit_fail = 0
			F.update_icon()
		else if(istype(I, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = I
			if(B.cell)
				B.cell.charge = B.cell.maxcharge
		else if(istype(I, /obj/item/gun/energy))
			var/obj/item/gun/energy/EG = I
			if(EG.cell?.charge < EG.cell.maxcharge)
				var/obj/item/ammo_casing/energy/S = EG.ammo_type[EG.current_firemode_index]
				EG.cell.give(S.e_cost * coeff)
				if(!EG.chambered)
					EG.recharge_newshot(TRUE)
				EG.update_icon()
			else
				EG.charge_tick = 0

	R.toner = R.tonermax

/obj/item/robot_module/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/R = loc
	var/held_modules = R.held_items.Copy()
	R.uneq_all()
	modules = list()
	for(var/obj/item/I in basic_modules)
		add_module(I, FALSE, FALSE)
	if(R.emagged)
		for(var/obj/item/I in emag_modules)
			add_module(I, FALSE, FALSE)
	if(is_servant_of_ratvar(R))
		for(var/obj/item/I in ratvar_modules)
			add_module(I, FALSE, FALSE)
	for(var/obj/item/I in added_modules)
		add_module(I, FALSE, FALSE)
	for(var/i in held_modules)
		if(i)
			R.activate_module(i)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()

/obj/item/robot_module/proc/transform_to(new_module_type)
	var/mob/living/silicon/robot/R = loc
	var/obj/item/robot_module/RM = new new_module_type(R)
	if(!RM.be_transformed_to(src))
		qdel(RM)
		return
	R.module = RM
	R.update_module_innate()
	RM.rebuild_modules()
	INVOKE_ASYNC(RM, .proc/do_transform_animation)
	if(RM.dogborg || R.dogborg)
		RM.dogborg_equip()
		R.typing_indicator_state = /obj/effect/overlay/typing_indicator/machine/dogborg
	else
		R.typing_indicator_state = /obj/effect/overlay/typing_indicator/machine
	R.maxHealth = borghealth
	R.health = min(borghealth, R.health)
	qdel(src)
	return RM

/obj/item/robot_module/proc/be_transformed_to(obj/item/robot_module/old_module)
	for(var/i in old_module.added_modules)
		added_modules += i
		old_module.added_modules -= i
	did_feedback = old_module.did_feedback
	return TRUE

/obj/item/robot_module/proc/do_transform_animation()
	var/mob/living/silicon/robot/R = loc
	if(R.hat)
		R.hat.forceMove(get_turf(R))
		R.hat = null
	R.cut_overlays()
	R.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_module/proc/do_transform_delay()
	var/mob/living/silicon/robot/R = loc
	var/prev_locked_down = R.locked_down
	sleep(1)
	flick("[cyborg_base_icon]_transform", R)
	R.mob_transforming = TRUE
	R.SetLockdown(1)
	R.anchored = TRUE
	sleep(1)
	for(var/i in 1 to 4)
		playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		sleep(7)
	if(!prev_locked_down)
		R.SetLockdown(0)
	R.setDir(SOUTH)
	R.set_anchored(FALSE)
	R.mob_transforming = FALSE
	R.updatehealth()
	R.update_icons()
	R.notify_ai(NEW_MODULE)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, R.module)

/**
  * check_menu: Checks if we are allowed to interact with a radial menu
  *
  * Arguments:
  * * user The mob interacting with a menu
  */
/obj/item/robot_module/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/robot_module/standard
	name = "Standard"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/healthanalyzer,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/pickaxe,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/cyborghug)
	emag_modules = list(/obj/item/melee/transforming/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/obj/item/clockwork/replica_fabricator/cyborg)
	moduleselect_icon = "standard"
	hat_offset = -3

/obj/item/robot_module/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo,
		/obj/item/weapon/gripper/medical,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/stack/medical/bone_gel/cyborg,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop,
		/obj/item/sensor_device,
		/obj/item/shockpaddles/cyborg)
	emag_modules = list(/obj/item/reagent_containers/borghypo/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "medical"
	moduleselect_icon = "medical"
	hat_offset = 3

/obj/item/robot_module/medical/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/med_icons
	if(!med_icons)
		med_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "medical"),
		"Droid" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "medical"),
		"Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleekmed"),
		"Marina" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "marinamed"),
		"Eyebot" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "eyebotmed"),
		"Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavymed")
		)
		var/list/L = list("Medihound" = "medihound", "Medihound Dark" = "medihounddark", "Vale" = "valemed")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			med_icons[a] = wide
		if(R.client && R.client.ckey == "nezuli")
			var/image/bad_snowflake = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = "alina-med")
			bad_snowflake.pixel_x = -16
			med_icons["Alina"] = bad_snowflake
		med_icons = sortList(med_icons)
	var/med_borg_icon = show_radial_menu(R, R , med_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(med_borg_icon)
		if("Default")
			cyborg_base_icon = "medical"
		if("Droid")
			cyborg_base_icon = "medical"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
			hat_offset = 4
		if("Sleek")
			cyborg_base_icon = "sleekmed"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinamed"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Eyebot")
			cyborg_base_icon = "eyebotmed"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavymed"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Medihound")
			cyborg_base_icon = "medihound"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "msleeper"
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_citadel/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Medihound Dark")
			cyborg_base_icon = "medihounddark"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "mdsleeper"
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_citadel/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valemed"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "valemedsleeper"
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_citadel/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-med"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			special_light_key = "alina"
			sleeper_overlay = "alinasleeper"
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_citadel/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

/obj/item/robot_module/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/holosign_creator/combifan,
		/obj/item/weapon/gripper,
		/obj/item/lightreplacer/cyborg,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/engineer,
		/obj/item/clockwork/replica_fabricator/cyborg)
	cyborg_base_icon = "engineer"
	moduleselect_icon = "engineer"
	magpulsing = TRUE
	hat_offset = -4

/obj/item/robot_module/engineering/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/engi_icons
	if(!engi_icons)
		engi_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "engineer"),
		"Default - Treads" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "engi-tread"),
		"Loader" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "loaderborg"),
		"Handy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "handyeng"),
		"Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleekeng"),
		"Can" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "caneng"),
		"Marina" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "marinaeng"),
		"Spider" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "spidereng"),
		"Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavyeng")
		)
		var/list/L = list("Pup Dozer" = "pupdozer", "Vale" = "valeeng")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			engi_icons[a] = wide
		if(R.client && R.client.ckey == "nezuli")
			var/image/bad_snowflake = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = "alina-eng")
			bad_snowflake.pixel_x = -16
			engi_icons["Alina"] = bad_snowflake
		engi_icons = sortList(engi_icons)
	var/engi_borg_icon = show_radial_menu(R, R , engi_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(engi_borg_icon)
		if("Default")
			cyborg_base_icon = "engineer"
		if("Default - Treads")
			cyborg_base_icon = "engi-tread"
			special_light_key = "engineer"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Loader")
			cyborg_base_icon = "loaderborg"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Handy")
			cyborg_base_icon = "handyeng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "sleekeng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "caneng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinaeng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidereng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavyeng"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Pup Dozer")
			cyborg_base_icon = "pupdozer"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "dozersleeper"
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valeeng"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "valeengsleeper"
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-eng"
			special_light_key = "alina"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "alinasleeper"
			dogborg = TRUE
		else
			return FALSE
	return ..()

/obj/item/robot_module/security
	name = "Security"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/pinpointer/crew)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "sec"
	moduleselect_icon = "security"
	hat_offset = 3

/obj/item/robot_module/security/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>While you have picked the security module, you still have to follow your laws, NOT Space Law. \
	For Crewsimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

/obj/item/robot_module/security/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/sec_icons
	if(!sec_icons)
		sec_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "sec"),
		"Default - Treads" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sec-tread"),
		"Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleeksec"),
		"Can" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "cansec"),
		"Marina" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "marinasec"),
		"Spider" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "spidersec"),
		"Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavysec")
		)
		var/list/L = list("K9" = "k9", "Vale" = "valesec", "K9 Dark" = "k9dark")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			sec_icons[a] = wide
		if(R.client && R.client.ckey == "nezuli")
			var/image/bad_snowflake = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = "alina-sec")
			bad_snowflake.pixel_x = -16
			sec_icons["Alina"] = bad_snowflake
		sec_icons = sortList(sec_icons)
	var/sec_borg_icon = show_radial_menu(R, R , sec_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(sec_borg_icon)
		if("Default")
			cyborg_base_icon = "sec"
		if("Default - Treads")
			cyborg_base_icon = "sec-tread"
			special_light_key = "sec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "sleeksec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinasec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "cansec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidersec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavysec"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("K9")
			cyborg_base_icon = "k9"
			sleeper_overlay = "ksleeper"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-sec"
			special_light_key = "alina"
			sleeper_overlay = "alinasleeper"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("K9 Dark")
			cyborg_base_icon = "k9dark"
			sleeper_overlay = "k9darksleeper"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valesec"
			sleeper_overlay = "valesecsleeper"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

/obj/item/robot_module/security/Initialize()
	. = ..()
	if(!CONFIG_GET(flag/weaken_secborg))
		for(var/obj/item/gun/energy/disabler/cyborg/pewpew in basic_modules)
			basic_modules -= pewpew
			basic_modules += new /obj/item/gun/energy/e_gun/advtaser/cyborg(src)
			qdel(pewpew)

/obj/item/robot_module/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/cookiesynth,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/megaphone,
		/obj/item/borg/projectile_dampen)
	emag_modules = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/peacekeeper,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "peace"
	moduleselect_icon = "standard"
	hat_offset = -2

/obj/item/robot_module/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV/CREWSIMOV, you are an enforcer of the PEACE. \
	You are not a security module and you are expected to follow orders to the best of your abilities without causing harm. Space law means nothing to you.</span>")

/obj/item/robot_module/peacekeeper/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/peace_icons = sortList(list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "peace"),
		"Borgi" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "borgi"),
		"Spider" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "whitespider")
		))
	var/peace_borg_icon = show_radial_menu(R, R , peace_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(peace_borg_icon)
		if("Default")
			cyborg_base_icon = "peace"
		if("Spider")
			cyborg_base_icon = "whitespider"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Borgi")
			cyborg_base_icon = "borgi"
			moduleselect_icon = "borgi"
			moduleselect_alternate_icon = 'modular_citadel/icons/ui/screen_cyborg.dmi'
			hat_offset = INFINITY
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		else
			return FALSE
	return ..()

//Janitor module combined with Service module
/*
/obj/item/robot_module/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/spray/cyborg_drying)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_lube)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/janitor,
		/obj/item/clockwork/replica_fabricator/cyborg)
	cyborg_base_icon = "janitor"
	moduleselect_icon = "janitor"
	hat_offset = -5
	clean_on_move = TRUE
	*/

/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)

/obj/item/robot_module/clown
	name = "Clown"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/soap/nanotrasen,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor,					//killbait material
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop/clown,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/obj/item/clockwork/replica_fabricator/cyborg)
	moduleselect_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

/obj/item/robot_module/butler
	name = "Service"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/rsf/cyborg,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/lollipop,
		/obj/item/screwdriver/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/mop/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/spray/cyborg_drying)
	emag_modules = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/service,
		/obj/item/borg/sight/xray/truesight_lens)
	moduleselect_icon = "service"
	hat_offset = 0
	clean_on_move = TRUE

/obj/item/robot_module/butler/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/reagent_containers/O = locate(/obj/item/reagent_containers/food/condiment/enzyme) in basic_modules
	var/obj/item/lightreplacer/LR = locate(/obj/item/lightreplacer) in basic_modules
	if(O)
		O.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)
	if(LR)
		for(var/i in 1 to coeff)
			LR.Charge(R)
	var/obj/item/reagent_containers/spray/cyborg_drying/CD = locate(/obj/item/reagent_containers/spray/cyborg_drying) in basic_modules
	if(CD)
		CD.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)

	var/obj/item/reagent_containers/spray/cyborg_lube/CL = locate(/obj/item/reagent_containers/spray/cyborg_lube) in emag_modules
	if(CL)
		CL.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)

/obj/item/robot_module/butler/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/service_icons
	if(!service_icons)
		service_icons = list(
		"(Service) Waitress" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_f"),
		"(Service) Butler" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_m"),
		"(Service) Bro" = image(icon = 'icons/mob/robots.dmi', icon_state = "brobot"),
		"(Service) Can" = image(icon = 'icons/mob/robots.dmi', icon_state = "kent"),
		"(Service) Tophat" = image(icon = 'icons/mob/robots.dmi', icon_state = "tophat"),
		"(Service) Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleekserv"),
		"(Service) Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavyserv"),
		"(Janitor) Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "janitor"),
		"(Janitor) Marina" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "marinajan"),
		"(Janitor) Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleekjan"),
		"(Janitor) Can" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "canjan"),
		"(Janitor) Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavyjan")
		)
		var/list/L = list("(Service) DarkK9" = "k50", "(Service) Vale" = "valeserv", "(Service) ValeDark" = "valeservdark",
						"(Janitor) Scrubpuppy" = "scrubpup")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			service_icons[a] = wide
		if(R.client && R.client.ckey == "nezuli")
			var/image/bad_snowflake = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = "alina-sec")
			bad_snowflake.pixel_x = -16
			service_icons["Alina"] = bad_snowflake
		service_icons = sortList(service_icons)
	var/service_robot_icon = show_radial_menu(R, R , service_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(service_robot_icon)
		if("(Service) Waitress")
			cyborg_base_icon = "service_f"
			special_light_key = "service"
		if("(Service) Butler")
			cyborg_base_icon = "service_m"
			special_light_key = "service"
		if("(Service) Bro")
			cyborg_base_icon = "brobot"
			special_light_key = "service"
		if("(Service) Can")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("(Service) Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He is already wearing a hat
		if("(Service) Sleek")
			cyborg_base_icon = "sleekserv"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Service) Heavy")
			cyborg_base_icon = "heavyserv"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Service) DarkK9")
			cyborg_base_icon = "k50"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "ksleeper"
			dogborg = TRUE
		if("(Service) Vale")
			cyborg_base_icon = "valeserv"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "valeservsleeper"
			dogborg = TRUE
		if("(Service) ValeDark")
			cyborg_base_icon = "valeservdark"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "valeservsleeper"
			dogborg = TRUE
		if("(Janitor) Default")
			cyborg_base_icon = "janitor"
		if("(Janitor) Marina")
			cyborg_base_icon = "marinajan"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Janitor) Sleek")
			cyborg_base_icon = "sleekjan"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Janitor) Can")
			cyborg_base_icon = "canjan"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Janitor) Heavy")
			cyborg_base_icon = "heavyres"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("(Janitor) Scrubpuppy")
			cyborg_base_icon = "scrubpup"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "jsleeper"
			dogborg = TRUE
		else
			return FALSE
	return ..()

/obj/item/robot_module/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/kinetic_crusher/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gun/energy/plasmacutter/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/weapon/gripper/mining,
		/obj/item/cyborg_clamp,
		/obj/item/stack/marker_beacon,
		/obj/item/destTagger,
		/obj/item/stack/packageWrap,
		/obj/item/card/id/miningborg)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/miner,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/obj/item/borg/sight/xray/truesight_lens)
	cyborg_base_icon = "miner"
	moduleselect_icon = "miner"
	hat_offset = 0

/obj/item/robot_module/miner/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/static/list/mining_icons
	if(!mining_icons)
		mining_icons = list(
		"Lavaland" = image(icon = 'icons/mob/robots.dmi', icon_state = "miner"),
		"Asteroid" = image(icon = 'icons/mob/robots.dmi', icon_state = "minerOLD"),
		"Droid" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "miner"),
		"Sleek" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "sleekmin"),
		"Marina" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "marinamin"),
		"Can" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "canmin"),
		"Heavy" = image(icon = 'modular_citadel/icons/mob/robots.dmi', icon_state = "heavymin")
		)
		var/list/L = list("Blade" = "blade", "Vale" = "valemine")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_citadel/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			mining_icons[a] = wide
		mining_icons = sortList(mining_icons)
	var/mining_borg_icon = show_radial_menu(R, R , mining_icons, custom_check = CALLBACK(src, .proc/check_menu, R), radius = 42, require_near = TRUE)
	switch(mining_borg_icon)
		if("Lavaland")
			cyborg_base_icon = "miner"
		if("Asteroid")
			cyborg_base_icon = "minerOLD"
			special_light_key = "miner"
		if("Droid")
			cyborg_base_icon = "miner"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
			hat_offset = 4
		if("Sleek")
			cyborg_base_icon = "sleekmin"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "canmin"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinamin"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidermin"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavymin"
			cyborg_icon_override = 'modular_citadel/icons/mob/robots.dmi'
		if("Blade")
			cyborg_base_icon = "blade"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "bladesleeper"
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valemine"
			cyborg_icon_override = 'modular_citadel/icons/mob/widerobot.dmi'
			sleeper_overlay = "valeminesleeper"
			dogborg = TRUE
		else
			return FALSE
	return ..()

/obj/item/robot_module/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/pinpointer/syndicate_cyborg)

	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "synd_sec"
	moduleselect_icon = "malf"
	hat_offset = 3

/obj/item/robot_module/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction  -= "silicon" //ai turrets

/obj/item/robot_module/syndicate/remove_module(obj/item/I, delete_after)
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction += "silicon" //ai is your bff now!

/obj/item/robot_module/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate,
		/obj/item/healthanalyzer/advanced,
		/obj/item/surgical_drapes/advanced,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/bonesetter,
		/obj/item/stack/medical/bone_gel,
		/obj/item/melee/transforming/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/card/emag,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "synd_medical"
	moduleselect_icon = "malf"
	hat_offset = 3

/obj/item/robot_module/saboteur
	name = "Syndicate Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/holosign_creator/atmos,
		/obj/item/weapon/gripper,
		/obj/item/lightreplacer/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/destTagger/borg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		)

	ratvar_modules = list(
	/obj/item/clockwork/slab/cyborg/engineer,
	/obj/item/clockwork/replica_fabricator/cyborg)

	cyborg_base_icon = "synd_engi"
	moduleselect_icon = "malf"
	magpulsing = TRUE
	hat_offset = -4
	canDispose = TRUE

/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(var/obj/item/robot_module/R = null)
	energy = max_energy
	if(R)
		R.storages |= src
	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return 1
		return 2
	else
		return 0

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"

/datum/robot_energy_storage/wrapping_paper
	max_energy = 30
	recharge_rate = 1
	name = "Wrapping Paper Storage"

/obj/item/robot_module/syndicate/spider// used for space ninja and their cyborg hacking special objective
	name = "Spider Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/pinpointer/spider_cyborg)

	cyborg_base_icon = "spider_sec"

/obj/item/robot_module/syndicate_medical/spider// ditto
	name = "Spider Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate,
		/obj/item/healthanalyzer/advanced,
		/obj/item/surgical_drapes/advanced,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/bonesetter,
		/obj/item/stack/medical/bone_gel,
		/obj/item/melee/transforming/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage,
		/obj/item/pinpointer/spider_cyborg)

	cyborg_base_icon = "spider_medical"

/obj/item/robot_module/saboteur/spider// ditto
	name = "Spider Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/holosign_creator/atmos,
		/obj/item/weapon/gripper,
		/obj/item/lightreplacer/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/destTagger/borg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/borg_chameleon,
		/obj/item/pinpointer/spider_cyborg)

	cyborg_base_icon = "spider_engi"
