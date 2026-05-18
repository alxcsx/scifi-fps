extends Node
class_name PlayerWeaponsManager

signal weapon_fired(weapon:WeaponItem, damage: float)
signal weapon_equipped(weapon: WeaponItem)
signal weapon_unequipped(weapon: WeaponItem)

@export var ammo_label: Label
@onready var inventory: PlayerInventoryManager = %InventoryManager

# This serves as our master dictionary/list of all possible weapon views in the game layout
var weapons: Array[BaseWeaponView] = []
var current_weapon_index := -1

func _ready() -> void:
  for c in %Weapons.get_children():
    if c is BaseWeaponView:
      print("Registering weapon view: %s" % c.name)
      c.hide()
      weapons.append(c)

  if not inventory:
    push_error("No PlayerInventoryManager found! Weapons will not function without it.")
    return;

  inventory.ammo_changed.connect(_on_ammo_changed)
  inventory.weapon_unlocked.connect(_on_weapon_unlocked)

  for w in weapons:
    var data := w.weapon_data
    if data and inventory.unlocked_weapons.has(data.weaponType):
      w.is_unlocked = true

  _update_ammo_display()

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("shoot"):
    _shoot()
  elif event.is_action_pressed("weapon_next"):
    equip_weapon(_get_next_unlocked_weapon_index(1))
  elif event.is_action_pressed("weapon_prev"):
    equip_weapon(_get_next_unlocked_weapon_index(-1))

func _shoot() -> void:
  var current_weapon := get_current_weapon()

  if not current_weapon: return;
  if not current_weapon.weapon_data: return;
  if current_weapon.is_busy(): return

  var data := current_weapon.weapon_data
  if inventory.ammo_inventory.has(data.ammo_type) and inventory.ammo_inventory[data.ammo_type] >= data.ammo_cost:
    inventory.add_ammo(data.ammo_type, -data.ammo_cost)
    current_weapon.play_shoot_effects()
    print("Fired weapon: %s, dealing %f damage!" % [data.weaponType, data.damage])
    weapon_fired.emit(data, data.damage)

func get_current_weapon() -> BaseWeaponView:
  if current_weapon_index == -1 or weapons.size() == 0: return null
  return weapons[current_weapon_index]

func equip_weapon(index: int) -> void:
  if index < 0 or index >= weapons.size() or index == current_weapon_index: return;
  if not weapons[index].is_unlocked: return;

  if current_weapon_index >= 0:
    weapons[current_weapon_index].deactivate()
    weapon_unequipped.emit(weapons[current_weapon_index].weapon_data)
    print("Unequipping weapon: %s" % weapons[current_weapon_index].name)

  print("Equipping weapon: %s" % weapons[index].name)
  current_weapon_index = index
  var new_weapon := weapons[current_weapon_index]
  new_weapon.activate()
  weapon_equipped.emit(new_weapon.weapon_data)
  _update_ammo_display()

func _get_next_unlocked_weapon_index(direction: int) -> int:
  var max_weapons = weapons.size()
  var start_search_index = 0 if current_weapon_index == -1 else current_weapon_index

  for i in range(1, max_weapons + 1):
    var check_index = (start_search_index + (direction * i) + max_weapons) % max_weapons
    if weapons[check_index].is_unlocked:
      return check_index

  return -1

func _on_ammo_changed(type: AmmoItem.AmmoType, _new_amount: int) -> void:
  var current_weapon := get_current_weapon()
  if not current_weapon: return

  var current_type = current_weapon.weapon_data.ammo_type
  if current_type == type:
    _update_ammo_display()

func _on_weapon_unlocked(weaponType: WeaponItem.WeaponType) -> void:
  var id := weapons.find_custom(func(w: BaseWeaponView): return w.weapon_data.weaponType == weaponType)
  print("Weapon unlocked: %s (%d)" % [weaponType, id])
  if id != -1:
    weapons[id].is_unlocked = true
    equip_weapon(id)
  else:
    push_warning("Unlocked weapon '%s' not found in weapons list!" % weaponType)

func _update_ammo_display() -> void:
  if not ammo_label or not inventory: return
  var current_weapon := get_current_weapon()

  if not current_weapon or not current_weapon.weapon_data or current_weapon.weapon_data.ammo_type == AmmoItem.AmmoType.NONE:
    ammo_label.text = "---"
    return

  var current_type = weapons[current_weapon_index].weapon_data.ammo_type
  var amount = inventory.ammo_inventory.get(current_type, 0)

  ammo_label.text = str(amount)
