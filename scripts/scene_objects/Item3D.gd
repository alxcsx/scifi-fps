extends Area3D
class_name Item3D

@export var item_to_give: Item

var float_speed := 2.0
var float_height := 0.5

@onready var start_y: float = global_position.y
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	body_entered.connect(on_body_entered)

	if item_to_give and item_to_give.icon:
		var frames := SpriteFrames.new()
		frames.add_animation("idle")
		frames.add_frame("idle", item_to_give.icon)
		sprite.sprite_frames = frames
		sprite.play("idle")

func _process(_delta: float) -> void:
	position.y = start_y + (sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_height)

func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var inventory: PlayerInventoryManager = body.get_node_or_null("InventoryManager")
		if inventory:
			inventory._on_item_picked_up(item_to_give)
			queue_free()
