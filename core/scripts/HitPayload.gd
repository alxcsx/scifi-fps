extends RefCounted
class_name HitPayload

var damage: float = 0.0
var knockback: float = 0.0
var hit_direction: Vector3 = Vector3.ZERO
var source_position: Vector3 = Vector3.ZERO
var is_stealthy: bool = false

var is_piercing: bool = false
var max_pierces: int = 0
var pierce_damage_retention: float = 1.0

func clone(overrides: Dictionary = {}) -> HitPayload:
  var copy = HitPayload.new()

  for property in get_property_list():
    var name = property.name
    copy.set(name, overrides.get(name, self.get(name)))

  return copy














