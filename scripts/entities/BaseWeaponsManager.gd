class_name BaseWeaponsManager
extends Node

signal weapon_failed_to_fire(weapon_data: WeaponItem, reason: WeaponItem.UseResult)
signal before_weapon_fired(weapon_data: WeaponItem, origin: Vector3, direction: Vector3)
signal weapon_fired(weapon_data: WeaponItem, origin: Vector3, direction: Vector3)
signal ammo_changed(current_ammo: int)

var current_weapon: WeaponItem

var hold_fire: bool = false
var current_loaded_ammo: Dictionary[AmmoItem.AmmoType, int] = {}
var last_fire_time: float = 0.0

func get_loaded_ammo(type: AmmoItem.AmmoType) -> int:
  return current_loaded_ammo.get(type, 0)

func has_ammo(type: AmmoItem.AmmoType, amount: int) -> bool:
  return get_loaded_ammo(type) >= amount

func reload() -> void:
  if current_weapon == null: return
  load_ammo(current_weapon.ammo_type, current_weapon.magazine_size - get_loaded_ammo(current_weapon.ammo_type))

func load_ammo(type: AmmoItem.AmmoType, amount: int) -> void:
  if amount == 0: return
  current_loaded_ammo[type] = get_loaded_ammo(type) + amount
  ammo_changed.emit(current_loaded_ammo[type])

func equip_weapon(_weaponType: WeaponItem.WeaponType) -> void:
  pass

func spend_ammo(amount: int) -> void:
  var type := current_weapon.ammo_type
  if current_loaded_ammo.has(type):
    current_loaded_ammo[type] -= amount
    if current_loaded_ammo[type] <= 0:
      current_loaded_ammo.erase(type)
    ammo_changed.emit(current_loaded_ammo.get(type, 0))

func request_fire() -> void:
  if current_weapon == null or hold_fire: return
  var attacker := _get_attacker()
  var origin := attacker.global_position
  var direction := -attacker.global_transform.basis.z.normalized()

  var current_time := Time.get_ticks_msec() / 1000.0
  if current_time - last_fire_time < current_weapon.fire_rate:
    return
    
  match current_weapon.try_use(self):
    WeaponItem.UseResult.SUCCESS:
      last_fire_time = current_time
      before_weapon_fired.emit(current_weapon, origin, direction)
      _execute_combat(origin, direction)
      weapon_fired.emit(current_weapon, origin, direction)
    var reason:
      weapon_failed_to_fire.emit(current_weapon, reason)

func _get_attacker() -> Node3D:
  return owner as Node3D

func _get_target_groups() -> Array[String]:
  return []

func _execute_combat(origin: Vector3, direction: Vector3) -> void:
  var attacker := _get_attacker()
  var space_state := attacker.get_world_3d().direct_space_state
  var end_pos := origin + (direction * current_weapon.attack_range)

  var query := PhysicsRayQueryParameters3D.create(origin, end_pos)
  var excluded_rids := []

  if attacker is CollisionObject3D:
    excluded_rids.append(attacker.get_rid())
  query.exclude = excluded_rids

  var hit_payload := current_weapon.create_hit_payload(origin, direction)
  var max_hits := hit_payload.max_pierces + 1 if hit_payload.is_piercing else 1
  var current_damage := hit_payload.damage
  var hits := 0
  var target_groups: Array[String] = _get_target_groups()

  while hits < max_hits:
    var result := space_state.intersect_ray(query)

    if result.is_empty():
      break

    var target = result.collider

    if target is BaseEntity and target != attacker:
      if target_groups.size() > 0 and not target_groups.any(target.is_in_group):
        print("Hit object %s is not in target groups, ignoring." % target.name)
        break

      var exact_hit_direction = origin.direction_to(result.position)
      target.take_damage(hit_payload.clone({"damage": current_damage, "hit_direction": exact_hit_direction}))
      current_damage *= hit_payload.pierce_damage_retention

      excluded_rids.append(result.rid)
      query.exclude = excluded_rids
      hits += 1
    else:
      break
