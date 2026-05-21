extends WeaponEffect
class_name KnockbackEffect

@export var force: float = 10.0

func apply(payload: HitPayload) -> void:
    payload.knockback += force
