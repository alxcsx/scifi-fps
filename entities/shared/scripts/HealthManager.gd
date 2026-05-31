extends Node
class_name HealthManager
# Tracks Health for an entity (players or enemies)

signal health_changed(current_health: float, max_health: float)
signal entity_died()

@export var max_health: float = 100.0
@onready var current_health: float = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0: return

	current_health -= amount
	current_health = max(current_health, 0.0)
	print("%s took damage! Health: %d" % [owner.name, current_health])
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		_die()

func heal(amount: float) -> void:
	if current_health <= 0 or current_health >= max_health:
		return

	current_health += amount
	current_health = min(current_health, max_health)
	print("%s healed! Health: %d" % [owner.name, current_health])
	health_changed.emit(current_health, max_health)

func _die() -> void:
	print("%s has died!" % [owner.name])
	entity_died.emit()














