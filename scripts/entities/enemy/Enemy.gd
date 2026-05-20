extends CharacterBody3D
class_name Enemy

@onready var health_manager: HealthManager = get_node_or_null("%HealthManager")
@onready var ai_manager: ChasingAIManager = get_node_or_null("%AIManager")
@onready var sprite: DirectionalSprite3D = get_node_or_null("%Sprite")

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
  _setup_health_manager()
  _setup_sprite()
  _setup_ai_manager()

func _setup_health_manager() -> void:
  if health_manager:
    health_manager.player_died.connect(_on_died)
  else:
    print_verbose("Enemy has no HealthManager! It will not be able to take damage or die.")

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
  if not is_on_floor():
    velocity.y -= gravity * delta

  if ai_manager and ai_manager.has_method("calculate_movement"):
    var ai_velocity: Vector3 = ai_manager.calculate_movement(self, delta)
    velocity.x = ai_velocity.x
    velocity.z = ai_velocity.z

  var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
  if horizontal_velocity.length_squared() > 0.1:
    var look_target := global_position + horizontal_velocity
    look_at(look_target, Vector3.UP)

  move_and_slide()

## Health | Combat

func take_damage(amount: float) -> void:
  if health_manager:
    health_manager.take_damage(amount)

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
