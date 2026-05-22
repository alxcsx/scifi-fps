extends BaseWeaponsManager
class_name PlayerWeaponsManager

signal weapon_equipped(weapon: WeaponItem)
signal weapon_unequipped(weapon: WeaponItem)

@export var player_vision: PlayerVision
@export var camera: Camera3D
@export var zoom_lerp_speed: float = 12.0

@onready var inventory: PlayerInventoryManager = %InventoryManager
@onready var crosshair_ui: TextureRect = $WeaponsHUD/UI_Root/CrossHair

var views: Dictionary[WeaponItem.WeaponType, BaseWeaponView] = {}

var is_zooming: bool = false
var default_camera_fov: float = 75.0
var weapon_zoom_fov: float = 75.0

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("shoot"):
    request_fire()
  elif event.is_action_pressed("weapon_next"):
    equip_weapon(_get_next_unlocked_weapon(1))
  elif event.is_action_pressed("weapon_prev"):
    equip_weapon(_get_next_unlocked_weapon(-1))
  elif event.is_action_pressed("reload"):
    reload()
  elif event is InputEventMouseButton and event.is_action_pressed("zoom"):
    is_zooming = not is_zooming

func _physics_process(delta: float) -> void:
  if camera:
    var target_fov := weapon_zoom_fov if is_zooming else default_camera_fov
    camera.fov = lerp(camera.fov, target_fov, zoom_lerp_speed * delta)

func _ready() -> void:
  if not inventory:
    push_error("No PlayerInventoryManager found! Weapons will not function without it.")
    queue_free();
    return;
  if camera == null: camera = %Camera
  if camera:
    default_camera_fov = camera.fov
    weapon_zoom_fov = camera.fov
  if player_vision:
    player_vision.targeting_enemy.connect(_on_target_enemy)

  inventory.weapon_unlocked.connect(_on_weapon_unlocked)
  inventory.ammo_changed.connect(
    func(ammo_type, _new_amount):
      if current_weapon and ammo_type == current_weapon.ammo_type:
        ammo_changed.emit(get_loaded_ammo(ammo_type))
  )

  for c in %Weapons.get_children():
    if c is BaseWeaponView:
      _setup_weapon_view(c)

func _setup_weapon_view(weapon_view: BaseWeaponView) -> void:
  if not weapon_view.weapon_data:
    push_warning("Weapon view '%s' has no weapon data assigned!" % weapon_view.name)
    weapon_view.queue_free()
    return

  print("Registering weapon view: %s" % weapon_view.name)
  weapon_view.hide()
  weapon_view.setup(self)
  views.set(weapon_view.weapon_data.weaponType, weapon_view)

func reload() -> void:
  if not current_weapon: return;

  var current_ammo := get_loaded_ammo(current_weapon.ammo_type)
  var max_ammo := current_weapon.magazine_size
  if current_ammo >= max_ammo: return

  hold_fire = true
  await get_current_view().on_reload()
  hold_fire = false

  var bullets_needed = max_ammo - current_ammo
  var reserve = inventory.get_ammo_count(current_weapon.ammo_type)

  if reserve <= 0: return

  var bullets_to_load = min(bullets_needed, reserve)
  inventory.add_ammo(current_weapon.ammo_type, -bullets_to_load, false)
  load_ammo(current_weapon.ammo_type, bullets_to_load)

func get_current_view() -> BaseWeaponView:
  return views.get(current_weapon.weaponType, null)

func equip_weapon(type: WeaponItem.WeaponType) -> void:
  if type == WeaponItem.WeaponType.NONE or not views.has(type): return
  if current_weapon and current_weapon.weaponType == type: return

  if current_weapon:
    views[current_weapon.weaponType].unequip()
    weapon_unequipped.emit(views[current_weapon.weaponType].weapon_data)
    print("Unequipping weapon: %s" % views[current_weapon.weaponType].name)

  print("Equipping weapon: %s" % views[type].name)
  current_weapon = views[type].weapon_data
  views[type].equip()

  # ZOOM
  weapon_zoom_fov = current_weapon.zoom_fov if current_weapon.zoom_enabled else default_camera_fov
  is_zooming = false
  # Range Detection
  player_vision.current_weapon_range = current_weapon.attack_range
  #
  weapon_equipped.emit(current_weapon)

func _get_next_unlocked_weapon(direction: int) -> WeaponItem.WeaponType:
  if not current_weapon or inventory.unlocked_weapons.is_empty():
    return WeaponItem.WeaponType.NONE

  var current_index := inventory.unlocked_weapons.find(current_weapon.weaponType)
  var next_index := (current_index + direction) % inventory.unlocked_weapons.size()
  if next_index < 0:
    next_index = inventory.unlocked_weapons.size() - 1

  return inventory.unlocked_weapons.get(next_index)

func _on_weapon_unlocked(weaponType: WeaponItem.WeaponType) -> void:
  print("Weapon unlocked: %s" % [weaponType])
  if views.has(weaponType):
    equip_weapon(weaponType)
    reload()
  else:
    push_warning("Unlocked weapon '%s' not found in views list!" % weaponType)

func _on_target_enemy(is_targeting: bool) -> void:
  print("Targeting enemy: %s" % is_targeting)
  if crosshair_ui:
    crosshair_ui.modulate = Color(1, 0, 0) if is_targeting else Color(1, 1, 1)
