extends Control
class_name StatusUi

@onready var health_label: Label = $HealthLabel
@onready var ammo_label: Label = $AmmoLabel
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager
@onready var health_manager: HealthManager = %HealthManager


func _ready() -> void:
	setup_ammo_display()
	setup_health_display()


## HEALTH
func setup_health_display() -> void:
	if not health_label:
		push_warning("No health label assigned to StatusUi!")
	elif health_manager:
		health_manager.health_changed.connect(_on_health_changed)
		_on_health_changed(health_manager.current_health, health_manager.max_health)
	else:
		push_warning("No HealthManager found! Health display will not function.")
		health_label.hide()

func _on_health_changed(current_health: float, max_health: float) -> void:
	health_label.text = "Health: %d / %d" % [current_health, max_health]

## AMMO

func setup_ammo_display() -> void:
	if not ammo_label:
		push_warning("No ammo label assigned to StatusUi!")
	elif weapons_manager:
		weapons_manager.weapon_equipped.connect(func(_w): _update_ammo_display())
		inventory_manager.ammo_changed.connect(_on_ammo_changed)
		_update_ammo_display()
	else:
		ammo_label.hide()

func _on_ammo_changed(ammo_type: AmmoItem.AmmoType, _new_amount: int) -> void:
	var current_weapon := weapons_manager.get_current_weapon()
	if current_weapon and current_weapon.weapon_data.ammo_type == ammo_type:
		_update_ammo_display()

func _update_ammo_display() -> void:
	var current_weapon := weapons_manager.get_current_weapon()

	if not current_weapon or not current_weapon.weapon_data or current_weapon.weapon_data.ammo_type == AmmoItem.AmmoType.NONE:
		ammo_label.text = "---"
		return

	var current_type = current_weapon.weapon_data.ammo_type
	var amount = inventory_manager.ammo_inventory.get(current_type, 0)

	ammo_label.text = str(amount)
