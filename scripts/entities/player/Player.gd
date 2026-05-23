extends BaseEntity
class_name Player

@export var combat_raycast: RayCast3D

# Managers
@onready var CameraManager: MouseCameraManager = %MouseCameraManager
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager
@onready var player_vision: PlayerVision = %PlayerVision

@onready var camera_pivot: Node3D = %Pivot


var current_interactable_target: Node3D = null

func _ready() -> void:
	super()
	movement_manager = %MovementManager
	player_vision.targeting_interactable.connect(_on_is_looking_at_interactable)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable_target:
		if current_interactable_target.has_method("interact"):
			current_interactable_target.interact(self)

func _on_is_looking_at_interactable(is_targeting: bool, interactable: Node3D) -> void:
	weapons_manager.hold_fire = is_targeting
	
	# Remove the outline
	if current_interactable_target and current_interactable_target.has_method("remove_outline"):
		current_interactable_target.remove_outline()
		
	if is_targeting:
		current_interactable_target = interactable
		
		# Add the outline
		if current_interactable_target.has_method("add_outline"):
			current_interactable_target.add_outline()
	else:
		current_interactable_target = null

func _on_died() -> void:
	print("Game Over! :p")
