extends BaseWeaponsManager
class_name EnemyWeaponsManager

signal target_acquired(target: Object)

@export_category("Weapon Setup")
@export var weapon: WeaponItem
@export var sight_raycast: RayCast3D
@export var muzzle_offset: Vector3 = Vector3(0.0, 1.2, -0.6)

@export_category("AI Difficulty")
@export_range(0.0, 15.0) var inaccuracy_degrees: float = 4.0
@export var fire_rate: float = 5.0
@export var burst_size: int = 3
@export var burst_cooldown: float = 1.2

var current_target: Node3D = null
var fire_timer: float = 0.0
var burst_timer: float = 0.0
var shots_in_burst: int = 0

func _get_target_groups() -> Array[String]:
	return ["Player"]

func _ready() -> void:
	if not weapon:
		queue_free()
		return

	current_weapon = weapon
	sight_raycast.target_position.z = -weapon.attack_range

func _physics_process(delta: float) -> void:
	if fire_timer > 0.0: fire_timer -= delta
	if burst_timer > 0.0: burst_timer -= delta

	current_target = null

	if sight_raycast.is_colliding():
		var collider := sight_raycast.get_collider()
		if is_instance_valid(collider) and not collider.is_queued_for_deletion():
			if collider.has_method("take_damage") and collider.is_in_group("Player"):
				current_target = collider
				target_acquired.emit(current_target)
				_try_to_shoot()

func _try_to_shoot() -> void:
	if get_loaded_ammo(weapon.ammo_type) <= 0:
		reload()
		return

	if burst_timer > 0.0 or fire_timer > 0.0:
		return

	match(weapon.try_use(self)):
		WeaponItem.UseResult.SUCCESS:
			_calculate_and_fire()
		var reason:
			reload()
			weapon_failed_to_fire.emit(weapon, reason)

func _calculate_and_fire() -> void:
	shots_in_burst += 1
	if shots_in_burst >= burst_size:
		shots_in_burst = 0
		burst_timer = burst_cooldown
	else:
		fire_timer = 1.0 / fire_rate

	var attacker := _get_attacker()

	var origin = attacker.to_global(muzzle_offset)
	var perfect_dir = origin.direction_to(sight_raycast.get_collision_point())

	var spread = deg_to_rad(inaccuracy_degrees)
	var final_dir = perfect_dir.rotated(Vector3.UP, randf_range(-spread, spread)).rotated(Vector3.RIGHT, randf_range(-spread, spread))
	before_weapon_fired.emit(weapon, origin, final_dir)
	_execute_combat(origin, final_dir)
	weapon_fired.emit(weapon, origin, final_dir)
