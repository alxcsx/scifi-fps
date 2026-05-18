extends Control
class_name BaseWeaponView

@export 	var weapon_data: WeaponItem
@onready 	var anim_player: AnimationPlayer = $AnimationPlayer

var is_unlocked := false

func is_busy() -> bool: return anim_player.is_playing()

func play_shoot_effects() -> void:
  anim_player.stop()
  if anim_player.has_animation("shoot"): anim_player.play("shoot")

func play_equip_effects() -> void:
  if anim_player.has_animation("equip"): anim_player.play("equip")

func activate() -> void:
  show()
  play_equip_effects()

func deactivate() -> void:
  anim_player.stop()
  hide()
