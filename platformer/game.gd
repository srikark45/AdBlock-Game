extends Node2D

@export var target_time := 30.0  # seconds for an S rank; tune per level

var stomp_targets_remaining = 0
var elapsed := 0.0
var finished := false

@onready var victory_screen = $VictoryScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for stomp_target in find_children("", "StompTarget"):
		stomp_targets_remaining += 1
		stomp_target.connect("stomped", _target_stomped)

func _process(delta: float) -> void:
	if not finished:
		elapsed += delta  # stops while paused, so pause time doesn't count

func _target_stomped():
	stomp_targets_remaining -= 1
	if stomp_targets_remaining == 0:
		finished = true
		victory_screen.show_results(elapsed, target_time)
