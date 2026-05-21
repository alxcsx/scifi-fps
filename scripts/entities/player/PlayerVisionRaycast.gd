extends RayCast3D
class_name PlayerVision

# Signals
signal targeting_enemy(is_targeting: bool)
signal targeting_interactable(is_targeting: bool, interactable: Node3D)

var was_seeing_enemy := false
var last_seen_interactable: Node3D = null

# Raycast settings
@export var interaction_range: float = 2.5
var current_weapon_range: float = 0.0


func _physics_process(_delta: float) -> void:
  target_position.z = -max(interaction_range, current_weapon_range)
  force_raycast_update()

  var is_seeing_enemy := false
  var current_interactable: Node3D = null

  if is_colliding():
    var collider  := get_collider()

    if is_instance_valid(collider) and not collider.is_queued_for_deletion():
      var hit_point := get_collision_point()
      var distance  := global_position.distance_to(hit_point)

      if collider.is_in_group("Enemy") and distance <= current_weapon_range:
        is_seeing_enemy = true

      elif collider.is_in_group("Interactable") and distance <= interaction_range:
        current_interactable = collider

  _handle_enemy_signals(is_seeing_enemy)
  _handle_interactable_signals(current_interactable)

func _handle_enemy_signals(is_seeing_enemy: bool) -> void:
  if is_seeing_enemy != was_seeing_enemy:
    targeting_enemy.emit(is_seeing_enemy)
    was_seeing_enemy = is_seeing_enemy
    print("targetting enemy: %s" % is_seeing_enemy)

func _handle_interactable_signals(current_interactable: Node3D) -> void:
  if last_seen_interactable and not is_instance_valid(last_seen_interactable):
    targeting_interactable.emit(false, null)
    last_seen_interactable = null
    print("Stopped seeing interactable: (destroyed)")
    return

  if current_interactable != last_seen_interactable:
    if last_seen_interactable != null:
      targeting_interactable.emit(false, last_seen_interactable)
      print("Stopped seeing interactable: %s" % last_seen_interactable.name)

    if current_interactable != null:
      targeting_interactable.emit(true, current_interactable)
      print("Started seeing interactable: %s" % current_interactable.name)

    last_seen_interactable = current_interactable
