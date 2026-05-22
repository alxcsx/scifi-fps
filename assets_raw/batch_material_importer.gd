@tool
extends EditorScenePostImport

# PRELOAD forces Godot to cache these in RAM before the multithreaded storm hits
const solid_mat = preload("res://assets_raw/ATLAS_MATERIAL.tres")
const glass_mat = preload("res://assets_raw/SEE_THROUGH_ATLAS_MATERIAL.tres") 

func _post_import(scene: Node) -> Object:
	_apply_smart_materials(scene)
	return scene

func _apply_smart_materials(node: Node) -> void:
	if node is MeshInstance3D and node.mesh != null:
		for i in range(node.mesh.get_surface_count()):
			var use_glass = false
			
			var orig_mat = node.mesh.surface_get_material(i)
			if orig_mat != null:
				var mat_name = orig_mat.resource_name.to_lower()
				if "glass" in mat_name or "see_through" in mat_name or "alpha" in mat_name:
					use_glass = true
			
			var node_name = node.name.to_lower()
			if "glass" in node_name or "window" in node_name or "fence" in node_name or "grate" in node_name:
				use_glass = true
			
			# OVERRIDE is safer for batch multithreading than modifying the raw mesh!
			if use_glass:
				node.set_surface_override_material(i, glass_mat)
			else:
				node.set_surface_override_material(i, solid_mat)
				
	for child in node.get_children():
		_apply_smart_materials(child)
