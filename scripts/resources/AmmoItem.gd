extends Item
class_name AmmoItem

enum AmmoType {
	NONE,
	BULLETS,
}

@export
var ammo_type: AmmoType = AmmoType.BULLETS

@export
var amount: int = 10
