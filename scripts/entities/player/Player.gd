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
	$PauseMenuLayer.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Escape key
		var is_paused = not get_tree().paused
		get_tree().paused = is_paused
		$PauseMenuLayer.visible = is_paused
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_unpause_button_pressed() -> void:
	get_tree().paused = false
	$PauseMenuLayer.hide()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://MainMenu.tscn")
