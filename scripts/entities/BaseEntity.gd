extends CharacterBody3D
class_name BaseEntity

@onready var health_manager: HealthManager = get_node_or_null("%HealthManager")
var movement_manager: BaseMovementManager

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var use_gravity: bool = true

func _ready() -> void:
  if health_manager:
    health_manager.player_died.connect(_on_died)

func _physics_process(delta: float) -> void:
  var intended_velocity := Vector3.ZERO
  if movement_manager:
    intended_velocity = movement_manager.calculate_movement(self, delta)

  if use_gravity and not is_on_floor():
    velocity.y -= gravity * delta

  var knockback := Vector3.ZERO
  if movement_manager:
    knockback = movement_manager.process_knockback(delta)

  velocity.x = intended_velocity.x + knockback.x
  velocity.z = intended_velocity.z + knockback.z
  move_and_slide()

## Combat | Health
func take_damage(payload: HitPayload) -> void:
    if health_manager:
        health_manager.take_damage(payload.damage)
    if payload.knockback > 0:
        if movement_manager:
            movement_manager.apply_knockback(payload.hit_direction, payload.knockback)

func heal(amount: float) -> void:
    if health_manager:
        health_manager.heal(amount)

func _on_died() -> void:
    pass
