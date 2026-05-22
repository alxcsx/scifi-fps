extends Control
class_name BaseWeaponView

@export 	var weapon_data: WeaponItem
@onready 	var anim_player: AnimationPlayer = $AnimationPlayer

signal fired(weapon_data: WeaponItem)

func _ready() -> void:
	hide();

func is_busy() -> bool: return anim_player.is_playing()

func use(manager: PlayerWeaponsManager) -> void:
	if is_busy() or not weapon_data: return

	if _use_ammo(manager):
		fired.emit(weapon_data)
		play_shoot_effects()

func on_reload():
	pass # TODO: add animaçõo

func play_shoot_effects() -> void:
	anim_player.stop()
	if anim_player.has_animation("shoot"): anim_player.play("shoot")

func play_equip_effects() -> void:
	if anim_player.has_animation("equip"): anim_player.play("equip")

func _use_ammo(manager: PlayerWeaponsManager) -> bool:
	if not weapon_data: return false
	var type := weapon_data.ammo_type
	var cost := weapon_data.ammo_cost

	return manager.use_ammo(type, cost)

func equip() -> void:
	show()
	play_equip_effects()

func unequip() -> void:
	anim_player.stop()
	hide()
