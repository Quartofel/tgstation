/obj/machinery/mineral/deep_drill
	name = "heavy-duty mining rig"
	desc = "Piece of heavy machinery designed to extract materials from the underground deposits."
	icon = 'icons/mecha/mech_fab.dmi'
	icon_state = "deep_drill-off"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/deep_drill
	layer = BELOW_OBJ_LAYER
<<<<<<< HEAD
	var/bluespace_upgrade = FALSE //Can it link with Ore Silo?
	var/on = FALSE
	var/energy_coeff //How good at not discharging
	var/efficiency_coeff //How good at mining
	var/power_draw = 0
=======
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
>>>>>>> parent of d52e79a602... Revert "zepsułem"
	var/datum/component/remote_materials/materials
	var/obj/item/stock_parts/cell/cell

	var/hacked = FALSE
	var/disabled = 0
	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire

/obj/machinery/mineral/deep_drill/Initialize(mapload)
	. = ..()
<<<<<<< HEAD
	wires = new /datum/wires/mineral/deep_drill(src)
=======
	cell = new(src)
>>>>>>> parent of d52e79a602... Revert "zepsułem"
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)
	component_parts = list(new /obj/item/circuitboard/machine/deep_drill,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/capacitor,
		new /obj/item/stock_parts/cell,
		new /obj/item/pickaxe/drill)
	RefreshParts()

/obj/machinery/mineral/deep_drill/on_construction()
	panel_open = FALSE
	//update_icon()
	return ..()

/obj/machinery/mineral/deep_drill/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/mineral/deep_drill/Destroy()
<<<<<<< HEAD
	QDEL_NULL(wires)
	drill_eject_mats()
	materials = null
	return ..()

/obj/machinery/mineral/deep_drill/RefreshParts() //Stock Part Effects
	efficiency_coeff = 0.8
	energy_coeff = 1.1
	for(var/obj/item/pickaxe/drill/diamonddrill/DD in component_parts)
		efficiency_coeff = 1.1
		energy_coeff = 1.5
=======
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
>>>>>>> parent of d52e79a602... Revert "zepsułem"
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 50000
		materials.set_local_size(total_storage)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency_coeff += M.rating * 0.1
<<<<<<< HEAD
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		energy_coeff -= C.rating * 0.1
=======

>>>>>>> parent of d52e79a602... Revert "zepsułem"

	power_draw = efficiency_coeff * 10 * energy_coeff //This defines how much power draw_power() should draw

//INTERACTIONS//////////////////////

/obj/machinery/mineral/deep_drill/examine(mob/user) //:eyes:
	. = ..()
	if(bluespace_upgrade)
		if(!materials?.silo)
			. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
		else if(materials?.on_hold())
			. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"
		else
			. += "<span class='notice'>It's connected to the ore silo.</span>"
	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
		. += "Current power draw: [cell ? round(power_draw, 1) : 0]W."
	else
		. += "It appears to be unpowered."

/obj/machinery/mineral/deep_drill/interact(mob/user)
<<<<<<< HEAD
	shock(user, 70)
	if(on && !panel_open)
		on = FALSE
		to_chat(user, "<span class='notice'>You switch the [src] off.</span>")
	else
		on = TRUE
		to_chat(user, "<span class='notice'>You switch the [src] on.</span>")
=======
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
>>>>>>> parent of d52e79a602... Revert "zepsułem"

/obj/machinery/mineral/deep_drill/AltClick(mob/user) //When alt-clicked the drill will try to drop stored mats.
	shock(user, 70)
	if(user.canUseTopic(src, !issilicon(usr)))
		drill_eject_mats()
<<<<<<< HEAD
=======
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
>>>>>>> parent of d52e79a602... Revert "zepsułem"

/obj/machinery/mineral/deep_drill/attack_hand(mob/user) //Handles interactions with empty hand
	. = ..() //code magic, references eldritch knowledge, hidden deep within the codebase - no touchey
	if(.)
		return
	if(!cell)
		return
	shock(user, 100)
	if(panel_open && cell)
		to_chat(user, "<span class='notice'>You remove the [cell] from the [src]</span>")
		user.put_in_hands(cell)
		cell.add_fingerprint(user)
		cell = null

	user.visible_message("[user] removes [cell] from [src].", "<span class='notice'>You remove [cell] from [src].</span>")

/obj/machinery/mineral/deep_drill/multitool_act(mob/living/user, obj/item/multitool/M) //Handles linking to Ore Silo if drill has Bluespace Resource Transfer Upgrade
	if(bluespace_upgrade)
		return FALSE
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/deep_drill/attackby(obj/item/I, mob/user, params) //Handles decon, power cell manipulations and upgrade module
	shock(user, 50)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()
	add_fingerprint(user)
	if(istype(I, /obj/item/stock_parts/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
				return
			else if(!user.transferItemToLoc(I, src))
				return
			cell = I
			I.add_fingerprint(usr)
			user.visible_message("<span class='notice'>\The [user] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>The maintenance hatch must be open to install the [I]!</span>")
			return

	else if(istype(I, /obj/item/disk/cargo/silo_drill))
		if(panel_open)
			if(!bluespace_upgrade)
				user.visible_message("<span class='notice'>\The [user] inserts a device into \the [src].</span>", "<span class='notice'>You insert the upgrade module into \the [src].</span>")
				user.transferItemToLoc(I, src)
				bluespace_upgrade = TRUE
		else
			to_chat(user, "<span class='warning'>The maintenance hatch must be open to install the [I]!</span>")
			return

	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on \the [src].</span>")
		//update_icon()

	else if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return TRUE

	else if(default_deconstruction_crowbar(I))
		return
	else
		return ..()

//PROCS//////////////////////

/obj/machinery/mineral/deep_drill/proc/drill_eject_mats(mob/user) //Eject mats if possible
	if(materials?.silo)
		to_chat(user, "<span class='warning'>[src] can't eject materials from the silo!</span>")
		return FALSE
	if(on && cell && cell.charge > 0)
		var/location = get_step(src,EAST)
		var/datum/component/material_container/mat_container = materials.mat_container
		mat_container.retrieve_all(location)
		to_chat(user, "<span class='notice'>You eject the materials from [src].</span>")
		return TRUE
	else
		to_chat(user, "<span class='warning'>[src] must be on to eject materials!</span>")
		return FALSE

/obj/machinery/mineral/deep_drill/proc/drill_mats(src) //Actually do the mining thing
	var/datum/component/material_container/mat_container = materials.mat_container
	var/turf/open/floor/plating/asteroid/basalt/vein/T = loc
	var/datum/material/ore = pick(T.ore_rates)
<<<<<<< HEAD
	mat_container.insert_amount_mat((T.ore_rates[ore] * 1000*efficiency_coeff), ore)
	draw_power()

obj/machinery/mineral/deep_drill/proc/draw_power() //This draws power from the cell when called
	cell.use(power_draw)

//HACKING PROCS//

/obj/machinery/mineral/deep_drill/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/mineral/deep_drill/proc/shock(mob/user, prb)
	if(!shocked && cell.charge < 100)		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		cell.use(100)
		return TRUE
	else
		return FALSE

/obj/machinery/mineral/deep_drill/proc/adjust_hacked(state)
	hacked = state
	if(hacked)
		drill_eject_mats()

//////////////////////

/obj/machinery/mineral/deep_drill/process() //Heart of this
	if(on && cell && cell.charge > 0 && !disabled)
		if(istype(get_turf(src), /turf/open/floor/plating/asteroid/basalt/vein))
			drill_mats()
		else
			power_draw = 0

//MISC STUFF//////////////////////

/obj/item/disk/cargo/silo_drill
	name = "Bluespace Resource Transfer Upgrade"
	desc = "Upgrade module for drill rigs allowing for remote transfer of the resources."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
=======
	mat_container.insert_amount_mat((ore_rates[ore] * 1000)*efficiency_coeff, ore)
	//var/datum/material/ore = pick(ore_rates)
	//mat_container.insert_amount_mat((ore_rates[ore] * 1000), ore)
>>>>>>> parent of d52e79a602... Revert "zepsułem"

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

