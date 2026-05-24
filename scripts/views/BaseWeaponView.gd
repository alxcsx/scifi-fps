extends Control
class_name BaseWeaponView

@export var weapon_data  : Item
@export var texture			: TextureRect
@export var anim_player  : AnimationPlayer
@export var audio_player : AudioStreamPlayer2D

func _ready() -> void:
  hide();

func is_busy() -> bool: return anim_player and anim_player.is_playing()

func setup(manager: BaseWeaponsManager) -> void:
  manager.weapon_fired.connect(_on_weapon_fired)

func _on_weapon_fired(weapon: WeaponItem, _origin: Vector3, _direction: Vector3) -> void:
  if is_busy() or not weapon_data: return
  if weapon == weapon_data:
    play_shoot_effects()

func on_reload():
  if anim_player and anim_player.has_animation("reload"):
    anim_player.play("reload")
    await anim_player.animation_finished
  else:
    await get_tree().process_frame

func play_shoot_effects() -> void:
  print("Playing shoot effects for %s. Has %s" % weapon_data.item_name, anim_player.get_animation_list())
  if not anim_player: return
  anim_player.stop()
  if anim_player.has_animation("shoot"):
    print("has shoot animatino")
    anim_player.play("shoot")

func play_equip_effects() -> void:
  if not anim_player: return
  if anim_player.has_animation("equip"): anim_player.play("equip")

func equip() -> void:
  show()
  play_equip_effects()

func unequip() -> void:
  if anim_player:
    anim_player.stop()
  hide()
