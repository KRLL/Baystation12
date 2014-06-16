//Powersystem Module
/obj/item/modular/module/powersystem
	name = "Powersystem Module"
	m_slowdown = 0.5
	var/charge = 0
	var/max_charge = 100000

	proc/use(var/amount as num)
		if(charge - amount >= 0 && charge - amount <= max_charge)
			charge -= amount
			return 1
		else
			return 0

