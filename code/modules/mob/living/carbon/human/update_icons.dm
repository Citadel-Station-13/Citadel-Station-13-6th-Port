	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //32 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

Note: The defines for layer numbers is now kept exclusvely in __DEFINES/misc.dm instead of being defined there,
	then redefined and undefiend everywhere else. If you need to change the layering of sprites (or add a new layer)
	that's where you should start.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's body layer and mutant bodyparts
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())


*/

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	RegisterSignal(src, SIGNAL_TRAIT(TRAIT_HUMAN_NO_RENDER), /mob.proc/regenerate_icons)

//HAIR OVERLAY
/mob/living/carbon/human/update_hair(send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		dna.species.handle_hair(src)
		if(send_signal)
			SEND_SIGNAL(src, COMSIG_HUMAN_HEAD_ICONS_UPDATED, "hair")

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts(send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		dna.species.handle_mutant_bodyparts(src, FALSE, send_signal)
		if(send_signal)
			SEND_SIGNAL(src, COMSIG_HUMAN_HEAD_ICONS_UPDATED, "mutant")

/mob/living/carbon/human/update_body(update_genitals = FALSE, send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(BODY_LAYER)
		dna.species.handle_body(src, send_signal)
		..()
		if(update_genitals)
			update_genitals()

/mob/living/carbon/human/update_fire()
	..((fire_stacks > 3) ? "Standing" : "Generic_mob_burning")

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		if(!..())
			icon_render_key = null //invalidate bodyparts cache
			update_body(TRUE)
			update_hair()
			update_inv_w_uniform()
			update_inv_wear_id()
			update_inv_gloves()
			update_inv_glasses()
			update_inv_ears()
			update_inv_shoes()
			update_inv_s_store()
			update_inv_wear_mask()
			update_inv_head()
			update_inv_belt()
			update_inv_back()
			update_inv_wear_suit()
			update_inv_pockets()
			update_inv_neck()
			update_transform()
			//mutations
			update_mutations_overlay()
			//damage overlays
			update_damage_overlays()
			//antagonism
			update_antag_overlays()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv


/mob/living/carbon/human/update_antag_overlays()
	remove_overlay(ANTAG_LAYER)
	var/datum/antagonist/cult/D = src?.mind?.has_antag_datum(/datum/antagonist/cult) //check for cultism
	if(D && D.cult_team?.cult_ascendent == TRUE)
		var/istate = pick("halo1","halo2","halo3","halo4","halo5","halo6")
		var/mutable_appearance/new_cult_overlay = mutable_appearance('icons/effects/32x64.dmi', istate, -ANTAG_LAYER)
		overlays_standing[ANTAG_LAYER] = new_cult_overlay
	var/datum/antagonist/clockcult/C = src?.mind?.has_antag_datum(/datum/antagonist/clockcult) //check for clockcultism - surely one can't be both cult and clockie, right?
	if(C)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		if(G && G.active && ishuman(src))
			var/mutable_appearance/new_cult_overlay = mutable_appearance('icons/effects/genetics.dmi', "servitude", -ANTAG_LAYER)
			overlays_standing[ANTAG_LAYER] = new_cult_overlay
	apply_overlay(ANTAG_LAYER)


/mob/living/carbon/human/update_inv_w_uniform()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(UNIFORM_LAYER)

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_W_UNIFORM]
			inv.update_icon()

		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			U.screen_loc = ui_iclothing
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)
					client.screen += w_uniform
			update_observer_view(w_uniform,1)

			if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
				return


			var/target_overlay = U.icon_state
			if(U.adjusted == ALT_STYLE)
				target_overlay = "[target_overlay]_d"

			var/alt_worn = U.mob_overlay_icon || 'icons/mob/clothing/uniform.dmi'
			var/variant_flag = NONE

			if((DIGITIGRADE in dna.species.species_traits) && U.mutantrace_variation & STYLE_DIGITIGRADE && !(U.mutantrace_variation & STYLE_NO_ANTHRO_ICON))
				alt_worn = U.anthro_mob_worn_overlay || 'icons/mob/clothing/uniform_digi.dmi'
				variant_flag |= STYLE_DIGITIGRADE

			var/mask
			if(dna.species.mutant_bodyparts["taur"])
				var/datum/sprite_accessory/taur/T = GLOB.taur_list[dna.features["taur"]]
				var/clip_flag = U.mutantrace_variation & T?.hide_legs
				if(clip_flag)
					variant_flag |= clip_flag
					mask = T.alpha_mask_state

			var/mutable_appearance/uniform_overlay

			var/gendered = (dna?.species.sexes && dna.features["body_model"] == FEMALE) ? U.fitted : NO_FEMALE_UNIFORM
			uniform_overlay = U.build_worn_icon( UNIFORM_LAYER, alt_worn, FALSE, gendered, target_overlay, variant_flag, FALSE, mask)

			if(OFFSET_UNIFORM in dna.species.offset_features)
				uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
				uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
			overlays_standing[UNIFORM_LAYER] = uniform_overlay

		apply_overlay(UNIFORM_LAYER)
		update_mutant_bodyparts()

/mob/living/carbon/human/update_inv_wear_id()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(ID_LAYER)

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_ID]
			inv.update_icon()

		var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]

		if(wear_id)
			wear_id.screen_loc = ui_id
			if(client && hud_used && hud_used.hud_shown)
				client.screen += wear_id
			update_observer_view(wear_id)

			//TODO: add an icon file for ID slot stuff, so it's less snowflakey
			id_overlay = wear_id.build_worn_icon(default_layer = ID_LAYER, default_icon_file = 'icons/mob/mob.dmi', override_state = wear_id.item_state)
			if(OFFSET_ID in dna.species.offset_features)
				id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID][1]
				id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID][2]
			overlays_standing[ID_LAYER] = id_overlay
		apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(GLOVES_LAYER)

		if(client && hud_used && hud_used.inv_slots[SLOT_GLOVES])
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLOVES]
			inv.update_icon()

		if(!gloves && bloody_hands)
			var/mutable_appearance/bloody_overlay = mutable_appearance('icons/effects/blood.dmi', "bloodyhands", -GLOVES_LAYER, color = blood_DNA_to_color())
			if(get_num_arms(FALSE) < 2)
				if(has_left_hand(FALSE))
					bloody_overlay.icon_state = "bloodyhands_left"
				else if(has_right_hand(FALSE))
					bloody_overlay.icon_state = "bloodyhands_right"

			overlays_standing[GLOVES_LAYER] = bloody_overlay

		var/mutable_appearance/gloves_overlay = overlays_standing[GLOVES_LAYER]
		if(gloves)
			gloves.screen_loc = ui_gloves
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)
					client.screen += gloves
			update_observer_view(gloves,1)
			overlays_standing[GLOVES_LAYER] = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/clothing/hands.dmi')
			gloves_overlay = overlays_standing[GLOVES_LAYER]
			if(OFFSET_GLOVES in dna.species.offset_features)
				gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
				gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
		overlays_standing[GLOVES_LAYER] = gloves_overlay
		apply_overlay(GLOVES_LAYER)

/mob/living/carbon/human/update_inv_glasses(send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(GLASSES_LAYER)

		if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
			return

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_GLASSES]
			inv.update_icon()

		if(send_signal)
			SEND_SIGNAL(src, COMSIG_HUMAN_HEAD_ICONS_UPDATED, "glasses")

/mob/living/carbon/human/update_inv_ears(send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		//send signal early incase the proc returns early for some reason
		if(send_signal)
			SEND_SIGNAL(src, COMSIG_HUMAN_HEAD_ICONS_UPDATED, "ears")

		if(glasses)
			glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open ...
					client.screen += glasses				//Either way, add the item to the HUD
			update_observer_view(glasses,1)
			if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
				overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/clothing/eyes.dmi', override_state = glasses.icon_state)
			var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
			if(glasses_overlay)
				if(OFFSET_GLASSES in dna.species.offset_features)
					glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
					glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
				overlays_standing[GLASSES_LAYER] = glasses_overlay
		apply_overlay(GLASSES_LAYER)

/mob/living/carbon/human/update_inv_ears()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(EARS_LAYER)

		if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
			return

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_EARS]
			inv.update_icon()

		if(ears)
			ears.screen_loc = ui_ears	//move the item to the appropriate screen loc
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open
					client.screen += ears					//add it to the client's screen
			update_observer_view(ears,1)

/mob/living/carbon/human/update_inv_shoes()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(SHOES_LAYER)

		if(get_num_legs(FALSE) <2)
			return

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_SHOES]
			inv.update_icon()

		if(dna.species.mutant_bodyparts["taur"])
			var/datum/sprite_accessory/taur/T = GLOB.taur_list[dna.features["taur"]]
			if(T?.hide_legs) //If only they actually made shoes unwearable. Please don't making cosmetics, guys.
				return

		if(shoes)
			var/obj/item/clothing/shoes/S = shoes
			shoes.screen_loc = ui_shoes					//move the item to the appropriate screen loc
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open
					client.screen += shoes					//add it to client's screen
			update_observer_view(shoes,1)

			var/alt_icon = S.mob_overlay_icon || 'icons/mob/clothing/feet.dmi'
			var/variation_flag = NONE
			if((DIGITIGRADE in dna.species.species_traits) && S.mutantrace_variation & STYLE_DIGITIGRADE && !(S.mutantrace_variation & STYLE_NO_ANTHRO_ICON))
				alt_icon = S.anthro_mob_worn_overlay || 'icons/mob/clothing/feet_digi.dmi'
				variation_flag |= STYLE_DIGITIGRADE

			overlays_standing[SHOES_LAYER] = shoes.build_worn_icon(SHOES_LAYER, alt_icon, FALSE, NO_FEMALE_UNIFORM, S.icon_state, variation_flag, FALSE)
			var/mutable_appearance/shoes_overlay = overlays_standing[SHOES_LAYER]
			if(OFFSET_SHOES in dna.species.offset_features)
				shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
				shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
			overlays_standing[SHOES_LAYER] = shoes_overlay
		apply_overlay(SHOES_LAYER)

/mob/living/carbon/human/update_inv_s_store()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(SUIT_STORE_LAYER)

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_S_STORE]
			inv.update_icon()

		if(s_store)
			s_store.screen_loc = ui_sstore1
			if(client && hud_used && hud_used.hud_shown)
				client.screen += s_store
			update_observer_view(s_store)
			var/t_state = s_store.item_state
			if(!t_state)
				t_state = s_store.icon_state
			overlays_standing[SUIT_STORE_LAYER]	= mutable_appearance(((s_store.mob_overlay_icon) ? s_store.mob_overlay_icon : 'icons/mob/clothing/belt_mirror.dmi'), t_state, -SUIT_STORE_LAYER)
			var/mutable_appearance/s_store_overlay = overlays_standing[SUIT_STORE_LAYER]
			if(OFFSET_S_STORE in dna.species.offset_features)
				s_store_overlay.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
				s_store_overlay.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
			overlays_standing[SUIT_STORE_LAYER] = s_store_overlay
		apply_overlay(SUIT_STORE_LAYER)

/mob/living/carbon/human/update_inv_head(send_signal = TRUE)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(HEAD_LAYER)

		if(send_signal)
			SEND_SIGNAL(src, COMSIG_HUMAN_HEAD_ICONS_UPDATED, "head")

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_HEAD]
			inv.update_icon()

		if(get_bodypart(BODY_ZONE_HEAD) && head)
			head.screen_loc = ui_head
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)
					client.screen += head
			update_observer_view(head,1)
			remove_overlay(HEAD_LAYER)
			var/obj/item/clothing/head/H = head
			var/alt_icon = H.mob_overlay_icon || 'icons/mob/clothing/head.dmi'
			var/muzzled = FALSE
			var/variation_flag = NONE
			if(dna.species.mutant_bodyparts["mam_snouts"] && dna.features["mam_snouts"] != "None")
				muzzled = TRUE
			else if(dna.species.mutant_bodyparts["snout"] && dna.features["snout"] != "None")
				muzzled = TRUE
			if(muzzled && H.mutantrace_variation & STYLE_MUZZLE && !(H.mutantrace_variation & STYLE_NO_ANTHRO_ICON))
				alt_icon = H.anthro_mob_worn_overlay || 'icons/mob/clothing/head_muzzled.dmi'
				variation_flag |= STYLE_MUZZLE

			overlays_standing[HEAD_LAYER] = H.build_worn_icon(HEAD_LAYER, alt_icon, FALSE, NO_FEMALE_UNIFORM, H.icon_state, variation_flag, FALSE)
			var/mutable_appearance/head_overlay = overlays_standing[HEAD_LAYER]

			if(OFFSET_HEAD in dna.species.offset_features)
				head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
				head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
			overlays_standing[HEAD_LAYER] = head_overlay
		apply_overlay(HEAD_LAYER)
		update_mutant_bodyparts(send_signal)

/mob/living/carbon/human/update_inv_belt()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(BELT_LAYER)

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BELT]
			inv.update_icon()

		if(belt)
			belt.screen_loc = ui_belt
			if(client && hud_used && hud_used.hud_shown)
				client.screen += belt
			update_observer_view(belt)

			overlays_standing[BELT_LAYER] = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/mob/clothing/belt.dmi')
			var/mutable_appearance/belt_overlay = overlays_standing[BELT_LAYER]
			if(OFFSET_BELT in dna.species.offset_features)
				belt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
				belt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
			overlays_standing[BELT_LAYER] = belt_overlay
		apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_inv_wear_suit()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(SUIT_LAYER)

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_SUIT]
			inv.update_icon()

		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			wear_suit.screen_loc = ui_oclothing
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)
					client.screen += wear_suit
			update_observer_view(wear_suit,1)

			var/worn_icon = wear_suit.mob_overlay_icon || 'icons/mob/clothing/suit.dmi'
			var/worn_state = wear_suit.icon_state
			var/center = FALSE
			var/dimension_x = 32
			var/dimension_y = 32
			var/variation_flag = NONE
			var/datum/sprite_accessory/taur/T
			if(dna.species.mutant_bodyparts["taur"])
				T = GLOB.taur_list[dna.features["taur"]]

			if(S.mutantrace_variation)

				if(T?.taur_mode)
					var/init_worn_icon = worn_icon
					variation_flag |= S.mutantrace_variation & T.taur_mode || S.mutantrace_variation & T.alt_taur_mode
					switch(variation_flag)
						if(STYLE_HOOF_TAURIC)
							worn_icon = 'icons/mob/clothing/taur_hooved.dmi'
						if(STYLE_SNEK_TAURIC)
							worn_icon = 'icons/mob/clothing/taur_naga.dmi'
						if(STYLE_PAW_TAURIC)
							worn_icon = 'icons/mob/clothing/taur_canine.dmi'
					if(worn_icon != init_worn_icon) //worn icon sprite was changed, taur offsets will have to be applied.
						if(S.taur_mob_worn_overlay) //not going to make several new variables for all taur types. Nope.
							var/static/list/icon_to_state = list('icons/mob/clothing/taur_hooved.dmi' = "_hooved", 'icons/mob/clothing/taur_naga.dmi' = "_naga", 'icons/mob/clothing/taur_canine.dmi' = "_paws")
							worn_state += icon_to_state[worn_icon]
							worn_icon = S.taur_mob_worn_overlay
						center = T.center
						dimension_x = T.dimension_x
						dimension_y = T.dimension_y

				else if((DIGITIGRADE in dna.species.species_traits) && S.mutantrace_variation & STYLE_DIGITIGRADE && !(S.mutantrace_variation & STYLE_NO_ANTHRO_ICON)) //not a taur, but digitigrade legs.
					worn_icon = S.anthro_mob_worn_overlay || 'icons/mob/clothing/suit_digi.dmi'
					variation_flag |= STYLE_DIGITIGRADE

			overlays_standing[SUIT_LAYER] = S.build_worn_icon(SUIT_LAYER, worn_icon, FALSE, NO_FEMALE_UNIFORM, worn_state, variation_flag, FALSE)
			var/mutable_appearance/suit_overlay = overlays_standing[SUIT_LAYER]
			if(OFFSET_SUIT in dna.species.offset_features)
				suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
				suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
			if(center)
				suit_overlay = center_image(suit_overlay, dimension_x, dimension_y)
			overlays_standing[SUIT_LAYER] = suit_overlay
		update_hair()
		update_mutant_bodyparts()

		apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/obj/screen/inventory/inv

		inv = hud_used.inv_slots[SLOT_L_STORE]
		inv.update_icon()

		inv = hud_used.inv_slots[SLOT_R_STORE]
		inv.update_icon()

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			update_observer_view(r_store)


/mob/living/carbon/human/update_inv_wear_mask()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		remove_overlay(FACEMASK_LAYER)

		if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
			return

		if(client && hud_used)
			var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_MASK]
			inv.update_icon()

		if(wear_mask)
			wear_mask.screen_loc = ui_mask
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)
					client.screen += wear_mask
			update_observer_view(wear_mask,1)
			var/obj/item/clothing/mask/M = wear_mask
			remove_overlay(FACEMASK_LAYER)
			var/alt_icon = M.mob_overlay_icon || 'icons/mob/clothing/mask.dmi'
			var/muzzled = FALSE
			var/variation_flag = NONE
			if(head && (head.flags_inv & HIDEMASK))
				return
			if(dna.species.mutant_bodyparts["mam_snouts"] && dna.features["mam_snouts"] != "None")
				muzzled = TRUE
			else if(dna.species.mutant_bodyparts["snout"] && dna.features["snout"] != "None")
				muzzled = TRUE
			if(muzzled && M.mutantrace_variation & STYLE_MUZZLE && !(M.mutantrace_variation & STYLE_NO_ANTHRO_ICON))
				alt_icon = M.anthro_mob_worn_overlay || 'icons/mob/clothing/mask_muzzled.dmi'
				variation_flag |= STYLE_MUZZLE

			var/mutable_appearance/mask_overlay = M.build_worn_icon(FACEMASK_LAYER, alt_icon, FALSE, NO_FEMALE_UNIFORM, wear_mask.icon_state, variation_flag, FALSE)

			if(OFFSET_FACEMASK in dna.species.offset_features)
				mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK][1]
				mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK][2]
			overlays_standing[FACEMASK_LAYER] = mask_overlay
			apply_overlay(FACEMASK_LAYER)
		update_mutant_bodyparts() //e.g. upgate needed because mask now hides lizard snout

/mob/living/carbon/human/update_inv_back()
	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		..()
		var/mutable_appearance/back_overlay = overlays_standing[BACK_LAYER]
		if(back_overlay)
			remove_overlay(BACK_LAYER)
			if(OFFSET_BACK in dna.species.offset_features)
				back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
				back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
				overlays_standing[BACK_LAYER] = back_overlay
			apply_overlay(BACK_LAYER)

/proc/wear_alpha_masked_version(state, icon, layer, female, alpha_mask)
	var/mask = "-[alpha_mask]"
	if(islist(alpha_mask))
		mask = "-"
		for(var/t in alpha_mask)
			mask += t
	var/index = "[state]-[icon]-[female][mask]"
	. = GLOB.alpha_masked_worn_icons[index]
	if(!.) 	//Create standing/laying icons if they don't exist
		. = generate_alpha_masked_clothing(index,state,icon,female,alpha_mask)
	return mutable_appearance(., layer = -layer)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out

//human HUD updates for items in our inventory

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/I)
	I.screen_loc = ui_neck
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)




/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
 inhands and any other form of worn item
 centering large appearances
 layering appearances on custom layers
 building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

override_state: A string to use as the state, otherwise item_state or icon_state will be used.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then mob_overlay_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

femalueuniform: A value matching a uniform item's fitted var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables

style_flags: mutant race appearance flags, mostly used for worn_overlays()

alpha_mask: a text string or list of text, the actual icons are stored in a global list and associated with said text string(s).

use_mob_overlay_icon: if FALSE, it will always use the default_icon_file even if mob_overlay_icon is present.

*/
/obj/item/proc/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state, style_flags = NONE, use_mob_overlay_icon = TRUE, alpha_mask)

	var/t_state
	t_state = override_state || item_state || icon_state

	//Find a valid icon file from variables+arguments
	var/file2use
	if(!isinhands && mob_overlay_icon && use_mob_overlay_icon)
		file2use = mob_overlay_icon
	if(!file2use)
		file2use = default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use
	if(alternate_worn_layer)
		layer2use = alternate_worn_layer
	if(!layer2use)
		layer2use = default_layer

	var/mutable_appearance/standing
	if(femaleuniform || alpha_mask)
		standing = wear_alpha_masked_version(t_state, file2use, layer2use, femaleuniform, alpha_mask)
	if(!standing)
		standing = mutable_appearance(file2use, t_state, -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands, file2use, t_state, style_flags)
	if(worn_overlays && worn_overlays.len)
		standing.overlays.Add(worn_overlays)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	//Handle held offsets
	var/mob/M = loc
	if(istype(M))
		var/list/L = get_held_offsets()
		if(L)
			standing.pixel_x += L["x"] //+= because of center()ing
			standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing.color = color

	return standing


/obj/item/proc/get_held_offsets()
	var/list/L
	if(ismob(loc))
		var/mob/M = loc
		L = M.get_item_offsets_for_index(M.get_held_index_of_item(src))
	return L


//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)



//produces a key based on the human's limbs
/mob/living/carbon/human/generate_icon_render_key()
	. = "[dna.species.mutant_bodyparts["limbs_id"]]"
	. += "[dna.features["color_scheme"]]"

	if(dna.check_mutation(HULK))
		. += "-coloured-hulk"
	else if(dna.species.use_skintones)
		. += "-coloured-[skin_tone]"
	else if(dna.species.fixed_mut_color)
		. += "-coloured-[dna.species.fixed_mut_color]"
	else if(dna.features["mcolor"])
		. += "-coloured-[dna.features["mcolor"]]-[dna.features["mcolor2"]]-[dna.features["mcolor3"]]"
	else
		. += "-not_coloured"

	. += "-[dna.features["body_model"]]"

	var/is_taur = FALSE
	if(dna.species.mutant_bodyparts["taur"])
		var/datum/sprite_accessory/taur/T = GLOB.taur_list[dna.features["taur"]]
		if(T?.hide_legs)
			is_taur = TRUE

	var/static/list/leg_day = typecacheof(list(/obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg))
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(is_taur && leg_day[BP.type])
			continue

		. += "-[BP.body_zone]"
		if(BP.is_organic_limb(FALSE))
			. += "-organic"
		else
			. += "-robotic"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
			if(BP.digitigrade_type)
				. += "-[BP.digitigrade_type]"
		if(BP.dmg_overlay_type)
			. += "-[BP.dmg_overlay_type]"
		if(BP.body_markings_list)
			. += "-[safe_json_encode(BP.body_markings_list)]"
		if(BP.icon)
			. += "-[BP.icon]"
		else
			. += "-no_marking"

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"

/mob/living/carbon/human/load_limb_from_cache(send_signal = TRUE)
	..()
	update_hair(send_signal)

/mob/living/carbon/human/proc/update_observer_view(obj/item/I, inventory)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

// Only renders the head of the human
/mob/living/carbon/human/proc/update_body_parts_head_only()
	if(!dna)
		return

	if(!dna.species)
		return

	if(!HAS_TRAIT(src, TRAIT_HUMAN_NO_RENDER))
		return

	var/obj/item/bodypart/HD = get_bodypart("head")
	if(!istype(HD))
		return

	HD.update_limb()

	add_overlay(HD.get_limb_icon())
	update_damage_overlays()

	if(HD && !(HAS_TRAIT(src, TRAIT_HUSK)))
		// lipstick
		if(lip_style && (LIPS in dna.species.species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/lips.dmi', "lips_[lip_style]", -BODY_LAYER)
			lip_overlay.color = lip_color
			if(OFFSET_LIPS in dna.species.offset_features)
				lip_overlay.pixel_x += dna.species.offset_features[OFFSET_LIPS][1]
				lip_overlay.pixel_y += dna.species.offset_features[OFFSET_LIPS][2]
			add_overlay(lip_overlay)

		// eyes
		if(!(NOEYES in dna.species.species_traits))
			var/has_eyes = getorganslot(ORGAN_SLOT_EYES)
			if(!has_eyes)
				add_overlay(mutable_appearance('icons/mob/eyes.dmi', "eyes_missing", -BODY_LAYER))
			else
				var/left_state = DEFAULT_LEFT_EYE_STATE
				var/right_state = DEFAULT_RIGHT_EYE_STATE
				if(dna.species)
					var/eye_type = dna.species.eye_type
					if(GLOB.eye_types[eye_type])
						left_state = eye_type + "_left_eye"
						right_state = eye_type + "_right_eye"
				var/mutable_appearance/left_eye = mutable_appearance('icons/mob/eyes.dmi', left_state, -BODY_LAYER)
				var/mutable_appearance/right_eye = mutable_appearance('icons/mob/eyes.dmi', right_state, -BODY_LAYER)
				if((EYECOLOR in dna.species.species_traits) && has_eyes)
					left_eye.color = "#" + left_eye_color
					right_eye.color = "#" + right_eye_color
				if(OFFSET_EYES in dna.species.offset_features)
					left_eye.pixel_x += dna.species.offset_features[OFFSET_EYES][1]
					left_eye.pixel_y += dna.species.offset_features[OFFSET_EYES][2]
					right_eye.pixel_x += dna.species.offset_features[OFFSET_EYES][1]
					right_eye.pixel_y += dna.species.offset_features[OFFSET_EYES][2]
				add_overlay(left_eye)
				add_overlay(right_eye)


	dna.species.handle_hair(src)

	update_inv_head()
	update_inv_wear_mask()
