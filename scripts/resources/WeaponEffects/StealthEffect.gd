extends WeaponEffect
class_name StealthEffect

# Weapons with this effect will not trigger enemy reactions.

func apply(payload: HitPayload) -> void:
    payload.is_stealthy = true
