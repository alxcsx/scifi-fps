extends Node
class_name PlayerWeaponsManager

signal weapon_fired(weapon:WeaponItem)
signal weapon_equipped(weapon: WeaponItem)
signal weapon_unequipped(weapon: WeaponItem)

@export var ammo_label: Label
@onready var inventory: PlayerInventoryManager = %InventoryManager

# This serves as our master dictionary/list of all possible weapon views in the game layout
var weapons: Array[BaseWeaponView] = []
var current_weapon_index := -1

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("shoot"):
    _shoot()
  elif event.is_action_pressed("weapon_next"):
    equip_weapon(_get_next_unlocked_weapon_index(1))
  elif event.is_action_pressed("weapon_prev"):
    equip_weapon(_get_next_unlocked_weapon_index(-1))

func _ready() -> void:
  if not inventory:
    push_error("No PlayerInventoryManager found! Weapons will not function without it.")
    queue_free();
    return;

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
