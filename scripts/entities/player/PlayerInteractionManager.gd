extends Node
class_name PlayerInteractionManager

@export var player_vision: PlayerVision

var current_interactable: Node3D = null

func _ready() -> void:
  player_vision.targeting_interactable.connect(_on_targeting_interactable)

func _on_targeting_interactable(is_targeting: bool, interactable: Node3D) -> void:
  if is_targeting:
    current_interactable = interactable
    # TODO: UI "Aperte (E) Para Interagir"
  elif current_interactable == interactable:
    current_interactable = null
    # TODO: esconder UI

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("interact") and current_interactable:
    if current_interactable.has_method("interact"):
      current_interactable.interact()
