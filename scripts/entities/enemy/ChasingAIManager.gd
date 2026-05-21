extends BaseMovementManager
class_name ChasingAIManager

signal started_chasing
signal stopped_chasing

@export var chasing_group: String = "Player"
@export var move_speed: float = 3.0
@export var field_of_view: float = 90.0

@onready var detectable_area: Area3D = $DetectableArea
@onready var sight_raycast: RayCast3D = $SightRayCast
@onready var nav_agent: NavigationAgent3D = $NavAgent

var potential_targets: Array[Node3D] = []
var current_target: Node3D = null

enum AIState { IDLE, CHASE, INVESTIGATING, RETURNING }
var current_state: AIState = AIState.IDLE

@onready var investigate_position := Vector3.ZERO
@onready var original_idle_position := Vector3.ZERO
@onready var investigation_timer := Timer.new();

func _ready() -> void:
	detectable_area.body_entered.connect(_on_body_entered)
	detectable_area.body_exited.connect(_on_body_exited)
	investigation_timer.one_shot = true
	investigation_timer.timeout.connect(_on_investigation_timeout)
	add_child(investigation_timer)

func investigate(source_pos: Vector3) -> void:
	if current_state == AIState.CHASE: return # Just keep chasing
	if current_state == AIState.IDLE:
		original_idle_position = get_parent().global_position

	current_state = AIState.INVESTIGATING
	investigate_position = source_pos
	investigation_timer.start(5.0)

func _on_investigation_timeout() -> void:
	if current_state == AIState.INVESTIGATING:
		current_state = AIState.RETURNING

func calculate_movement(chaser: CharacterBody3D, _delta: float) -> Vector3:
	var previous_state = current_state

	_update_target_and_sight(chaser)

	if current_state == AIState.CHASE and previous_state != AIState.CHASE:
		started_chasing.emit()
	elif current_state == AIState.IDLE and previous_state != AIState.IDLE:
		stopped_chasing.emit()

	var target_pos: Vector3
	var should_move: bool = false
	var calculated_velocity := Vector3.ZERO

	match current_state:
		AIState.CHASE:
			if current_target:
				target_pos = current_target.global_position
				should_move = true
		AIState.INVESTIGATING:
			target_pos = investigate_position
			var flat_pos = Vector3(chaser.global_position.x, 0, chaser.global_position.z)
			var flat_target = Vector3(investigate_position.x, 0, investigate_position.z)
			if flat_pos.distance_squared_to(flat_target) > 1.0:
				should_move = true
		AIState.RETURNING:
			target_pos = original_idle_position
			var flat_pos = Vector3(chaser.global_position.x, 0, chaser.global_position.z)
			var flat_target = Vector3(original_idle_position.x, 0, original_idle_position.z)
			if flat_pos.distance_squared_to(flat_target) > 1.0:
				should_move = true
			else:
				current_state = AIState.IDLE
		AIState.IDLE:
			should_move = false

	if should_move:
		nav_agent.target_position = target_pos

		var next_path_pos := nav_agent.get_next_path_position()
		next_path_pos.y = 0
		var flat_enemy_pos := chaser.global_position
		flat_enemy_pos.y = 0
		var direction: Vector3 = flat_enemy_pos.direction_to(next_path_pos)

		calculated_velocity.x = direction.x * move_speed
		calculated_velocity.z = direction.z * move_speed
	else:
		calculated_velocity.x = move_toward(chaser.velocity.x, 0, move_speed)
		calculated_velocity.z = move_toward(chaser.velocity.z, 0, move_speed)

	return calculated_velocity

func _update_target_and_sight(chaser: CharacterBody3D) -> void:
	if potential_targets.is_empty():
		if current_state == AIState.CHASE:
			current_state = AIState.IDLE
		current_target = null
		return

	var closest_distance := INF
	var best_target: Node3D = null

	var forward_dir := -chaser.global_transform.basis.z
	forward_dir.y = 0
	forward_dir = forward_dir.normalized()

	for target in potential_targets:
		var dir_to_target := chaser.global_position.direction_to(target.global_position)
		dir_to_target.y = 0
		dir_to_target = dir_to_target.normalized()

		var angle_to_target := rad_to_deg(forward_dir.angle_to(dir_to_target))

		if angle_to_target > (field_of_view / 2.0):
			continue

		var dist = chaser.global_position.distance_squared_to(target.global_position)
		if dist < closest_distance:
			var target_pos = target.global_position + Vector3.UP * 1.0
			sight_raycast.target_position = sight_raycast.to_local(target_pos)
			sight_raycast.force_raycast_update()

			if sight_raycast.is_colliding() and sight_raycast.get_collider() == target:
				closest_distance = dist
				best_target = target

	if best_target:
		current_target = best_target
		current_state = AIState.CHASE
		investigation_timer.stop()
	else:
		current_target = null
		if current_state == AIState.CHASE:
			current_state = AIState.IDLE

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(chasing_group) and not potential_targets.has(body):
		potential_targets.append(body)

func _on_body_exited(body: Node3D) -> void:
	if potential_targets.has(body):
		potential_targets.erase(body)
