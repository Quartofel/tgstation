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
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/deep_drill/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)
	component_parts = list(new /obj/item/circuitboard/machine/deep_drill,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/matter_bin,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/manipulator,
		new /obj/item/stock_parts/capacitor,
		new /obj/item/pickaxe/drill)
	RefreshParts()

/obj/machinery/mineral/deep_drill/Destroy()
	drill_eject_mats()
	materials = null
	return ..()

/obj/machinery/mineral/deep_drill/RefreshParts() //Stock Part Effects
	efficiency_coeff = 0.8
	energy_coeff = 1.1
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * 50000
		materials.set_local_size(total_storage)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency_coeff += M.rating * 0.1
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		energy_coeff -= C.rating * 0.1

//INTERACTIONS//////////////////////

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
	if(on)
		on = FALSE
		to_chat(user, "<span class='notice'>You switch the [src] off.</span>")
	else
		on = TRUE
		to_chat(user, "<span class='notice'>You switch the [src] on.</span>")

/obj/machinery/mineral/deep_drill/AltClick(mob/user) //When alt-clicked the drill will try to drop stored mats.
	if(user.canUseTopic(src, !issilicon(usr)))
		drill_eject_mats()

/obj/machinery/mineral/deep_drill/multitool_act(mob/living/user, obj/item/multitool/M) //If it has Bluespace Resource Transfer Upgrade it can be linked to Ore Silo
	if(bluespace_upgrade)
		return FALSE
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

//PROCS//////////////////////

/obj/machinery/mineral/deep_drill/proc/drill_eject_mats(mob/user) //Eject mats if possible
	if(materials?.silo)
		to_chat(user, "<span class='warning'>[src] can't eject materials from the silo!</span>")
		return FALSE
	if(on)
		var/location = get_step(src,EAST)
		var/datum/component/material_container/mat_container = materials.mat_container
		mat_container.retrieve_all(location)
		to_chat(user, "<span class='notice'>You eject the materials from [src].</span>")
		return TRUE
	else
		to_chat(user, "<span class='warning'>[src] must be on to eject materials!</span>")
		return FALSE

/obj/machinery/mineral/deep_drill/process()
	//if(!materials?.silo || materials?.on_hold())
	//	return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return

	//here be runtime
	if(on)
		if(istype(get_turf(src), /turf/open/floor/plating/asteroid/basalt/vein))
			var/turf/open/floor/plating/asteroid/basalt/vein/T = loc
			var/datum/material/ore = pick(T.ore_rates)
			mat_container.insert_amount_mat((T.ore_rates[ore] * 1000*efficiency_coeff), ore)
		else
			playsound(src, 'sound/misc/compiler-failure.ogg')
			sleep(120)

//MISC STUFF//////////////////////

/obj/item/disk/cargo/silo_drill
	name = "Ore Silo Link Upgrade"
	desc = "Upgrade module for drill rigs allowing for remote transfer of the resources."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL

