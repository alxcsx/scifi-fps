extends BaseEntity
class_name Enemy

@onready var ai_manager: ChasingAIManager = get_node_or_null("%AIManager")
@onready var sprite: DirectionalSprite3D = get_node_or_null("%Sprite")

func _ready() -> void:
  super();
  movement_manager = ai_manager
  _setup_sprite()
  _setup_ai_manager()

func _setup_sprite() -> void:
  if sprite:
    sprite.freeze_animation = true
  else:
    print_verbose("Enemy has no DirectionalSprite3D! It will not have proper animations.")

func _setup_ai_manager() -> void:
  if ai_manager:
    ai_manager.started_chasing.connect(_on_chase_started)
    ai_manager.stopped_chasing.connect(_on_chase_stopped)
  else:
    print_verbose("Enemy has no AIManager! It will not be able to chase the player.")

func _physics_process(delta: float) -> void:
  super._physics_process(delta)

  var raw_velocity := velocity - movement_manager.knockback_velocity
  var horizontal_velocity := Vector3(raw_velocity.x, 0, raw_velocity.z)
  if horizontal_velocity.length_squared() > 0.1:
    var look_target := global_position + horizontal_velocity
    look_at(look_target, Vector3.UP)

## Health | Combat
func take_damage(payload: HitPayload) -> void:
    super.take_damage(payload)
    if ai_manager and not payload.is_stealthy:
      ai_manager.investigate(payload.source_position)

func _on_died() -> void:
  print("Enemy destroyed!")
  queue_free()

## AI

func _on_chase_started() -> void:
  if sprite:
    sprite.freeze_animation = false

func _on_chase_stopped() -> void:
  if sprite:
    sprite.freeze_animation = true
