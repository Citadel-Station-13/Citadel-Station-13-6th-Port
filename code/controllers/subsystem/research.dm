
SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 10
	init_order = INIT_ORDER_RESEARCH
	//TECHWEB STATIC
	var/list/techweb_nodes = list() //associative id = node datum
	var/list/techweb_designs = list() //associative id = node datum
	var/list/datum/techweb/techwebs = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/datum/techweb_node/error_node/error_node //These two are what you get if a node/design is deleted and somehow still stored in a console.
	var/datum/design/error_design/error_design

	//ERROR LOGGING
	var/list/invalid_design_ids = list() //associative id = number of times
	var/list/invalid_node_ids = list() //associative id = number of times
	var/list/invalid_node_boost = list() //associative id = error message

	var/list/obj/machinery/rnd/server/servers = list()

	var/list/techweb_nodes_starting = list() //associative id = TRUE
	var/list/techweb_categories = list() //category name = list(node.id = TRUE)
	var/list/techweb_boost_items = list() //associative double-layer path = list(id = list(point_type = point_discount))
	var/list/techweb_nodes_hidden = list() //Node ids that should be hidden by default.
	var/list/techweb_nodes_experimental = list() //Node ids that are exclusive to the BEPIS.
	var/list/techweb_point_items = list( //path = list(point type = value)
	/obj/item/assembly/signaler/anomaly            = list(TECHWEB_POINT_TYPE_GENERIC = 10000),
	//   -   Slime Extracts!   - Basics
	/obj/item/slime_extract/grey                   = list(TECHWEB_POINT_TYPE_GENERIC = 500),
	/obj/item/slime_extract/metal                  = list(TECHWEB_POINT_TYPE_GENERIC = 750),
	/obj/item/slime_extract/purple                 = list(TECHWEB_POINT_TYPE_GENERIC = 750),
	/obj/item/slime_extract/orange                 = list(TECHWEB_POINT_TYPE_GENERIC = 750),
	/obj/item/slime_extract/blue                   = list(TECHWEB_POINT_TYPE_GENERIC = 750),
	/obj/item/slime_extract/yellow                 = list(TECHWEB_POINT_TYPE_GENERIC = 1000),
	/obj/item/slime_extract/silver                 = list(TECHWEB_POINT_TYPE_GENERIC = 1000),
	/obj/item/slime_extract/darkblue               = list(TECHWEB_POINT_TYPE_GENERIC = 1000),
	/obj/item/slime_extract/darkpurple             = list(TECHWEB_POINT_TYPE_GENERIC = 1000),
	/obj/item/slime_extract/bluespace              = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/sepia                  = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/cerulean               = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/pyrite                 = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/red                    = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/green                  = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/pink                   = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/gold                   = list(TECHWEB_POINT_TYPE_GENERIC = 1250),
	/obj/item/slime_extract/black                  = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slime_extract/adamantine             = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slime_extract/oil                    = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slime_extract/lightpink              = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slime_extract/rainbow                = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
		//  Reproductive -    Crossbreading Cores!    - (Grey Cores)
	/obj/item/slimecross/reproductive/grey         = list(TECHWEB_POINT_TYPE_GENERIC = 1000),
	/obj/item/slimecross/reproductive/orange       = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slimecross/reproductive/purple       = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slimecross/reproductive/blue         = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slimecross/reproductive/metal        = list(TECHWEB_POINT_TYPE_GENERIC = 1500),
	/obj/item/slimecross/reproductive/yellow       = list(TECHWEB_POINT_TYPE_GENERIC = 1750),
	/obj/item/slimecross/reproductive/darkpurple   = list(TECHWEB_POINT_TYPE_GENERIC = 1750),
	/obj/item/slimecross/reproductive/darkblue     = list(TECHWEB_POINT_TYPE_GENERIC = 1750),
	/obj/item/slimecross/reproductive/silver       = list(TECHWEB_POINT_TYPE_GENERIC = 1750),
	/obj/item/slimecross/reproductive/bluespace    = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/reproductive/sepia        = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/reproductive/cerulean     = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/reproductive/pyrite       = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/reproductive/red          = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/reproductive/green        = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/reproductive/pink         = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/reproductive/gold         = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/reproductive/oil          = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/reproductive/black        = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/reproductive/lightpink    = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/reproductive/adamantine   = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/reproductive/rainbow      = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	//  Burning -    Crossbreading Cores!    - (Orange Cores)
	/obj/item/slimecross/burning/grey              = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/burning/orange            = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/burning/purple            = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/burning/blue              = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/burning/metal             = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/burning/yellow            = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/burning/darkpurple        = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/burning/darkblue          = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/burning/silver            = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/burning/bluespace         = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/burning/sepia             = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/burning/cerulean          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/burning/pyrite            = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/burning/red               = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/burning/green             = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/burning/pink              = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/burning/gold              = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/burning/oil               = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/burning/black             = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/burning/lightpink         = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/burning/adamantine        = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/burning/rainbow           = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
		//  Regenerative -    Crossbreading Cores!    - (Purple Cores)
	/obj/item/slimecross/regenerative/grey         = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/regenerative/orange       = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/regenerative/purple       = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/regenerative/blue         = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/regenerative/metal        = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/regenerative/yellow       = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/regenerative/darkpurple   = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/regenerative/darkblue     = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/regenerative/silver       = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/regenerative/bluespace    = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/regenerative/sepia        = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/regenerative/cerulean     = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/regenerative/pyrite       = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/regenerative/red          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/regenerative/green        = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/regenerative/pink         = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/regenerative/gold         = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/regenerative/oil          = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/regenerative/black        = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/regenerative/lightpink    = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/regenerative/adamantine   = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/regenerative/rainbow      = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
		//  Stabilized -    Crossbreading Cores!    - (Blue Cores)
	/obj/item/slimecross/stabilized/grey           = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/stabilized/orange         = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/stabilized/purple         = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/stabilized/blue           = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/stabilized/metal          = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/stabilized/yellow         = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/stabilized/darkpurple     = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/stabilized/darkblue       = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/stabilized/silver         = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/stabilized/bluespace      = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/stabilized/sepia          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/stabilized/cerulean       = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/stabilized/pyrite         = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/stabilized/red            = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/stabilized/green          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/stabilized/pink           = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/stabilized/gold           = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/stabilized/oil            = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/stabilized/black          = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/stabilized/lightpink      = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/stabilized/adamantine     = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/stabilized/rainbow        = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
		//  Industrial -    Crossbreading Cores!    - (Metal Cores)
	/obj/item/slimecross/industrial/grey           = list(TECHWEB_POINT_TYPE_GENERIC = 2000),
	/obj/item/slimecross/industrial/orange         = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/industrial/purple         = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/industrial/blue           = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/industrial/metal          = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/industrial/yellow         = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/industrial/darkpurple     = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/industrial/darkblue       = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/industrial/silver         = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/industrial/bluespace      = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/industrial/sepia          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/industrial/cerulean       = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/industrial/pyrite         = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/industrial/red            = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/industrial/green          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/industrial/pink           = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/industrial/gold           = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/industrial/oil            = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/industrial/black          = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/industrial/lightpink      = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/industrial/adamantine     = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/industrial/rainbow        = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
		//  Charged -    Crossbreading Cores!    - (Yellow Cores)
	/obj/item/slimecross/charged/grey              = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/charged/orange            = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/charged/purple            = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/charged/blue              = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/charged/metal             = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/charged/yellow            = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/charged/darkpurple        = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/charged/darkblue          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/charged/silver            = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/charged/bluespace         = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/charged/sepia             = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/charged/cerulean          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/charged/pyrite            = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/charged/red               = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/charged/green             = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/charged/pink              = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/charged/gold              = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/charged/oil               = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/charged/black             = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/charged/lightpink         = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/charged/adamantine        = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/charged/rainbow           = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
			//  Selfsustaining -    Crossbreading Cores!    - (Dark Purple Cores)
	/obj/item/slimecross/selfsustaining/grey       = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/selfsustaining/orange     = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/selfsustaining/purple     = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/selfsustaining/blue       = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/selfsustaining/metal      = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/selfsustaining/yellow     = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/selfsustaining/darkpurple = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/selfsustaining/darkblue   = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/selfsustaining/silver     = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/selfsustaining/bluespace  = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/selfsustaining/sepia      = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/selfsustaining/cerulean   = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/selfsustaining/pyrite     = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/selfsustaining/red        = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/selfsustaining/green      = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/selfsustaining/pink       = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/selfsustaining/gold       = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/selfsustaining/oil        = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/selfsustaining/black      = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/selfsustaining/lightpink  = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/selfsustaining/adamantine = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/selfsustaining/rainbow    = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
			//  Consuming -    Crossbreading Cores!    - (Sliver Cores)
	/obj/item/slimecross/consuming/grey            = list(TECHWEB_POINT_TYPE_GENERIC = 2250),
	/obj/item/slimecross/consuming/orange          = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/consuming/purple          = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/consuming/blue            = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/consuming/metal           = list(TECHWEB_POINT_TYPE_GENERIC = 2750),
	/obj/item/slimecross/consuming/yellow          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/consuming/darkpurple      = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/consuming/darkblue        = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/consuming/silver          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/consuming/bluespace       = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/consuming/sepia           = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/consuming/cerulean        = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/consuming/pyrite          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/consuming/red             = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/consuming/green           = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/consuming/pink            = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/consuming/gold            = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/consuming/oil             = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/consuming/black           = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/consuming/lightpink       = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/consuming/adamantine      = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/consuming/rainbow         = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
		//  Prismatic -    Crossbreading Cores!    - (Pyrite Cores)
	/obj/item/slimecross/prismatic/grey            = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/prismatic/orange          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/prismatic/purple          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/prismatic/blue            = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/prismatic/metal           = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/prismatic/yellow          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/prismatic/darkpurple      = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/prismatic/darkblue        = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/prismatic/silver          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/prismatic/bluespace       = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/prismatic/sepia           = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/prismatic/cerulean        = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/prismatic/pyrite          = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/prismatic/red             = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/prismatic/green           = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/prismatic/pink            = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/prismatic/gold            = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/prismatic/oil             = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/prismatic/black           = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/prismatic/lightpink       = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/prismatic/adamantine      = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/prismatic/rainbow         = list(TECHWEB_POINT_TYPE_GENERIC = 4250),
		//  Recurring -    Crossbreading Cores!    - (Cerulean Cores)
	/obj/item/slimecross/recurring/grey            = list(TECHWEB_POINT_TYPE_GENERIC = 2500),
	/obj/item/slimecross/recurring/orange          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/recurring/purple          = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/recurring/blue            = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/recurring/metal           = list(TECHWEB_POINT_TYPE_GENERIC = 3000),
	/obj/item/slimecross/recurring/yellow          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/recurring/darkpurple      = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/recurring/darkblue        = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/recurring/silver          = list(TECHWEB_POINT_TYPE_GENERIC = 3250),
	/obj/item/slimecross/recurring/bluespace       = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/recurring/sepia           = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/recurring/cerulean        = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/recurring/pyrite          = list(TECHWEB_POINT_TYPE_GENERIC = 3500),
	/obj/item/slimecross/recurring/red             = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/recurring/green           = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/recurring/pink            = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/recurring/gold            = list(TECHWEB_POINT_TYPE_GENERIC = 3750),
	/obj/item/slimecross/recurring/oil             = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/recurring/black           = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/recurring/lightpink       = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/recurring/adamantine      = list(TECHWEB_POINT_TYPE_GENERIC = 4000),
	/obj/item/slimecross/recurring/rainbow         = list(TECHWEB_POINT_TYPE_GENERIC = 4250)
	)
	var/list/errored_datums = list()
	var/list/point_types = list() //typecache style type = TRUE list
	//----------------------------------------------
	var/list/single_server_income = list(TECHWEB_POINT_TYPE_GENERIC = 35)
	var/multiserver_calculation = FALSE
	var/last_income
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

	/// The global list of raw anomaly types that have been refined, for hard limits.
	var/list/created_anomaly_types = list()
	/// The hard limits of cores created for each anomaly type. For faster code lookup without switch statements.
	var/list/anomaly_hard_limit_by_type = list(
	ANOMALY_CORE_BLUESPACE = MAX_CORES_BLUESPACE,
	ANOMALY_CORE_PYRO = MAX_CORES_PYRO,
	ANOMALY_CORE_GRAVITATIONAL = MAX_CORES_GRAVITATIONAL,
	ANOMALY_CORE_VORTEX = MAX_CORES_VORTEX,
	ANOMALY_CORE_FLUX = MAX_CORES_FLUX
	)

/datum/controller/subsystem/research/Initialize()
	point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	error_design = new
	error_node = new

	for(var/A in subtypesof(/obj/item/seeds))
		var/obj/item/seeds/S = A
		var/list/L = list()
		//First we get are yield and rarity and times it by two
		//Then we subtract production and maturation, making it so faster growing plants are better for RnD
		//Then we add in lifespan and potency,
		//A basic seed can be worth 268 points if its the best it can be.
		L[TECHWEB_POINT_TYPE_GENERIC] = 50 + initial(S.rarity) * 2 + initial(S.yield) * 2 - initial(S.maturation) - initial(S.production) + initial(S.lifespan) + initial(S.potency)
		techweb_point_items[S] = L

	return ..()

/datum/controller/subsystem/research/fire()
	var/list/bitcoins = list()
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			var/list/result = (miner.mine())	//SLAVE AWAY, SLAVE.
			for(var/i in result)
				result[i] *= eff
				bitcoins[i] = bitcoins[i]? bitcoins[i] + result[i] : result[i]
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break			//Just need one to work.
	if (!isnull(last_income))
		var/income_time_difference = world.time - last_income
		science_tech.last_bitcoins = bitcoins  // Doesn't take tick drift into account
		for(var/i in bitcoins)
			bitcoins[i] *= income_time_difference / 10
		science_tech.add_point_list(bitcoins)
	last_income = world.time

/datum/controller/subsystem/research/proc/calculate_server_coefficient() //Diminishing returns.
	var/amt = servers.len
	if(!amt)
		return 0
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = TRUE
		else
			techweb_categories[I.category] = list(I.id = TRUE)

/datum/controller/subsystem/research/proc/techweb_node_by_id(id)
	return techweb_nodes[id] || error_node

/datum/controller/subsystem/research/proc/techweb_design_by_id(id)
	return techweb_designs[id] || error_design

/datum/controller/subsystem/research/proc/on_design_deletion(datum/design/D)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN = techwebs[i]
		TN.on_design_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/on_node_deletion(datum/techweb_node/TN)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN2 = techwebs[i]
		TN2.on_node_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(techweb_nodes) && clearall)
		QDEL_LIST(techweb_nodes)
	if(islist(techweb_nodes_starting && clearall))
		techweb_nodes_starting.Cut()
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected! Path: [path]")
			errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_nodes_starting[TN.id] = TRUE
	for(var/id in techweb_nodes)
		var/datum/techweb_node/TN = techweb_nodes[id]
		TN.Initialize()
	techweb_nodes = returned
	if (!verify_techweb_nodes()) //Verify all nodes have ids and such.
		stack_trace("Invalid techweb nodes detected")
	calculate_techweb_nodes()
	calculate_techweb_boost_list()
	if (!verify_techweb_nodes()) //Verify nodes and designs have been crosslinked properly.
		CRASH("Invalid techweb nodes detected")

/datum/controller/subsystem/research/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(techweb_designs) && clearall)
		QDEL_LIST(techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			stack_trace("WARNING: Design with null ID detected. Build path: [initial(DN.build_path)]")
			continue
		else if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(returned[initial(DN.id)])
			stack_trace("WARNING: Design ID clash with ID [initial(DN.id)] detected! Path: [path]")
			errored_datums[DN] = initial(DN.id)
			continue
		DN.InitializeMaterials() //Initialize the materials in the design
		returned[initial(DN.id)] = DN
	techweb_designs = returned
	verify_techweb_designs()


/datum/controller/subsystem/research/proc/verify_techweb_nodes()
	. = TRUE
	for(var/n in techweb_nodes)
		var/datum/techweb_node/N = techweb_nodes[n]
		if(!istype(N))
			WARNING("Invalid research node with ID [n] detected and removed.")
			techweb_nodes -= n
			research_node_id_error(n)
			. = FALSE
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = techweb_nodes[p]
			if(!istype(P))
				WARNING("Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
				. = FALSE
		for(var/d in N.design_ids)
			var/datum/design/D = techweb_designs[d]
			if(!istype(D))
				WARNING("Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.design_ids -= d
				design_id_error(d)
				. = FALSE
		for(var/u in N.unlock_ids)
			var/datum/techweb_node/U = techweb_nodes[u]
			if(!istype(U))
				WARNING("Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlock_ids -= u
				research_node_id_error(u)
				. = FALSE
		for(var/p in N.boost_item_paths)
			if(!ispath(p))
				N.boost_item_paths -= p
				WARNING("[p] is not a valid path.")
				node_boost_error(N.id, "[p] is not a valid path.")
				. = FALSE
			var/list/points = N.boost_item_paths[p]
			if(islist(points))
				for(var/i in points)
					if(!isnum(points[i]))
						WARNING("[points[i]] is not a valid number.")
						node_boost_error(N.id, "[points[i]] is not a valid number.")
						. = FALSE
					else if(!point_types[i])
						WARNING("[i] is not a valid point type.")
						node_boost_error(N.id, "[i] is not a valid point type.")
						. = FALSE
			else if(!isnull(points))
				N.boost_item_paths -= p
				node_boost_error(N.id, "No valid list.")
				WARNING("No valid list.")
				. = FALSE
		CHECK_TICK

/datum/controller/subsystem/research/proc/verify_techweb_designs()
	for(var/d in techweb_designs)
		var/datum/design/D = techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			techweb_designs -= d
		CHECK_TICK

/datum/controller/subsystem/research/proc/research_node_id_error(id)
	if(invalid_node_ids[id])
		invalid_node_ids[id]++
	else
		invalid_node_ids[id] = 1

/datum/controller/subsystem/research/proc/design_id_error(id)
	if(invalid_design_ids[id])
		invalid_design_ids[id]++
	else
		invalid_design_ids[id] = 1

/datum/controller/subsystem/research/proc/calculate_techweb_nodes()
	for(var/design_id in techweb_designs)
		var/datum/design/D = techweb_designs[design_id]
		D.unlocked_by.Cut()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
		for(var/i in node.design_ids)
			var/datum/design/D = techweb_designs[i]
			node.design_ids[i] = TRUE
			D.unlocked_by += node.id
		if(node.hidden)
			techweb_nodes_hidden[node.id] = TRUE
		if(node.experimental)
			techweb_nodes_experimental[node.id] = TRUE
		CHECK_TICK
	generate_techweb_unlock_linking()

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in techweb_nodes) //Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq_node = techweb_node_by_id(prereq_id)
			prereq_node.unlock_ids[node.id] = node

/datum/controller/subsystem/research/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		techweb_boost_items = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(techweb_boost_items[path]))
				techweb_boost_items[path][node.id] = node.boost_item_paths[path]
			else
				techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK
