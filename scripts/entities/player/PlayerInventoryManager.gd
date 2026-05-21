extends Node
class_name PlayerInventoryManager

signal ammo_changed(ammo_type: AmmoItem.AmmoType, new_amount: int)
signal weapon_unlocked(weaponType: WeaponItem.WeaponType)
signal item_picked_up(item_data: Item)

var ammo_inventory: Dictionary[AmmoItem.AmmoType, int] = {
	AmmoItem.AmmoType.BULLETS: 0,
	AmmoItem.AmmoType.NONE: 999,
}

var unlocked_weapons: Array[WeaponItem.WeaponType] = []

func is_weapon_unlocked(weaponType: WeaponItem.WeaponType) -> bool:
	return weaponType in unlocked_weapons


func _on_item_picked_up(item_data: Item) -> void:
	item_picked_up.emit(item_data)
	if item_data is AmmoItem:
		print("Picked up %d %s!" % [item_data.amount, item_data.ammo_type])
		add_ammo(item_data.ammo_type, item_data.amount)
	elif item_data is WeaponItem:
		print("Picked up Weapon: %s!" % item_data.item_name)
		add_ammo(item_data.ammo_type, item_data.starting_ammo)
		unlock_weapon(item_data.weaponType)
	else:
		print("Picked up Item: %s! The Inventory Manager doesn't know how to handle it." % item_data.item_name)


func add_ammo(type: AmmoItem.AmmoType, amount: int) -> void:
	if amount == 0: return
	if ammo_inventory.has(type):
		ammo_inventory[type] += amount
		ammo_changed.emit(type, ammo_inventory[type])

func unlock_weapon(weaponType: WeaponItem.WeaponType) -> void:
	if not unlocked_weapons.has(weaponType):
		unlocked_weapons.append(weaponType)
		weapon_unlocked.emit(weaponType)
