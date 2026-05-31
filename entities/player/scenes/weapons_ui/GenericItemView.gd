extends BaseWeaponView
class_name GenericItemView

func _ready() -> void:
  super._ready()
  if weapon_data and weapon_data.icon:
    texture.texture = weapon_data.icon














