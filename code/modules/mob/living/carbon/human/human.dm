/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "caucasian_m"
	SET_APPEARANCE_FLAGS(KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE)

/mob/living/carbon/human/Initialize()
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/lay_down)
	add_verb(src, /mob/living/carbon/human/verb/underwear_toggle)
	add_verb(src, /mob/living/verb/subtle)
	add_verb(src, /mob/living/verb/subtler)
	//initialize limbs first
	create_bodyparts()

	setup_human_dna()

	if(dna.species)
		set_species(dna.species.type)

	//initialise organs
	create_internal_organs() //most of it is done in set_species now, this is only for parent call
	physiology = new()

	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, 2)
	. = ..()

	if(CONFIG_GET(flag/disable_stambuffer))
		enable_intentional_sprint_mode()

	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, /atom.proc/clean_blood)
	GLOB.human_list += src

/mob/living/carbon/human/proc/setup_human_dna()
	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	if(!CONFIG_GET(flag/disable_human_mood))
		AddComponent(/datum/component/mood)
	AddComponent(/datum/component/combat_mode)
	AddElement(/datum/element/flavor_text/carbon, _name = "Flavor Text", _save_key = "flavor_text")
	AddElement(/datum/element/flavor_text/carbon/temporary, "", "Set Pose (Temporary Flavor Text)", "This should be used only for things pertaining to the current round!", _save_key = null)
	AddElement(/datum/element/flavor_text, _name = "OOC Notes", _addendum = "Put information on ERP/vore/lewd-related preferences here. THIS SHOULD NOT CONTAIN REGULAR FLAVORTEXT!!", _always_show = TRUE, _save_key = "ooc_notes", _examine_no_preview = TRUE)

/mob/living/carbon/human/Destroy()
	QDEL_NULL(physiology)
	QDEL_NULL_LIST(vore_organs) // CITADEL EDIT belly stuff
	GLOB.human_list -= src
	return ..()

/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"
	. += "Move Mode: [m_intent]"
	if(internal)
		if(!internal.air_contents)
			qdel(internal)
		else
			. += ""
			. += "Internal Atmosphere Info: [internal.name]"
			. += "Tank Pressure: [internal.air_contents.return_pressure()]"
			. += "Distribution Pressure: [internal.distribute_pressure]"
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			. += ""
			. += "Chemical Storage: [changeling.chem_charges]/[changeling.chem_storage]"
			. += "Absorbed DNA: [changeling.absorbedcount]"
	//NINJACODE
	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)) //Only display if actually a ninja.
		var/obj/item/clothing/suit/space/space_ninja/SN = wear_suit
		. += "SpiderOS Status: [SN.s_initialized ? "Initialized" : "Disabled"]"
		. += "Current Time: [STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)]"
		if(SN.s_initialized)
			//Suit gear
			. += "Energy Charge: [round(SN.cell.charge/100)]%"
			. += "Smoke Bombs: \Roman [SN.s_bombs]"
			//Ninja status
			. += "Fingerprints: [md5(dna.uni_identity)]"
			. += "Unique Identity: [dna.unique_enzymes]"
			. += "Overall Status: [stat > 1 ? "dead" : "[health]% healthy"]"
			. += "Nutrition Status: [nutrition]"
			. += "Oxygen Loss: [getOxyLoss()]"
			. += "Toxin Levels: [getToxLoss()]"
			. += "Burn Severity: [getFireLoss()]"
			. += "Brute Trauma: [getBruteLoss()]"
			. += "Radiation Levels: [radiation] rad"
			. += "Body Temperature: [bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)"

			//Diseases
			if(length(diseases))
				. += "Viruses:"
				for(var/thing in diseases)
					var/datum/disease/D = thing
					. += "* [D.name], Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]"


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()
	var/list/dat = list()

	dat += "<table>"
	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<tr><td><B>[get_held_index_name(i)]:</B></td><td><A href='?src=[REF(src)];item=[SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[REF(src)];item=[SLOT_BACK]'>[(back && !(back.item_flags & ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_BACK]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[REF(src)];item=[SLOT_HEAD]'>[(head && !(head.item_flags & ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_WEAR_MASK in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.item_flags & ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_NECK in obscured)
		dat += "<tr><td><font color=grey><B>Neck:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Neck:</B></td><td><A href='?src=[REF(src)];item=[SLOT_NECK]'>[(wear_neck && !(wear_neck.item_flags & ABSTRACT)) ? wear_neck : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_GLASSES in obscured)
		dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=[REF(src)];item=[SLOT_GLASSES]'>[(glasses && !(glasses.item_flags & ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_EARS in obscured)
		dat += "<tr><td><font color=grey><B>Ears:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Ears:</B></td><td><A href='?src=[REF(src)];item=[SLOT_EARS]'>[(ears && !(ears.item_flags & ABSTRACT))		? ears		: "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_SUIT]'>[(wear_suit && !(wear_suit.item_flags & ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A>"
	if(wear_suit)
		if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
			var/hardsuit_head = head && istype(head, /obj/item/clothing/head/helmet/space/hardsuit)
			dat += "&nbsp;<A href='?src=[REF(src)];toggle_helmet=[SLOT_WEAR_SUIT]'>[hardsuit_head ? "Retract Helmet" : "Extend Helmet"]</A>"
		dat += "</td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=[REF(src)];item=[SLOT_S_STORE]'>[(s_store && !(s_store.item_flags & ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(s_store, /obj/item/tank))
			dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_S_STORE]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
	else
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

	if(SLOT_SHOES in obscured)
		dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=[REF(src)];item=[SLOT_SHOES]'>[(shoes && !(shoes.item_flags & ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A>"
		if(shoes && shoes.can_be_tied && shoes.tied != SHOES_KNOTTED)
			dat += "&nbsp;<A href='?src=[REF(src)];shoes=[SLOT_SHOES]'>[shoes.tied ? "Untie shoes" : "Knot shoes"]</A>"

		dat += "</td></tr>"

	if(SLOT_GLOVES in obscured)
		dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=[REF(src)];item=[SLOT_GLOVES]'>[(gloves && !(gloves.item_flags & ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(SLOT_W_UNIFORM in obscured)
		dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=[REF(src)];item=[SLOT_W_UNIFORM]'>[(w_uniform && !(w_uniform.item_flags & ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

	if((w_uniform == null && !(dna && dna.species.nojumpsuit)) || (SLOT_W_UNIFORM in obscured))
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
	else
		dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=[REF(src)];item=[SLOT_BELT]'>[(belt && !(belt.item_flags & ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(belt, /obj/item/tank))
			dat += "&nbsp;<A href='?src=[REF(src)];internal=[SLOT_BELT]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=[REF(src)];pockets=left'>[(l_store && !(l_store.item_flags & ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += "&nbsp;<A href='?src=[REF(src)];pockets=right'>[(r_store && !(r_store.item_flags & ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A></td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=[REF(src)];item=[SLOT_WEAR_ID]'>[(wear_id && !(wear_id.item_flags & ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 440, 510)
	popup.set_content(dat.Join())
	popup.open()

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)
	var/mob/living/simple_animal/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

	spreadFire(AM)

/mob/living/carbon/human/Topic(href, href_list)
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["embedded_object"])
			var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
			if(!L)
				return
			var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
			if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
				return
			SEND_SIGNAL(src, COMSIG_CARBON_EMBED_RIP, I, L)
			return
		if(href_list["toggle_helmet"])
			if(!istype(head, /obj/item/clothing/head/helmet/space/hardsuit))
				return
			var/obj/item/clothing/head/helmet/space/hardsuit/hardsuit_head = head
			visible_message("<span class='danger'>[usr] tries to [hardsuit_head ? "retract" : "extend"] [src]'s helmet.</span>", \
								"<span class='userdanger'>[usr] tries to [hardsuit_head ? "retract" : "extend"] [src]'s helmet.</span>", \
								target = usr, target_message = "<span class='danger'>You try to [hardsuit_head ? "retract" : "extend"] [src]'s helmet.</span>")
			if(!do_mob(usr, src, hardsuit_head ? head.strip_delay : POCKET_STRIP_DELAY))
				return
			if(!istype(wear_suit, /obj/item/clothing/suit/space/hardsuit) || (hardsuit_head ? (!head || head != hardsuit_head) : head))
				return
			var/obj/item/clothing/suit/space/hardsuit/hardsuit = wear_suit //This should be an hardsuit given all our checks
			if(hardsuit.ToggleHelmet(FALSE))
				visible_message("<span class='danger'>[usr] [hardsuit_head ? "retract" : "extend"] [src]'s helmet</span>", \
										"<span class='userdanger'>[usr] [hardsuit_head ? "retract" : "extend"] [src]'s helmet</span>", \
										target = usr, target_message = "<span class='danger'>You [hardsuit_head ? "retract" : "extend"] [src]'s helmet.</span>")
			return
		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return
		if(href_list["pockets"])
			var/strip_mod = 1
			var/strip_silence = FALSE
			var/obj/item/clothing/gloves/G = gloves
			if(istype(G))
				strip_mod = G.strip_mod
				strip_silence = G.strip_silence
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? SLOT_R_STORE : SLOT_L_STORE)
			var/obj/item/pocket_item = (pocket_id == SLOT_R_STORE ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_held_item() // Item to place in the pocket, if it's empty

			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.item_flags & ABSTRACT))
				if(HAS_TRAIT(pocket_item, TRAIT_NODROP))
					to_chat(usr, "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
				to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
			else if(place_item && place_item.mob_can_equip(src, usr, pocket_id, 1) && !(place_item.item_flags & ABSTRACT))
				to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, max(round(POCKET_STRIP_DELAY/(delay_denominator*strip_mod)),1), ignorehelditem = TRUE)) //placing an item into the pocket is 4 times faster (and the strip_mod too)
				if(pocket_item)
					if(pocket_item == (pocket_id == SLOT_R_STORE ? r_store : l_store)) //item still in the pocket we search
						dropItemToGround(pocket_item)
						if(!usr.can_hold_items() || !usr.put_in_hands(pocket_item))
							pocket_item.forceMove(drop_location())
						log_combat(usr, src, "pickpocketed of item: [pocket_item]")
				else
					if(place_item)
						if(place_item.mob_can_equip(src, usr, pocket_id, FALSE, TRUE))
							usr.temporarilyRemoveItemFromInventory(place_item, TRUE)
							equip_to_slot(place_item, pocket_id, TRUE)
							log_combat(usr, src, "placed item [place_item] onto")
						//do nothing otherwise

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up
				if(!strip_silence)
					to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")
				log_combat(usr, src, "failed to [pocket_item ? "pickpocket item [pocket_item] from" : "place item [place_item] onto "]")

	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY, null, FALSE))
		// separate from first canusetopic
		var/mob/living/user = usr
		if(istype(user) && href_list["shoes"] && (user.mobility_flags & MOBILITY_USE)) // we need to be on the ground, so we'll be a bit looser
			shoes.handle_tying(usr)

	..()	//CITADEL CHANGE - removes a tab from behind this ..() so that flavortext can actually be examined


///////HUDs///////
	if(href_list["hud"])
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/perpname = get_face_name(get_id_name(""))
			if(istype(H.glasses, /obj/item/clothing/glasses/hud) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud))
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(href_list["photo_front"] || href_list["photo_side"])
					if(R)
						if(!H.canUseHUD())
							return
						else if(!istype(H.glasses, /obj/item/clothing/glasses/hud) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
							return
						var/obj/item/photo/P = null
						if(href_list["photo_front"])
							P = R.fields["photo_front"]
						else if(href_list["photo_side"])
							P = R.fields["photo_side"]
						if(P)
							P.show(H)

				if(href_list["hud"] == "m")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
						if(href_list["p_stat"])
							var/health_status = input(usr, "Specify a new physical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
							if(R)
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
									return
								if(health_status && health_status != "Cancel")
									R.fields["p_stat"] = health_status
							return
						if(href_list["m_stat"])
							var/health_status = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
							if(R)
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/medical))
									return
								if(health_status && health_status != "Cancel")
									R.fields["m_stat"] = health_status
							return
						if(href_list["evaluation"])
							if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
								to_chat(usr, "<span class='notice'>No external injuries detected.</span><br>")
								return
							var/span = "notice"
							var/status = ""
							if(getBruteLoss())
								to_chat(usr, "<b>Physical trauma analysis:</b>")
								for(var/X in bodyparts)
									var/obj/item/bodypart/BP = X
									var/brutedamage = BP.brute_dam
									if(brutedamage > 0)
										status = "received minor physical injuries."
										span = "notice"
									if(brutedamage > 20)
										status = "been seriously damaged."
										span = "danger"
									if(brutedamage > 40)
										status = "sustained major trauma!"
										span = "userdanger"
									if(brutedamage)
										to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
							if(getFireLoss())
								to_chat(usr, "<b>Analysis of skin burns:</b>")
								for(var/X in bodyparts)
									var/obj/item/bodypart/BP = X
									var/burndamage = BP.burn_dam
									if(burndamage > 0)
										status = "signs of minor burns."
										span = "notice"
									if(burndamage > 20)
										status = "serious burns."
										span = "danger"
									if(burndamage > 40)
										status = "major burns!"
										span = "userdanger"
									if(burndamage)
										to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
							if(getOxyLoss())
								to_chat(usr, "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>")
							if(getToxLoss() > 20)
								to_chat(usr, "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>")

				if(href_list["hud"] == "s")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
						if(usr.stat || usr == src) //|| !usr.canmove || usr.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
							return													  //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
						// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
						var/allowed_access = null
						var/obj/item/clothing/glasses/G = H.glasses
						if (!(G.obj_flags & EMAGGED))
							if(H.wear_id)
								var/list/access = H.wear_id.GetAccess()
								if(ACCESS_SEC_DOORS in access)
									allowed_access = H.get_authentification_name()
						else
							allowed_access = "@%&ERROR_%$*"


						if(!allowed_access)
							to_chat(H, "<span class='warning'>ERROR: Invalid Access</span>")
							return

						if(perpname)
							R = find_record("name", perpname, GLOB.data_core.security)
							if(R)
								if(href_list["status"])
									var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Paroled", "Discharged", "Cancel")
									if(setcriminal != "Cancel")
										if(R)
											if(H.canUseHUD())
												if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
													investigate_log("[key_name(src)] has been set from [R.fields["criminal"]] to [setcriminal] by [key_name(usr)].", INVESTIGATE_RECORDS)
													R.fields["criminal"] = setcriminal
													sec_hud_set_security_status()
									return

								if(href_list["view"])
									if(R)
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
											return
										to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
										to_chat(usr, "<b>Minor Crimes:</b>")
										for(var/datum/data/crime/c in R.fields["mi_crim"])
											to_chat(usr, "<b>Crime:</b> [c.crimeName]")
											to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
											to_chat(usr, "Added by [c.author] at [c.time]")
											to_chat(usr, "----------")
										to_chat(usr, "<b>Major Crimes:</b>")
										for(var/datum/data/crime/c in R.fields["ma_crim"])
											to_chat(usr, "<b>Crime:</b> [c.crimeName]")
											to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
											to_chat(usr, "Added by [c.author] at [c.time]")
											to_chat(usr, "----------")
										to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
									return

								if(href_list["add_crime"])
									switch(alert("What crime would you like to add?","Security HUD","Minor Crime","Major Crime","Cancel"))
										if("Minor Crime")
											if(R)
												var/t1 = stripped_input("Please input minor crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input minor crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access)
														return
													else if(!H.canUseHUD())
														return
													else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
														return
													var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, STATION_TIME_TIMESTAMP("hh:mm:ss", world.time))
													GLOB.data_core.addMinorCrime(R.fields["id"], crime)
													investigate_log("New Minor Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
													to_chat(usr, "<span class='notice'>Successfully added a minor crime.</span>")
													return
										if("Major Crime")
											if(R)
												var/t1 = stripped_input("Please input major crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input major crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access)
														return
													else if (!H.canUseHUD())
														return
													else if (!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
														return
													var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, STATION_TIME_TIMESTAMP("hh:mm:ss", world.time))
													GLOB.data_core.addMajorCrime(R.fields["id"], crime)
													investigate_log("New Major Crime: <strong>[t1]</strong>: [t2] | Added to [R.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
													to_chat(usr, "<span class='notice'>Successfully added a major crime.</span>")
									return

								if(href_list["view_comment"])
									if(R)
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
											return
										to_chat(usr, "<b>Comments/Log:</b>")
										var/counter = 1
										while(R.fields[text("com_[]", counter)])
											to_chat(usr, R.fields[text("com_[]", counter)])
											to_chat(usr, "----------")
											counter++
										return

								if(href_list["add_comment"])
									if(R)
										var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
										if(R)
											if (!t1 || !allowed_access)
												return
											else if(!H.canUseHUD())
												return
											else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot(ORGAN_SLOT_HUD), /obj/item/organ/cyberimp/eyes/hud/security))
												return
											var/counter = 1
											while(R.fields[text("com_[]", counter)])
												counter++
											R.fields["com_[counter]"] = "Made by [allowed_access] on [STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)] [time2text(world.realtime, "MMM DD")], [GLOB.year_integer]<BR>[t1]"
											to_chat(usr, "<span class='notice'>Successfully added comment.</span>")
											return
							to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

/mob/living/carbon/human/proc/canUseHUD()
	return CHECK_MOBILITY(src, MOBILITY_UI)

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE, bypass_immunity = FALSE)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_selected
	if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE) && !bypass_immunity)
		. = 0
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if (!penetrate_thick)
		if(above_neck(target_zone))
			if(head && istype(head, /obj/item/clothing))
				var/obj/item/clothing/CH = head
				if (CH.clothing_flags & THICKMATERIAL)
					. = 0
		else
			if(wear_suit && istype(wear_suit, /obj/item/clothing))
				var/obj/item/clothing/CS = wear_suit
				if (CS.clothing_flags & THICKMATERIAL)
					. = 0
	if(!. && error_msg && user)
		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on [p_their()] head" : "on [p_their()] body"].</span>")

/mob/living/carbon/human/check_obscured_slots()
	. = ..()
	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			LAZYOR(., SLOT_GLOVES)
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			LAZYOR(., SLOT_W_UNIFORM)
		if(wear_suit.flags_inv & HIDESHOES)
			LAZYOR(., SLOT_SHOES)

/mob/living/carbon/human/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgement_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if( (judgement_criteria & JUDGE_IDCHECK) && !idcard && name=="Unknown")
		threatcount += 4

	//Check for weapons
	if( (judgement_criteria & JUDGE_WEAPONCHECK) && weaponcheck)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			for(var/obj/item/I in held_items) //if they're holding a gun
				if(weaponcheck.Invoke(I))
					threatcount += 4
			if(weaponcheck.Invoke(belt) || weaponcheck.Invoke(back)) //if a weapon is present in the belt or back slot
				threatcount += 2 //not enough to trigger look_for_perp() on it's own unless they also have criminal status.

	//Check for arrest warrant
	if(judgement_criteria & JUDGE_RECORDCHECK)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Paroled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/syndi) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi))
		threatcount += 4 //fuk u antags <3			//no you

	//mindshield implants imply trustworthyness
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/card/id/syndicate))
		threatcount -= 2

	return threatcount


//Used for new human mobs created by cloning/goleming/podding
/mob/living/carbon/human/proc/set_cloned_appearance()
	if(dna.features["body_model"] == MALE)
		facial_hair_style = "Full Beard"
	else
		facial_hair_style = "Shaved"
	hair_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	underwear = "Nude"
	undershirt = "Nude"
	socks = "Nude"
	update_body(TRUE)
	update_hair()

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in held_items)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	rad_act(current_size * 3)
	if(mob_negates_gravity())
		return

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/C)
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		to_chat(src, "<span class='warning'>[C.name] is dead!</span>")
		return
	if(is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return 0
	if(C.is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove [p_their()] mask first!</span>")
		return 0

	if(C.cpr_time < world.time + 30)
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>You try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_mob(src, C))
			to_chat(src, "<span class='warning'>You fail to perform CPR on [C]!</span>")
			return 0

		var/they_breathe = !HAS_TRAIT(C, TRAIT_NOBREATH)
		var/they_lung = C.getorganslot(ORGAN_SLOT_LUNGS)

		if(C.health > C.crit_threshold)
			return

		src.visible_message("[src] performs CPR on [C.name]!", "<span class='notice'>You perform CPR on [C.name].</span>")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "perform_cpr", /datum/mood_event/perform_cpr)
		C.cpr_time = world.time
		log_combat(src, C, "CPRed")

		if(they_breathe && they_lung)
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air enter your lungs... It feels good...</span>")
		else if(they_breathe && !they_lung)
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air... but you don't feel any better...</span>")
		else
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air... which is a sensation you don't recognise...</span>")

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(dna && dna.check_mutation(HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		if(..(I, cuff_break = FAST_CUFFBREAK))
			dropItemToGround(I)
	else
		if(..())
			dropItemToGround(I)

/mob/living/carbon/human/clean_blood()
	var/mob/living/carbon/human/H = src
	if(H.gloves)
		if(H.gloves.clean_blood())
			H.update_inv_gloves()
	else
		..() // Clear the Blood_DNA list
		if(H.bloody_hands)
			H.bloody_hands = 0
			H.update_inv_gloves()
	update_icons()	//apply the now updated overlays to the mob

/mob/living/carbon/human/wash_cream()
	if(creamed) //clean both to prevent a rare bug
		cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_snout"))
		cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_human"))
		creamed = FALSE

//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//Handle mutant parts if possible
	if(dna && dna.species)
		add_atom_colour("#000000", TEMPORARY_COLOUR_PRIORITY)
		var/static/mutable_appearance/electrocution_skeleton_anim
		if(!electrocution_skeleton_anim)
			electrocution_skeleton_anim = mutable_appearance(icon, "electrocuted_base")
			electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
		add_overlay(electrocution_skeleton_anim)
		addtimer(CALLBACK(src, .proc/end_electrocution_animation, electrocution_skeleton_anim), anim_duration)

	else //or just do a generic animation
		flick_overlay_view(image(icon,src,"electrocuted_generic",ABOVE_MOB_LAYER), src, anim_duration)

/mob/living/carbon/human/proc/end_electrocution_animation(mutable_appearance/MA)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#000000")
	cut_overlay(MA)

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE, check_resting = TRUE)
	if(incapacitated() || (check_resting && !CHECK_MOBILITY(src, MOBILITY_STAND)))
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(!Adjacent(M) && (M.loc != src))
		if((be_close == 0) || (!no_tk && (dna.check_mutation(TK) && tkMaxRangeCheck(src, M))))
			return TRUE
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		MarkResistTime()
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/replace_records_name(oldname,newname) // Only humans have records right now, move this up if changed.
	for(var/list/L in list(GLOB.data_core.general,GLOB.data_core.medical,GLOB.data_core.security,GLOB.data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		. += glasses.tint

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(hud_used.healths)
			var/health_amount = min(health, maxHealth - clamp(getStaminaLoss()-50, 0, 80))//CIT CHANGE - makes staminaloss have less of an impact on the health hud
			if(..(health_amount)) //not dead
				switch(hal_screwyhud)
					if(SCREWYHUD_CRIT)
						hud_used.healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						hud_used.healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
						hud_used.healths.icon_state = "health0"
		if(hud_used.healthdoll)
			hud_used.healthdoll.cut_overlays()
			if(stat != DEAD)
				hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
				for(var/X in bodyparts)
					var/obj/item/bodypart/BP = X
					var/damage = BP.burn_dam + BP.brute_dam
					var/comparison = (BP.max_damage/5)
					var/icon_num = 0
					if(damage)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					if(hal_screwyhud == SCREWYHUD_HEALTHY)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone][icon_num]"))
				for(var/t in get_missing_limbs()) //Missing limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]6"))
				for(var/t in get_disabled_limbs()) //Disabled limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]7"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"

		hud_used.staminas?.update_icon_state()
		hud_used.staminabuffer?.mark_dirty()

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	if(admin_revive)
		regenerate_limbs()
		regenerate_organs()
	remove_all_embedded_objects()
	set_heartattack(FALSE)
	drunkenness = 0
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM.quality != POSITIVE)
			dna.remove_mutation(HM.name)
	if(blood_volume < (BLOOD_VOLUME_NORMAL*blood_ratio))
		blood_volume = (BLOOD_VOLUME_NORMAL*blood_ratio)
	..()

/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	. = ..()
	if (dna && dna.species)
		. += dna.species.check_weakness(weapon, attacker)

/mob/living/carbon/human/is_literate()
	return TRUE

/mob/living/carbon/human/update_gravity(has_gravity,override = 0)
	if(dna && dna.species) //prevents a runtime while a human is being monkeyfied
		override = dna.species.override_float
	..()

/mob/living/carbon/human/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, vomit_type = VOMIT_TOXIC, harm = TRUE, force = FALSE, purge_ratio = 0.1)
	if(blood && dna?.species && (NOBLOOD in dna.species.species_traits))
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing in your stomach!</span>")
		if(stun)
			DefaultCombatKnockdown(200)
		return 1
	..()

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_COPY_OUTFIT, "Copy Outfit")
	VV_DROPDOWN_OPTION(VV_HK_MOD_QUIRKS, "Add/Remove Quirks")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_MONKEY, "Make Monkey")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_CYBORG, "Make Cyborg")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_SLIME, "Make Slime")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_ALIEN, "Make Alien")
	VV_DROPDOWN_OPTION(VV_HK_SET_SPECIES, "Set Species")
	VV_DROPDOWN_OPTION(VV_HK_PURRBATION, "Toggle Purrbation")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_COPY_OUTFIT])
		if(!check_rights(R_SPAWN))
			return
		copy_outfit()
	if(href_list[VV_HK_MOD_QUIRKS])
		if(!check_rights(R_SPAWN))
			return

		var/list/options = list("Clear"="Clear")
		for(var/x in subtypesof(/datum/quirk))
			var/datum/quirk/T = x
			var/qname = initial(T.name)
			options[has_quirk(T) ? "[qname] (Remove)" : "[qname] (Add)"] = T

		var/result = input(usr, "Choose quirk to add/remove","Quirk Mod") as null|anything in options
		if(result)
			if(result == "Clear")
				for(var/datum/quirk/q in roundstart_quirks)
					remove_quirk(q.type)
			else
				var/T = options[result]
				if(has_quirk(T))
					remove_quirk(T)
				else
					add_quirk(T,TRUE)
	if(href_list[VV_HK_MAKE_MONKEY])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("monkeyone"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_CYBORG])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makerobot"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_ALIEN])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makealien"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MAKE_SLIME])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeslime"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_SET_SPECIES])
		if(!check_rights(R_SPAWN))
			return
		var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list
		if(result)
			var/newtype = GLOB.species_list[result]
			admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src] to [result]")
			set_species(newtype)
	if(href_list[VV_HK_PURRBATION])
		if(!check_rights(R_SPAWN))
			return
		if(!ishumanbasic(src))
			to_chat(usr, "This can only be done to the basic human species at the moment.")
			return
		var/success = purrbation_toggle(src)
		if(success)
			to_chat(usr, "Put [src] on purrbation.")
			log_admin("[key_name(usr)] has put [key_name(src)] on purrbation.")
			var/msg = "<span class='notice'>[key_name_admin(usr)] has put [key_name(src)] on purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)

		else
			to_chat(usr, "Removed [src] from purrbation.")
			log_admin("[key_name(usr)] has removed [key_name(src)] from purrbation.")
			var/msg = "<span class='notice'>[key_name_admin(usr)] has removed [key_name(src)] from purrbation.</span>"
			message_admins(msg)
			admin_ticket_log(src, msg)

/mob/living/carbon/human/MouseDrop_T(mob/living/target, mob/living/user)
	var/GS_needed = istype(target, /mob/living/silicon/pai)? GRAB_PASSIVE : GRAB_AGGRESSIVE
	if(pulling == target && grab_state >= GS_needed && stat == CONSCIOUS)
		//If they dragged themselves and we're currently aggressively grabbing them try to piggyback
		if(user == target && can_piggyback(target))
			piggyback(target)
			return
		//If you dragged them to you and you're aggressively grabbing try to fireman carry them
		else if(user == src)
			if(user.a_intent == INTENT_GRAB)
				fireman_carry(target)
				return
	. = ..()

//src is the user that will be carrying, target is the mob to be carried
/mob/living/carbon/human/proc/can_piggyback(mob/living/target)
	return (iscarbon(target) || ispAI(target)) && target.stat == CONSCIOUS

/mob/living/carbon/human/proc/can_be_firemanned(mob/living/carbon/target)
	return (ishuman(target) && !CHECK_MOBILITY(target, MOBILITY_STAND)) || ispAI(target)

/mob/living/carbon/human/proc/fireman_carry(mob/living/carbon/target)
	var/carrydelay = 50 //if you have latex you are faster at grabbing
	var/skills_space = "" //cobby told me to do this
	if(HAS_TRAIT(src, TRAIT_QUICKER_CARRY))
		carrydelay = 30
		skills_space = "expertly "
	else if(HAS_TRAIT(src, TRAIT_QUICK_CARRY))
		carrydelay = 40
		skills_space = "quickly "
	if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE))
		visible_message("<span class='notice'>[src] starts [skills_space]lifting [target] onto their back..</span>",
		//Joe Medic starts quickly/expertly lifting Grey Tider onto their back..
		"<span class='notice'>[carrydelay < 35 ? "Using your gloves' nanochips, you" : "You"] [skills_space]start to lift [target] onto your back[carrydelay == 40 ? ", while assisted by the nanochips in your gloves.." : "..."]</span>")
		//(Using your gloves' nanochips, you/You) ( /quickly/expertly) start to lift Grey Tider onto your back(, while assisted by the nanochips in your gloves../...)
		if(do_after(src, carrydelay, TRUE, target))
			//Second check to make sure they're still valid to be carried
			if(can_be_firemanned(target) && !incapacitated(FALSE, TRUE))
				buckle_mob(target, TRUE, TRUE, 90, 1, 0, TRUE)
				return
		visible_message("<span class='warning'>[src] fails to fireman carry [target]!")
	else
		if (ishuman(target))
			to_chat(src, "<span class='notice'>You can't fireman carry [target] while they're standing!</span>")
		else
			to_chat(src, "<span class='notice'>You can't seem to fireman carry that kind of species.</span>")

/mob/living/carbon/human/proc/piggyback(mob/living/carbon/target)
	if(can_piggyback(target))
		visible_message("<span class='notice'>[target] starts to climb onto [src]...</span>")
		if(do_after(target, 15, target = src, required_mobility_flags = MOBILITY_STAND))
			if(can_piggyback(target))
				if(target.incapacitated(FALSE, TRUE) || incapacitated(FALSE, TRUE))
					target.visible_message("<span class='warning'>[target] can't hang onto [src]!</span>")
					return
				buckle_mob(target, TRUE, TRUE, 0, 1, 2, FALSE)
		else
			visible_message("<span class='warning'>[target] fails to climb onto [src]!</span>")
	else
		to_chat(target, "<span class='warning'>You can't piggyback ride [src] right now!</span>")

/mob/living/carbon/human/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, lying_buckle = 0, hands_needed = 0, target_hands_needed = 0, fireman = FALSE)
	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return
	if(!is_type_in_typecache(target, can_ride_typecache))
		target.visible_message("<span class='warning'>[target] really can't seem to mount [src]...</span>")
		return
	buckle_lying = lying_buckle
	var/datum/component/riding/human/riding_datum = LoadComponent(/datum/component/riding/human)
	if(target_hands_needed)
		riding_datum.ride_check_rider_restrained = TRUE
	if(buckled_mobs && ((target in buckled_mobs) || (buckled_mobs.len >= max_buckled_mobs)) || buckled)
		return
	if(istype(target, /mob/living/silicon/pai))
		hands_needed = 1
		target_hands_needed = 0
	var/equipped_hands_self
	var/equipped_hands_target
	if(hands_needed)
		equipped_hands_self = riding_datum.equip_buckle_inhands(src, hands_needed, target)
	if(target_hands_needed)
		equipped_hands_target = riding_datum.equip_buckle_inhands(target, target_hands_needed)

	if(hands_needed || target_hands_needed)
		if(hands_needed && !equipped_hands_self)
			src.visible_message("<span class='warning'>[src] can't get a grip on [target] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [target] because your hands are full!</span>")
			return
		else if(target_hands_needed && !equipped_hands_target)
			target.visible_message("<span class='warning'>[target] can't get a grip on [src] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [src] because your hands are full!</span>")
			return

	stop_pulling()
	riding_datum.handle_vehicle_layer(dir)
	riding_datum.fireman_carrying = fireman
	. = ..(target, force, check_loc)

/mob/living/carbon/human/proc/is_shove_knockdown_blocked() //If you want to add more things that block shove knockdown, extend this
	for(var/obj/item/clothing/C in get_equipped_items()) //doesn't include pockets
		if(C.blocks_shove_knockdown)
			return TRUE
	return FALSE

/mob/living/carbon/human/updatehealth()
	. = ..()
	dna?.species.spec_updatehealth(src)
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))	//if we want to ignore slowdown from damage and equipment
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
		return
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))	//if we want to ignore slowdown from damage, but not from equipment
		var/scaling = maxHealth / 100
		var/health_deficiency = max(((maxHealth / scaling) - (health / scaling)), max(0, getStaminaLoss() - 39))
		if(health_deficiency >= 40)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, health_deficiency / 75)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, health_deficiency / 25)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
			remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)

/mob/living/carbon/human/is_bleeding()
	if(NOBLOOD in dna.species.species_traits || bleedsuppress)
		return FALSE
	return ..()

/mob/living/carbon/human/get_total_bleed_rate()
	if(NOBLOOD in dna.species.species_traits)
		return FALSE
	return ..()

/mob/living/carbon/human/species
	var/race = null

/mob/living/carbon/human/species/Initialize()
	. = ..()
	set_species(race)

/**
 * # `spec_trait_examine_font()`
 *
 * This gets a humanoid's special examine font, which is used to color their species name during examine / health analyzing.
 * The first of these that applies is returned.
 * Returns:
 * * Metallic font if robotic
 * * Cyan if a toxinlover
 * * Purple if plasmaperson
 * * Rock / Brownish if a golem
 * * Green if none of the others apply (aka, generic organic)
*/
/mob/living/carbon/human/proc/spec_trait_examine_font()
	if(HAS_TRAIT(src, TRAIT_ROBOTIC_ORGANISM))
		return "<font color='#aaa9ad'>"
	if(HAS_TRAIT(src, TRAIT_TOXINLOVER))
		return "<font color='#00ffff'>"
	if(isplasmaman(src))
		return "<font color='#800080'"
	if(isgolem(src))
		return "<font color='#8b4513'"
	return "<font color='#18d855'>"


/mob/living/carbon/human/get_tooltip_data()
	var/t_He = p_they(TRUE)
	var/t_is = p_are()
	. = list()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if(skipface || get_visible_name() == "Unknown")
		. += "You can't make out what species they are."
	else
		. += "[t_He] [t_is] a [spec_trait_examine_font()][dna.custom_species ? dna.custom_species : dna.species.name]</font>"
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, usr, .)

/mob/living/carbon/human/species/abductor
	race = /datum/species/abductor

/mob/living/carbon/human/species/android
	race = /datum/species/android

/mob/living/carbon/human/species/angel
	race = /datum/species/angel

/mob/living/carbon/human/species/corporate
	race = /datum/species/corporate

/mob/living/carbon/human/species/dullahan
	race = /datum/species/dullahan

/mob/living/carbon/human/species/felinid
	race = /datum/species/human/felinid

/mob/living/carbon/human/species/fly
	race = /datum/species/fly

/mob/living/carbon/human/species/golem
	race = /datum/species/golem

/mob/living/carbon/human/species/golem/random
	race = /datum/species/golem/random

/mob/living/carbon/human/species/golem/adamantine
	race = /datum/species/golem/adamantine

/mob/living/carbon/human/species/golem/plasma
	race = /datum/species/golem/plasma

/mob/living/carbon/human/species/golem/diamond
	race = /datum/species/golem/diamond

/mob/living/carbon/human/species/golem/gold
	race = /datum/species/golem/gold

/mob/living/carbon/human/species/golem/silver
	race = /datum/species/golem/silver

/mob/living/carbon/human/species/golem/plasteel
	race = /datum/species/golem/plasteel

/mob/living/carbon/human/species/golem/titanium
	race = /datum/species/golem/titanium

/mob/living/carbon/human/species/golem/plastitanium
	race = /datum/species/golem/plastitanium

/mob/living/carbon/human/species/golem/alien_alloy
	race = /datum/species/golem/alloy

/mob/living/carbon/human/species/golem/wood
	race = /datum/species/golem/wood

/mob/living/carbon/human/species/golem/uranium
	race = /datum/species/golem/uranium

/mob/living/carbon/human/species/golem/sand
	race = /datum/species/golem/sand

/mob/living/carbon/human/species/golem/glass
	race = /datum/species/golem/glass

/mob/living/carbon/human/species/golem/bluespace
	race = /datum/species/golem/bluespace

/mob/living/carbon/human/species/golem/bananium
	race = /datum/species/golem/bananium

/mob/living/carbon/human/species/golem/blood_cult
	race = /datum/species/golem/runic

/mob/living/carbon/human/species/golem/cloth
	race = /datum/species/golem/cloth

/mob/living/carbon/human/species/golem/plastic
	race = /datum/species/golem/plastic

/mob/living/carbon/human/species/golem/bronze
	race = /datum/species/golem/bronze

/mob/living/carbon/human/species/golem/cardboard
	race = /datum/species/golem/cardboard

/mob/living/carbon/human/species/golem/leather
	race = /datum/species/golem/leather

/mob/living/carbon/human/species/golem/bone
	race = /datum/species/golem/bone

/mob/living/carbon/human/species/golem/durathread
	race = /datum/species/golem/durathread

/mob/living/carbon/human/species/golem/clockwork
	race = /datum/species/golem/clockwork

/mob/living/carbon/human/species/golem/clockwork/no_scrap
	race = /datum/species/golem/clockwork/no_scrap

/mob/living/carbon/human/species/jelly
	race = /datum/species/jelly

/mob/living/carbon/human/species/jelly/slime
	race = /datum/species/jelly/slime

/mob/living/carbon/human/species/jelly/stargazer
	race = /datum/species/jelly/stargazer

/mob/living/carbon/human/species/jelly/luminescent
	race = /datum/species/jelly/luminescent

/mob/living/carbon/human/species/lizard
	race = /datum/species/lizard

/mob/living/carbon/human/species/ethereal
	race = /datum/species/ethereal

/mob/living/carbon/human/species/lizard/ashwalker
	race = /datum/species/lizard/ashwalker

/mob/living/carbon/human/species/insect
	race = /datum/species/insect

/mob/living/carbon/human/species/mush
	race = /datum/species/mush

/mob/living/carbon/human/species/plasma
	race = /datum/species/plasmaman

/mob/living/carbon/human/species/pod
	race = /datum/species/pod

/mob/living/carbon/human/species/shadow
	race = /datum/species/shadow

/mob/living/carbon/human/species/shadow/nightmare
	race = /datum/species/shadow/nightmare

/mob/living/carbon/human/species/skeleton
	race = /datum/species/skeleton

/mob/living/carbon/human/species/synth
	race = /datum/species/synth

/mob/living/carbon/human/species/synth/military
	race = /datum/species/synth/military

/mob/living/carbon/human/species/vampire
	race = /datum/species/vampire

/mob/living/carbon/human/species/zombie
	race = /datum/species/zombie

/mob/living/carbon/human/species/zombie/infectious
	race = /datum/species/zombie/infectious

/mob/living/carbon/human/species/zombie/krokodil_addict
	race = /datum/species/krokodil_addict

/mob/living/carbon/human/species/mammal
	race = /datum/species/mammal

/mob/living/carbon/human/species/insect
	race = /datum/species/insect

/mob/living/carbon/human/species/xeno
	race = /datum/species/xeno

/mob/living/carbon/human/species/ipc
	race = /datum/species/ipc

/mob/living/carbon/human/species/roundstartslime
	race = /datum/species/jelly/roundstartslime

/mob/living/carbon/human/species/arachnid
	race = /datum/species/arachnid
