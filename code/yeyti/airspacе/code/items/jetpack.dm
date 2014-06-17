/obj/item/weapon/tank/jetpack
//	..()
	name = "Jetpack"
	var/obj/item/weapon/aerospace/jetflap/T3 = null
	var/obj/item/weapon/aerospace/jetaircontrol/T4 = null
	var/obj/item/weapon/circuitboard/jet/T5 = null
	var/obj/item/weapon/cable_coil/T6 = null
	icon_override = 'code/yeyti/airspacе/img/aerospace_suits.dmi'
	icon = 'code/yeyti/airspacе/img/aerospace_items.dmi'
	icon_state="jet"
	item_state = "jet"
	var/open = 0
	var/obj/item/weapon/tank/T1 = null
	var/obj/item/weapon/tank/T2 = null

/obj/item/weapon/tank/jetpack/proc/icon_update()
	icon_state = "jet"
	item_state = "jet"
	if(open == 0 || open == 1)
		if(T1 != null)
			if(istype(T1, /obj/item/weapon/tank/oxygen/red))
				icon_state+="r"
				item_state+="r"
			else if(istype(T1, /obj/item/weapon/tank/oxygen/yellow))
				icon_state+="y"
				item_state+="y"
			else if(istype(T1, /obj/item/weapon/tank/oxygen/black))
				icon_state+="c"
				item_state+="c"
			else
				icon_state+="b"
				item_state+="b"

		if(T2 != null)
			if(istype(T2, /obj/item/weapon/tank/oxygen/red))
				icon_state+="r"
				item_state+="r"
			else if(istype(T2, /obj/item/weapon/tank/oxygen/yellow))
				icon_state+="y"
				item_state+="y"
			else if(istype(T1, /obj/item/weapon/tank/oxygen/black))
				icon_state+="c"
				item_state+="c"
			else
				icon_state+="b"
				item_state+="b"
	else if(open == 2)
		icon_state += "open"
		item_state += "open"
	else if(open == 3 && T6 == null)
		icon_state += "open2"
		item_state += "open2"
	else if(open == 3 && T6 != null)
		icon_state += "open3"
		item_state += "open3"

/obj/item/weapon/tank/jetpack/New()
	..()
	air_contents.remove(air_contents.total_moles()) //супердебаг от вади
	if(T2 != null)
		volume = T1.volume + T2.volume
		air_contents.adjust(T1.air_contents.oxygen, T1.air_contents.carbon_dioxide, T1.air_contents.nitrogen, T1.air_contents.phoron)
		T1.air_contents.remove(air_contents.total_moles())
		air_contents.adjust(T2.air_contents.oxygen, T2.air_contents.carbon_dioxide, T2.air_contents.nitrogen, T2.air_contents.phoron)
		T2.air_contents.remove(T2.air_contents.total_moles())
	else if(T1 != null)
		volume = T1.volume
		air_contents.adjust(T1.air_contents.oxygen, T1.air_contents.carbon_dioxide, T1.air_contents.nitrogen, T1.air_contents.phoron)
	else
		volume = 0
	open = 3
	on = 0
	icon_update()

/obj/item/weapon/tank/jetpack/verb/toggle()
	if(open == 0)
		set name = "Включить ранец"
		set category = "Object"
		on = !on
		if(on)
			ion_trail.start()
		else
			ion_trail.stop()
	else
		usr << " реактивный ранец открыт, включение не возможно"
	return

/obj/item/weapon/tank/jetpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/tank/oxygen) && open == 1)
		if(T1 == null)
			T1 = W
			user.drop_item()
			W.loc = src
			volume = 0
			volume += T1.volume
			air_contents.adjust(T1.air_contents.oxygen, T1.air_contents.carbon_dioxide, T1.air_contents.nitrogen, T1.air_contents.phoron)
			T1.air_contents.remove(T1.air_contents.total_moles())

		else if(T2 == null)
			T2 = W
			user.drop_item()
			W.loc = src
			volume += T2.volume
			air_contents.adjust(T2.air_contents.oxygen, T2.air_contents.carbon_dioxide, T2.air_contents.nitrogen, T2.air_contents.phoron)
			T2.air_contents.remove(T2.air_contents.total_moles())

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(open == 0)
			open = 1
			if(on)
				on = !on
			user << " клапаны открыты"
		else if(T1 != null || T2 != null)
			open = 0
			user << " клапаны закрыты"
			if(T3 != null && T4 != null && T5 != null && T6 != null)
				if(!(on))
					on = !on
			else
				user << " реактивный ранец не работает"
		else if(open == 1)
			open = 2
			user << " крышка откручена"
		else if(open == 2)
			open = 1
			user << " крышка закручена"

	else if(istype(W, /obj/item/weapon/wrench))
		if(open == 1)
			if(T2 != null)
				T2.air_contents.adjust(air_contents.oxygen*(T2.volume/volume), air_contents.carbon_dioxide*(T2.volume/volume), air_contents.nitrogen*(T2.volume/volume), air_contents.phoron*(T2.volume/volume))
				air_contents.remove(T2.air_contents.total_moles())
				T2.loc = usr.loc
				T2 = null
				user << " баллон изьят"
			else if(T1 != null)
				T1.air_contents.adjust(air_contents.oxygen, air_contents.carbon_dioxide, air_contents.nitrogen, air_contents.phoron)
				air_contents.remove(T1.air_contents.total_moles())
				volume = 0
				T1.loc = usr.loc
				T1 = null
				user << " баллон изьят"
		else
			user << " открути клапаны дибил!"
	else if(istype(W, /obj/item/weapon/crowbar))
		if(open == 2)
			open = 3
			T3.loc = usr.loc
			T3 = null
			T4.loc = usr.loc
			T4 = null
			T5.loc = usr.loc
			T5 = null
		else if(open == 3)
			if(T4 != null)
				T4.loc = usr.loc
				T4 = null
			else if(T5 != null)
				T5.loc = usr.loc
				T5 = null
	else if(istype(W, /obj/item/weapon/aerospace/jetaircontrol))
		if(open == 3 && T4 == null)
			T4 = W
			user.drop_item()
			W.loc = src
	else if(istype(W, /obj/item/weapon/circuitboard/jet))
		if(open == 3 && T5 == null)
			T5 = W
			user.drop_item()
			W.loc = src
	else if(istype(W, /obj/item/weapon/aerospace/jetflap))
		if(open == 3 && T3 == null)
			T3 = W
			user.drop_item()
			W.loc = src
			open = 2
	else if(istype(W, /obj/item/weapon/cable_coil))
		if(open == 3 && T6 == null)
			T6 = W
			user.drop_item()
			W.loc = src
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(open == 3)
			T6.loc = usr.loc
			T6 = null
	icon_update()
	return


/obj/item/weapon/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."

	New()
		T6 = new/obj/item/weapon/cable_coil (src)
		T5 = new/obj/item/weapon/circuitboard/jet (src)
		T4 = new/obj/item/weapon/aerospace/jetaircontrol (src)
		T3 = new/obj/item/weapon/aerospace/jetflap (src)
		T1 = new/obj/item/weapon/tank/oxygen/red (src)
		T2 = new/obj/item/weapon/tank/oxygen/red (src)
		..()
		open = 0
		icon_update()
		return

/obj/item/weapon/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."

	New()
		T6 = new/obj/item/weapon/cable_coil (src)
		T5 = new/obj/item/weapon/circuitboard/jet (src)
		T4 = new/obj/item/weapon/aerospace/jetaircontrol (src)
		T3 = new/obj/item/weapon/aerospace/jetflap (src)
		T1 = new/obj/item/weapon/tank/oxygen (src)
		T2 = new/obj/item/weapon/tank/oxygen (src)
		..()
		open = 0
		icon_update()
		return

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0

	New()
		T6 = new/obj/item/weapon/cable_coil (src)
		T5 = new/obj/item/weapon/circuitboard/jet (src)
		T4 = new/obj/item/weapon/aerospace/jetaircontrol (src)
		T3 = new/obj/item/weapon/aerospace/jetflap (src)
		T1 = new/obj/item/weapon/tank/oxygen/black (src)
		T2 = new/obj/item/weapon/tank/oxygen/black (src)
		..()
		open = 0
		icon_update()
		src.ion_trail = new /datum/effect/effect/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		return

	examine()
		set src in usr
		..()
		if(air_contents.carbon_dioxide < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'sound/effects/alert.ogg', 50, 1)
		return

/obj/item/weapon/aerospace/jetflap
	name = "крышка от ранца"
	desc = " крышка от джетпака, найди владельца!"
	icon_state = "jetpanel"

/obj/item/weapon/circuitboard/jet
	icon = 'code/yeyti/airspacе/img/aerospace_items.dmi'
	icon_state = "jetelectronics"
	name = "Jet Electronics"
	build_path = "/obj/item/weapon/tank/jetpack/oxygen"
	board_type = "jet"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "kjk"
	req_components = list()

/obj/item/weapon/aerospace
	icon = 'code/yeyti/airspacе/img/aerospace_items.dmi'

/obj/item/weapon/aerospace/jetaircontrol
	icon_state = "jetaircontroller"
	name = "воздушный распределитель"

/obj/item/weapon/tank/oxygen/black
	name = "black tank"
	desc = "A tank of CO2."
	icon = 'code/yeyti/airspacе/img/aerospace_items.dmi'
	icon_override = 'code/yeyti/airspacе/img/aerospace_suits.dmi'
	icon_state = "blackballon"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

	New()
		..()
		air_contents.adjust(0,(6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
		return

	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")











//не огорчаем тракториста :3