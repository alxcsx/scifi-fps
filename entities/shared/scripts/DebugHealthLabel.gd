extends Label3D
class_name DebugHealthLabel

@export var health_manager: HealthManager

func _ready() -> void:
	if not health_manager:
		health_manager = %HealthManager


	if health_manager:
		health_manager.health_changed.connect(_on_health_changed)
		_update_text(health_manager.current_health, health_manager.max_health)
	else:
		text = "HP: ???!"
		push_warning("DebugHealthLabel on " + str(owner.name) + " is missing a HealthManager!")

func _on_health_changed(current_health: float, max_health: float) -> void:
	_update_text(current_health, max_health)

func _update_text(current: float, maximum: float) -> void:
	text = "HP: %s / %s" % [str(current), str(maximum)]














