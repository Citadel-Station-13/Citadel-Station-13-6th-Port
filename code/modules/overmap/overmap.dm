/**
  * Overmap datums
  */
/datum/overmap
	/// Width
	var/width = 512
	/// Height
	var/height = 512

	/// Wraparound
	var/wraparound = TRUE

	/// All objects on this
	var/list/datum/overmap_object/objects

	/// Head of our quadtree structure
	var/datum/overmap_quadtree/tree_head

/datum/overmap/New()
	objects = list()
	regenerate_tree()

/datum/overmap/proc/regenerate_tree()
	qdel(tree_head)
	tree_head = new(null, 0, 0, width, height)
	for(var/i in objects)
		var/datum/overmap_object/O = i
		tree_head.insert(O)

/datum/overmap/proc/insert_object(datum/overmap_object/O)
	return tree_head.insert(O)
