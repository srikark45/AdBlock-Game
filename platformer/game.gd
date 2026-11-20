extends Node2D

var stomp_targets_remaining = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for stomp_target in find_children("", "StompTarget"):
		stomp_targets_remaining += 1
		stomp_target.connect("stomped", _target_stomped)

func _target_stomped():
	stomp_targets_remaining -= 1
	if stomp_targets_remaining == 0:
		print("You win!") # TODO
