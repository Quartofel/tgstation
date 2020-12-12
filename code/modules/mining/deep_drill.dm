/obj/machinery/mineral/deep_drill
	name = "heavy-duty mining rig"
	desc = "Piece of heavy machinery designed to extract materials from the underground deposits."
	icon = 'icons/mecha/mech_fab.dmi'
	icon_state = "deep_drill-off"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/deep_drill
	layer = BELOW_OBJ_LAYER
	var/bluespace_upgrade = FALSE //Can it link with Ore Silo?
	var/on = FALSE
	var/energy_coeff //How good at not discharging
	var/efficiency_coeff //How good at mining
	var/power_draw = 0
	var/datum/component/remote_materials/materials
	var/obj/item/stock_parts/cell/cell

/obj/machinery/mineral/deep_drill/Initialize(mapload)
	. = ..()
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

/obj/machinery/space_heater/on_construction()
	qdel(cell)
	cell = null
	panel_open = FALSE
	//update_icon()
	return ..()

/obj/machinery/space_heater/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/mineral/deep_drill/Destroy()
	drill_eject_mats()
	materials = null
	return ..()

/obj/machinery/mineral/deep_drill/RefreshParts() //Stock Part Effects
	efficiency_coeff = 0.8
	energy_coeff = 1.1
	for(var/obj/item/pickaxe/drill/diamonddrill/DD in component_parts)
		efficiency_coeff = 1.1
		energy_coeff = 1.5
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 50000
		materials.set_local_size(total_storage)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency_coeff += M.rating * 0.1
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		energy_coeff -= C.rating * 0.1
	power_draw = efficiency_coeff * 100 * energy_coeff

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
		cell.use(-draw_power())
	else
		. += "It appears to be unpowered."

/obj/machinery/mineral/deep_drill/interact(mob/user)
	if(on && !panel_open)
		on = FALSE
		to_chat(user, "<span class='notice'>You switch the [src] off.</span>")
	else
		on = TRUE
		to_chat(user, "<span class='notice'>You switch the [src] on.</span>")

/obj/machinery/mineral/deep_drill/AltClick(mob/user) //When alt-clicked the drill will try to drop stored mats.
	if(user.canUseTopic(src, !issilicon(usr)))
		drill_eject_mats()

/obj/machinery/mineral/deep_drill/attack_hand(mob/user) //Handles interactions with empty hand
	. = ..() //code magic, references eldritch knowledge, hidden deep within the codebase - no touchey
	if(.)
		return
	if(!cell)
		return
	if(panel_open)
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
			to_chat(user, "<span class='warning'>The hatch must be open to insert a power cell!</span>")
			return

	else if(istype(I, /obj/item/disk/cargo/silo_drill))
		if(panel_open)
			if(!bluespace_upgrade)
				user.visible_message("<span class='notice'>\The [user] inserts a device into \the [src].</span>", "<span class='notice'>You insert the upgrade module into \the [src].</span>")
				user.transferItemToLoc(I, src)
				bluespace_upgrade = TRUE
		else
			to_chat(user, "<span class='warning'>You must open the maintenance hatch first!</span>")
			return

	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on \the [src].</span>")
		//update_icon()

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
	mat_container.insert_amount_mat((T.ore_rates[ore] * 1000*efficiency_coeff), ore)
	draw_power()

obj/machinery/mineral/deep_drill/proc/draw_power() //This draws power from the cell when called
	cell.use(power_draw)

/obj/machinery/mineral/deep_drill/process() //Heart of this
	if(on && cell && cell.charge > 0)
		if(istype(get_turf(src), /turf/open/floor/plating/asteroid/basalt/vein))
			drill_mats()

//MISC STUFF//////////////////////

/obj/item/disk/cargo/silo_drill
	name = "Ore Silo Link Upgrade"
	desc = "Upgrade module for drill rigs allowing for remote transfer of the resources."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL

