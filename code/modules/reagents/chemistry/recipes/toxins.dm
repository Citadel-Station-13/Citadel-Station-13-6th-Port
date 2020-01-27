
/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = /datum/reagent/toxin/formaldehyde
	results = list(/datum/reagent/toxin/formaldehyde = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1, /datum/reagent/silver = 1)
	mix_message = "A horrible smell emits from the beaker."
	required_temp = 420

/datum/chemical_reaction/fentanyl
	name = "fentanyl"
	id = /datum/reagent/toxin/fentanyl
	results = list(/datum/reagent/toxin/fentanyl = 1)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1)
	mix_message = "A sickly sweet smell emits from the beaker."
	required_temp = 674

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = /datum/reagent/toxin/cyanide
	results = list(/datum/reagent/toxin/cyanide = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/ammonia = 1, /datum/reagent/oxygen = 1)
	mix_message = "<span class='danger'>A bitter smell emits from the beaker.</span>"
	required_temp = 380

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = /datum/reagent/toxin/itching_powder
	results = list(/datum/reagent/toxin/itching_powder = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/ammonia = 1, /datum/reagent/medicine/charcoal = 1)
	mix_message = "<span class='danger'>A dusty powder forms.</span>"

/datum/chemical_reaction/facid
	name = "Fluorosulfuric acid"
	id = /datum/reagent/toxin/acid/fluacid
	results = list(/datum/reagent/toxin/acid/fluacid = 4)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/potassium = 1)
	mix_message = "<span class='danger'>A colourless liquid forms.</span>"
	required_temp = 380

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = /datum/reagent/toxin/sulfonal
	results = list(/datum/reagent/toxin/sulfonal = 3)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/sulfur = 1)
	mix_message = "The liquid evenly mixes."

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = /datum/reagent/toxin/lipolicide
	results = list(/datum/reagent/toxin/lipolicide = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/diethylamine = 1, /datum/reagent/medicine/ephedrine = 1)

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = /datum/reagent/toxin/mutagen
	results = list(/datum/reagent/toxin/mutagen = 3)
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/chlorine = 1)
	mix_message = "The liquid becomes runny"

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = /datum/reagent/toxin/lexorin
	results = list(/datum/reagent/toxin/lexorin = 3)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	mix_message = "The liquid becomes thick"

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = /datum/reagent/toxin/chloralhydrate
	results = list(/datum/reagent/toxin/chloralhydrate = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 3, /datum/reagent/water = 1)
	mix_message = "A fruity smell emits from the beaker."

/datum/chemical_reaction/mutetoxin //i'll just fit this in here snugly between other unfun chemicals :v
	name = "Mute Toxin"
	id = /datum/reagent/toxin/mutetoxin
	results = list(/datum/reagent/toxin/mutetoxin = 2)
	required_reagents = list(/datum/reagent/uranium = 2, /datum/reagent/water = 1, /datum/reagent/carbon = 1)
	mix_message = "The liquid is silent as it bubbles."

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = /datum/reagent/toxin/zombiepowder
	results = list(/datum/reagent/toxin/zombiepowder = 2)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, /datum/reagent/medicine/morphine = 5, /datum/reagent/copper = 5)
	mix_message = "<span class='danger'>A green powder forms in the beaker.</span>"

/datum/chemical_reaction/ghoulpowder
	name = "Ghoul Powder"
	id = /datum/reagent/toxin/ghoulpowder
	results = list(/datum/reagent/toxin/ghoulpowder = 2)
	required_reagents = list(/datum/reagent/toxin/zombiepowder = 1, /datum/reagent/medicine/epinephrine = 1)
	mix_message = "<span class='danger'>A horrible smell emits out of the beaker.</span>"

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = /datum/reagent/toxin/mindbreaker
	results = list(/datum/reagent/toxin/mindbreaker = 5)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/charcoal = 1)
	mix_message = "The liquid fluffs up quickly."

/datum/chemical_reaction/heparin
	name = "Heparin"
	id = /datum/reagent/toxin/heparin
	results = list(/datum/reagent/toxin/heparin = 4)
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/chlorine = 1, /datum/reagent/lithium = 1)
	mix_message = "The mixture thins and loses all color."

/datum/chemical_reaction/rotatium
	name = "Rotatium"
	id = /datum/reagent/toxin/rotatium
	results = list(/datum/reagent/toxin/rotatium = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/teslium = 1, /datum/reagent/toxin/fentanyl = 1)
	mix_message = "<span class='danger'>After sparks, fire, and the smell of mindbreaker, the mix is constantly spinning with no stop in sight.</span>"

/datum/chemical_reaction/skewium
	name = "Skewium"
	id = /datum/reagent/toxin/skewium
	results = list(/datum/reagent/toxin/skewium = 5)
	required_reagents = list(/datum/reagent/toxin/rotatium = 2, /datum/reagent/toxin/plasma = 2, /datum/reagent/toxin/acid = 1)
	mix_message = "<span class='danger'>Wow! it turns out if you mix rotatium with some plasma and sulphuric acid, it gets even worse!</span>"

/datum/chemical_reaction/anacea
	name = "Anacea"
	id = /datum/reagent/toxin/anacea
	results = list(/datum/reagent/toxin/anacea = 3)
	required_reagents = list(/datum/reagent/medicine/haloperidol = 1, /datum/reagent/impedrezene = 1, /datum/reagent/radium = 1)
	mix_message = "The liquid mixes effortlessly."

/datum/chemical_reaction/mimesbane
	name = "Mime's Bane"
	id = /datum/reagent/toxin/mimesbane
	results = list(/datum/reagent/toxin/mimesbane = 3)
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1)
	mix_message = "The liquid bubbles stop moving."

/datum/chemical_reaction/bonehurtingjuice
	name = "Bone Hurting Juice"
	id = /datum/reagent/toxin/bonehurtingjuice
	results = list(/datum/reagent/toxin/bonehurtingjuice = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/toxin/itching_powder = 3, /datum/reagent/consumable/milk = 1)
	mix_message = "<span class='danger'>The mixture suddenly becomes clear and looks a lot like water. You feel a strong urge to drink it.</span>"
