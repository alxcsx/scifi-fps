extends Node
class_name BaseMovementManager

var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_friction: float = 25.0

func calculate_movement(_entity: CharacterBody3D, _delta: float) -> Vector3:
		return Vector3.ZERO

func apply_knockback(direction: Vector3, force: float) -> void:
		knockback_velocity += direction * force

func process_knockback(delta: float) -> Vector3:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
		return knockback_velocity
