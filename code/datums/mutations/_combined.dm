/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(findtext(A, "[mutation1]") && findtext(A, "[mutation2]"))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/hulk
	required = "/datum/mutation/human/strong; /datum/mutation/human/radioactive"
	result = HULK

/datum/generecipe/megafart
	required = "/datum/mutation/human/strong; /datum/mutation/human/toxicfart"
	result = MEGAFART

/datum/generecipe/armblade
	required = "/datum/mutation/human/strong; /datum/mutation/human/claws"
	result = ARMBLADE

/datum/generecipe/x_ray
	required = "/datum/mutation/human/thermal; /datum/mutation/human/radioactive"
	result = XRAY

/datum/generecipe/lasereyes
	required = "/datum/mutation/human/thermal; /datum/mutation/human/glow"
	result = LASEREYES

/datum/generecipe/mindread
	required = "/datum/mutation/human/antenna; /datum/mutation/human/paranoia"
	result = MINDREAD

/datum/generecipe/shock
	required = "/datum/mutation/human/insulated; /datum/mutation/human/radioactive"
	result = SHOCKTOUCH

/datum/generecipe/antiglow
	required = "/datum/mutation/human/glow; /datum/mutation/human/void"
	result = ANTIGLOWY

/datum/generecipe/cluwne
	required = "/datum/mutation/human/clumsy; /datum/mutation/human/badblink"
	result = CLUWNEMUT
