extends Node
class_name PlayerInventoryManager

signal ammo_changed(ammo_type: AmmoItem.AmmoType, new_amount: int)
signal item_picked_up(item_data: Item)
signal active_slot_changed(new_index: int, item: Item)
const MAX_SLOTS := 9

var hotbar: Array[Item] = []
var active_slot_index: int = 0


var ammo_inventory: Dictionary[AmmoItem.AmmoType, int] = {
	AmmoItem.AmmoType.BULLETS: 0,
	AmmoItem.AmmoType.NONE: 999,
}


func _ready() -> void:
	hotbar.resize(MAX_SLOTS) # Fills the array with 9 empty slots


func _unhandled_input(event: InputEvent) -> void:
	# Mouse Wheel Scrolling
	if event.is_action_pressed("scroll_up"):
		equip_slot((active_slot_index - 1 + MAX_SLOTS) % MAX_SLOTS)
	elif event.is_action_pressed("scroll_down"):
		equip_slot((active_slot_index + 1) % MAX_SLOTS)

	# Number Keys 1-9 (Assumes you set inputs mapped "slot_1" to "slot_9")
	for i in range(MAX_SLOTS):
		if event.is_action_pressed("slot_" + str(i + 1)):
			equip_slot(i)

func equip_slot(index: int) -> void:
	active_slot_index = index
	active_slot_changed.emit(active_slot_index, hotbar[active_slot_index])
	print("Switched to slot: ", index + 1)


func try_add_item(item_data: Item) -> bool:
	if item_data is HealthItem:
		item_picked_up.emit(item_data)
		return true

	if item_data is AmmoItem:
		add_ammo(item_data.ammo_type, item_data.amount)
		item_picked_up.emit(item_data) # Tell the UI to update ammo
		return true

	if item_data is WeaponItem:
		add_ammo(item_data.ammo_type, item_data.starting_ammo)

	for i in range(MAX_SLOTS):
		if hotbar[i] == null:
			hotbar[i] = item_data
			print("Picked up %s into slot %d" % [item_data.item_name, i + 1])

			# Tell the UI to redraw the screen
			item_picked_up.emit(item_data)

			equip_slot(i)

			return true

	print("Inventory Full!")
	return false

func get_ammo_count(type: AmmoItem.AmmoType) -> int:
	return ammo_inventory.get(type, 0)


func add_ammo(type: AmmoItem.AmmoType, amount: int, broadcast: bool = true) -> void:
	if amount == 0: return
	if ammo_inventory.has(type):
		ammo_inventory[type] += amount
		if broadcast:
			ammo_changed.emit(type, ammo_inventory[type])


func get_active_item() -> Item:
	return hotbar[active_slot_index]
