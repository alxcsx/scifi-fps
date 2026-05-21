extends CharacterBody3D
class_name BaseEntity

@onready var health_manager: HealthManager = get_node_or_null("%HealthManager")
var movement_manager: BaseMovementManager

## Combat | Health
func take_damage(payload: HitPayload) -> void:
    if health_manager:
        health_manager.take_damage(payload.damage)
        health_manager.player_died.connect(_on_died)
    if payload.knockback > 0:
        if movement_manager:
            movement_manager.apply_knockback(payload.hit_direction, payload.knockback)

func heal(amount: float) -> void:
    if health_manager:
        health_manager.heal(amount)

func _on_died() -> void:
    pass
