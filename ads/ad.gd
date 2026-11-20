@tool
class_name Ad
extends Node2D
## A basic pop-up ad (F002a). Stomp its red X to close it.
##
## How to use: drag ads/ad.tscn into a level, then set `size` and `text`
## in the Inspector. The panel, the solid box you can stand on, and the X
## all follow `size` automatically, so you never resize them by hand.
## The level's game.gd counts the X, so closing every ad wins the level.

## Emitted right before the ad disappears.
signal closed

## Width and height of the ad in pixels. One line of page text is 39px tall,
## so 78 = 2 lines and 117 = 3 lines. The top-left corner is the node's position.
@export var size := Vector2(130, 78):
	set(value):
		size = value
		_update_layout()

## Placeholder text until we have real ad art.
@export_multiline var text := "BUY NOW!":
	set(value):
		text = value
		_update_layout()


func _ready() -> void:
	# Exported values are applied before the children exist,
	# so lay out once more now that they do.
	_update_layout()


func _update_layout() -> void:
	if not is_node_ready():
		return
	$Panel.size = size
	$Panel/Label.text = text
	$Body/CollisionShape2D.shape.size = size
	$Body/CollisionShape2D.position = size / 2
	# Just inside the top-right corner, where a stomp from on top of the ad reaches it.
	$CloseButton.position = Vector2(size.x - 20, 16)


func _on_close_button_stomped() -> void:
	closed.emit()
	queue_free()
