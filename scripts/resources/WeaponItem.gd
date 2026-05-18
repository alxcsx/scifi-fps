extends Item
class_name WeaponItem

#TODO: acho que pode ser um enum
@export var weapon_id: String 

@export_category("Weapon Stats")
@export var damage: float = 10.0
@export var fire_rate: float = 0.2

@export_category("Ammo")
@export var starting_ammo: int = 20
@export var ammo_type: AmmoItem.AmmoType = AmmoItem.AmmoType.BULLETS
@export var ammo_cost: int = 1