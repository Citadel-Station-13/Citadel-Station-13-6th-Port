/datum/reagent/blood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_HUMAN, "blood_type"= null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	value = REAGENT_VALUE_UNCOMMON // $$$ blood ""donations"" $$$
	color = BLOOD_COLOR_HUMAN // rgb: 200, 0, 0
	description = "Blood from some creature."
	metabolization_rate = 5 //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"
	shot_glass_icon_state = "shotglassred"
	pH = 7.4

// FEED ME,SEYMOUR!
/datum/reagent/blood/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustPests(rand(2,3))

/datum/reagent/blood/reaction_mob(mob/living/L, method = TOUCH, reac_volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if((method == TOUCH || method == VAPOR) && (D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				L.ContactContractDisease(D)
			else //ingest, patch or inject
				L.ForceContractDisease(D)

	if(data["blood_type"] == "SY")
		//Synthblood is very disgusting to bloodsuckers. They will puke it out to expel it, unless they have masquarade on
		switch(reac_volume)
			if(0 to 3)
				disgust_bloodsucker(L, 3, FALSE, FALSE, FALSE)
			if(3 to 6)
				//If theres more than 8 units, they will start expelling it, even if they are masquarading.
				disgust_bloodsucker(L, 5, FALSE, FALSE, TRUE)
			else
				//If they have too much in them, they will also puke out their blood.
				disgust_bloodsucker(L, 7, -5, TRUE, TRUE)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		var/blood_id = C.get_blood_id()
		if((HAS_TRAIT(C, TRAIT_NOMARROW) || blood_id == /datum/reagent/blood || blood_id == /datum/reagent/blood/jellyblood) && (method == INJECT || (method == INGEST && C.dna && C.dna.species && (DRINKSBLOOD in C.dna.species.species_traits))))
			C.AddIntegrationBlood(round(reac_volume, 0.1))
			// we don't care about bloodtype here, we're just refilling the mob

	if(reac_volume >= 10 && istype(L) && method != INJECT)
		L.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/blood/on_mob_life(mob/living/carbon/C)	//Because lethals are preferred over stamina. damnifino.
	var/blood_id = C.get_blood_id()
	if((blood_id in GLOB.blood_reagent_types) && !HAS_TRAIT(C, TRAIT_NOMARROW))
		if(!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type)))	//we only care about bloodtype here because this is where the poisoning should be
			C.adjustToxLoss(rand(2,8)*REM, TRUE, TRUE)	//forced to ensure people don't use it to gain beneficial toxin as slime person
	..()

/datum/reagent/blood/reaction_obj(obj/O, volume)
	if(volume >= 3 && istype(O))
		O.add_blood_DNA(data)

/datum/reagent/blood/reaction_turf(turf/T, reac_volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/B = locate() in T //find some blood here
	if(!B)
		B = new(T)
	if(data["blood_DNA"])
		B.blood_DNA[data["blood_DNA"]] = data["blood_type"]
		if(!B.blood_DNA["color"])
			B.blood_DNA["color"] = data["bloodcolor"]
		else
			B.blood_DNA["color"] = BlendRGB(B.blood_DNA["color"], data["bloodcolor"])
	if(B.reagents)
		B.reagents.add_reagent(type, reac_volume)
	B.update_icon()

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)
		color = data["bloodcolor"]
		if(data["blood_type"] == "SY")
			name = "Synthetic Blood"
			taste_description = "oil"

		if(data["blood_type"] == "X*")
			name = "Xenomorph Blood"
			taste_description = "acidic heresy"
			shot_glass_icon_state = "shotglassgreen"
			pH = 2.5

		if(data["blood_type"] == "HF")
			name = "Hydraulic Blood"
			taste_description = "burnt oil"
			pH = 9.75

		if(data["blood_type"] == "BUG")
			name = "Insect Blood"
			taste_description = "grease"
			pH = 7.25

		if(data["blood_type"] == "L")
			name = "Lizard Blood"
			taste_description = "something spicy"
			pH = 6.85

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_DNA"] != mix_data["blood_DNA"])
			data["cloneable"] = FALSE //On mix, consider the genetic sampling unviable for pod cloning if the DNA sample doesn't match.
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve
	return TRUE

/datum/reagent/blood/proc/get_diseases()
	. = list()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing
			. += D

/datum/reagent/blood/synthetics
	data = list("donor"=null,"viruses"=null,"blood_DNA"="REPLICATED", "bloodcolor" = BLOOD_COLOR_SYNTHETIC, "blood_type"="SY","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	name = "Synthetic Blood"
	description = "A synthetically produced imitation of blood."
	taste_description = "oil"
	color = BLOOD_COLOR_SYNTHETIC // rgb: 11, 7, 48
	value = REAGENT_VALUE_NONE

/datum/reagent/blood/jellyblood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_SLIME, "blood_type"="GEL","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	name = "Slime Jelly Blood"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	color = BLOOD_COLOR_SLIME
	taste_description = "slime"
	taste_mult = 1.3
	pH = 4

/datum/reagent/blood/tomato
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_HUMAN, "blood_type"="SY","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	name = "Tomato Blood"
	description = "This highly resembles blood, but it doesnt actually function like it, resembling more ketchup, with a more blood-like consistency."
	taste_description = "sap" //Like tree sap?
	pH = 7.45
	value = REAGENT_VALUE_NONE

/datum/reagent/blood/jellyblood/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		if(M.dna?.species?.exotic_bloodtype != "GEL")
			to_chat(M, "<span class='danger'>Your insides are burning!</span>")
		M.adjustToxLoss(rand(20,60)*REM, 0)
		. = 1
	else if(prob(40) && isjellyperson(M))
		M.heal_bodypart_damage(2*REM)
		. = 1
	..()

/datum/reagent/liquidgibs
	name = "Liquid gibs"
	color = BLOOD_COLOR_HUMAN
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"
	shot_glass_icon_state = "shotglassred"
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_HUMAN, "blood_type"= "O+","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	pH = 7.45

/datum/reagent/liquidgibs/xeno
	name = "Liquid xeno gibs"
	color = BLOOD_COLOR_XENO
	taste_description = "blended heresy"
	shot_glass_icon_state = "shotglassgreen"
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_XENO, "blood_type"="X*","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	pH = 2.5

/datum/reagent/liquidgibs/slime
	name = "Slime sludge"
	color = BLOOD_COLOR_SLIME
	taste_description = "slime"
	shot_glass_icon_state = "shotglassgreen"
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_SLIME, "blood_type"="GEL","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	pH = 4

/datum/reagent/liquidgibs/synth
	name = "Synthetic sludge"
	color = BLOOD_COLOR_SYNTHETIC
	taste_description = "jellied plastic"
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_SYNTHETIC, "blood_type"="SY","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)

/datum/reagent/liquidgibs/oil
	name = "Hydraulic sludge"
	color = BLOOD_COLOR_OIL
	taste_description = "chunky burnt oil"
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null, "bloodcolor" = BLOOD_COLOR_OIL, "blood_type"="HF","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	pH = 9.75

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_description = "slime"

/datum/reagent/vaccine/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(islist(data) && (method == INGEST || method == INJECT))
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		L.disease_resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/water
	name = "Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "water"
	overdose_threshold = 150 //Imagine drinking a gallon of water
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of water"
	glass_desc = "The father of all refreshments."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/water/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(M.blood_volume)
		M.AddIntegrationBlood(0.1) // water is good for you!

/*
 *	Water reaction to turf
 */

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	var/CT = cooling_temperature

	if(reac_volume >= 5)
		T.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))

	for(var/mob/living/simple_animal/slime/M in T)
		M.apply_water()

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !isspaceturf(T))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.set_temperature(max(min(G.return_temperature()-(CT*1000),G.return_temperature()/CT),TCMB))
			G.react(src)
			qdel(hotspot)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - reac_volume*50, 0)

/*
 *	Water reaction to an object
 */

/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	O.extinguish()
	O.acid_level = 0
	// cubes
	if(istype(O, /obj/item/reagent_containers/food/snacks/cube))
		var/obj/item/reagent_containers/food/snacks/cube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/HH = O
		new /obj/item/stack/sheet/wetleather(get_turf(HH), HH.amount)
		qdel(HH)

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	..()

/datum/reagent/water/overdose_start(mob/living/M)
	metabolization_rate = 45 * REAGENTS_METABOLISM
	. = 1

///For weird backwards situations where water manages to get added to trays nutrients, as opposed to being snowflaked away like usual.
/datum/reagent/water/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	if(chems.has_reagent(src.type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(src.type) * 1))
		//You don't belong in this world, monster!
		chems.remove_reagent(/datum/reagent/water, chems.get_reagent_amount(src.type))

/datum/reagent/water/hollowwater
	name = "Hollow Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen, but it looks kinda hollow."
	color = "#88878777"
	taste_description = "emptiness"


/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
	glass_icon_state  = "glass_clear"
	glass_name = "glass of holy water"
	glass_desc = "A glass of holy water."
	pH = 7.5 //God is alkaline

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits. Also ALSO increases instability.
/datum/reagent/water/holywater/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	if(chems.has_reagent(src.type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 0.1))
		if(myseed)
			myseed.adjust_instability(round(chems.get_reagent_amount(src.type) * 0.15))

/datum/reagent/water/holywater/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_HOLY, type)

	if(is_servant_of_ratvar(L))
		to_chat(L, "<span class='userdanger'>A fog spreads through your mind, purging the Justiciar's influence!</span>")
	else if(iscultist(L))
		to_chat(L, "<span class='userdanger'>A fog spreads through your mind, weakening your connection to the veil and purging Nar-sie's influence</span>")

/datum/reagent/water/holywater/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_HOLY, type)
	if(iscultist(L))
		for(var/datum/action/innate/cult/blood_magic/BM in L.actions)
			BM.holy_dispel = FALSE
	return ..()

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	if(M.blood_volume)
		M.AddIntegrationBlood(0.1) // water is good for you!
	if(!data)
		data = list("misc" = 1)
	data["misc"]++
	M.jitteriness = min(M.jitteriness+4,10)
	if(iscultist(M, FALSE, TRUE))
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			if(!BM.holy_dispel)
				BM.holy_dispel = TRUE
				to_chat(M, "<span class='cultlarge'>Your blood rites falter as holy water scours your body!</span>")
				for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
					qdel(BS)
	if(data["misc"] >= 25)		// 10 units, 45 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering+4, 10)
		M.Dizzy(5)
		if(iscultist(M) && prob(20))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
				M.Unconscious(120)
				to_chat(M, "<span class='cultlarge'>[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")].</span>")
		else if(is_servant_of_ratvar(M) && prob(8))
			switch(pick("speech", "message", "emote"))
				if("speech")
					clockwork_say(M, "...[text2ratvar(pick("Engine... your light grows dark...", "Where are you, master?", "He lies rusting in Error...", "Purge all untruths and... and... something..."))]")
				if("message")
					to_chat(M, "<span class='boldwarning'>[pick("Ratvar's illumination of your mind has begun to flicker", "He lies rusting in Reebe, derelict and forgotten. And there he shall stay", \
					"You can't save him. Nothing can save him now", "It seems that Nar'Sie will triumph after all")].</span>")
				if("emote")
					M.visible_message("<span class='warning'>[M] [pick("whimpers quietly", "shivers as though cold", "glances around in paranoia")].</span>")
	if(data["misc"] >= 60)	// 30 units, 135 seconds
		if(iscultist(M, FALSE, TRUE) || is_servant_of_ratvar(M, FALSE, TRUE))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
			else if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M)
			M.jitteriness = 0
			M.stuttering = 0
			holder.del_reagent(type)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			return
	holder.remove_reagent(type, 0.4)	//fixed consumption to prevent balancing going out of whack

/datum/reagent/water/holywater/reaction_turf(turf/T, reac_volume)
	..()
	if(!istype(T))
		return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/water/holywater/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	mytray.adjustWater(round(chems.get_reagent_amount(src.type) * 1))
	mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 0.1))
	if(myseed)
		myseed.adjust_instability(round(chems.get_reagent_amount(src.type) * 0.15))

/datum/reagent/fuel/unholywater	//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	overdose_threshold = 150 //Same as normal water
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "suffering"
	pH = 6.5
	value = REAGENT_VALUE_RARE

/datum/reagent/fuel/unholywater/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent(type, reac_volume/4)
		return
	return ..()

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/M)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustUnconscious(-20, FALSE)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-10, FALSE)
		M.adjustToxLoss(-2, FALSE, TRUE)
		M.adjustOxyLoss(-2, FALSE)
		M.adjustBruteLoss(-2, FALSE)
		M.adjustFireLoss(-2, FALSE)
		if(ishuman(M) && M.blood_volume < (BLOOD_VOLUME_NORMAL*M.blood_ratio))
			M.AddIntegrationBlood(3)
	else  // Will deal about 90 damage when 50 units are thrown
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, FALSE)
		M.adjustFireLoss(2, FALSE)
		M.adjustOxyLoss(2, FALSE)
		M.adjustBruteLoss(2, FALSE)
	holder.remove_reagent(type, 1)
	return TRUE

/datum/reagent/fuel/unholywater/overdose_start(mob/living/M)
	metabolization_rate = 60 * REAGENTS_METABOLISM
	. = 1

/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	description = "YOUR FLESH! IT BURNS!"
	taste_description = "burning"
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/M)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1, FALSE)
	M.adjustFireLoss(1, FALSE)		//Hence the other damages... ain't I a bastard?
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 150)
	holder.remove_reagent(type, 1)
	pH = 0.1

/datum/reagent/fuel/holyoil		//Its oil
	name = "Zelus Oil"
	description = "Oil blessed by a greater being."
	taste_description = "metallic oil"
	value = REAGENT_VALUE_RARE

/datum/reagent/fuel/holyoil/on_mob_life(mob/living/carbon/M)
	if(is_servant_of_ratvar(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustUnconscious(-60, FALSE)
		M.AdjustAllImmobility(-30, FALSE)
		M.AdjustKnockdown(-40, FALSE)
		M.adjustStaminaLoss(-15, FALSE)
		M.adjustToxLoss(-5, FALSE, TRUE)
		M.adjustOxyLoss(-3, FALSE)
		M.adjustBruteLoss(-3, FALSE)
		M.adjustFireLoss(-5, FALSE)
	if(iscultist(M))
		M.AdjustUnconscious(1, FALSE)
		M.AdjustAllImmobility(10, FALSE)
		M.AdjustKnockdown(10, FALSE)
		M.adjustStaminaLoss(15, FALSE)
	else
		M.adjustToxLoss(3, FALSE)
		M.adjustOxyLoss(2, FALSE)
		M.adjustStaminaLoss(10, FALSE)
		holder.remove_reagent(type, 1)
	return TRUE

//We only get 30u to start with...

/datum/reagent/fuel/holyoil/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		reac_volume = min(reac_volume, M.amount)
		new/obj/item/stack/tile/brass(get_turf(M), reac_volume)
		M.use(reac_volume)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150
	value = REAGENT_VALUE_RARE

/datum/reagent/lube
	name = "Space Lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
	taste_description = "cherry" // by popular demand
	var/lube_kind = TURF_WET_LUBE ///What kind of slipperiness gets added to turfs.

/datum/reagent/lube/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	if(reac_volume >= 1)
		T.MakeSlippery(lube_kind, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

///Stronger kind of lube. Applies TURF_WET_SUPERLUBE.
/datum/reagent/lube/superlube
	name = "Super Duper Lube"
	description = "This \[REDACTED\] has been outlawed after the incident on \[DATA EXPUNGED\]."
	lube_kind = TURF_WET_SUPERLUBE

/datum/reagent/spraytan
	name = "Spray Tan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "sour oranges"
	pH = 5

/datum/reagent/spraytan/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/H = M
			if(H.dna.species.use_skintones)
				if(!H.dna.skin_tone_override)
					var/diff_len = length(GLOB.skin_tones - GLOB.nonstandard_skin_tones)
					H.skin_tone = GLOB.skin_tones[min(diff_len, GLOB.skin_tones.Find(H.skin_tone) + 1)]
				else
					H.skin_tone = H.dna.skin_tone_override = tan_mutant_color(H.dna.skin_tone_override, MINIMUM_MUTANT_COLOR)
			if(MUTCOLORS in H.dna.species.species_traits) //take current alien color and darken it slightly
				H.dna.features["mcolor"] = tan_mutant_color(H.dna.features["mcolor"])
			H.update_body()

	if(method == INGEST)
		if(show_message)
			to_chat(M, "<span class='notice'>That tasted horrible.</span>")

	return ..()

/datum/reagent/spraytan/proc/tan_mutant_color(color, limit = MINIMUM_MUTANT_COLOR)
	var/newcolor = ""
	var/len = length(color)
	var/char = ""
	var/ascii = 0
	for(var/i=1, i<=len, i += length(char))
		char = color[i]
		ascii = text2ascii(char)
		switch(ascii)
			if(35)
				newcolor += "#"
			if(48)
				newcolor += "0"
			if(49 to 57)
				newcolor += ascii2text(ascii-1)	//numbers 1 to 9
			if(97)
				newcolor += "9"
			if(98 to 102)
				newcolor += ascii2text(ascii-1)	//letters b to f lowercase
			if(65)
				newcolor += "9"
			if(66 to 70)
				newcolor += ascii2text(ascii+31)	//letters B to F - translates to lowercase
			else
				break
	if(ReadHSV(newcolor)[3] >= ReadHSV(limit)[3])
		return newcolor
	return color

/datum/reagent/spraytan/overdose_start(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hair_style = "Spiky"
		H.facial_hair_style = "Shaved"
		H.facial_hair_color = "000"
		H.hair_color = "000"
		if(!(HAIR in H.dna.species.species_traits)) //No hair? No problem!
			H.dna.species.species_traits += HAIR
		if(H.dna.species.use_skintones)
			if(H.dna.skin_tone_override)
				H.skin_tone = H.dna.skin_tone_override = "#FF8800"
			else
				H.skin_tone = "orange"
		else if(MUTCOLORS in H.dna.species.species_traits) //Aliens with custom colors simply get turned orange
			H.dna.features["mcolor"] = "f80"
		H.update_body()

/datum/reagent/spraytan/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(7))
			if(H.w_uniform)
				H.visible_message(pick("<b>[H]</b>'s collar pops up without warning.</span>", "<b>[H]</b> flexes [H.p_their()] arms."))
			else
				H.visible_message("<b>[H]</b> flexes [H.p_their()] arms.")
	if(prob(10))
		M.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don’t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."), forced = "spraytan")
	return ..()

/datum/reagent/mutationtoxin
	name = "Stable Mutation Toxin"
	description = "A humanizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY //So it instantly removes all of itself
	taste_description = "slime"
	value = REAGENT_VALUE_RARE
	var/datum/species/race = /datum/species/human
	var/mutationtext = "<span class='danger'>The pain subsides. You feel... human.</span>"

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	to_chat(H, "<span class='warning'><b>You crumple in agony as your flesh wildly morphs into new forms!</b></span>")
	H.visible_message("<b>[H]</b> falls to the ground and screams as [H.p_their()] skin bubbles and froths!") //'froths' sounds painful when used with SKIN.
	H.DefaultCombatKnockdown(60)
	addtimer(CALLBACK(src, .proc/mutate, H), 30)
	return

/datum/reagent/mutationtoxin/proc/mutate(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	var/current_species = H.dna.species.type
	var/datum/species/mutation = race
	if(mutation && mutation != current_species)
		to_chat(H, mutationtext)
		H.set_species(mutation)
	else
		to_chat(H, "<span class='danger'>The pain vanishes suddenly. You feel no different.</span>")

/datum/reagent/mutationtoxin/classic //The one from plasma on green slimes
	name = "Mutation Toxin"
	description = "A corruptive toxin."
	color = "#13BC5E" // rgb: 19, 188, 94
	race = /datum/species/jelly/slime
	mutationtext = "<span class='danger'>The pain subsides. Your whole body feels like slime.</span>"

/datum/reagent/mutationtoxin/felinid
	name = "Felinid Mutation Toxin"
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/human/felinid
	mutationtext = "<span class='danger'>The pain subsides. You feel... like a degenerate.</span>"

/datum/reagent/mutationtoxin/lizard
	name = "Lizard Mutation Toxin"
	description = "A lizarding toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard
	mutationtext = "<span class='danger'>The pain subsides. You feel... scaly.</span>"

/datum/reagent/mutationtoxin/fly
	name = "Fly Mutation Toxin"
	description = "An insectifying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/fly
	mutationtext = "<span class='danger'>The pain subsides. You feel... buzzy.</span>"

/datum/reagent/mutationtoxin/insect
	name = "Insect Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/insect
	mutationtext = "<span class='danger'>The pain subsides. You feel... attracted to light.</span>"

/datum/reagent/mutationtoxin/pod
	name = "Podperson Mutation Toxin"
	description = "A vegetalizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/pod
	mutationtext = "<span class='danger'>The pain subsides. You feel... plantlike.</span>"

/datum/reagent/mutationtoxin/jelly
	name = "Imperfect Mutation Toxin"
	description = "An jellyfying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/jelly
	mutationtext = "<span class='danger'>The pain subsides. You feel... wobbly.</span>"

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "A crystal toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/golem/random
	mutationtext = "<span class='danger'>The pain subsides. You feel... rocky.</span>"

/datum/reagent/mutationtoxin/abductor
	name = "Abductor Mutation Toxin"
	description = "An alien toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/abductor
	mutationtext = "<span class='danger'>The pain subsides. You feel... alien.</span>"

/datum/reagent/mutationtoxin/android
	name = "Android Mutation Toxin"
	description = "A robotic toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/android
	mutationtext = "<span class='danger'>The pain subsides. You feel... artificial.</span>"

//Citadel Races
/datum/reagent/mutationtoxin/mammal
	name = "Mammal Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/mammal
	mutationtext = "<span class='danger'>The pain subsides. You feel... fluffier.</span>"

/datum/reagent/mutationtoxin/insect
	name = "Insect Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/insect
	mutationtext = "<span class='danger'>The pain subsides. You feel... attracted to dark, moist areas.</span>"

/datum/reagent/mutationtoxin/xenoperson
	name = "Xeno-Hybrid Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/xeno
	mutationtext = "<span class='danger'>The pain subsides. You feel... oddly longing for the Queen.</span>" //sadly, not the British one.

//BLACKLISTED RACES
/datum/reagent/mutationtoxin/skeleton
	name = "Skeleton Mutation Toxin"
	description = "A scary toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/skeleton
	mutationtext = "<span class='danger'>The pain subsides. You feel... spooky.</span>"

/datum/reagent/mutationtoxin/zombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/zombie //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	mutationtext = "<span class='danger'>The pain subsides. You feel... undead.</span>"

/datum/reagent/mutationtoxin/ash
	name = "Ash Mutation Toxin"
	description = "An ashen toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard/ashwalker
	mutationtext = "<span class='danger'>The pain subsides. You feel... savage.</span>"

/datum/reagent/mutationtoxin/arachnid
	name = "Arachnid Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/arachnid
	mutationtext = "<span class='danger'>The pain subsides. You feel... silky.</span>"

//DANGEROUS RACES
/datum/reagent/mutationtoxin/shadow
	name = "Shadow Mutation Toxin"
	description = "A dark toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/shadow
	mutationtext = "<span class='danger'>The pain subsides. You feel... darker.</span>"

/datum/reagent/mutationtoxin/plasma
	name = "Plasma Mutation Toxin"
	description = "A plasma-based toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/plasmaman
	mutationtext = "<span class='danger'>The pain subsides. You feel... flammable.</span>"

/datum/reagent/slime_toxin
	name = "Slime Mutation Toxin"
	description = "A toxin that turns organic material into slime."
	color = "#5EFF3B" //RGB: 94, 255, 59
	taste_description = "slime"
	metabolization_rate = 0.2
	value = REAGENT_VALUE_RARE

/datum/reagent/slime_toxin/on_mob_life(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(!H.dna || !H.dna.species || !(H.mob_biotypes & MOB_ORGANIC))
		return

	if(isjellyperson(H))
		to_chat(H, "<span class='warning'>Your jelly shifts and morphs, turning you into another subspecies!</span>")
		var/species_type = pick(subtypesof(/datum/species/jelly))
		H.set_species(species_type)
		H.reagents.del_reagent(type)

	switch(current_cycle)
		if(1 to 6)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("You don't feel very well.", "Your skin feels a little slimy.")]</span>")
		if(7 to 12)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("Your appendages are melting away.", "Your limbs begin to lose their shape.")]</span>")
		if(13 to 19)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("You feel your internal organs turning into slime.", "You feel very slimelike.")]</span>")
		if(20 to INFINITY)
			var/species_type = pick(subtypesof(/datum/species/jelly))
			H.set_species(species_type)
			H.reagents.del_reagent(type)
			to_chat(H, "<span class='warning'>You've become \a jellyperson!</span>")

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "This toxin will rapidly change the DNA of human beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY
	taste_description = "slime"
	value = REAGENT_VALUE_RARE

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H)
	..()
	if (!istype(H))
		return
	to_chat(H, "<span class='warning'><b>You grit your teeth in pain as your body rapidly mutates!</b></span>")
	H.visible_message("<b>[H]</b> suddenly transforms!")
	randomize_human(H)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	taste_description = "slime"
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/aslimetoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != TOUCH)
		L.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B" //RGB: 94, 255, 59
	can_synth = FALSE
	taste_description = "decay"
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/gluttonytoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	L.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	pH = 10

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0 // oderless and tasteless
	pH = 9.2//It's acutally a huge range and very dependant on the chemistry but pH is basically a made up var in it's implementation anyways

/datum/reagent/oxygen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/oxygen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "metal"
	pH = 5.5

/datum/reagent/copper/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		reac_volume = min(reac_volume, M.amount)
		new/obj/item/stack/sheet/bronze(get_turf(M), reac_volume)
		M.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0


/datum/reagent/nitrogen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/nitrogen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0
	pH = 0.1//Now I'm stuck in a trap of my own design. Maybe I should make -ve pHes? (not 0 so I don't get div/0 errors)

/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "sweetness"

/datum/reagent/mercury
	name = "Mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848" // rgb: 72, 72, 72A
	taste_mult = 0 // apparently tasteless.

/datum/reagent/mercury/on_mob_life(mob/living/carbon/M)
	if(CHECK_MOBILITY(M, MOBILITY_MOVE) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "rotten eggs"
	pH = 4.5

/datum/reagent/carbon
	name = "Carbon"
	description = "A crumbly black solid that, while unexciting on an physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "sour chalk"
	pH = 5
	material = /datum/material/diamond

/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "chlorine"
	pH = 7.4

// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/chlorine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustToxic(round(chems.get_reagent_amount(src.type) * 1.5))
		mytray.adjustWater(-round(chems.get_reagent_amount(src.type) * 0.5))
		mytray.adjustWeeds(-rand(1,3))

/datum/reagent/chlorine/on_mob_life(mob/living/carbon/M)
	M.take_bodypart_damage(1*REM, 0, 0, 0)
	. = 1
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "acid"
	pH = 2

// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/fluorine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(-round(chems.get_reagent_amount(src.type) * 2))
		mytray.adjustToxic(round(chems.get_reagent_amount(src.type) * 2.5))
		mytray.adjustWater(-round(chems.get_reagent_amount(src.type) * 0.5))
		mytray.adjustWeeds(-rand(1,4))

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1*REM, 0)
	. = 1
	..()

/datum/reagent/sodium
	name = "Sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting in on your chips."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "salty metal"
	pH = 11.6

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "vinegar"
	pH = 6.5

/datum/reagent/lithium
	name = "Lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "metal"
	pH = 11.3

/datum/reagent/lithium/on_mob_life(mob/living/carbon/M)
	if(CHECK_MOBILITY(M, MOBILITY_MOVE) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/glycerol
	name = "Glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "sweetness"
	pH = 9

/datum/reagent/radium
	name = "Radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	taste_description = "the colour blue and regret"
	pH = 10

/datum/reagent/radium/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustToxic(round(chems.get_reagent_amount(src.type) * 1))

/datum/reagent/radium/on_mob_life(mob/living/carbon/M)
	M.apply_effect(2*REM/M.metabolism_efficiency,EFFECT_IRRADIATE,0)
	..()

/datum/reagent/radium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			GG.reagents.add_reagent(/datum/reagent/radium, reac_volume)

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#e6f1f5" // rgb: 200, 165, 220
	taste_description = "bitterness"
	pH = 10.5

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.success_multiplier = max(0.2, S.success_multiplier)
			// +20% success propability on each step, useful while operating in less-than-perfect conditions
	..()

/datum/reagent/space_cleaner/sterilizine/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		reac_volume = min((reac_volume / 5), G.amount)
		new /obj/item/stack/medical/gauze/adv(get_turf(G), reac_volume)
		G.use(reac_volume)


/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	taste_description = "iron"
	pH = 6
	overdose_threshold = 30
	color = "#c2391d"
	material = /datum/material/iron

/datum/reagent/iron/on_mob_life(mob/living/carbon/C)
	if((HAS_TRAIT(C, TRAIT_NOMARROW)))
		return
	if(C.blood_volume < (BLOOD_VOLUME_NORMAL*C.blood_ratio))
		C.AddIntegrationBlood(0.25)
	..()

/datum/reagent/iron/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_IRON)) //If the target is weak to cold iron, then poison them.
		if(holder && holder.chem_temp < 100) // COLD iron.
			M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/iron/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You start feeling your guts twisting painfully!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/iron/overdose_process(mob/living/M)
	if(prob(20))
		var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
		if(L)
			L.applyOrganDamage(2)
	..()

/datum/reagent/gold
	name = "Gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "expensive metal"
	material = /datum/material/gold

/datum/reagent/silver
	name = "Silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "expensive yet reasonable metal"
	material = /datum/material/silver

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_SILVER))
		M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/uranium
	name ="Uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_description = "the inside of a reactor"
	pH = 4
	material = /datum/material/uranium

/datum/reagent/uranium/on_mob_life(mob/living/carbon/M)
	M.apply_effect(1/M.metabolism_efficiency,EFFECT_IRRADIATE,0)
	..()

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			GG.reagents.add_reagent(/datum/reagent/uranium, reac_volume)

//Mutagenic chem side-effects.
/datum/reagent/uranium/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.mutation_roll(user)
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustToxic(round(chems.get_reagent_amount(src.type) * 2))

/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	reagent_state = SOLID
	color = "#0000CC"
	taste_description = "fizzling blue"
	pH = 12
	value = REAGENT_VALUE_RARE
	material = /datum/material/bluespace

/datum/reagent/bluespace/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		do_teleport(M, get_turf(M), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //4 tiles per crystal
	..()

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/M)
	if(current_cycle > 10 && prob(15))
		to_chat(M, "<span class='warning'>You feel unstable...</span>")
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, /mob/living/proc/bluespace_shuffle), 30)
	..()

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/telecrystal
	name = "Telecrystal Dust"
	description = "A blood-red dust comprised of something that was much more useful when it was intact."
	reagent_state = SOLID
	color = "#660000" // rgb: 102, 0, 0.
	taste_description = "contraband"

/datum/reagent/aluminium
	name = "Aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "metal"

/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_mult = 0
	pH = 10
	material = /datum/material/glass

/datum/reagent/fuel
	name = "Welding fuel"
	description = "Required for welders. Flamable."
	color = "#660000" // rgb: 102, 0, 0
	taste_description = "gross metal"
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Unless you're an industrial tool, this is probably not safe for consumption."
	pH = 4


/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner
	name = "Space cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	color = "#A5F0EE" // rgb: 165, 240, 238
	taste_description = "sourness"
	pH = 5.5

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/effect/decal/cleanable)  || istype(O, /obj/item/projectile/bullet/reusable/foam_dart) || istype(O, /obj/item/ammo_casing/caseless/foam_dart))
		qdel(O)
	else
		if(O)
			O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
			O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1)
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		SEND_SIGNAL(T, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.lip_style)
					H.lip_style = null
					H.update_body()
			for(var/obj/item/I in C.held_items)
				SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
				I.clean_blood()
			if(C.wear_mask)
				SEND_SIGNAL(C.wear_mask, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
				if(C.wear_mask.clean_blood())
					C.update_inv_wear_mask()
			if(ishuman(M))
				var/mob/living/carbon/human/H = C
				if(H.head)
					SEND_SIGNAL(H.head, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
					if(H.head.clean_blood())
						H.update_inv_head()
				if(H.wear_suit)
					SEND_SIGNAL(H.wear_suit, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
					if(H.wear_suit.clean_blood())
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					SEND_SIGNAL(H.w_uniform, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
					if(H.w_uniform.clean_blood())
						H.update_inv_w_uniform()
				if(H.shoes)
					SEND_SIGNAL(H.shoes, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
					if(H.shoes.clean_blood())
						H.update_inv_shoes()
				H.wash_cream()
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
			M.clean_blood()

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "A powerful, acidic cleaner sold by Waffle Co. Affects organic matter while leaving other objects unaffected."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"
	pH = 2
	value = REAGENT_VALUE_RARE

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(3.33)
	M.adjustFireLoss(3.33)
	M.adjustToxLoss(3.33)
	..()

/datum/reagent/space_cleaner/ez_clean/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	..()
	if((method == TOUCH || method == VAPOR) && !issilicon(M))
		M.adjustBruteLoss(1)
		M.adjustFireLoss(1)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#7529b3" // rgb: 200, 165, 220
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"
	pH = 11.9

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/M)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#587a31" // rgb: 200, 165, 220A
	taste_description = "numbness"
	pH = 9.1

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	..()

/datum/reagent/nanomachines
	name = "Nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_description = "sludge"
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/nanomachines/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_description = "sludge"
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/xenomicrobes/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/xeno(), FALSE, TRUE)

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125
	can_synth = FALSE
	taste_description = "slime"
	pH = 11
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/fungalspores/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "metal"
	pH = 11

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	description = "An agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	pH = 11.5

/datum/reagent/smart_foaming_agent //Smart foaming agent. Functions similarly to metal foam, but conforms to walls.
	name = "Smart foaming agent"
	description = "An agent that yields metallic foam which conforms to area boundaries when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	pH = 11.8
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/ammonia
	name = "Ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "mordant"
	pH = 11.6

/datum/reagent/ammonia/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	// Ammonia is bad ass.
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 0.12))
		if(myseed && prob(10))
			myseed.adjust_yield(1)
			myseed.adjust_instability(1)

/datum/reagent/diethylamine
	name = "Diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48
	taste_description = "iron"
	pH = 12

// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant. The new trade off is it culls stability.
/datum/reagent/diethylamine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustPests(-rand(1,2))
		if(myseed)
			myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 1))
			myseed.adjust_instability(-round(chems.get_reagent_amount(src.type) * 1))

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	reagent_state = GAS
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	taste_description = "something unknowable"
	pH = 6

/datum/reagent/carbondioxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")

/datum/reagent/carbondioxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")
	return

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	description = "A potent oxidizer used as fuel in rockets and as an anaesthetic during surgery."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	taste_description = "sweetness"
	pH = 5.8

/datum/reagent/nitrous_oxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		M.drowsyness += max(round(reac_volume, 1), 2)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/M)
	M.drowsyness += 2
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - 2.5, 0)
	if(prob(20))
		M.losebreath += 2
		M.confused = min(M.confused + 2, 5)
	..()

/datum/reagent/stimulum
	name = "Stimulum"
	description = "An unstable experimental gas that greatly increases the energy of those that inhale it"
	reagent_state = GAS
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "E1A116"
	taste_description = "sourness"
	value = REAGENT_VALUE_EXCEPTIONAL

/datum/reagent/stimulum/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)

/datum/reagent/stimulum/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/stimulum/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(-2*REM, 0)
	current_cycle++
	holder.remove_reagent(type, 0.99)		//Gives time for the next tick of life().
	. = TRUE //Update status effects.

/datum/reagent/nitryl
	name = "Nitryl"
	description = "A highly reactive gas that makes you feel faster"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM
	color = "90560B"
	taste_description = "burning"
	pH = 2
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/nitryl/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitryl)

/datum/reagent/nitryl/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitryl)
	..()

/////////////////////////Coloured Crayon Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents


/datum/reagent/colorful_reagent/crayonpowder
	name = "Crayon Powder"
	var/colorname = "none"
	description = "A powder made by grinding down crayons, good for colouring chemical reagents."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
	taste_description = "the back of class"
	no_mob_color = TRUE
	value = REAGENT_VALUE_NONE

/datum/reagent/colorful_reagent/crayonpowder/New()
	description = "\an [colorname] powder made by grinding down crayons, good for colouring chemical reagents."


/datum/reagent/colorful_reagent/crayonpowder/red
	name = "Red Crayon Powder"
	colorname = "red"
	color = "#DA0000" // red
	random_color_list = list("#DA0000")
	pH = 0.5

/datum/reagent/colorful_reagent/crayonpowder/orange
	name = "Orange Crayon Powder"
	colorname = "orange"
	color = "#FF9300" // orange
	random_color_list = list("#FF9300")
	pH = 2

/datum/reagent/colorful_reagent/crayonpowder/yellow
	name = "Yellow Crayon Powder"
	colorname = "yellow"
	color = "#FFF200" // yellow
	random_color_list = list("#FFF200")
	pH = 5

/datum/reagent/colorful_reagent/crayonpowder/green
	name = "Green Crayon Powder"
	colorname = "green"
	color = "#A8E61D" // green
	random_color_list = list("#A8E61D")


/datum/reagent/colorful_reagent/crayonpowder/blue
	name = "Blue Crayon Powder"
	colorname = "blue"
	color = "#00B7EF" // blue
	random_color_list = list("#00B7EF")
	pH = 10

/datum/reagent/colorful_reagent/crayonpowder/purple
	name = "Purple Crayon Powder"
	colorname = "purple"
	color = "#DA00FF" // purple
	random_color_list = list("#DA00FF")
	pH = 13

/datum/reagent/colorful_reagent/crayonpowder/invisible
	name = "Invisible Crayon Powder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list(null)	//because using the powder color turns things invisible

/datum/reagent/colorful_reagent/crayonpowder/black
	name = "Black Crayon Powder"
	colorname = "black"
	color = "#1C1C1C" // not quite black
	random_color_list = list("#404040")

/datum/reagent/colorful_reagent/crayonpowder/white
	name = "White Crayon Powder"
	colorname = "white"
	color = "#FFFFFF" // white
	random_color_list = list("#FFFFFF") //doesn't actually change appearance at all

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "plant food"
	pH = 3

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM, 0)
		. = 1
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	description = "Contains electrolytes. It's what plants crave."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10

/datum/reagent/plantnutriment/eznutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_instability(0.2)
		myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.3))
		myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 0.1))

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25

/datum/reagent/plantnutriment/left4zednutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_instability(round(chems.get_reagent_amount(src.type) * 0.2))

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Very potent nutriment that slows plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15

/datum/reagent/plantnutriment/robustharvestnutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_instability(-0.25)
		myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 0.2))

/datum/reagent/plantnutriment/endurogrow
	name = "Enduro Grow"
	description = "A specialized nutriment, which decreases product quantity and potency, but strengthens the plants endurance."
	color = "#a06fa7" // RBG: 160, 111, 167
	tox_prob = 15

/datum/reagent/plantnutriment/endurogrow/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_potency(-round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_yield(-round(chems.get_reagent_amount(src.type) * 0.075))
		myseed.adjust_endurance(round(chems.get_reagent_amount(src.type) * 0.35))

/datum/reagent/plantnutriment/liquidearthquake
	name = "Liquid Earthquake"
	description = "A specialized nutriment, which increases the plant's production speed, as well as it's susceptibility to weeds."
	color = "#912e00" // RBG: 145, 46, 0
	tox_prob = 25

/datum/reagent/plantnutriment/liquidearthquake/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_weed_rate(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_weed_chance(round(chems.get_reagent_amount(src.type) * 0.3))
		myseed.adjust_production(-round(chems.get_reagent_amount(src.type) * 0.075))


// GOON OTHERS

/datum/reagent/oil
	name = "Oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#292929"
	taste_description = "oil"

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#6b008f"
	taste_description = "bitterness"
	taste_mult = 1.5
	pH = 1.5

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C)
	C.adjustPlasma(10)
	..()

/datum/reagent/iodine
	name = "Iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#694600"
	taste_description = "metal"
	pH = 4.5

/datum/reagent/bromine
	name = "Bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	reagent_state = LIQUID
	color = "#b37740"
	taste_description = "chemicals"
	pH = 7.8

/datum/reagent/phenol
	name = "Phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	reagent_state = LIQUID
	taste_description = "sweet and tarry" //Again, not a strong acid.
	pH = 5.5
	color = "#e6e8ff"

/datum/reagent/ash
	name = "Ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	reagent_state = LIQUID
	color = "#665c56"
	taste_description = "ash"
	pH = 6.5

// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
/datum/reagent/ash/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustWeeds(-1)

/datum/reagent/acetone
	name = "Acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	taste_description = "solvent"//It's neutral though..?
	color = "#e6e6e6"

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Thoroughly sample the rainbow."
	reagent_state = LIQUID
	color = "#FFFF00"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	taste_description = "rainbows"
	value = REAGENT_VALUE_RARE
	var/no_mob_color = FALSE

/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/M)
	if(!no_mob_color)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(!no_mob_color)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Has a high chance of making you look like a mad scientist."
	reagent_state = LIQUID
	color = "#ff00dd"
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code
	taste_description = "sourness"
	value = REAGENT_VALUE_RARE

/datum/reagent/hair_dye/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_color = pick(potential_colors)
			H.facial_hair_color = pick(potential_colors)
			H.update_hair()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#fac34b"
	taste_description = "sourness"
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hair_styles_list)
			H.hair_style = picked_hair
			H.facial_hair_style = picked_beard
			H.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#ffaf00"
	taste_description = "sourness"
	value = REAGENT_VALUE_RARE

/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Very Long Beard"
			H.update_hair()

/datum/reagent/baldium
	name = "Baldium"
	description = "A major cause of hair loss across the world."
	reagent_state = LIQUID
	color = "#ecb2cf"
	taste_description = "bitterness"

/datum/reagent/baldium/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			to_chat(H, "<span class='danger'>Your hair is falling out in clumps!</span>")
			H.hair_style = "Bald"
			H.facial_hair_style = "Shaved"
			H.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "Volatile. Controversial. Third Thing."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "cool salt"
	pH = 11.2

/datum/reagent/lye
	name = "Lye"
	description = "Also known as sodium hydroxide. As a profession making this is somewhat underwhelming."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow
	taste_description = "alkali" //who put ACID for NaOH ????
	pH = 11.9

// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
/datum/reagent/saltpetre/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		var/salt = chems.get_reagent_amount(src.type)
		mytray.adjustHealth(round(salt * 0.18))
		if(myseed)
			myseed.adjust_production(-round(salt/10)-prob(salt%10))
			myseed.adjust_potency(round(salt*1))

/datum/reagent/drying_agent
	name = "Drying agent"
	description = "A desiccant. Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "dryness"
	pH = 10.7
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/drying_agent/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.MakeDry(ALL, TRUE, reac_volume * 5 SECONDS)		//50 deciseconds per unit

/datum/reagent/drying_agent/reaction_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)

// Liquid Carpets
/datum/reagent/carpet
	name = "Liquid Carpet"
	description = "For those that need a more creative way to roll out a carpet."
	reagent_state = LIQUID
	color = "#b51d05"
	taste_description = "carpet" // Your tounge feels furry.
	var/carpet_type = /turf/open/floor/carpet

/datum/reagent/carpet/reaction_turf(turf/T, reac_volume)
	if(isplatingturf(T) || istype(T, /turf/open/floor/plasteel))
		var/turf/open/floor/F = T
		F.PlaceOnTop(carpet_type, flags = CHANGETURF_INHERIT_AIR)
	..()

/datum/reagent/carpet/black
	name = "Liquid Black Carpet"
	color = "#363636"
	carpet_type = /turf/open/floor/carpet/black

/datum/reagent/carpet/arcade
	name = "Liquid Arcade Carpet"
	color = "#b51d05"
	carpet_type = /turf/open/floor/carpet/arcade

/datum/reagent/carpet/blackred
	name = "Liquid Red Black Carpet"
	color = "#342125"
	carpet_type = /turf/open/floor/carpet/blackred

/datum/reagent/carpet/monochrome
	name = "Liquid Monochrome Carpet"
	color = "#b4b4b4"
	carpet_type = /turf/open/floor/carpet/monochrome

/datum/reagent/carpet/blue
	name = "Liquid Blue Carpet"
	color = "#1256ff"
	carpet_type = /turf/open/floor/carpet/blue

/datum/reagent/carpet/cyan
	name = "Liquid Cyan Carpet"
	color = "#3acfb9"
	carpet_type = /turf/open/floor/carpet/cyan

/datum/reagent/carpet/green
	name = "Liquid Green Carpet"
	color = "#619b62"
	carpet_type = /turf/open/floor/carpet/green

/datum/reagent/carpet/orange
	name = "Liquid Orange Carpet"
	color = "#cc7900"
	carpet_type = /turf/open/floor/carpet/orange

/datum/reagent/carpet/purple
	name = "Liquid Purple Carpet"
	color = "#6d3392"
	carpet_type = /turf/open/floor/carpet/purple


/datum/reagent/carpet/red
	name = "Liquid Red Carpet"
	color = "#871515"
	carpet_type = /turf/open/floor/carpet/red


/datum/reagent/carpet/royalblack
	name = "Liquid Royal Black Carpet"
	color = "#483d05"
	carpet_type = /turf/open/floor/carpet/royalblack


/datum/reagent/carpet/royalblue
	name = "Liquid Royal Blue Carpet"
	color = "#24227e"
	carpet_type = /turf/open/floor/carpet/royalblue


// Virology virus food chems.

/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "mutagenic agar"
	color = "#A3C00F" // rgb: 163,192,15
	taste_description = "sourness"

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "sucrose agar"
	color = "#41B0C0" // rgb: 65,176,192
	taste_description = "sweetness"

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "virus rations"
	color = "#D18AA5" // rgb: 209,138,165
	taste_description = "bitterness"

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "virus plasma"
	color = "#A69DA9" // rgb: 166,157,169
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "weakened virus plasma"
	color = "#CEC3C6" // rgb: 206,195,198
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/uranium/uraniumvirusfood
	name = "decaying uranium gel"
	color = "#67ADBA" // rgb: 103,173,186
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "unstable uranium gel"
	color = "#2FF2CB" // rgb: 47,242,203
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "stable uranium gel"
	color = "#04506C" // rgb: 4,80,108
	taste_description = "the inside of a reactor"

// Bee chemicals

/datum/reagent/royal_bee_jelly
	name = "royal bee jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	taste_description = "strange honey"
	pH = 3
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "royal bee jelly")
	..()

//Misc reagents

/datum/reagent/romerol
	name = "Romerol"
	// the REAL zombie powder
	description = "Romerol is a highly experimental bioterror agent \
		which causes dormant nodules to be etched into the grey matter of \
		the subject. These nodules only become active upon death of the \
		host, upon which, the secondary structures activate and take control \
		of the host body."
	color = "#123524" // RGB (18, 53, 36)
	metabolization_rate = INFINITY
	can_synth = FALSE
	taste_description = "brains"
	pH = 0.5
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/romerol/reaction_mob(mob/living/carbon/human/H, method=TOUCH, reac_volume)
	// Silently add the zombie infection organ to be activated upon death
	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(H)
	..()

/datum/reagent/magillitis
	name = "Magillitis"
	description = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	reagent_state = LIQUID
	color = "#00f041"
	value = REAGENT_VALUE_EXCEPTIONAL

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/M)
	..()
	if((ismonkey(M) || ishuman(M)) && current_cycle >= 10)
		M.gorillize()

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "A commercial chemical designed to help older men in the bedroom."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = RESIZE_DEFAULT_SIZE
	value = REAGENT_VALUE_COMMON
	taste_description = "bitterness" // apparently what viagra tastes like

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25*RESIZE_DEFAULT_SIZE
		if(20 to 49)
			newsize = 1.5*RESIZE_DEFAULT_SIZE
		if(50 to 99)
			newsize = 2*RESIZE_DEFAULT_SIZE
		if(100 to 199)
			newsize = 2.5*RESIZE_DEFAULT_SIZE
		if(200 to INFINITY)
			newsize = 3.5*RESIZE_DEFAULT_SIZE

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

/datum/reagent/plastic_polymers
	name = "plastic polymers"
	description = "the petroleum based components of plastic."
	color = "#f7eded"
	taste_description = "plastic"
	pH = 6

/datum/reagent/glitter
	name = "generic glitter"
	description = "if you can see this description, contact a coder."
	color = "#FFFFFF" //pure white
	taste_description = "plastic"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter

/datum/reagent/glitter/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	new glitter_type(T)

/datum/reagent/glitter/pink
	name = "pink glitter"
	description = "pink sparkles that get everywhere"
	color = "#ff8080" //A light pink color
	glitter_type = /obj/effect/decal/cleanable/glitter/pink

/datum/reagent/glitter/white
	name = "white glitter"
	description = "white sparkles that get everywhere"
	glitter_type = /obj/effect/decal/cleanable/glitter/white

/datum/reagent/glitter/blue
	name = "blue glitter"
	description = "blue sparkles that get everywhere"
	color = "#4040FF" //A blueish color
	glitter_type = /obj/effect/decal/cleanable/glitter/blue

/datum/reagent/pax
	name = "pax"
	description = "A colorless liquid that suppresses violence on the subjects."
	color = "#AAAAAA55"
	taste_description = "water"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	value = REAGENT_VALUE_RARE
	pH = 15

/datum/reagent/pax/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/pax/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/bz_metabolites
	name = "BZ metabolites"
	description = "A harmless metabolite of BZ gas"
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/bz_metabolites/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/bz_metabolites/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/bz_metabolites/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
	return ..()

/datum/reagent/pax/peaceborg
	name = "synth-pax"
	description = "A colorless liquid that suppresses violence on the subjects. Cheaper to synthetize, but wears out faster than normal Pax."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	value = REAGENT_VALUE_COMMON

/datum/reagent/peaceborg_confuse
	name = "Dizzying Solution"
	description = "Makes the target off balance and dizzy"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "dizziness"
	value = REAGENT_VALUE_COMMON

/datum/reagent/peaceborg_confuse/on_mob_life(mob/living/carbon/M)
	if(M.confused < 6)
		M.confused = clamp(M.confused + 3, 0, 5)
	if(M.dizziness < 6)
		M.dizziness = clamp(M.dizziness + 3, 0, 5)
	if(prob(20))
		to_chat(M, "You feel confused and disorientated.")
	..()

/datum/reagent/peaceborg_tire
	name = "Tiring Solution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"
	value = REAGENT_VALUE_COMMON

/datum/reagent/peaceborg_tire/on_mob_life(mob/living/carbon/M)
	var/healthcomp = (100 - M.health)	//DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	if(M.getStaminaLoss() < (45 - healthcomp))	//At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		M.adjustStaminaLoss(10)
	if(prob(30))
		to_chat(M, "You should sit down and take a rest...")
	..()

/datum/reagent/tranquility
	name = "Tranquility"
	description = "A highly mutative liquid of unknown origin."
	color = "#9A6750" //RGB: 154, 103, 80
	taste_description = "inner peace"
	can_synth = FALSE
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/tranquility/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)

/datum/reagent/moonsugar
	name = "Moonsugar"
	description = "The primary precursor for an ancient feline delicacy known as skooma. While it has no notable effects on it's own, mixing it with morphine in a chilled container may yield interesting results."
	color = "#FAEAFF"
	taste_description = "synthetic catnip"
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/moonsugar/on_mob_life(mob/living/carbon/M)
	if(prob(20))
		to_chat(M, "You find yourself unable to supress the desire to meow!")
		M.emote("nya")
	..()

/datum/reagent/changeling_string
	name = "UNKNOWN"
	description = "404: Chemical not found."
	metabolization_rate = REAGENTS_METABOLISM
	color = "#0000FF"
	can_synth = FALSE
	var/datum/dna/original_dna
	var/reagent_ticks = 0
	chemical_flags = REAGENT_INVISIBLE
	value = REAGENT_VALUE_GLORIOUS

/datum/reagent/changeling_string/on_mob_metabolize(mob/living/carbon/C)
	if(ishuman(C) && C.dna && data["desired_dna"])
		original_dna = new C.dna.type
		C.dna.copy_dna(original_dna)
		var/datum/dna/new_dna = data["desired_dna"]
		new_dna.transfer_identity(C, TRUE)
		C.real_name = new_dna.real_name
		C.updateappearance(mutcolor_update = TRUE)
		C.domutcheck()
	..()

/datum/reagent/changeling_string/on_mob_end_metabolize(mob/living/carbon/C)
	if(original_dna)
		original_dna.transfer_identity(C, TRUE)
		C.real_name = original_dna.real_name
		C.updateappearance(mutcolor_update = TRUE)
		C.domutcheck()
	..()

/datum/reagent/changeling_string/Destroy()
	qdel(original_dna)
	return ..()

/datum/reagent/mustardgrind
	name = "Mustardgrind"
	description = "A powerd that is mixed with water and enzymes to make mustard."
	color = "#BCC740" //RGB: 188, 199, 64
	taste_description = "plant dust"

/datum/reagent/pax/catnip
	name = "catnip"
	taste_description = "grass"
	description = "A colorless liquid that makes people more peaceful and felines more happy."
	metabolization_rate = 1.75 * REAGENTS_METABOLISM
	value = REAGENT_VALUE_COMMON

/datum/reagent/pax/catnip/on_mob_life(mob/living/carbon/M)
	if(prob(20))
		M.emote("nya")
	if(prob(20))
		to_chat(M, "<span class = 'notice'>[pick("Headpats feel nice.", "The feeling of a hairball...", "Backrubs would be nice.", "Whats behind those doors?")]</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/list/adjusted = H.adjust_arousal(2,"catnip", aphro = TRUE)
		for(var/g in adjusted)
			var/obj/item/organ/genital/G = g
			to_chat(M, "<span class='userlove'>You feel like playing with your [G.name]!</span>")
	..()

/datum/reagent/preservahyde
	name = "Preservahyde"
	description = "A powerful preservation agent, utilizing the preservative effects of formaldehyde with significantly less of the histamine."
	reagent_state = LIQUID
	color = "#f7685e"
	metabolization_rate = REAGENTS_METABOLISM * 0.25


/datum/reagent/wittel
	name = "Wittel"
	description = "An extremely rare metallic-white substance only found on demon-class planets."
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_mult = 0 // oderless and tasteless

/datum/reagent/metalgen
	name = "Metalgen"
	data = list("material"=null)
	description = "A purple metal morphic liquid, said to impose it's metallic properties on whatever it touches."
	color = "#b000aa"
	taste_mult = 0 // oderless and tasteless
	var/applied_material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	var/minumum_material_amount = 100

/datum/reagent/metalgen/reaction_obj(obj/O, volume)
	metal_morph(O)
	return

/datum/reagent/metalgen/reaction_turf(turf/T, volume)
	metal_morph(T)
	return

///turn an object into a special material
/datum/reagent/metalgen/proc/metal_morph(atom/A)
	var/metal_ref = data["material"]
	if(!metal_ref)
		return
	var/metal_amount = 0

	for(var/B in A.custom_materials) //list with what they're made of
		metal_amount += A.custom_materials[B]

	if(!metal_amount)
		metal_amount = minumum_material_amount //some stuff doesn't have materials at all. To still give them properties, we give them a material. Basically doesnt exist

	var/list/metal_dat = list()
	metal_dat[metal_ref] = metal_amount //if we pass the list directly, byond turns metal_ref into "metal_ref" kjewrg8fwcyvf

	A.material_flags = applied_material_flags
	A.set_custom_materials(metal_dat)

/datum/reagent/gravitum
	name = "Gravitum"
	description = "A rare kind of null fluid, capable of temporalily removing all weight of whatever it touches." //i dont even
	color = "#050096" // rgb: 5, 0, 150
	taste_mult = 0 // oderless and tasteless
	metabolization_rate = 0.1 * REAGENTS_METABOLISM //20 times as long, so it's actually viable to use
	var/time_multiplier = 1 MINUTES //1 minute per unit of gravitum on objects. Seems overpowered, but the whole thing is very niche

/datum/reagent/gravitum/reaction_obj(obj/O, volume)
	O.AddElement(/datum/element/forced_gravity, 0)

	addtimer(CALLBACK(O, .proc/_RemoveElement, /datum/element/forced_gravity, 0), volume * time_multiplier)

/datum/reagent/gravitum/on_mob_add(mob/living/L)
	L.AddElement(/datum/element/forced_gravity, 0) //0 is the gravity, and in this case weightless

/datum/reagent/gravitum/on_mob_end_metabolize(mob/living/L)
	L.RemoveElement(/datum/element/forced_gravity, 0)


//body bluids
/datum/reagent/consumable/semen
	name = "Semen"
	description = "Sperm from some animal. Useless for anything but insemination, really."
	taste_description = "something salty"
	taste_mult = 2 //Not very overpowering flavor
	data = list("donor"=null,"viruses"=null,"donor_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null)
	reagent_state = LIQUID
	color = "#FFFFFF" // rgb: 255, 255, 255
	can_synth = FALSE
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	var/decal_path = /obj/effect/decal/cleanable/semen

/datum/reagent/consumable/semen/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	if(reac_volume < 10)
		return

	var/obj/effect/decal/cleanable/semen/S = locate() in T
	if(!S)
		S = new decal_path(T)
	if(data["blood_DNA"])
		S.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/obj/effect/decal/cleanable/semen
	name = "semen"
	desc = null
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'icons/obj/genitals/effects.dmi'
	icon_state = "semen1"
	random_icon_states = list("semen1", "semen2", "semen3", "semen4")

/obj/effect/decal/cleanable/semen/Initialize(mapload)
	. = ..()
	dir = GLOB.cardinals
	add_blood_DNA(list("Non-human DNA" = "A+"))

/obj/effect/decal/cleanable/semen/replace_decal(obj/effect/decal/cleanable/semen/S)
	if(S.blood_DNA)
		blood_DNA |= S.blood_DNA
	return ..()

/datum/reagent/consumable/semen/femcum
	name = "Female Ejaculate"
	description = "Vaginal lubricant found in most mammals and other animals of similar nature. Where you found this is your own business."
	taste_description = "something with a tang" // wew coders who haven't eaten out a girl.
	color = "#AAAAAA77"
	decal_path = /obj/effect/decal/cleanable/semen/femcum

/obj/effect/decal/cleanable/semen/femcum
	name = "female ejaculate"
	icon_state = "fem1"
	random_icon_states = list("fem1", "fem2", "fem3", "fem4")
	blood_state = null
	bloodiness = null

/datum/reagent/determination
	name = "Determination"
	description = "For when you need to push on a little more. Do NOT allow near plants."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM // 5u (WOUND_DETERMINATION_CRITICAL) will last for ~17 ticks
	/// Whether we've had at least WOUND_DETERMINATION_SEVERE (2.5u) of determination at any given time. No damage slowdown immunity or indication we're having a second wind if it's just a single moderate wound
	var/significant = FALSE
	self_consuming = TRUE

/datum/reagent/determination/on_mob_end_metabolize(mob/living/carbon/M)
	if(significant)
		var/stam_crash = 0
		for(var/thing in M.all_wounds)
			var/datum/wound/W = thing
			stam_crash += (W.severity + 1) * 3 // spike of 3 stam damage per wound severity (moderate = 6, severe = 9, critical = 12) when the determination wears off if it was a combat rush
		M.adjustStaminaLoss(stam_crash)
	M.remove_status_effect(STATUS_EFFECT_DETERMINED)
	..()

/datum/reagent/determination/on_mob_life(mob/living/carbon/M)
	if(!significant && volume >= WOUND_DETERMINATION_SEVERE)
		significant = TRUE
		M.apply_status_effect(STATUS_EFFECT_DETERMINED) // in addition to the slight healing, limping cooldowns are divided by 4 during the combat high

	volume = min(volume, WOUND_DETERMINATION_MAX)

	for(var/thing in M.all_wounds)
		var/datum/wound/W = thing
		var/obj/item/bodypart/wounded_part = W.limb
		if(wounded_part)
			wounded_part.heal_damage(0.25, 0.25)
		M.adjustStaminaLoss(-0.25*REM) // the more wounds, the more stamina regen
	..()

/datum/reagent/eldritch
	name = "Eldritch Essence"
	description = "Strange liquid that defies the laws of physics"
	taste_description = "Ag'hsj'saje'sh"
	color = "#1f8016"

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/M)
	if(IS_HERETIC(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-15, FALSE)
		M.adjustToxLoss(-3, FALSE, TRUE)
		M.adjustOxyLoss(-3, FALSE)
		M.adjustBruteLoss(-3, FALSE)
		M.adjustFireLoss(-3, FALSE)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.AddIntegrationBlood(3)
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, FALSE)
		M.adjustFireLoss(2, FALSE)
		M.adjustOxyLoss(2, FALSE)
		M.adjustBruteLoss(2, FALSE)
	holder.remove_reagent(type, 1)
	return TRUE

/datum/reagent/cellulose
	name = "Cellulose Fibers"
	description = "A crystaline polydextrose polymer, plants swear by this stuff."
	reagent_state = SOLID
	color = "#E6E6DA"
	taste_mult = 0


/datum/reagent/hairball
	name = "Hairball"
	description = "A bundle of keratinous bits and fibers, not easily digestible."
	reagent_state = SOLID
	can_synth = FALSE
	metabolization_rate = 0.05 * REAGENTS_METABOLISM
	taste_description = "wet hair"
	var/amount = 0
	var/knotted = FALSE

/datum/reagent/hairball/on_mob_life(mob/living/carbon/M)
	amount = M.reagents.get_reagent_amount(/datum/reagent/hairball)

	if(amount < 10)
		if(prob(10))
			M.losebreath += 1
			M.emote("cough")
			to_chat(M, "<span class='notice'>You clear your throat.</span>")
	else
		if(!knotted)
			to_chat(M, "<span class='notice'>You feel a knot in your stomach.</span>")
			knotted = TRUE

		if(prob(5 + amount * 0.5)) // don't want this to cause too much damage
			M.losebreath += 2
			to_chat(M, "<span class='notice'>You feel a knot in your throat.</span>")
			M.emote("cough")

		else if(prob(amount - 4))
			to_chat(M, "<span class='warning'>Your stomach feels awfully bloated.</span>")
			playsound(M,'sound/voice/catpeople/distressed.ogg', 50, FALSE)
			M.visible_message("<span class='warning'>[M] seems distressed!.</span>", ignored_mobs=M)

		else if(prob(amount - 8))
			knotted = FALSE
			playsound(M,'sound/voice/catpeople/puking.ogg', 110, FALSE)
			M.Immobilize(30)
			sleep(30) //snowflake but it works, don't wanna proc this
			if(QDELETED(M) || QDELETED(src)) //this handles race conditions about m or src not existing.
				return
			M.visible_message("<span class='warning'>[M] throws up a hairball! Disgusting!</span>", ignored_mobs=M)
			new /obj/item/toy/plush/hairball(get_turf(M))
			to_chat(M, "<span class='notice'>Aaaah that's better!</span>")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "cleared_stomach", /datum/mood_event/cleared_stomach, name)
			M.reagents.del_reagent(/datum/reagent/hairball)
			return
	..()

/datum/reagent/red_ichor
	name = "Red Ichor"
	can_synth = FALSE
	description = "A unknown red liquid, linked to healing of most moral wounds."
	color = "#c10000"
	metabolization_rate = REAGENTS_METABOLISM * 2.5

/datum/reagent/red_ichor/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-50)
	M.adjustOxyLoss(-50)
	M.adjustBruteLoss(-50)
	M.adjustFireLoss(-50)
	M.adjustToxLoss(-50, TRUE) //heals TOXINLOVERs
	M.adjustCloneLoss(-50)
	M.adjustStaminaLoss(-50)
	..()

/datum/reagent/green_ichor
	name = "Green Ichor"
	can_synth = FALSE
	description = "A unknown green liquid, linked to healing of most internal wounds."
	color = "#158c00"
	metabolization_rate = REAGENTS_METABOLISM * 2.5

/datum/reagent/green_ichor/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -100)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, -100)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -100)
	M.adjustOrganLoss(ORGAN_SLOT_EARS, -100)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, -100)
	M.adjustOrganLoss(ORGAN_SLOT_TONGUE, -100)
	M.adjustOrganLoss(ORGAN_SLOT_EYES, -100)
	..()

/datum/reagent/blue_ichor
	name = "Blue Ichor"
	can_synth = FALSE
	description = "A unknown blue liquid, linked to healing the mind."
	color = "#0914e0"
	metabolization_rate = REAGENTS_METABOLISM * 2.5

/datum/reagent/blue_ichor/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -100)
	M.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	M.hallucination = 0
	M.dizziness = 0
	M.disgust = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.SetSleeping(0, 0)
	..()

//Nerdy card reagents

/datum/reagent/card_powder
	var/rarity = "Stoopid"

/datum/reagent/card_powder/blue
	name = "Blue Card Powder"
	rarity = "Rare"
	color = "#00B7EF" // blue

/datum/reagent/card_powder/purple
	name = "Purple Card Powder"
	rarity = "Epic"
	color = "#DA00FF" // purple

/datum/reagent/card_powder/yellow
	name = "Yellow Crayon Powder"
	rarity = "Legendary"
	color = "#FFF200" // yellow

/datum/reagent/card_powder/green
	name = "Green Crayon Powder"
	rarity = "Common"
	color = "#A8E61D" // green

/datum/reagent/card_powder/black
	name = "Black Crayon Powder"
	rarity = "Exodia"
	color = "#1C1C1C" // not quite black
