extends Item
class_name WeaponItem

enum WeaponType {
	NONE,
	PISTOL,
	RIFLE,
	FLASHLIGHT,
	MELEE,
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

@export_category("Sight")
@export var zoom_enabled: bool = true
@export var zoom_fov: float = 40.0

@export_category("Modifiers")
@export var effects: Array[WeaponEffect] = []

func create_hit_payload(attacker: Node3D) -> HitPayload:
		var payload = HitPayload.new()
		payload.damage = self.damage
		payload.source_position = attacker.global_position

		for effect in effects:
				effect.apply(payload)

		return payload
