extends CharacterBody3D
class_name Enemy

@onready var health_manager: HealthManager = %HealthManager


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if health_manager:
		health_manager.player_died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func take_damage(amount: float) -> void:
	if health_manager:
		health_manager.take_damage(amount)

func _on_died() -> void:
	print("Enemy destroyed!")
	queue_free()
