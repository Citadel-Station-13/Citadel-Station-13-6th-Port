//This is the file that handles donator loadout items.

/datum/gear/donator
	name = "IF YOU SEE THIS, PING A CODER RIGHT NOW!"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn/golden
	category = LOADOUT_CATEGORY_DONATOR
	ckeywhitelist = list("This entry should never appear with this variable set.") //If it does, then that means somebody fucked up the whitelist system pretty hard

/datum/gear/donator/pet
	name = "Pet Beacon"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/choice_beacon/pet
	ckeywhitelist = list()
	donator_group_id = DONATOR_GROUP_TIER_1 // can be accessed by all donators

/datum/gear/donator/carpet
	name = "Carpet Beacon"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/choice_beacon/box/carpet
	ckeywhitelist = list()
	donator_group_id = DONATOR_GROUP_TIER_1

/datum/gear/donator/chameleon_bedsheet
	name = "Chameleon Bedsheet"
	slot = SLOT_NECK
	path = /obj/item/bedsheet/chameleon
	ckeywhitelist = list()
	donator_group_id = DONATOR_GROUP_TIER_1

/datum/gear/donator/donortestingbikehorn
	name = "Donor item testing bikehorn"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn
	geargroupID = list("DONORTEST") //This is a list mainly for the sake of testing, but geargroupID works just fine with ordinary strings

/datum/gear/donator/kevhorn
	name = "Airhorn"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn/airhorn
	ckeywhitelist = list("kevinz000")

/datum/gear/donator/kiaracloak
	name = "Kiara's cloak"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/inferno
	ckeywhitelist = list("inferno707")

/datum/gear/donator/kiaracollar
	name = "Kiara's collar"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/inferno
	ckeywhitelist = list("inferno707")

/datum/gear/donator/kiaramedal
	name = "Insignia of Steele"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/accessory/medal/steele
	ckeywhitelist = list("inferno707")

/datum/gear/donator/hheart
	name = "The Hollow Heart"
	slot = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/hheart
	ckeywhitelist = list("inferno707")

/datum/gear/donator/engravedzippo
	name = "Engraved zippo"
	slot = SLOT_HANDS
	path = /obj/item/lighter/gold
	ckeywhitelist = list("dirtyoldharry")

/datum/gear/donator/geisha
	name = "Geisha suit"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/costume/geisha
	ckeywhitelist = list("atiefling")

/datum/gear/donator/specialscarf
	name = "Special scarf"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/scarf/zomb
	ckeywhitelist = list("zombierobin")

/datum/gear/donator/redmadcoat
	name = "The Mad's labcoat"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/toggle/labcoat/mad/red
	ckeywhitelist = list("zombierobin")

/datum/gear/donator/santahat
	name = "Santa hat"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/santa/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/donator/reindeerhat
	name = "Reindeer hat"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/hardhat/reindeer/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/donator/treeplushie
	name = "Christmas tree plushie"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/tree
	ckeywhitelist = list("illotafv")

/datum/gear/donator/santaoutfit
	name = "Santa costume"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/space/santa/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/donator/treecloak
	name = "Christmas tree cloak"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/festive
	ckeywhitelist = list("illotafv")

/datum/gear/donator/carrotplush
	name = "Carrot plushie"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/donator/carrotcloak
	name = "Carrot cloak"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/donator/albortorosamask
	name = "Alborto Rosa mask"
	slot = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/luchador/zigfie
	ckeywhitelist = list("zigfie")

/datum/gear/donator/mankini
	name = "Mankini"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/misc/stripper/mankini
	ckeywhitelist = list("zigfie")

/datum/gear/donator/pinkshoes
	name = "Pink shoes"
	slot = SLOT_SHOES
	path = /obj/item/clothing/shoes/sneakers/pink
	ckeywhitelist = list("zigfie")

/datum/gear/donator/reecesgreatcoat
	name = "Reece's Great Coat"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/trenchcoat/green
	ckeywhitelist = list("geemiesif")

/datum/gear/donator/russianflask
	name = "Russian flask"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/reagent_containers/food/drinks/flask/russian
	cost = 2
	ckeywhitelist = list("slomka")

/datum/gear/donator/stalkermask
	name = "S.T.A.L.K.E.R. mask"
	slot = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/gas/stalker
	ckeywhitelist = list("slomka")

/datum/gear/donator/stripedcollar
	name = "Striped collar"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/stripe
	ckeywhitelist = list("jademanique")

/datum/gear/donator/performersoutfit
	name = "Bluish performer's outfit"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/costume/singer/yellow/custom
	ckeywhitelist = list("killer402402")

/datum/gear/donator/vermillion
	name = "Vermillion clothing"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/suit/vermillion
	ckeywhitelist = list("fractious")

/datum/gear/donator/AM4B
	name = "Foam Force AM4-B"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/gun/ballistic/automatic/AM4B
	ckeywhitelist = list("zeronetalpha")

/datum/gear/donator/carrotsatchel
	name = "Carrot Satchel"
	slot = SLOT_HANDS
	path = /obj/item/storage/backpack/satchel/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/donator/naomisweater
	name = "worn black sweater"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/sweater/black/naomi
	ckeywhitelist = list("technicalmagi")

/datum/gear/donator/naomicollar
	name = "worn pet collar"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/naomi
	ckeywhitelist = list("technicalmagi")

/datum/gear/donator/gladiator
	name = "Gladiator Armor"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/under/costume/gladiator
	ckeywhitelist = list("aroche")

/datum/gear/donator/bloodredtie
	name = "Blood Red Tie"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/tie/bloodred
	ckeywhitelist = list("kyutness")

/datum/gear/donator/puffydress
	name = "Puffy Dress"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/puffydress
	ckeywhitelist = list("stallingratt")

/datum/gear/donator/labredblack
	name = "Black and Red Coat"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/toggle/labcoat/labredblack
	ckeywhitelist = list("blakeryan", "durandalphor")

/datum/gear/donator/torisword
	name = "Rainbow Zweihander"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/dualsaber/hypereutactic/toy/rainbow
	ckeywhitelist = list("annoymous35")

/datum/gear/donator/darksabre
	name = "Dark Sabre"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/darksabre
	ckeywhitelist = list("inferno707")

/datum/gear/donator/darksabresheath
	name = "Dark Sabre Sheath"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/storage/belt/sabre/darksabre
	ckeywhitelist = list("inferno707")

/datum/gear/donator/toriball
	name = "Rainbow Tennis Ball"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/fluff/tennis_poly/tri/squeak/rainbow
	ckeywhitelist = list("annoymous35")

/datum/gear/donator/izzyball
	name = "Katlin's Ball"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/fluff/tennis_poly/tri/squeak/izzy
	ckeywhitelist = list("izzyinbox")

/datum/gear/donator/cloak
	name = "Green Cloak"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/green
	ckeywhitelist = list("killer402402")

/datum/gear/donator/steelflask
	name = "Steel Flask"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/reagent_containers/food/drinks/flask/steel
	cost = 2
	ckeywhitelist = list("nik707")

/datum/gear/donator/paperhat
	name = "Paper Hat"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/paperhat
	ckeywhitelist = list("kered2")

/datum/gear/donator/cloakce
	name = "Polychromic CE Cloak"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/neck/cloak/polychromic/polyce
	ckeywhitelist = list("worksbythesea", "blakeryan")
	loadout_flags = LOADOUT_CAN_COLOR_POLYCHROMIC
	loadout_initial_colors = list("#808080", "#8CC6FF", "#FF3535")

/datum/gear/donator/ssk
	name = "Stun Sword Kit"
	slot = SLOT_IN_BACKPACK
	path = 	/obj/item/ssword_kit
	ckeywhitelist = list("phillip458")

/datum/gear/donator/techcoat
	name = "Techomancers Labcoat"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/suit/toggle/labcoat/mad/techcoat
	ckeywhitelist = list("wilchen")

/datum/gear/donator/leechjar
	name = "Jar of Leeches"
	slot = SLOT_IN_BACKPACK
	path = 	/obj/item/custom/leechjar
	ckeywhitelist = list("sgtryder")

/datum/gear/donator/darkarmor
	name = "Dark Armor"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/suit/armor/vest/darkcarapace
	ckeywhitelist = list("inferno707")

/datum/gear/donator/devilwings
	name = "Strange Wings"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/devilwings
	ckeywhitelist = list("kitsun")

/datum/gear/donator/flagcape
	name = "US Flag Cape"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/neck/flagcape
	ckeywhitelist = list("darnchacha")

/datum/gear/donator/luckyjack
	name = "Lucky Jackboots"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/shoes/lucky
	ckeywhitelist = list("donaldtrumpthecommunist")

/datum/gear/donator/raiqbawks
	name = "Miami Boombox"
	slot = SLOT_HANDS
	cost = 2
	path = /obj/item/boombox/raiq
	ckeywhitelist = list("chefferz")

/datum/gear/donator/m41
	name = "Toy M41"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/gun/m41
	ckeywhitelist = list("thalverscholen")

/datum/gear/donator/Divine_robes
	name = "Divine robes"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/custom/lunasune
	ckeywhitelist = list("invader4352")

/datum/gear/donator/gothcoat
	name = "Goth Coat"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/gothcoat
	ckeywhitelist = list("norko")

/datum/gear/donator/corgisuit
	name = "Corgi Suit"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/ian_costume
	ckeywhitelist = list("cathodetherobot")

/datum/gear/donator/sharkcloth
	name = "Leon's Skimpy Outfit"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/under/custom/leoskimpy
	ckeywhitelist = list("spectrosis")

/datum/gear/donator/mimemask
	name = "Mime Mask"
	slot = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/gas/mime
	ckeywhitelist = list("pireamaineach")

/datum/gear/donator/mimeoveralls
	name = "Mime's Overalls"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/under/custom/mimeoveralls
	ckeywhitelist = list("pireamaineach")

/datum/gear/donator/soulneck
	name = "Soul Necklace"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/undertale
	ckeywhitelist = list("twilightic")

/datum/gear/donator/frenchberet
	name = "French Beret"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/frenchberet
	ckeywhitelist = list("notazoltan")

/datum/gear/donator/zuliecloak
	name = "Project: Zul-E"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/cloak/zuliecloak
	ckeywhitelist = list("asky")

/datum/gear/donator/blackredgold
	name = "Black, Red, and Gold Coat"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/blackredgold
	ckeywhitelist = list("ttbnc")

/datum/gear/donator/fritzplush
	name = "Fritz Plushie"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/mammal/dog/fritz
	ckeywhitelist = list("analwerewolf")

/datum/gear/donator/kimono
	name = "Kimono"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/kimono
	ckeywhitelist = list("sfox63")

/datum/gear/donator/commjacket
	name = "Dusty Commisar's Cloak"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/commjacket
	ckeywhitelist = list("sadisticbatter")

/datum/gear/donator/mw2_russian_para
	name = "Russian Paratrooper Jumper"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/custom/mw2_russian_para
	ckeywhitelist = list("investigator77")

/datum/gear/donator/longblackgloves
	name = "Luna's Gauntlets"
	slot = SLOT_GLOVES
	path = /obj/item/clothing/gloves/longblackgloves
	ckeywhitelist = list("bigmanclancy")

/datum/gear/donator/trendy_fit
	name = "Trendy Fit"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/custom/trendy_fit
	ckeywhitelist = list("midgetdragon")

/datum/gear/donator/singery
	name = "Yellow Performer Outfit"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/costume/singer/yellow
	ckeywhitelist = list("maxlynchy")

/datum/gear/donator/csheet
	name = "NT Bedsheet"
	slot = SLOT_NECK
	path = /obj/item/bedsheet/captain
	ckeywhitelist = list("tikibomb")

/datum/gear/donator/borgplush
	name = "Robot Plush"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/borgplushie
	ckeywhitelist = list("nicholaiavenicci")

/datum/gear/donator/donorberet
	name = "Atmos Beret"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/blueberet
	ckeywhitelist = list("foxystalin")

/datum/gear/donator/donorgoggles
	name = "Flight Goggles"
	slot = SLOT_HEAD
	path = /obj/item/clothing/head/flight
	ckeywhitelist = list("maxlynchy")

/datum/gear/donator/onionneck
	name = "Onion Necklace"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/necklace/onion
	ckeywhitelist = list("cdrcross")

/datum/gear/donator/mikubikini
	name = "starlight singer bikini"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/custom/mikubikini
	ckeywhitelist = list("grandvegeta")

/datum/gear/donator/mikujacket
	name = "starlight singer jacket"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/mikujacket
	ckeywhitelist = list("grandvegeta")

/datum/gear/donator/mikuhair
	name = "starlight singer hair"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/head/mikuhair
	ckeywhitelist = list("grandvegeta")

/datum/gear/donator/mikugloves
	name = "starlight singer gloves"
	slot = SLOT_GLOVES
	path = /obj/item/clothing/gloves/mikugloves
	ckeywhitelist = list("grandvegeta")

/datum/gear/donator/mikuleggings
	name = "starlight singer leggings"
	slot = SLOT_SHOES
	path = /obj/item/clothing/shoes/sneakers/mikuleggings
	ckeywhitelist = list("grandvegeta")

/datum/gear/donator/cosmos
	name = "cosmic space bedsheet"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/bedsheet/cosmos
	ckeywhitelist = list("grunnyyy")

/datum/gear/donator/customskirt
	name = "custom atmos skirt"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/under/custom/customskirt
	ckeywhitelist = list("thakyz")

/datum/gear/donator/hisakaki
	name = "halo"
	slot = SLOT_HEAD
	path = 	/obj/item/clothing/head/halo
	ckeywhitelist = list("hisakaki")

/datum/gear/donator/vest
	name = "vest and shirt"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/custom/vest
	ckeywhitelist = list("maylowfox")

/datum/gear/donator/exo
	name = "exo frame"
	slot = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/custom/exo
	ckeywhitelist = list("jesterz7")

/datum/gear/donator/choker
	name = "NT Choker"
	slot = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/donorchoker
	ckeywhitelist = list("trigillass")

/datum/gear/donator/strangemask
	name = "Strange Metal Mask"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/clothing/mask/breath/mmask
	ckeywhitelist = list("sneka")

/datum/gear/donator/smaiden
	name = "shrine maiden outfit"
	slot = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/smaiden
	ckeywhitelist = list("ultimarifox")

/datum/gear/donator/donksoftgun
	name = "Totally a Real Gun"
	slot = SLOT_IN_BACKPACK
	path = /obj/item/gun/ballistic/automatic/toy/pistol/custom
	ckeywhitelist = list("azeric")
