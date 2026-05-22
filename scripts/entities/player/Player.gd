extends BaseEntity
class_name Player

@export var combat_raycast: RayCast3D
# Managers
@onready var CameraManager: MouseCameraManager = %MouseCameraManager
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager
@onready var interaction_manager: PlayerInteractionManager = %InteractionManager
@onready var player_vision: PlayerVision = %PlayerVision

@onready var camera_pivot: Node3D = %Pivot

func _ready() -> void:
  super();
  movement_manager = %MovementManager
  inventory_manager.item_picked_up.connect(_on_item_picked_up)
  player_vision.targeting_interactable.connect(_on_is_looking_at_interactable)

func _on_is_looking_at_interactable(is_targeting: bool, _interactable: Node3D) -> void:
  weapons_manager.hold_fire = is_targeting

func _on_item_picked_up(item_data: Item) -> void:
  if item_data is HealthItem:
    heal(item_data.heal_amount)

func _on_died() -> void:
  print("Game Over! :p")
