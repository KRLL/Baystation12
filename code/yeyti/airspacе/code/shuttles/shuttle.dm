
/obj/mecha/working/shuttle
	name = "shuttle"
	icon = 'code/yeyti/airspacе/img/Shuttle_Xpanda.dmi'
	icon_state = "shuttleciv"
	initial_icon = "shuttleciv"
	desc = "small-ranged space shuttle"
	wreckage = /obj/effect/decal/mecha_wreckage/spaceshuttle
	step_in = 0.01
	max_equip = 6
/*	var/obj/colliders = list()
	var/wdir = 0
	var/turf/T = null
	var/turf/T1 = null
	var/turf/T2 = null*/

/obj/mecha/Del()
	src.go_out()
	mechas_list -= src //global mech list
	..()
	return



/obj/mecha/working/shuttle/dyndomove(direction)
/*	T = get_step(src, 1)
	T1 = get_step(src, 4)
	T2 = get_step(T1, 1)*/
//	var/truestep = 0
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
/*	if(direction == 1)
		if(istype(get_step(T, direction),/turf/simulated/wall) && istype(get_step(T2, direction),/turf/simulated/wall))
			truestep = 1
	else if(direction == 2)
		if(istype(get_step(src, direction),/turf/simulated/wall) && istype(get_step(T1, direction),/turf/simulated/wall))
			truestep = 1
	else if(direction == 4)
		if(istype(get_step(T1, direction),/turf/simulated/wall) && istype(get_step(T2, direction),/turf/simulated/wall))
			truestep = 1
	else if(direction == 8)
		if(istype(get_step(src, direction),/turf/simulated/wall) && istype(get_step(T, direction),/turf/simulated/wall))
			truestep = 1*/
//	if(truestep)
	var/move_result = 0
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(src.dir!=direction)
		move_result = mechturn(direction)
	else
		move_result	= mechstep(direction)
	if(move_result)
		can_move = 0
		use_power(step_energy_drain)
		/*if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")*/
		if(do_after(step_in))
			can_move = 1
		return 1
	return 0


//these three procs overriden to play different sounds
/obj/mecha/working/shuttle/mechturn(direction)
	dir = direction
	playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/mecha/working/shuttle/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/obj/mecha/working/shuttle/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result

/obj/mecha/working/shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/mmi) || istype(W, /obj/item/device/mmi/posibrain))
		if(mmi_move_inside(W,user))
			user << "[src]-MMI interface initialized successfuly"
		else
			user << "[src]-MMI interface initialization failed."
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment/shuttle))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				user.drop_item()
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
			else
				user << "You were unable to attach [W] to [src]"
		return

	else if(istype(W, /obj/item/weapon/wrench))
		if(state==1)
			state = 2
			user << "You undo the armor bolts."
		else if(state==2)
			state = 1
			user << "You tighten the armor bolts."
		return

	else if(istype(W, /obj/item/weapon/crowbar))
		if(state==2)
			state = 3
			user << "You open the armor plate"
			icon_state = "shuttleciv-plat2"
		else if(state==3)
			state=2
			user << "You close the armor plate"
		return

	else if(istype(W, /obj/item/weapon/cable_coil))
		if(state >= 3 && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/weapon/cable_coil/CC = W
			if(CC.amount > 1)
				CC.use(2)
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				user << "You replace the fused wires."
			else
				user << "There's not enough wire to finish the task."
		return

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(state==3 && src.cell)
			src.cell.forceMove(src.loc)
			src.cell = null
			state = 4
			user << "You unscrew and pry out the powercell."
			src.log_message("Powercell removed")
		else if(state==4 && src.cell)
			state=3
			user << "You screw the cell in place"
		return

/obj/effect/decal/mecha_wreckage/spaceshuttle
	name = "Odysseus wreckage"
	icon_state = "shuttleciv-plat"
	New()
		..()
		var/list/parts = list(
									/obj/item/mecha_parts/part/odysseus_torso,
									/obj/item/mecha_parts/part/odysseus_head,
									/obj/item/mecha_parts/part/odysseus_left_arm,
									/obj/item/mecha_parts/part/odysseus_right_arm,
									/obj/item/mecha_parts/part/odysseus_left_leg,
									/obj/item/mecha_parts/part/odysseus_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/item/mecha_parts/mecha_equipment/shuttle

/*
/datum/construction/mecha/shuttle_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
		const_holder.icon = 'icons/mecha/Shuttle_Xpanda.dmi'
		const_holder.icon_state = "shuttleciv-plat"
		const_holder.density = 1
		const_holder.overlays.len = 0
		spawn()
			del src
		return


/datum/construction/reversible/mecha/shuttle
	result = "/obj/mecha/working/shuttle"
	steps = list(
					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
					 //9
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Central control module is installed"),
					 //10
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/main,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is adjusted"),
					 //11
					 list("key"=/obj/item/weapon/wirecutters,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is added"),
					 //12
					 list("key"=/obj/item/weapon/cable_coil,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are disconnected.")
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(14)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
				holder.icon_state = "ripley1"
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
					holder.icon_state = "ripley2"
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
					holder.icon_state = "ripley0"
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
					holder.icon_state = "ripley3"
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
					holder.icon_state = "ripley1"
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
					holder.icon_state = "ripley4"
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/weapon/cable_coil/coil = new /obj/item/weapon/cable_coil(get_turf(holder))
					coil.amount = 4
					holder.icon_state = "ripley2"
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
					holder.icon_state = "ripley5"
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
					holder.icon_state = "ripley3"
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
					holder.icon_state = "ripley6"
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
					holder.icon_state = "ripley4"
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
					holder.icon_state = "ripley7"
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
					holder.icon_state = "ripley5"
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
					holder.icon_state = "ripley8"
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
					holder.icon_state = "ripley6"
			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
					holder.icon_state = "ripley9"
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
					holder.icon_state = "ripley7"
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
					holder.icon_state = "ripley10"
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
					var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
					MS.amount = 5
					holder.icon_state = "ripley8"
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
					holder.icon_state = "ripley11"
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
					holder.icon_state = "ripley9"
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
					holder.icon_state = "ripley12"
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
					holder.icon_state = "ripley10"
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
					holder.icon_state = "ripley13"
				else
					user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
					holder.icon_state = "ripley11"
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
					holder.icon_state = "ripley12"
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_ripley_created",1)
		return



/obj/item/mecha_parts/chassis/shuttle
	name = "Shuttle Chassis"
	New()
		..()
		construct = new /datum/construction/mecha/shuttle_chassis(src)

/obj/item/mecha_parts/part/sre
	name="Shuttle part"
	desc="A Shuttle part."
	icon_state = "ripley_harness"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=40000,"glass"=15000)

/obj/item/mecha_parts/part/sle
	name="Ripley Left Arm"
	desc="A Ripley APLU left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_l_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/sme
	name="Ripley Right Arm"
	desc="A Ripley APLU right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_r_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=25000)
*/
/obj/item/mecha_parts/part/sac //air collector
	name="life support"
	desc="A Shuttle air collector systems."
	icon = 'code/yeyti/airspacе/img/parts.dmi'
	icon_state = "ls"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)
	var/obj/item/weapon/tank/oxygen/T1 = null
	var/obj/item/weapon/tank/oxygen/T2 = null
	var/obj/item/weapon/tank/oxygen/T3 = null
	var/open = 0

	update_icon()
		icon_state = "ls"
		if(T1 != null)
			if(istype(T1,/obj/item/weapon/tank/oxygen/red))
				icon_state += "r"
			else
				icon_state += "b"
		if(T2 != null)
			if(istype(T2,/obj/item/weapon/tank/oxygen/red))
				icon_state += "r"
			else
				icon_state += "b"
		if(T3 != null)
			if(istype(T3,/obj/item/weapon/tank/oxygen/red))
				icon_state += "r"
			else
				icon_state += "b"

/obj/item/mecha_parts/part/sac/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/tank/oxygen) && open == 0)
		if(T1 == null)
			user << "airtank 1 sucsefulled conected"
			T1 = W
			user.drop_item()
			W.loc = src
			update_icon()
		else if(T2 == null)
			T2 = W
			user.drop_item()
			W.loc = src
			user << "airtank 2 sucsefulled conected"
			update_icon()
		else if(T3 == null)
			T3 = W
			user.drop_item()
			W.loc = src
			user << "airtank 3 sucsefulled conected"
			update_icon()
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(open == 0)
			if(T1 != null || T2 != null || T3!= null)
				user << "клапаны sucsefulled conected"
				open = 1
			else
				user << "please conect клапаны"
		else
			open = 0
			user << "клапаны sucsefulled открыты"
	else if(istype(W, /obj/item/weapon/wrench))
		if(open == 0)
			if(T3 != null)
				T3.loc = usr.loc
				T3 = null
				update_icon()
			else if(T2 != null)
				T2.loc = usr.loc
				T2 = null
				update_icon()
			else if(T1 != null)
				T1.loc = usr.loc
				T1 = null
				update_icon()
		else
			user << "открути клапаны дибил!"
	return
/*

/obj/item/mecha_parts/part/sec
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/ssp
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/sls
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/sha
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)
	var/hp = 1000

/obj/item/mecha_parts/part/stc
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 300
	construction_cost = list("metal"=30000)
	var/hp = 1000 */