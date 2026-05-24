extends Item
class_name WeaponItem

enum WeaponType {
	NONE,
	PISTOL,
	RIFLE,
	FLASHLIGHT,
	MELEE,
	KEY, # temp
}

enum UseResult {
	SUCCESS,
	NO_AMMO,
	NOT_EQUIPPED,
}

@export var weaponType: WeaponType = WeaponType.NONE

@export_category("Weapon Stats")
@export var damage: float = 10.0
@export var fire_rate: float = 0.2
@export var attack_range: float = 50.0

@export_category("Ammo")
@export var starting_ammo: int = 20
@export var ammo_type: AmmoItem.AmmoType = AmmoItem.AmmoType.BULLETS
@export var ammo_cost: int = 1
@export var magazine_size: int = 6

@export_category("Sight")
@export var zoom_enabled: bool = true
@export var zoom_fov: float = 40.0

@export_category("Modifiers")
@export var effects: Array[WeaponEffect] = []

func create_hit_payload(origin: Vector3, direction: Vector3) -> HitPayload:
		var payload = HitPayload.new()
		payload.damage = self.damage
		payload.source_position = origin
		payload.hit_direction = direction

		for effect in effects:
				effect.apply(payload)

		return payload

func try_use(manager: BaseWeaponsManager) -> UseResult:
	if not manager or manager.current_weapon != self: return UseResult.NOT_EQUIPPED
	if ammo_cost == 0 or ammo_type == AmmoItem.AmmoType.NONE:
		return UseResult.SUCCESS
	elif manager.has_ammo(ammo_type, ammo_cost):
		manager.spend_ammo(ammo_cost)
		return UseResult.SUCCESS

	return UseResult.NO_AMMO
