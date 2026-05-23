extends BaseWeaponView
class_name FlashlightView

var flashlight: SpotLight3D

var is_on := false

func _ready() -> void:
	super._ready()
	var player: Player = get_tree().get_first_node_in_group("Player")
	if player:
		flashlight = player.get_node_or_null("%PlayerFlashlight")

	if not flashlight:
		push_error("FlashlightView: Could not find %PlayerFlashlight in the Player scene!")
	else:
		flashlight.hide()

func play_shoot_effects() -> void:
	if not flashlight: return 
	
	is_on = !is_on
	flashlight.visible = is_on
	anim_player.stop()
	
	if is_on:
		if anim_player.has_animation("turn_on"):
			anim_player.play("turn_on")
	else:
		if anim_player.has_animation("turn_off"):
			anim_player.play("turn_off")

func unequip() -> void:
	is_on = false
	if flashlight:
		flashlight.hide()
	super.unequip()

