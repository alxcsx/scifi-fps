extends WeaponEffect
class_name PiercingEffect

@export var max_pierces: int = 1
@export_range(0.0, 1.0) var pierce_damage_retention: float = 0.5

func apply(payload: HitPayload) -> void:
		payload.is_piercing = true
		payload.max_pierces += max_pierces
		payload.pierce_damage_retention = pierce_damage_retention















