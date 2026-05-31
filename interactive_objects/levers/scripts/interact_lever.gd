extends StaticBody3D
class_name InteractLever

@export_category("Lever Settings")
@export var target_lights: Array[Light3D]
@export var flicker_sound: AudioStream
@export var starts_on    : bool = false

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var is_on: bool = false
const OUTLINE_MAT = preload("res://core/resources/shared_resources/OUTLINE.tres")


func _ready() -> void:
	if starts_on:
		_turn_lights_on_with_flicker()
	else:
		_turn_lights_off()


func apply_material_to_meshes(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_overlay = mat
	for child in node.get_children():
		apply_material_to_meshes(child, mat)

func add_outline() -> void:
	apply_material_to_meshes(self, OUTLINE_MAT)

func remove_outline() -> void:
	apply_material_to_meshes(self, null)

func interact(_player: Node3D) -> void:
	is_on = !is_on

	if is_on:
		# Play the physical lever pull animation
		if anim_player and anim_player.has_animation("turn_on"):
			anim_player.play("turn_on")

		_turn_lights_on_with_flicker()
	else:
		# Play the physical lever push animation
		if anim_player and anim_player.has_animation("turn_off"):
			anim_player.play("turn_off")

		_turn_lights_off()

func _turn_lights_off() -> void:
	# Play a heavy power-down sound here
	for light in target_lights:
		if light:
			light.visible = false

# Flicker Effect
func _turn_lights_on_with_flicker() -> void:
	# 1. Electrical buzz sound
	if audio_player and flicker_sound:
		audio_player.stream = flicker_sound
		audio_player.play()

	# 2. Flashes 6 times
	for i in range(6):
		var random_delay = randf_range(0.05, 0.15)

		# Alternates true/false
		var flicker_state = (i % 2 == 0)

		for light in target_lights:
			if light:
				light.visible = flicker_state

		# Pause the code execution here for the random delay
		await get_tree().create_timer(random_delay).timeout

	# Lck the lights to the fully ON state
	for light in target_lights:
		if light:
			light.visible = true













