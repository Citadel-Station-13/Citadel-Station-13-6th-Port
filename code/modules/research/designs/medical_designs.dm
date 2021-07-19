/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligences."
	id = "mmi_posi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/posibrain
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 3000, /datum/material/plasma = 3000, /datum/material/diamond = 250, /datum/material/bluespace = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SERVICE

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xlarge_beaker
	name = "X-large Beaker"
	id = "xlarge_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/plastic
	category = list("Medical Designs")

/datum/design/meta_beaker
	name = "Metamaterial Beaker"
	id = "meta_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/meta
	category = list("Medical Designs")

/datum/design/bluespacesyringe
	name = "Bluespace Syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals"
	id = "bluespacesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/syringe/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactsyringe
	name = "Cryo Syringe"
	desc = "An advanced syringe that stops reagents inside from reacting. It can hold up to 20 units."
	id = "noreactsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/reagent_containers/syringe/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/piercesyringe
	name = "Piercing Syringe"
	desc = "A diamond-tipped syringe that pierces armor when launched at high velocity. It can hold up to 10 units."
	id = "piercesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/diamond = 1000)
	build_path = /obj/item/reagent_containers/syringe/piercing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medicinalsmartdart
	name = "Medicinal Smartdart"
	desc = "A non-harmful dart that can administer medication from a range. Once it hits a patient using its smart nanofilter technology, only medicines contained within the dart are administered to the patient. Additonally, due to capillary action, injection of chemicals past the overdose limit is prevented."
	id = "medicinalsmartdart"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 100, /datum/material/plastic = 100, /datum/material/iron = 100)
	build_path = /obj/item/reagent_containers/syringe/dart
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/bluespacesmartdart
	name = "bluespace smartdart"
	desc = "A non-harmful dart that can administer medication from a range. Once it hits a patient using it's smart nanofilter technology only medicines contained within the dart are administered to the patient. Additonally, due to capillary action, injection of chemicals past the overdose limit is prevented. Has an extended volume capacity thanks to bluespace foam."
	id = "bluespacesmartdart"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 250, /datum/material/plastic = 250, /datum/material/iron = 250, /datum/material/bluespace = 250)
	build_path = /obj/item/reagent_containers/syringe/dart/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/smartdartgun
	name = "dart gun"
	desc = "A compressed air gun, designed to fit medicinal darts for application of medicine for those patients just out of reach."
	id = "smartdartgun"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/plastic = 1000, /datum/material/iron = 500)
	build_path = /obj/item/gun/syringe/dart
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/plasmarefiller
	name = "Plasma-Man Jumpsuit Refill"
	desc = "A refill pack for the auto-extinguisher on Plasma-man suits."
	id = "plasmarefiller" //Why did this have no plasmatech
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 1000)
	build_path = /obj/item/extinguisher_refill
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/crewpinpointer
	name = "Crew Pinpointer"
	desc = "Allows tracking of someone's location if their suit sensors are turned to tracking beacon."
	id = "crewpinpointer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1500, /datum/material/gold = 200)
	build_path = /obj/item/pinpointer/crew
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/telescopiciv
	name = "Telescopic IV Drip"
	desc = "An IV drip with an advanced infusion pump that can both drain blood into and inject liquids from attached containers. Blood packs are processed at an accelerated rate. This one is telescopic, and can be picked up and put down."
	id = "telescopiciv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 3500, /datum/material/silver = 1000)
	build_path = /obj/item/tele_iv
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/genescanner
	name = "Genetic Sequence Analyzer"
	desc = "A handy hand-held analyzers for quickly determining mutations and collecting the full sequence."
	id = "genescanner"
	build_path = /obj/item/sequence_scanner
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/healthanalyzer_advanced
	name = "Advanced Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	id = "healthanalyzer_advanced"
	build_path = /obj/item/healthanalyzer/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medspray
	name = "Medical Spray"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap."
	id = "medspray"
	build_path = /obj/item/reagent_containers/medspray
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medicalkit
	name = "Empty Medkit"
	desc = "A plastic medical kit for storging medical items."
	id = "medicalkit"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 5000)
	build_path = /obj/item/storage/firstaid //So we dont spawn medical items in it
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hypospraykit
	name = "Empty Hypospray Kit"
	desc = "A plastic medical kit for storing hyposprays and hypospray accessories."
	id = "hypokit"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 5000)
	build_path = /obj/item/storage/hypospraykit // let's not summon new hyposprays thanks
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hypospray/mkii
	name = "Hypospray Mk. II"
	id = "hypospray_mkii"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1600, /datum/material/glass = 1000)
	build_path = /obj/item/hypospray/mkii
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/blood_bag
	name = "Empty Blood Bag"
	desc = "A small sterilized plastic bag for blood."
	id = "blood_bag"
	build_path = /obj/item/reagent_containers/blood
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1500, /datum/material/plastic = 3500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/bsblood_bag
	name = "Empty Bluespace Blood Bag"
	desc = "A large sterilized plastic bag for blood."
	id = "bsblood_bag"
	build_path = /obj/item/reagent_containers/blood/bluespace
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 4500, /datum/material/bluespace = 250)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/chem_pack
	name = "Intravenous Medicine Bag"
	desc = "A plastic pressure bag for IV administration of drugs."
	id = "chem_pack"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/plastic = 1500)
	build_path = /obj/item/reagent_containers/chem_pack
	category = list("Medical Designs")

/datum/design/cloning_disk
	name = "Cloning Data Disk"
	desc = "Produce additional disks for storing genetic data."
	id = "cloning_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver=50)
	build_path = /obj/item/disk/data
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/organbox
	name = "Empty Organ Box"
	desc = "A large cool box that can hold large amouts of medical tools or organs."
	id = "organbox"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/silver= 3500, /datum/material/gold = 3500, /datum/material/plastic = 5000)
	build_path = /obj/item/storage/belt/organbox
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

////////////////////////////////////////
//////////Body Bags/////////////////////
////////////////////////////////////////

/datum/design/bodybag
	name = "Body Bag"
	desc = "A normal body bag used for storage of dead crew."
	id = "bodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 4000)
	build_path = /obj/item/bodybag
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebodybag
	name = "Bluespace Body Bag"
	desc = "A bluespace body bag, powered by experimental bluespace technology. It can hold loads of bodies and the largest of creatures."
	id = "bluespacebodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/plasma = 2000, /datum/material/diamond = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/bodybag/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/containmentbodybag
	name = "Containment Body Bag"
	desc = "A containment body bag, heavy and radiation proof."
	id = "containmentbodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/plastic = 4000, /datum/material/titanium = 2000)
	build_path = /obj/item/bodybag/containment
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

////////////////////////////////////////
//////////Defibrillator Tech////////////
////////////////////////////////////////

/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A portable defibrillator, used for resuscitating recently deceased crew."
	id = "defibrillator"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/silver = 3000, /datum/material/gold = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_mount
	name = "Defibrillator Wall Mount"
	desc = "An all-in-one mounted frame for holding defibrillators, complete with ID-locked clamps and recharging cables."
	id = "defibmount"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/wallframe/defib_mount
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defib_heal
	name = "Defibrillator Healing disk"
	desc = "An upgrade which increases the healing power of the defibrillator."
	id = "defib_heal"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 18000, /datum/material/gold = 6000, /datum/material/silver = 6000)
	build_path = /obj/item/disk/medical/defib_heal
	construction_time = 10
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defib_shock
	name = "Defibrillator Anti-Shock Disk"
	desc = "A safety upgrade that guarantees only the patient will get shocked."
	id = "defib_shock"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 18000, /datum/material/gold = 6000, /datum/material/silver = 6000)
	build_path = /obj/item/disk/medical/defib_shock
	construction_time = 10
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defib_decay
	name = "Defibrillator Body-Decay Extender Disk"
	desc = "An upgrade allowing the defibrillator to work on more decayed bodies."
	id = "defib_decay"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 18000, /datum/material/gold = 16000, /datum/material/silver = 6000, /datum/material/titanium = 2000)
	build_path = /obj/item/disk/medical/defib_decay
	construction_time = 10
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defib_speed
	name = "Defibrillator Fast Charge Disk"
	desc = "An upgrade to the defibrillator's capacitors, which lets it charge faster."
	id = "defib_speed"
	build_type = PROTOLATHE
	build_path = /obj/item/disk/medical/defib_speed
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 8000, /datum/material/gold = 26000, /datum/material/silver = 26000)
	construction_time = 10
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_compact
	name = "Compact Defibrillator"
	desc = "A compact defibrillator that can be worn on a belt."
	id = "defibrillator_compact"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator/compact
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 8000, /datum/material/silver = 6000, /datum/material/gold = 3000)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals. Reagents have to be supplied with beakers."
	id = "portable_chem_mixer"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/plastic = 5000, /datum/material/iron = 10000, /datum/material/glass = 3000)
	build_path = /obj/item/storage/portable_chem_mixer
	category = list("Equipment")

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield Eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 400)
	build_path = /obj/item/organ/eyes/robotic/shield
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_gloweyes
	name = "Luminescent Eyes"
	desc = "A pair of cybernetic eyes that can emit multicolored light"
	id = "ci-gloweyes"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000)
	build_path = /obj/item/organ/eyes/robotic/glow
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	id = "ci-breather"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(/datum/material/iron = 600, /datum/material/glass = 250)
	build_path = /obj/item/organ/cyberimp/mouth/breathing_tube
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_surgical
	name = "Surgical Arm Implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-surgery"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/surgery
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/toolset
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_shield
	name = "Riot Shield Arm Implant"
	desc = "An implanted riot shield, designed to be installed on subject's arm."
	id = "ci-shield"
	build_type = PROTOLATHE
	materials = list (/datum/material/iron = 8500, /datum/material/glass = 8500, /datum/material/silver = 1800, /datum/material/titanium = 600)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/shield
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_janitor
	name = "Janitor Arm Implant"
	desc = "A set of janitor tools fitted into an arm implant, designed to be installed on subject's arm."
	id = "ci-janitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/janitor
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_service
	name = "Service Arm Implant"
	desc = "Everything a cook or barkeep needs in an arm implant, designed to be installed on subject's arm."
	id = "ci-service"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/service
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_medical_hud
	name = "Medical HUD Implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/medical
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_diagnostics_hud
	name = "Diagnostics HUD Implant"
	desc = "These cybernetic eyes will display a diagnostics HUD over everything you see. Wiggle eyes to control."
	id = "ci-diaghud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/diagnostic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_science_hud
	name = "Science HUD Implant"
	desc = "These cybernetic eyes will display a science HUD over everything you see. Wiggle eyes to control."
	id = "ci-scihud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/science
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_security_hud
	name = "Security HUD Implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 750, /datum/material/gold = 750)
	build_path = /obj/item/organ/cyberimp/eyes/hud/security
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_xray
	name = "X-ray Eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/uranium = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/organ/eyes/robotic/xray
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/organ/eyes/robotic/thermals
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_meson
	name = "Meson Eyes"
	desc = "These cybernetic eyes will give you Meson vision."
	id = "ci-meson"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 700, /datum/material/plasma = 800)
	build_path = /obj/item/organ/eyes/robotic/meson
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antidrop
	name = "Anti-Drop Implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400, /datum/material/gold = 400)
	build_path = /obj/item/organ/cyberimp/brain/anti_drop
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 1000)
	build_path = /obj/item/organ/cyberimp/brain/anti_stun
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_robot_radshielding
	name = "ECC System Guard Implant"
	desc = "This implant can counteract the effects of harmful radiation in robots, effectively increasing their radiation tolerance significantly."
	id = "ci-robot-radshielding"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 400, /datum/material/silver = 350, /datum/material/gold = 1000, /datum/material/diamond = 100)
	build_path = /obj/item/organ/cyberimp/brain/robot_radshielding
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment
	name = "Nutriment Pump Implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	id = "ci-nutriment"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/gold = 500)
	build_path = /obj/item/organ/cyberimp/chest/nutriment
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment Pump Implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/gold = 500, /datum/material/uranium = 750)
	build_path = /obj/item/organ/cyberimp/chest/nutriment/plus
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 800, /datum/material/glass = 800, /datum/material/gold = 300, /datum/material/uranium = 500)
	build_path = /obj/item/organ/cyberimp/chest/reviver
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thrusters
	name = "Thrusters Set Implant"
	desc = "This implant will allow you to use gas from environment or your internals for propulsion in zero-gravity areas."
	id = "ci-thrusters"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/silver = 1000, /datum/material/diamond = 1000)
	build_path = /obj/item/organ/cyberimp/chest/thrusters
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200)
	build_path = /obj/item/implanter
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case for containing an implant."
	id = "implantcase"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/implantcase
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_sadtrombone
	name = "Sad Trombone Implant Case"
	desc = "Makes death amusing."
	id = "implant_trombone"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/bananium = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//if you get bananium you get the sad trombones.

/datum/design/implant_chem
	name = "Chemical Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 700)
	build_path = /obj/item/implantcase/chem
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_tracking
	name = "Tracking Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/track
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

//Cybernetic organs

/datum/design/cybernetic_liver
	name = "Basic Cybernetic Liver"
	desc = "A basic cybernetic liver."
	id = "cybernetic_liver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/liver/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_liver/tier2
	name = "Cybernetic Liver"
	desc = "A cybernetic liver."
	id = "cybernetic_liver_tier2"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/liver/cybernetic/tier2

/datum/design/cybernetic_liver/tier3
	name = "Upgraded Cybernetic Liver"
	desc = "An upgraded cybernetic liver."
	id = "cybernetic_liver_tier3"
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/organ/liver/cybernetic/tier3

/datum/design/cybernetic_heart
	name = "Basic Cybernetic Heart"
	desc = "A basic cybernetic heart."
	id = "cybernetic_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/heart/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart/tier2
	name = "Cybernetic Heart"
	desc = "A cybernetic heart."
	id = "cybernetic_heart_tier2"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/heart/cybernetic/tier2

/datum/design/cybernetic_heart/tier3
	name = "Upgraded Cybernetic Heart"
	desc = "An upgraded cybernetic heart."
	id = "cybernetic_heart_tier3"
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/organ/heart/cybernetic/tier3

/datum/design/cybernetic_lungs
	name = "Basic Cybernetic Lungs"
	desc = "A basic pair of cybernetic lungs."
	id = "cybernetic_lungs"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/lungs/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs/tier2
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs_tier2"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/lungs/cybernetic/tier2

/datum/design/cybernetic_lungs/tier3
	name = "Upgraded Cybernetic Lungs"
	desc = "A pair of upgraded cybernetic lungs."
	id = "cybernetic_lungs_tier3"
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/organ/lungs/cybernetic/tier3

/datum/design/cybernetic_stomach
	name = "Basic Cybernetic Stomach"
	desc = "A basic cybernetic stomach."
	id = "cybernetic_stomach"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/stomach/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach/tier2
	name = "Cybernetic Stomach"
	desc = "A cybernetic stomach."
	id = "cybernetic_stomach_tier2"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/stomach/cybernetic/tier2

/datum/design/cybernetic_stomach/tier3
	name = "Upgraded Cybernetic Stomach"
	desc = "An upgraded cybernetic stomach."
	id = "cybernetic_stomach_tier3"
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/organ/stomach/cybernetic/tier3

/datum/design/cybernetic_tongue
	name = "Cybernetic tongue"
	desc = "A fancy cybernetic tongue."
	id = "cybernetic_tongue"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/tongue/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_ears
	name = "Cybernetic Ears"
	desc = "A pair of cybernetic ears."
	id = "cybernetic_ears"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 30
	materials = list(/datum/material/iron = 250, /datum/material/glass = 400)
	build_path = /obj/item/organ/ears/cybernetic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_ears_u
	name = "Upgraded Cybernetic Ears"
	desc = "A pair of upgraded cybernetic ears."
	id = "cybernetic_ears_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500)
	build_path = /obj/item/organ/ears/cybernetic/upgraded
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////
/////Synth Organs////
/////////////////////

/datum/design/ipc_stomach
	name = "IPC cell"
	desc = "Effectively the robot equivalent of a stomach, handling power storage."
	id = "ipc_stomach"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 300, /datum/material/silver = 500, /datum/material/gold = 400)
	build_path = /obj/item/organ/stomach/ipc
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_power_cord
	name = "IPC power cord"
	desc = "A implant for Robots designed to siphon power from APCs to recharge their own cell."
	id = "ci-power-cord"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 75
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/silver = 1200, /datum/material/gold = 1600, /datum/material/plasma = 1000)
	build_path = /obj/item/organ/cyberimp/arm/power_cord
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////
///Surgery Designs///
/////////////////////

/datum/design/surgery
	name = "Surgery Design"
	desc = "what"
	id = "surgery_parent"
	research_icon = 'icons/obj/surgery.dmi'
	research_icon_state = "surgery_any"
	var/surgery

/datum/design/surgery/experimental_dissection
	name = "Advanced Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and automatically adds new findings to the research database."
	id = "surgery_adv_dissection"
	surgery = /datum/surgery/advanced/experimental_dissection/adv
	research_icon_state = "surgery_chest"

/datum/design/surgery/experimental_dissection/exp
	name = "Experimental Dissection"
	id = "surgery_exp_dissection"
	surgery = /datum/surgery/advanced/experimental_dissection/exp

/datum/design/surgery/experimental_dissection/ext
	name = "Extraterrestrial Dissection"
	id = "surgery_ext_dissection"
	surgery = /datum/surgery/advanced/experimental_dissection/alien

/datum/design/surgery/lobotomy
	name = "Lobotomy"
	desc = "An invasive surgical procedure which guarantees removal of almost all brain traumas, but might cause another permanent trauma in return."
	id = "surgery_lobotomy"
	surgery = /datum/surgery/advanced/lobotomy
	research_icon_state = "surgery_head"

/datum/design/surgery/pacify
	name = "Pacification"
	desc = "A surgical procedure which permanently inhibits the aggression center of the brain, making the patient unwilling to cause direct harm."
	id = "surgery_pacify"
	surgery = /datum/surgery/advanced/pacify
	research_icon_state = "surgery_head"

/datum/design/surgery/viral_bonding
	name = "Viral Bonding"
	desc = "A surgical procedure that forces a symbiotic relationship between a virus and its host. The patient must be dosed with spaceacillin, virus food, and formaldehyde."
	id = "surgery_viral_bond"
	surgery = /datum/surgery/advanced/viral_bonding
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing
	name = "Tend Wounds"
	desc = "An upgraded version of the original surgery."
	id = "surgery_healing_base" //holder because travis cries otherwise. Not used in techweb unlocks.
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing/brute_upgrade
	name = "Tend Wounds (Brute) Upgrade I"
	surgery = /datum/surgery/healing/brute/upgraded
	id = "surgery_heal_brute_upgrade"

/datum/design/surgery/healing/brute_upgrade_2
	name = "Tend Wounds (Brute) Upgrade II"
	surgery = /datum/surgery/healing/brute/upgraded/femto
	id = "surgery_heal_brute_upgrade_femto"

/datum/design/surgery/healing/burn_upgrade
	name = "Tend Wounds (Burn) Upgrade I"
	surgery = /datum/surgery/healing/burn/upgraded
	id = "surgery_heal_burn_upgrade"

/datum/design/surgery/healing/burn_upgrade_2
	name = "Tend Wounds (Burn) Upgrade II"
	surgery = /datum/surgery/healing/brute/upgraded/femto
	id = "surgery_heal_burn_upgrade_femto"

/datum/design/surgery/healing/combo
	name = "Tend Wounds (Mixture)"
	desc = "A surgical procedure that repairs both bruises and burns. Repair efficiency is not as high as the individual surgeries but it is faster."
	surgery = /datum/surgery/healing/combo
	id = "surgery_heal_combo"

/datum/design/surgery/healing/combo_upgrade
	name = "Tend Wounds (Mixture) Upgrade I"
	surgery = /datum/surgery/healing/combo/upgraded
	id = "surgery_heal_combo_upgrade"

/datum/design/surgery/healing/combo_upgrade_2
	name = "Tend Wounds (Mixture) Upgrade II"
	desc = "A surgical procedure that repairs both bruises and burns faster than their individual counterparts. It is more effective than both the individual surgeries."
	surgery = /datum/surgery/healing/combo/upgraded/femto
	id = "surgery_heal_combo_upgrade_femto"

/datum/design/surgery/healing/robot_upgrade
	name = "Repair Robotic Limbs Upgrade"
	surgery = /datum/surgery/robot_healing/upgraded
	id = "surgery_heal_robo_upgrade"

/datum/design/surgery/healing/robot_upgrade_2
	name = "Repair Robotic Limbs Upgrade II"
	surgery = /datum/surgery/robot_healing/upgraded/femto
	id = "surgery_heal_robo_upgrade_femto"

/datum/design/surgery/surgery_toxinhealing
	name = "Body Rejuvenation"
	desc = "A surgical procedure that helps deal with oxygen  deprecation, and treat toxic damaged. Works on corpses and alive alike without chemicals."
	id = "surgery_toxinhealing"
	surgery = /datum/surgery/advanced/toxichealing
	research_icon_state = "surgery_chest"

/datum/design/surgery/revival
	name = "Revival"
	desc = "An experimental surgical procedure which involves reconstruction and reactivation of the patient's brain even long after death. The body must still be able to sustain life."
	id = "surgery_revival"
	surgery = /datum/surgery/advanced/revival
	research_icon_state = "surgery_head"

/datum/design/surgery/brainwashing
	name = "Brainwashing"
	desc = "A surgical procedure which directly implants a directive into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	id = "surgery_brainwashing"
	surgery = /datum/surgery/advanced/brainwashing
	research_icon_state = "surgery_head"

/datum/design/surgery/nerve_splicing
	name = "Nerve Splicing"
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	id = "surgery_nerve_splice"
	surgery = /datum/surgery/advanced/bioware/nerve_splicing
	research_icon_state = "surgery_chest"

/datum/design/surgery/nerve_grounding
	name = "Nerve Grounding"
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	id = "surgery_nerve_ground"
	surgery = /datum/surgery/advanced/bioware/nerve_grounding
	research_icon_state = "surgery_chest"

/datum/design/surgery/vein_threading
	name = "Vein Threading"
	desc = "A surgical procedure which severely reduces the amount of blood lost in case of injury."
	id = "surgery_vein_thread"
	surgery = /datum/surgery/advanced/bioware/vein_threading
	research_icon_state = "surgery_chest"

/datum/design/surgery/muscled_veins
	name = "Vein Muscle Membrane"
	desc = "A surgical procedure which adds a muscled membrane to blood vessels, allowing them to pump blood without a heart."
	id = "surgery_muscled_veins"
	surgery = /datum/surgery/advanced/bioware/muscled_veins
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_hook
	name = "Ligament Hook"
	desc = "A surgical procedure which reshapes the connections between torso and limbs, making it so limbs can be attached manually if severed. \
	However this weakens the connection, making them easier to detach as well."
	id = "surgery_ligament_hook"
	surgery = /datum/surgery/advanced/bioware/ligament_hook
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_reinforcement
	name = "Ligament Reinforcement"
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
	However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	id = "surgery_ligament_reinforcement"
	surgery = /datum/surgery/advanced/bioware/ligament_reinforcement
	research_icon_state = "surgery_chest"

/datum/design/surgery/necrotic_revival
	name = "Necrotic Revival"
	desc = "An experimental surgical procedure that stimulates the growth of a Romerol tumor inside the patient's brain. Requires zombie powder or rezadone."
	id = "surgery_zombie"
	surgery = /datum/surgery/advanced/necrotic_revival
	research_icon_state = "surgery_head"

/////////////////////////////////////////
////////////Medical Prosthetics//////////
/////////////////////////////////////////

/datum/design/basic_l_arm
	name = "Surplus prosthetic left arm"
	desc = "Basic outdated and fragile prosthetic left arm."
	id = "basic_l_arm"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	construction_time = 20
	build_path = /obj/item/bodypart/l_arm/robot/surplus
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/basic_r_arm
	name = "Surplus prosthetic right arm"
	desc = "Basic outdated and fragile prosthetic left arm."
	id = "basic_r_arm"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	construction_time = 20
	build_path = /obj/item/bodypart/r_arm/robot/surplus
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/basic_l_leg
	name = "Surplus prosthetic left leg"
	desc = "Basic outdated and fragile prosthetic left leg."
	id = "basic_l_leg"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	construction_time = 20
	build_path = /obj/item/bodypart/l_leg/robot/surplus
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/basic_r_leg
	name = "Surplus prosthetic right leg"
	desc = "Basic outdated and fragile prosthetic right leg."
	id = "basic_r_leg"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	construction_time = 20
	build_path = /obj/item/bodypart/r_leg/robot/surplus
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_r_leg
	name = "Advanced prosthetic right leg"
	desc = "A renforced prosthetic right leg."
	id = "adv_r_leg"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3500, /datum/material/gold = 500, /datum/material/titanium = 800)
	construction_time = 40
	build_path = /obj/item/bodypart/r_leg/robot/surplus_upgraded
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_l_leg
	name = "Advanced prosthetic left leg"
	desc = "A renforced prosthetic left leg."
	id = "adv_l_leg"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3500, /datum/material/gold = 500, /datum/material/titanium = 800)
	construction_time = 40
	build_path = /obj/item/bodypart/l_leg/robot/surplus_upgraded
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_l_arm
	name = "Advanced prosthetic left arm"
	desc = "A renforced prosthetic left arm."
	id = "adv_l_arm"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3500, /datum/material/gold = 500, /datum/material/titanium = 800)
	construction_time = 40
	build_path = /obj/item/bodypart/l_arm/robot/surplus_upgraded
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_r_arm
	name = "Advanced prosthetic right arm"
	desc = "A renforced prosthetic right arm."
	id = "adv_r_arm"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3500, /datum/material/gold = 500, /datum/material/titanium = 800)
	construction_time = 40
	build_path = /obj/item/bodypart/r_arm/robot/surplus_upgraded
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL


/////////////////////////////////////////
////////////     Plumbing      //////////
/////////////////////////////////////////

/datum/design/acclimator
	name = "Plumbing Acclimator"
	desc = "A heating and cooling device for pipes!"
	id = "acclimator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/acclimator
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disposer
	name = "Plumbing Disposer"
	desc = "Using the power of Science, dissolves reagents into nothing (almost)."
	id = "disposer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 100)
	construction_time = 15
	build_path = /obj/machinery/plumbing/disposer
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_filter
	name = "Plumbing Filter"
	desc = "Filters out chemicals by their NTDB ID."
	id = "plumb_filter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/filter
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_synth
	name = "Plumbing Synthesizer"
	desc = "Using standard mass-energy dynamic autoconverters, generates reagents from power and puts them in a pipe."
	id = "plumb_synth"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/plastic = 1000)
	construction_time = 15
	build_path = /obj/machinery/plumbing/synthesizer
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_grinder
	name = "Plumbing-Linked Autogrinder"
	desc = "Automatically extracts reagents from an item by grinding it. Think of the possibilities! Note: does not grind people."
	id = "plumb_grinder"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/grinder_chemical
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/reaction_chamber
	name = "Plumbing Reaction Chamber"
	desc = "You can set a list of allowed reagents and amounts. Once the chamber has these reagents, will let the products through."
	id = "reaction_chamber"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/reaction_chamber
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/duct_print
	name = "Plumbing Ducts"
	desc = "Ducts for plumbing! Now lathed for efficiency."
	id = "duct_print"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 400)
	construction_time = 1
	build_path = /obj/item/stack/ducts
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_splitter
	name = "Plumbing Chemical Splitter"
	desc = "A splitter. Has 2 outputs. Can be configured to allow a certain amount through each side."
	id = "plumb_splitter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 750, /datum/material/glass = 250)
	construction_time = 15
	build_path = /obj/machinery/plumbing/splitter
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pill_press
	name = "Plumbing Automatic Pill Former"
	desc = "Automatically forms pills to the required parameters with piped reagents! A good replacement for those lazy, useless chemists."
	id = "pill_press"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/pill_press
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_pump
	name = "Liquid Extraction Pump"
	desc = "Use it for extracting liquids from lavaland's geysers!"
	id = "plumb_pump"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 15
	build_path = /obj/machinery/plumbing/liquid_pump
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_in
	name = "Plumbing Input Device"
	desc = "A big piped funnel for putting stuff in the pipe network."
	id = "plumb_in"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 400)
	construction_time = 15
	build_path = /obj/machinery/plumbing/input
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_out
	name = "Plumbing Output Device"
	desc = "A big piped funnel for taking stuff out of the pipe network."
	id = "plumb_out"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 400)
	construction_time = 15
	build_path = /obj/machinery/plumbing/output
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_tank
	name = "Plumbed Storage Tank"
	desc = "A tank for storing plumbed reagents."
	id = "plumb_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/plastic = 4000)
	construction_time = 15
	build_path = /obj/machinery/plumbing/tank
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumb_rcd
	name = "Plumbed Autoconstruction Device"
	desc = "A RCD for plumbing machines! Cannot make ducts."
	id = "plumb_rcd"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 10000, /datum/material/plastic = 20000, /datum/material/titanium = 2000, /datum/material/diamond = 800, /datum/material/gold = 2000, /datum/material/silver = 2000)
	construction_time = 150
	build_path = /obj/item/construction/plumbing
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/rplunger
    name = "Reinforced Plunger"
    desc = "A plunger designed for heavy duty clogs."
    id = "rplunger"
    build_type = PROTOLATHE
    materials = list(/datum/material/plasma = 1000, /datum/material/iron = 1000, /datum/material/glass = 1000)
    construction_time = 15
    build_path = /obj/item/plunger/reinforced
    category = list ("Misc","Medical Designs")
    departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO
