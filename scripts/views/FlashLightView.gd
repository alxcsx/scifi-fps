extends BaseWeaponView
class_name FlashlightView

@export var flashlight: SpotLight3D

var is_on := false

func _ready() -> void:
	super._ready()
	if not flashlight:
		push_error("FlashlightView: No 3D flashlight assigned!")
	else:
		flashlight.hide()

func use(_manager: PlayerWeaponsManager) -> void:
	if is_busy() or not weapon_data: return
	is_on = !is_on
	flashlight.visible = is_on
	fired.emit(weapon_data)
	play_shoot_effects()

func play_shoot_effects() -> void:
	anim_player.stop()
	if is_on:
		if anim_player.has_animation("turn_on"):
			anim_player.play("turn_on")
	else:
		if anim_player.has_animation("turn_off"):
			anim_player.play("turn_off")

func unequip() -> void:
	is_on = false
	flashlight.hide()
	super.unequip()
