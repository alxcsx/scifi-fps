extends Node
class_name PlayerMovementManager
# Constants
const MAX_SPEED = 10
const MAX_CROUCH_SPEED = 5

const CROUCH_ACCEL = 1.0
const ACCEL = 2.5
const DEACCEL= 16.0

# "Constants" that can be edited from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
# "Constants" that can be edited from the menu
var mouse_sensitivity = 0.09

@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var player: CharacterBody3D = owner as CharacterBody3D
@export var pivot: Node3D
@export var camera: Camera3D
@export var flashlight: SpotLight3D
# State
var is_crouching 	:= false
var direction 		:= Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if pivot 	== null: pivot 	= %Pivot
  if camera == null: camera = %Camera
  if flashlight == null: flashlight = %Pivot/Flashlight

  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  weapons_manager.weapon_fired.connect(_handle_flashlight_on_weapon_fire)
  weapons_manager.weapon_unequipped.connect(_handle_flashlight_on_weapon_unequipped)
  flashlight.hide()

#TODO: mover para o weapons manager ou alguma outra classe auxiliar.
func _handle_flashlight_on_weapon_fire(weapon: WeaponItem, _damage: float) -> void:
  if weapon.weapon_id == "Flashlight":
    flashlight.visible = not flashlight.visible

func _handle_flashlight_on_weapon_unequipped(weapon: WeaponItem) -> void:
  if weapon.weapon_id == "Flashlight":
    flashlight.hide()

func _physics_process(delta: float) -> void:
  process_input(delta)
  process_movement(delta)


func process_input(_delta: float) -> void:
  mouse_capture_control();
  crounching_control();

  var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
  direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
  

func crounching_control():
  is_crouching = Input.is_action_pressed("crouch")	

func mouse_capture_control():
  if Input.is_action_just_pressed("ui_cancel"):
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func process_movement(delta: float) -> void:
  if not player.is_on_floor():
    player.velocity.y -= gravity * delta

  var hvel := player.velocity;
  hvel.y = 0

  var target_speed := MAX_CROUCH_SPEED if is_crouching else MAX_SPEED
  var target_velocity := direction * target_speed
  var current_accel := (CROUCH_ACCEL if is_crouching else ACCEL) if (direction.dot(hvel) > 0) else DEACCEL
  
  hvel = hvel.lerp(target_velocity, current_accel * delta)
  player.velocity.x = hvel.x
  player.velocity.z = hvel.z
  
  player.move_and_slide()


func _unhandled_input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    # Rotate the pivot up/down, rotate the player left/right
    pivot.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity * -1))
    player.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))

    # Clamp the camera using radians directly, avoiding conversion back and forth
    pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-70), deg_to_rad(70))