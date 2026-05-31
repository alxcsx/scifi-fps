extends Area3D
class_name Item3D

const OUTLINE_MAT = preload("res://core/resources/shared_resources/OUTLINE.tres")

@export var item_to_give: Item

var float_speed := 1.0
var float_height := 0.25

@onready var start_y: float = global_position.y
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	setup()

func setup() -> void:
	if item_to_give and item_to_give.icon:
		var frames := SpriteFrames.new()
		frames.add_animation("idle")
		frames.add_frame("idle", item_to_give.icon)
		sprite.sprite_frames = frames
		sprite.play("idle")

func _process(_delta: float) -> void:
	position.y = start_y + (sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_height)

func interact(player: Node3D) -> void:
	var inventory: PlayerInventoryManager = player.get_node_or_null("InventoryManager")
	if inventory:
		if inventory.try_add_item(item_to_give):
			queue_free()


func add_outline() -> void:
	sprite.material_overlay = OUTLINE_MAT

func remove_outline() -> void:
	sprite.material_overlay = null














