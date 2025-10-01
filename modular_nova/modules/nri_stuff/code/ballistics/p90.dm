/obj/item/gun/ballistic/automatic/p90
	name = "\improper FN P-09"
	desc = "A compact Bullpup submachine gun of the pilots and tank crew of the Old Empire. After its collapse, the weapon's blueprints were taken by mercenaries from InteQ."
	icon = 'modular_nova/modules/nri_stuff/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "p90"
	lefthand_file = 'modular_nova/modules/nri_stuff/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_nova/modules/nri_stuff/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "p90"
	worn_icon = 'modular_nova/modules/nri_stuff/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "p90"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/p90
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	fire_delay = 2
	burst_size = 1
	fire_sound = 'modular_nova/modules/nri_stuff/sound/guns/fire/p90_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'modular_nova/modules/nri_stuff/sound/guns/interact/p90_cock.ogg'
	load_sound = 'modular_nova/modules/nri_stuff/sound/guns/interact/p90_magin.ogg'
	load_empty_sound = 'modular_nova/modules/nri_stuff/sound/guns/interact/p90_magin.ogg'
	eject_sound = 'modular_nova/modules/nri_stuff/sound/guns/interact/p90_magout.ogg'

/obj/item/gun/ballistic/automatic/p90/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/p90
	name = "\improper FN P-09 magazine"
	icon = 'modular_nova/modules/nri_stuff/icons/guns/gunsgalore_items.dmi'
	icon_state = "p90"
	ammo_type = /obj/item/ammo_casing/c385
	caliber = ".385"
	max_ammo = 45
	multiple_sprites = AMMO_BOX_FULL_EMPTY
