extends StaticBody3D
class_name InteractButton

@export_category("Console Settings")
@export var linked_door: BaseDoor
@export var requires_key: bool = false
@export var required_key_name: String = "Red Keycard"

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const OUTLINE_MAT = preload("res://assets_raw/OUTLINE.tres")

func apply_material_to_meshes(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_overlay = mat
	for child in node.get_children():
		apply_material_to_meshes(child, mat)


func add_outline() -> void:
	apply_material_to_meshes(self, OUTLINE_MAT)

func remove_outline() -> void:
	apply_material_to_meshes(self, null)

func interact(player: Node3D) -> void:
	if anim_player and anim_player.has_animation("press"):
		anim_player.queue("press")

	if requires_key:
		var inventory = player.get_node_or_null("%InventoryManager")
		if not inventory: return
		
		var active_item = inventory.get_active_item()
		if active_item and active_item.item_name == required_key_name:
			print("Console: Authorization Accepted!")
			if linked_door: 
				anim_player.queue("allowed") 
				if linked_door.is_open():
					linked_door.close_door()
				else:
					linked_door.open_door()

		else:
			print("Console: Access Denied. Requires: " + required_key_name)
			anim_player.queue("denied")
			
	else:
		print("Console: Button pushed!")
		if linked_door: 
			anim_player.queue("allowed")
			if linked_door.is_open():
				linked_door.close_door()
			else:
				linked_door.open_door()
