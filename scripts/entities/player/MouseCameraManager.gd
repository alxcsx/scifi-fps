extends Node
class_name MouseCameraManager

@export var pivot_node: Node3D
@export var base_node: Node3D

# "Constants" that can be edited from the menu
var mouse_sensitivity = 0.09

func _unhandled_input(event: InputEvent) -> void:
	mouse_capture_control()
	handle_camera_rotation(pivot_node,base_node, event)

func mouse_capture_control():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_camera_rotation(x_axis: Node3D, y_axis: Node3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		x_axis.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity * -1))
		y_axis.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))

		x_axis.rotation.x = clamp(x_axis.rotation.x, deg_to_rad(-70), deg_to_rad(70))

