/obj/machinery/mineral/deep_drill
	name = "heavy-duty mining rig"
	desc = "Piece of heavy machinery designed to extract materials from the underground deposits."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/deep_drill
	layer = BELOW_OBJ_LAYER
	var/list/ore_rates_common = list(/datum/material/iron = 0.6, /datum/material/glass = 0.6, /datum/material/copper = 0.4)
	var/list/ore_rates_volatile = list(/datum/material/plasma = 0.2, /datum/material/uranium = 0.1)
	var/list/ore_rates_noble = list(/datum/material/silver = 0.2, /datum/material/gold = 0.1, /datum/material/titanium = 0.1)
	var/list/ore_rates_rare = list(/datum/material/diamond = 0.1, /datum/material/bluespace = 0.1)

/obj/machinery/mineral/deep_drill/Initialize()
	AddComponent(/datum/component/material_container, list(/datum/material/iron,
	/datum/material/glass,
	/datum/material/copper,
	/datum/material/gold,
	/datum/material/gold,
	/datum/material/silver,
	/datum/material/diamond,
	/datum/material/uranium,
	/datum/material/plasma,
	/datum/material/bluespace,
	/datum/material/titanium), 0, TRUE, null, null, CALLBACK(src, minemats()))

	component_parts = list(new /obj/item/circuitboard/machine/deep_drill,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/pickaxe/drill)
	. = ..()

/obj/machinery/mineral/deep_drill/Destroy()
	//materials.retrieve_all()
	return ..()

/obj/machinery/mineral/deep_drill/proc/minemats()
	var/datum/component/material_container/materials
	materials.max_amount = 10000
	var/debug = 1
	var/datum/material/ore
	if(istype(loc, /turf/open/floor/plating/asteroid/basalt/vein/common))
		ore = pick(ore_rates_common)
		materials.insert_amount_mat((ore_rates_common * 1000), ore)
	if(istype(loc, /turf/open/floor/plating/asteroid/basalt/vein/volatile))
		ore = pick(ore_rates_volatile)
		materials.insert_amount_mat((ore_rates_volatile * 1000), ore)
	if(istype(loc, /turf/open/floor/plating/asteroid/basalt/vein/noble))
		ore = pick(ore_rates_noble)
		materials.insert_amount_mat((ore_rates_noble * 1000), ore)
	if(istype(loc, /turf/open/floor/plating/asteroid/basalt/vein/rare))
		ore = pick(ore_rates_rare)
		materials.insert_amount_mat((ore_rates_rare * 1000), ore)
	if(debug == 1)
		ore = pick(ore_rates_common)
		materials.insert_amount_mat((ore_rates_common * 1000), ore)

/obj/machinery/mineral/deep_drill/process()
	if(anchored)
		minemats()

/obj/machinery/mineral/deep_drill/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br></b>.<span>"

/obj/machinery/mineral/deep_drill/AltClick(mob/user) //When alt-clicked the drill will drop stored mats.
	if(user.canUseTopic(src, !issilicon(usr)))
		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
		materials.retrieve_all()
		to_chat(user, "<span class='notice'>You retrieve the materials from [src].</span>")

/obj/machinery/mineral/deep_drill/on_deconstruction() //When Deconstructed, drill will drop stored mats.
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/item/disk/cargo/silo_drill
	name = "Ore Silo Link Upgrade"
	desc = "Upgrade module for drill rigs allowing for remote transfer of the resources."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
	/*
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * 1000), ore)
	*/
