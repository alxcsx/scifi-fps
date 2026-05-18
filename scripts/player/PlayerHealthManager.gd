extends Node
class_name PlayerHealthManager

signal health_changed(current_health: float, max_health: float)
signal player_died()

@export var max_health: float = 100.0
@onready var current_health: float = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0: return

	current_health -= amount
	current_health = max(current_health, 0.0)
	print("Player took damage! Health: ", current_health)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		_die()

func heal(amount: float) -> void:
	if current_health <= 0 or current_health >= max_health:
		return

	current_health += amount
	current_health = min(current_health, max_health)
	print("Player healed! Health: ", current_health)
	health_changed.emit(current_health, max_health)

func _die() -> void:
	print("Player has died!")
	player_died.emit()
