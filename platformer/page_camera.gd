extends Camera2D

@export var player: CharacterBody2D

func _ready() -> void:
	global_position.y = player.global_position.y

func _physics_process(_delta: float) -> void:
	global_position.y = player.global_position.y
