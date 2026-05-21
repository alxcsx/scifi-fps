extends BaseMovementManager
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

# State
var is_crouching 	:= false
var direction 		:= Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func calculate_movement(player: CharacterBody3D, delta: float) -> Vector3:
	_process_input(player, delta)
	return process_movement(player, delta)

func _process_input(player: CharacterBody3D, _delta: float) -> void:
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

func process_movement(player: CharacterBody3D, delta: float) -> Vector3:
	var calculated_velocity := player.velocity
	if not player.is_on_floor():
		calculated_velocity.y -= gravity * delta

	var hvel := calculated_velocity
	hvel.y = 0

	var target_speed := MAX_CROUCH_SPEED if is_crouching else MAX_SPEED
	var target_velocity := direction * target_speed
	var current_accel := (CROUCH_ACCEL if is_crouching else ACCEL) if (direction.dot(hvel) > 0) else DEACCEL

	hvel = hvel.lerp(target_velocity, current_accel * delta)
	var current_knockback = process_knockback(delta)

	calculated_velocity.x = hvel.x + current_knockback.x
	calculated_velocity.z = hvel.z + current_knockback.z

	return calculated_velocity


func handle_camera_rotation(x_axis: Node3D, y_axis: Node3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		x_axis.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity * -1))
		y_axis.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))

		x_axis.rotation.x = clamp(x_axis.rotation.x, deg_to_rad(-70), deg_to_rad(70))
