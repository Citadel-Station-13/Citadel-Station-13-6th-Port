/obj/item/clothing/accessory //Ties moved to neck slot items, but as there are still things like medals, pokadots, and armbands, this accessory system is being kept as-is
	name = "Accessory"
	desc = "Something has gone wrong!"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "plasma"
	item_state = ""	//no inhands
	item_color = "plasma" //On accessories, this controls the worn sprite. That's a bit weird.
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	var/above_suit = FALSE
	var/minimize_when_attached = TRUE // TRUE if shown as a small icon in corner, FALSE if overlayed
	var/datum/component/storage/detached_pockets

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/U, user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		if(SEND_SIGNAL(U, COMSIG_CONTAINS_STORAGE))
			return FALSE
		U.TakeComponent(storage)
		detached_pockets = storage
	U.attached_accessory = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	if(minimize_when_attached)
		transform *= 0.5	//halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= 8
	U.add_overlay(src)

	if (islist(U.armor) || isnull(U.armor)) 										// This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)

	if(isliving(user))
		on_uniform_equip(U, user)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/U, user)
	if(detached_pockets && detached_pockets.parent == U)
		TakeComponent(detached_pockets)

	U.armor = U.armor.detachArmor(armor)

	if(isliving(user))
		on_uniform_dropped(U, user)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += 8
	layer = initial(layer)
	plane = initial(plane)
	U.cut_overlays()
	U.attached_accessory = null
	U.accessory_overlay = null

/obj/item/clothing/accessory/proc/on_uniform_equip(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/AltClick(mob/user)
	. = ..()
	if(istype(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(initial(above_suit))
			above_suit = !above_suit
			to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")
			return TRUE

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] can be attached to a uniform. Alt-click to remove it once attached.</span>"
	if(initial(above_suit))
		. += "<span class='notice'>\The [src] can be worn above or below your suit. Alt-click to toggle.</span>"

/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	item_color = "waistcoat"
	minimize_when_attached = FALSE

/obj/item/clothing/accessory/maidapron
	name = "maid apron"
	desc = "The best part of a maid costume."
	icon_state = "maidapron"
	item_state = "maidapron"
	item_color = "maidapron"
	minimize_when_attached = FALSE

//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	item_color = "bronze"
	custom_materials = list(/datum/material/iron=1000)
	resistance_flags = FIRE_PROOF
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && (user.a_intent == INTENT_HELP))

		if(M.wear_suit)
			if((M.wear_suit.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				to_chat(user, "<span class='warning'>Medals can only be pinned on jumpsuits.</span>")
				return

		if(M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			var/delay = 20
			if(user == M)
				delay = 0
			else
				user.visible_message("[user] is trying to pin [src] on [M]'s chest.", \
									 "<span class='notice'>You try to pin [src] on [M]'s chest.</span>")
			var/input
			if(!commended && user != M)
				input = stripped_input(user,"Please input a reason for this commendation, it will be recorded by Nanotrasen.", ,"", 140)
			if(do_after(user, delay, target = M))
				if(U.attach_accessory(src, user, 0)) //Attach it, do not notify the user of the attachment
					if(user == M)
						to_chat(user, "<span class='notice'>You attach [src] to [U].</span>")
					else
						user.visible_message("[user] pins \the [src] on [M]'s chest.", \
											 "<span class='notice'>You pin \the [src] on [M]'s chest.</span>")
						if(input)
							SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[user.real_name]", "commendee" = "[M.real_name]", "medal" = "[src]", "reason" = input))
							GLOB.commendations += "[user.real_name] awarded <b>[M.real_name]</b> the <span class='medaltext'>[name]</span>! \n- [input]"
							commended = TRUE
							desc += "<br>The inscription reads: [input] - [user.real_name]"
							log_game("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
							message_admins("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")

		else
			to_chat(user, "<span class='warning'>Medals can only be pinned on jumpsuits!</span>")
	else
		..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/engineer
	name = "\"Shift's Best Electrician\" award"
	desc = "An award bestowed upon engineers who have excelled at keeping the station running in the best possible condition against all odds."
	icon_state = "engineer"

/obj/item/clothing/accessory/medal/greytide
	name = "\"Greytider of the shift\" award"
	desc = "An award for only the most annoying of assistants.  Locked doors mean nothing to you and behaving is not in your vocabulary"
	icon_state = "greytide"

/obj/item/clothing/accessory/medal/ribbon
	name = "ribbon"
	desc = "A ribbon"
	icon_state = "cargo"
	item_color = "cargo"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "\"cargo tech of the shift\" award"
	desc = "An award bestowed only upon those cargotechs who have exhibited devotion to their duty in keeping with the highest traditions of Cargonia."

/obj/item/clothing/accessory/medal/ribbon/medical_doctor
	name = "\"doctor of the shift\" award"
	desc = "An award bestowed only upon the most capable doctors who have upheld the Hippocratic Oath to the best of their ability"
	icon_state = "medical_doctor"

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	item_color = "silver"
	medaltype = "medal-silver"
	custom_materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	item_color = "gold"
	medaltype = "medal-gold"
	custom_materials = list(/datum/material/gold=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/accessory/medal/gold/captain/family
	name = "old medal of captaincy"
	desc = "A rustic badge pure gold, has been through hell and back by the looks, the syndcate have been after these by the looks of it for generations..."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 10) //Pure gold
	custom_materials = list(/datum/material/gold=2000)

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentCom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	item_color = "plasma"
	medaltype = "medal-plasma"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = -10, "acid" = 0) //It's made of plasma. Of course it's flammable.
	custom_materials = list(/datum/material/plasma=1000)

/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
		visible_message("<span class='danger'> \The [src] bursts into flame!</span>","<span class='userdanger'>Your [src] bursts into flame!</span>")
		qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or engineering."

////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "red armband"
	desc = "An fancy red armband!"
	icon_state = "redband"
	item_color = "redband"

/obj/item/clothing/accessory/armband/deputy
	name = "security deputy armband"
	desc = "An armband, worn by personnel authorized to act as a deputy of station security."

/obj/item/clothing/accessory/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is brown."
	icon_state = "cargoband"
	item_color = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engieband"
	item_color = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "science guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is purple."
	icon_state = "rndband"
	item_color = "rndband"

/obj/item/clothing/accessory/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is green and blue."
	icon_state = "hydroband"
	item_color = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white."
	icon_state = "medband"
	item_color = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white and blue."
	icon_state = "medblueband"
	item_color = "medblueband"

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"
	item_color = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "attorney's badge")
	user.visible_message("[user] shows [user.p_their()] attorney's badge.", "<span class='notice'>You show your attorney's badge.</span>")

/obj/item/clothing/accessory/lawyers_badge/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = initial(L.bubble_icon)

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"
	item_color = "pocketprotector"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/pocketprotector

/obj/item/clothing/accessory/pocketprotector/full/Initialize()
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize()
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	item_color = "talisman"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	item_color = "skull"
	above_suit = TRUE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)

/obj/item/clothing/accessory/skullcodpiece/fake
	name = "false codpiece"
	desc = "A plastic ornament, intended to protect the important things in life. It's not very good at it."
	icon_state = "skull"
	item_color = "skull"
	above_suit = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/////////////////////
//Synda Accessories//
/////////////////////

/obj/item/clothing/accessory/padding
	name = "soft padding"
	desc = "Some long sheets of padding to help soften the blows of a physical attacks."
	icon_state = "padding"
	item_color = "nothing"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 0, "energy" = 0, "bomb" = 5, "bio" = 0, "rad" = 0, "fire" = -20, "acid" = 45)

/obj/item/clothing/accessory/kevlar
	name = "kevlar sheets"
	desc = "Long thin sheets of kevlar to help resist bullets and some physical attacks."
	icon_state = "padding"
	item_color = "nothing"
	armor = list("melee" = 10, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 25)

/obj/item/clothing/accessory/plastics
	name = "underling plastic sheet"
	desc = "A full body sheet of white plastic to help defuse lasers and energy based weapons."
	icon_state = "plastics"
	item_color = "nothing"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 20, "energy" = 10, "bomb" = 0, "bio" = 30, "rad" = 0, "fire" = 0, "acid" = -40)

/////////////////////
//Pokadots On Pants//
/////////////////////

/obj/item/clothing/accessory/attrocious_pokadots
	name = "atrocious pokadots"
	desc = "They look like something out of a thrift store. Attaches to clothing not to be worn by itself."
	icon_state = "attrocious_pokadots"
	item_color = "attrocious_pokadots"
	attack_verb = list("horrifed", "eye bleeded")

/obj/item/clothing/accessory/black_white_pokadots
	name = "checkered pokadots"
	desc = "You can play a game of chess on these! Attaches to clothing not to be worn by itself."
	icon_state = "black_white_pokadots"
	item_color = "black_white_pokadots"
	attack_verb = list("check", "mate")

/obj/item/clothing/accessory/nt_pokadots
	name = "blue and white pokadots"
	desc = "To show your pride in your workplace, in the most annoying possable way. Attaches to clothing not to be worn by itself."
	icon_state = "nt_pokadots"
	item_color = "nt_pokadots"
	attack_verb = list("eye bleeded", "annoyed")

/obj/item/clothing/accessory/syndi_pokadots
	name = "black and red pokadots"
	desc = "King me. Attaches to clothing not to be worn by itself." //checkers!
	icon_state = "syndi_pokadots"
	item_color = "syndi_pokadots"
	attack_verb = list("jumped", "taken")