extends CharacterBody3D
class_name Player

@export var combat_raycast: RayCast3D
# Managers
@onready var health_manager: HealthManager = %HealthManager
@onready var movement_manager: PlayerMovementManager = %MovementManager
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager
@onready var interaction_manager: PlayerInteractionManager = %InteractionManager
@onready var player_vision: PlayerVision = %PlayerVision

func _ready() -> void:
  inventory_manager.item_picked_up.connect(_on_item_picked_up)
  player_vision.targeting_interactable.connect(_on_is_looking_at_interactable)
  weapons_manager.weapon_fired.connect(_on_weapon_fired)

func _on_is_looking_at_interactable(can_interact: bool) -> void:
  weapons_manager.hold_fire(can_interact)

func _on_item_picked_up(item_data: Item) -> void:
  if item_data is HealthItem:
    heal(item_data.heal_amount)

func take_damage(amount: float) -> void:
  health_manager.take_damage(amount)

func heal(amount: float) -> void:
  health_manager.heal(amount)

func _on_weapon_fired(weapon_data: WeaponItem) -> void:
  combat_raycast.target_position = Vector3(0, 0, -weapon_data.attack_range)
  combat_raycast.force_raycast_update()

  if combat_raycast.is_colliding():
      var target = combat_raycast.get_collider()
      if target.has_method("take_damage"):
          target.take_damage(weapon_data.damage)
