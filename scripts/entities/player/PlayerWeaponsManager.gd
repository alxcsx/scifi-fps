extends Node
class_name PlayerWeaponsManager

signal weapon_fired(weapon:WeaponItem)
signal weapon_equipped(weapon: WeaponItem)
signal weapon_unequipped(weapon: WeaponItem)

@export var player_vision: PlayerVision
@export var camera: Camera3D
@export var zoom_lerp_speed: float = 12.0

@onready var inventory: PlayerInventoryManager = %InventoryManager
@onready var crosshair_ui: TextureRect = $WeaponsHUD/UI_Root/CrossHair

var weapons: Array[BaseWeaponView] = []
var current_weapon_index := -1
var hold_fire: bool = false
var is_zooming: bool = false
var default_camera_fov: float = 75.0
var weapon_zoom_fov: float = 75.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot()
	elif event.is_action_pressed("weapon_next"):
		equip_weapon(_get_next_unlocked_weapon_index(1))
	elif event.is_action_pressed("weapon_prev"):
		equip_weapon(_get_next_unlocked_weapon_index(-1))

	if event is InputEventMouseButton and event.is_action_pressed("zoom"):
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
	for c in %Weapons.get_children():
		if c is BaseWeaponView:
			_setup_weapon_view(c)

func _setup_weapon_view(weapon_view: BaseWeaponView) -> void:
	if not weapon_view.weapon_data:
		push_warning("Weapon view '%s' has no weapon data assigned!" % weapon_view.name)
		weapon_view.queue_free()
		return

	print("Registering weapon view: %s" % weapon_view.name)
	weapon_view.fired.connect(weapon_fired.emit)
	weapon_view.hide()
	weapons.append(weapon_view)

func _shoot() -> void:
	if hold_fire: return
	var current_weapon := get_current_weapon()
	if not current_weapon: return;

	current_weapon.use(inventory)


func get_current_weapon() -> BaseWeaponView:
	if current_weapon_index == -1 or weapons.size() == 0: return null

	return weapons[current_weapon_index]

func equip_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size() or index == current_weapon_index: return;
	if not inventory.is_weapon_unlocked(weapons[index].weapon_data.weaponType): return;

	if current_weapon_index >= 0:
		weapons[current_weapon_index].unequip()
		weapon_unequipped.emit(weapons[current_weapon_index].weapon_data)
		print("Unequipping weapon: %s" % weapons[current_weapon_index].name)

	print("Equipping weapon: %s" % weapons[index].name)
	current_weapon_index = index
	var new_weapon := weapons[current_weapon_index]
	new_weapon.equip()
	weapon_equipped.emit(new_weapon.weapon_data)

	player_vision.current_weapon_range = new_weapon.weapon_data.attack_range
	weapon_zoom_fov = new_weapon.weapon_data.zoom_fov if new_weapon.weapon_data.zoom_enabled else default_camera_fov
	is_zooming = false

	print("Current weapon range set to: %f" % player_vision.current_weapon_range)

func _get_next_unlocked_weapon_index(direction: int) -> int:
	var max_weapons := weapons.size()
	var start_search_index := 0 if current_weapon_index == -1 else current_weapon_index

	for i in range(1, max_weapons + 1):
		var check_index := (start_search_index + (direction * i) + max_weapons) % max_weapons
		var weapon_type := weapons[check_index].weapon_data.weaponType
		if inventory.is_weapon_unlocked(weapon_type):
			return check_index

	return -1

func _on_weapon_unlocked(weaponType: WeaponItem.WeaponType) -> void:
	var id := weapons.find_custom(func(w: BaseWeaponView): return w.weapon_data.weaponType == weaponType)
	print("Weapon unlocked: %s (%d)" % [weaponType, id])
	if id != -1:
		equip_weapon(id)
	else:
		push_warning("Unlocked weapon '%s' not found in weapons list!" % weaponType)

func _on_target_enemy(is_targeting: bool) -> void:
	print("Targeting enemy: %s" % is_targeting)
	if crosshair_ui:
		crosshair_ui.modulate = Color(1, 0, 0) if is_targeting else Color(1, 1, 1)
