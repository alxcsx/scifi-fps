extends Area3D
class_name Item3D

@export var item_to_give: Item 

var float_speed := 2.0
var float_height := 0.5

@onready var start_y: float = global_position.y
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
  body_entered.connect(on_body_entered)
  if item_to_give and item_to_give.icon:
    var material = mesh.get_active_material(0)
    if material:
      var unique_material = material.duplicate()
      unique_material.albedo_texture = item_to_give.icon
      mesh.set_surface_override_material(0, unique_material)

func _process(_delta: float) -> void:
  position.y = start_y + (sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_height)

func on_body_entered(body: Node3D) -> void:
  if body is CharacterBody3D and body.name == "Player":        
    var inventory: PlayerInventoryManager = body.get_node("InventoryManager")
    if inventory:
      inventory._on_item_picked_up(item_to_give)
      queue_free()
