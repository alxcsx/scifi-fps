extends Control
class_name BaseWeaponView

@export 	var weapon_data: WeaponItem
@onready 	var anim_player: AnimationPlayer = $AnimationPlayer

signal fired(weapon_data: WeaponItem)

func _ready() -> void:
  hide();

func is_busy() -> bool: return anim_player.is_playing()

func use(inventory: PlayerInventoryManager) -> void:
  if is_busy() or not weapon_data: return

  if _use_ammo(inventory):
    fired.emit(weapon_data)
    play_shoot_effects()

func play_shoot_effects() -> void:
  anim_player.stop()
  if anim_player.has_animation("shoot"): anim_player.play("shoot")

func play_equip_effects() -> void:
  if anim_player.has_animation("equip"): anim_player.play("equip")

func _use_ammo(inventory: PlayerInventoryManager) -> bool:
  if not weapon_data: return false
  var type := weapon_data.ammo_type
  var cost := weapon_data.ammo_cost

  if inventory.ammo_inventory.has(type) and inventory.ammo_inventory[type] >= cost:
    inventory.add_ammo(type, -cost)
    return true
  return false

func equip() -> void:
  show()
  play_equip_effects()

func unequip() -> void:
  anim_player.stop()
  hide()
