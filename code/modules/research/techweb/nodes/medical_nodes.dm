
////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "scan_console", "cloning_disk")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("splitbeaker", "noreactsyringe", "cryotube", "cryo_Grenade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/adv_defibrillator_tec
	id = "adv_defibrillator_tec"
	display_name = "Defibrillator Upgrades"
	description = "More ways to bring back the newly dead."
	prereq_ids = list("adv_biotech", "exp_surgery", "adv_engi", "adv_power")
	design_ids = list("defib_decay", "defib_shock", "defib_heal", "defib_speed")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/plumbing
	id = "plumbing"
	display_name = "Reagent Plumbing Technology"
	description = "Plastic tubes, and machinery used for manipulating things in them."
	prereq_ids = list("base")
	design_ids = list("acclimator", "disposer", "plumb_filter", "plumb_synth", "plumb_grinder", "reaction_chamber", "duct_print", "plumb_splitter", "pill_press", "plumb_pump", "plumb_in", "plumb_out", "plumb_tank", "medipen_refiller")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)


/datum/techweb_node/advplumbing
	id = "advplumbing"
	display_name = "Advanced Plumbing Technology"
	description = "Plumbing RCD."
	prereq_ids = list("plumbing", "adv_engi")
	design_ids = list("plumb_rcd", "autohydrotray", "rplunger")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

//////////////////////Cybernetics/////////////////////

/datum/techweb_node/surplus_limbs
	id = "surplus_limbs"
	display_name = "Basic Prosthetics"
	description = "Basic fragile prosthetics for the impaired."
	starting_node = TRUE
	prereq_ids = list("biotech")
	design_ids = list("basic_l_arm", "basic_r_arm", "basic_r_leg", "basic_l_leg")

/datum/techweb_node/advance_limbs
	id = "advance_limbs"
	display_name = "Upgraded Prosthetics"
	description = "Reinforced prosthetics for the impaired."
	prereq_ids = list("adv_biotech", "surplus_limbs")
	design_ids = list("adv_l_arm", "adv_r_arm", "adv_r_leg", "adv_l_leg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1250)

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech", "datatheory")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_tracking", "locator", "c38_trac")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/basic_cyber_organs
	id = "basic_cyber_organs"
	starting_node = TRUE
	display_name = "Basic Cybernetic Organs"
	description = "We have the techinology to force him to live a disgusting halflife."
	design_ids = list("cybernetic_liver", "cybernetic_heart", "cybernetic_lungs", "cybernetic_stomach")

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("biotech")
	design_ids = list("cybernetic_ears", "cybernetic_heart_tier2", "cybernetic_liver_tier2", "cybernetic_lungs_tier2", "cybernetic_stomach_tier2", "cybernetic_tongue")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("adv_biotech", "cyber_organs")
	design_ids = list("cybernetic_ears_u", "cybernetic_heart_tier3", "cybernetic_liver_tier3", "cybernetic_lungs_tier3", "cybernetic_stomach_tier3")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "adv_datatheory")
	design_ids = list("ci-nutriment", "ci-breather", "ci-gloweyes", "ci-welding", "ci-medhud", "ci-sechud", "ci-diaghud", "ci-scihud", "ci-service", "ci-power-cord")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list("ci-toolset", "ci-surgery", "ci-reviver", "ci-nutrimentplus", "ci-robot-radshielding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list("ci-meson", "ci-antidrop", "ci-antistun", "ci-thrusters", "ci-shield")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/////////////////////////Advanced Surgery/////////////////////////
/datum/techweb_node/imp_wt_surgery
	id = "imp_wt_surgery"
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list("biotech")
	design_ids = list("surgery_heal_brute_upgrade","surgery_heal_burn_upgrade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list("imp_wt_surgery")
	design_ids = list("surgery_revival", "surgery_lobotomy", "surgery_heal_brute_upgrade_femto","surgery_heal_burn_upgrade_femto","surgery_heal_robo_upgrade","surgery_heal_combo", "surgery_toxinhealing", "organbox", "surgery_adv_dissection")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/advance_surgerytools
	id = "advance_surgerytools"
	display_name = "Advanced Surgery Tools"
	description = "Refined and improved redesigns for the run-of-the-mill medical utensils."
	prereq_ids = list("adv_biotech", "adv_surgery")
	design_ids = list("drapes", "retractor_adv", "surgicaldrill_adv", "scalpel_adv", "bonesetter", "surgical_tape")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list("adv_surgery")
	design_ids = list("surgery_pacify","surgery_vein_thread","surgery_muscled_veins","surgery_nerve_splice","surgery_nerve_ground","surgery_ligament_hook","surgery_ligament_reinforcement","surgery_viral_bond", "surgery_exp_dissection","surgery_heal_robo_upgrade_femto","surgery_heal_combo_upgrade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list("exp_surgery", "alientech")
	design_ids = list("surgery_brainwashing","surgery_zombie", "surgery_ext_dissection", "surgery_heal_combo_upgrade_femto")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
