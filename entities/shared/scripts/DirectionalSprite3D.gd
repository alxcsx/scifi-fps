extends AnimatedSprite3D
class_name DirectionalSprite3D

@export_category("Directional Settings")
@export var target_node: Node3D
@export var animations: Array[String] = ["front", "left", "back", "right"]
@export var mirror_map: Dictionary[String,String] = {
	"right": "left"
}

@export var freeze_animation: bool = false

func _ready() -> void:
	if not target_node:
		target_node = get_parent() as Node3D

func _process(_delta: float) -> void:
	if not target_node or animations.is_empty(): return
	var camera := get_viewport().get_camera_3d()
	if not camera: return

	var forward := -target_node.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var dir_to_camera := target_node.global_position.direction_to(camera.global_position)
	dir_to_camera.y = 0
	dir_to_camera = dir_to_camera.normalized()

	var angle := forward.signed_angle_to(dir_to_camera, Vector3.UP)
	_update_directional_sprite(angle)

func _update_directional_sprite(angle: float) -> void:
	var normalized_angle := wrapf(angle, 0.0, TAU)
	var slice_size := TAU / animations.size()
	var index := int(round(normalized_angle / slice_size)) % animations.size()

	var target_anim := animations[index]

	if mirror_map.has(target_anim):
		target_anim = mirror_map[target_anim]
		flip_h = true
	else:
		flip_h = false

	if freeze_animation:
		animation = target_anim
		frame = 0
		stop()
	else:
		play(target_anim)















