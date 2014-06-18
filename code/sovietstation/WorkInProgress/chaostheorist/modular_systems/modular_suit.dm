//Module Suit
/obj/item/clothing/suit/armor/modular
	name = "Modular Armor"
	icon = 'code/sovietstation/WorkInProgress/chaostheorist/modular_systems/exo-suit.dmi'
	icon_state = "exosuit_base"
	icon_override = 'code/sovietstation/WorkInProgress/chaostheorist/modular_systems/exo-suit.dmi'
	item_state = "none"
	w_class = 4
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS

	var/list/armor_modules = newlist()
	var/secured = 0

/obj/item/clothing/suit/armor/modular/New()
	processing_objects += src
	..()

/obj/item/clothing/suit/armor/modular/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
		if(secured)
			user.visible_message("[user] unscrewed [src].", "You unscrewed [src].")
			secured = 0
		else
			user.visible_message("[user] screwed [src].", "You screwed [src].")
			secured = 1
	else if(istype(W, /obj/item/modular/module))
		var/obj/item/modular/module/mod = W
		var/list/d_needing_modules = mod.needing_modules
		for(var/obj/item/modular/module/mod_i in armor_modules)
			if(istype(mod, mod_i) || mod_i.type in mod.conflicting_modules)
				return

			if(mod_i.type in d_needing_modules)
				d_needing_modules -= mod_i.type

		if(d_needing_modules.len)
			return

		user.drop_item()
		mod.loc = src
		armor_modules += mod
		slowdown += mod.m_slowdown
		mod.attach(src)

	else
		for(var/obj/item/modular/module/mod in armor_modules)
			if(mod.attackby(W, user))
				return
		..()

/obj/item/clothing/suit/armor/modular/attack_self(mob/user as mob)
	if(!secured)
		var/dat = "Modular Suit Modules:<br>"
		for(var/obj/item/modular/module/M in armor_modules)
			dat += "[M.name]: <a href='?src=\ref[src];action=detach&value=[M.name]'>DETACH</a><br>"
		var/datum/browser/popup = new(user, "modular_suit", "Suit Menu", 400, 240)
		popup.set_content(dat)
		popup.open()

/obj/item/clothing/suit/armor/modular/Topic(href, href_list)
	var/action = href_list["action"]
	if(action == "detach")
		var/d_name = href_list["value"]
		for(var/obj/item/modular/module/mod in armor_modules)
			if(mod.name == d_name)
				if(istype(loc, /turf))
					mod.loc = loc
				else
					mod.loc = loc.loc
				slowdown -= mod.m_slowdown
				armor_modules -= mod
				mod.detach(src)

/obj/item/clothing/suit/armor/modular/process()
	if(loc.type == /mob/living/carbon/human)
		var/mob/living/carbon/human/h_mob = loc
		if(src == h_mob.wear_suit)
			h_mob.update_icons()
	for(var/obj/item/modular/module/M in armor_modules)
		M.p_step()

/obj/item/clothing/suit/armor/modular/proc/get_module(var/n_type)
	for(var/obj/item/modular/module/mod in armor_modules)
		if(mod.type == n_type)
			return mod
	return null

/obj/item/modular/module
	name = "Module"
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	var/list/conflicting_modules = newlist()
	var/list/needing_modules = newlist()
	var/m_slowdown = 0

	proc/attach(obj/item/clothing/suit/armor/modular/O as obj)
		return

	proc/detach(obj/item/clothing/suit/armor/modular/O as obj)
		return

	proc/p_step()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		return 0