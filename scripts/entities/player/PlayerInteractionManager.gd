extends Node
class_name PlayerInteractionManager

@export var raycast: RayCast3D

signal is_looking_at_interactable(looking: bool)
signal interacted_with_object(object: Node)

var _was_looking_at_interactable := false

func _ready() -> void:
  raycast.enabled = true

func _process(_delta: float) -> void:
  var is_looking_now := false
  if raycast.is_colliding():
    var collider := raycast.get_collider()
    if collider and collider.has_method("interact"):
        is_looking_now = true
        if Input.is_action_just_pressed("interact"):
            collider.interact()
            interacted_with_object.emit(collider)

    if is_looking_now != _was_looking_at_interactable:
        is_looking_at_interactable.emit(is_looking_now)
        _was_looking_at_interactable = is_looking_now

func get_looked_at_object() -> Node:
  if raycast.is_colliding():
    return raycast.get_collider()
  return null
