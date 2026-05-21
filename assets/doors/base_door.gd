class_name BaseDoor
extends Node3D

enum STATE {OPEN, CLOSED}
enum TRIGGER {PROXIMITY, INTERACT, LOCKED}

@export_category("Door Configuration")
@export  var initial_state : STATE   = STATE.CLOSED
@export  var trigger_type  : TRIGGER = TRIGGER.PROXIMITY
@export  var required_key  : String = " "                # Only usefull if the trigger is LOCKED

@export_category("References")
@export var animation : AnimationPlayer

@onready var state : STATE = initial_state

func _ready() -> void:
	# Safety check
	if not animation:
		push_warning("AnimationPlayer missing on door: ", name)
		return

	# Initial state setup
	if state == STATE.CLOSED:
		animation.play("Close")
		animation.seek(animation.current_animation_length, true)
	elif state == STATE.OPEN:
		animation.play("Open")
		animation.seek(animation.current_animation_length, true)


func open_door() -> void:
	if state != STATE.OPEN and animation:
		animation.queue("Open")
		state = STATE.OPEN

func close_door() -> void:
	if state != STATE.CLOSED and animation:
		animation.queue("Close")
		state = STATE.CLOSED

# Proximity doors --------------------------------------------------------------
func _on_area_3d_body_entered(body: Node3D) -> void:
	if trigger_type == TRIGGER.PROXIMITY:
		open_door()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if trigger_type == TRIGGER.PROXIMITY:
		close_door()

# Interact/Locked doors --------------------------------------------------------
func interact(player_inventory: Array = []) -> void:
	if trigger_type == TRIGGER.INTERACT:
		open_door()
	elif trigger_type == TRIGGER.LOCKED:
		if required_key in player_inventory:
			print("Access Granted!")
			open_door()
		else:
			print("Access Denied. Required: ", required_key)
			# Play error sound/animation
