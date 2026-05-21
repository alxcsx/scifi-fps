extends WeaponEffect
class_name PiercingEffect

@export var max_pierces: int = 1

func apply(payload: HitPayload) -> void:
    payload.is_piercing = true
    payload.max_pierces += max_pierces
