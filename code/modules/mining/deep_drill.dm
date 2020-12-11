/*
/obj/machinery/mineral/deep_drill
	name = "heavy-duty mining rig"
	desc = "Piece of heavy machinery designed to extract materials from the underground deposits."
	icon = 'icons/mecha/mech_fab.dmi'
	icon_state = "deep_drill-off"
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
*/
/obj/machinery/mineral/deep_drill
	name = "heavy-duty mining rig"
	desc = "Piece of heavy machinery designed to extract materials from the underground deposits."
	icon = 'icons/mecha/mech_fab.dmi'
	icon_state = "deep_drill-off"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/deep_drill
	layer = BELOW_OBJ_LAYER
	var/bluespace_upgrade = FALSE

	var/efficiency_coeff
	var/on = FALSE
	var/obj/item/stock_parts/cell/cell
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/deep_drill/Initialize(mapload)
	. = ..()
	cell = new(src)
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)
	component_parts = list(new /obj/item/circuitboard/machine/deep_drill,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/pickaxe/drill)
	RefreshParts()

/obj/machinery/mineral/deep_drill/Destroy()
	materials = null
	return ..()

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/mineral/deep_drill/on_construction()
	qdel(cell)
	cell = null
	panel_open = FALSE
	return ..()

/obj/machinery/mineral/deep_drill/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	mat_container.retrieve_all()
	return ..()

/obj/machinery/mineral/deep_drill/update_icon()
	if(on)
		icon_state = "deep_drill-on"
	else
		icon_state = "deep_drill-off"
	if(panel_open)
		icon_state = "deep_drill-open"

/obj/machinery/mineral/deep_drill/RefreshParts()
	efficiency_coeff = 1
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 50000
		materials.set_local_size(total_storage)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency_coeff += M.rating * 0.1


/obj/machinery/mineral/deep_drill/multitool_act(mob/living/user, obj/item/multitool/M)
	if(bluespace_upgrade)
		return FALSE
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/deep_drill/examine(mob/user)
	. = ..()
	if(bluespace_upgrade)
		if(!materials?.silo)
			. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
		else if(materials?.on_hold())
			. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"
		else
			. += "<span class='notice'>It's connected to the ore silo.</span>"

/obj/machinery/mineral/deep_drill/interact(mob/user)
	if(!drill_eject_mats())
		to_chat(user, "<span class='warning'>[src] can't eject materials from the silo!</span>")

/obj/machinery/mineral/deep_drill/proc/drill_eject_mats(mob/user)
	if(materials?.silo)
		return FALSE
	var/datum/component/material_container/mat_container = materials.mat_container
	var/location = get_step(src,EAST)
	var/turf/outlet = get_step(src,EAST)
	if(outlet.density)
		say("Error! Drill outlet is obstructed.")
		return FALSE
	else
		to_chat(user, "<span class='notice'>You retrieve the materials from [src].</span>")
		mat_container.retrieve_all(location)
		flick("deep_drill-eject")
		return TRUE

/obj/machinery/mineral/deep_drill/AltClick(mob/user) //When alt-clicked the drill will drop stored mats.
	if(user.canUseTopic(src, !issilicon(usr)))
		drill_eject_mats()
/*
/obj/machinery/mineral/deep_drill/attackby(obj/item/I, mob/user, params)
	if(panel_open)
		if(istype(I, /obj/item/stock_parts/cell))
			if(cell)
				to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
				return
			else if(!user.transferItemToLoc(I, src))
				return
			cell = I
			I.add_fingerprint(usr)
			user.visible_message("<span class='notice'>\The [user] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")
		if(istype(I, /obj/item/disk/cargo/silo_drill) && bluespace_upgrade)
		to_chat(user, "<span class='notice'>You install the upgrade module into \the [src].</span>")
		user.transferItemToLoc(I, src)
		bluespace_upgrade = TRUE
	else
		to_chat(user, "<span class='warning'>The maintenance hatch must be open first!</span>")
		return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on \the [src].</span>")
		update_icon()
	else if(default_deconstruction_crowbar(I))
		return
	else
		return ..()
*/

/obj/machinery/mineral/deep_drill/process()
	//if(!materials?.silo || materials?.on_hold())
	//	return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return

	//here be runtime
	var/turf/open/floor/plating/asteroid/basalt/vein/T = loc
	var/datum/material/ore = pick(T.ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * 1000)*efficiency_coeff, ore)
	//var/datum/material/ore = pick(ore_rates)
	//mat_container.insert_amount_mat((ore_rates[ore] * 1000), ore)

/obj/item/disk/cargo/silo_drill
	name = "Ore Silo Link Upgrade"
	desc = "Upgrade module for drill rigs allowing for remote transfer of the resources."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL

/*
Roadmap:
-Produkcja materiałów zależnie od turfa RUNTIME/DONE
-Stock parts PARTIALLY DONE
-Lokalne materiały i możliwość linkowania po upgrade PARTIALLY DONE
-Techweb DONE
-Drop pod z wiertłem
-generowanie mining points
-random gen veinów
-dźwięk wiertła
-sprite states wiertła
-wypadanie materiałów obok wiertła DONE
-BS Miner goes yeet (inny PR?)
-zużycie baterii
*/

