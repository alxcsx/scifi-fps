extends CharacterBody3D
class_name Player

@onready var health_manager: PlayerHealthManager = %HealthManager
@onready var movement_manager: PlayerMovementManager = %MovementManager
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager

func _ready() -> void:
  inventory_manager.item_picked_up.connect(_on_item_picked_up)

func _on_item_picked_up(item_data: Item) -> void:
  if item_data is HealthItem:
    heal(item_data.heal_amount)

func take_damage(amount: float) -> void:
  health_manager.take_damage(amount)

func heal(amount: float) -> void:
  health_manager.heal(amount)

