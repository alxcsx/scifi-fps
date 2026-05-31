extends RigidBody3D

func _ready() -> void:
	freeze = true
	body_entered.connect(_on_body_entered)



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		freeze = false
		$Timer.start()



func _on_timer_timeout() -> void:
	queue_free()














