extends BaseEntity
class_name Player

@export var combat_raycast: RayCast3D
# Managers
@onready var CameraManager: MouseCameraManager = %CameraManager
@onready var weapons_manager: PlayerWeaponsManager = %WeaponsManager
@onready var inventory_manager: PlayerInventoryManager = %InventoryManager
@onready var interaction_manager: PlayerInteractionManager = %InteractionManager
@onready var player_vision: PlayerVision = %PlayerVision

@onready var camera_pivot: Node3D = %Pivot

func _ready() -> void:
  super();
  movement_manager = %MovementManager
  inventory_manager.item_picked_up.connect(_on_item_picked_up)
  player_vision.targeting_interactable.connect(_on_is_looking_at_interactable)
  weapons_manager.weapon_fired.connect(_on_weapon_fired)

func _on_is_looking_at_interactable(is_targeting: bool, _interactable: Node3D) -> void:
  weapons_manager.hold_fire = is_targeting

func _on_item_picked_up(item_data: Item) -> void:
  if item_data is HealthItem:
    heal(item_data.heal_amount)

func _on_weapon_fired(weapon_data: WeaponItem) -> void:
  var payload := weapon_data.create_hit_payload(self)
  payload.hit_direction = -combat_raycast.global_transform.basis.z.normalized()

  var space_state := get_world_3d().direct_space_state
  var origin := combat_raycast.global_position
  var direction := -combat_raycast.global_transform.basis.z.normalized()
  var end_pos := origin + (direction * weapon_data.attack_range)

  var query := PhysicsRayQueryParameters3D.create(origin, end_pos)
  var excluded_rids := []
  query.exclude = excluded_rids

  # Piercing Logic. If the weapon has no piercing effect then max_hits will be 1 and it will behave like a normal raycast.
  var hits := 0
  var max_hits := payload.max_pierces + 1 if payload.is_piercing else 1
  var current_damage := payload.damage
  while hits < max_hits:
    var result := space_state.intersect_ray(query)
    if result:
        var target = result.collider
        if target is BaseEntity and target != self:
            target.take_damage(payload.clone({"damage": current_damage}))
            current_damage = current_damage * payload.pierce_damage_retention;

        excluded_rids.append(result.rid)
        query.exclude = excluded_rids
        hits += 1
    else:
        break

func _on_died() -> void:
  print("Game Over! :p")
