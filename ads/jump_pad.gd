class_name JumpPad
extends Area2D
## Combo-box launcher (F004a): a jump pad that launches the player upward.
## Touching it gives a normal launch; stomping into it gives a bigger one.
##
## How to use: drag ads/jump_pad.tscn into a level so it sits on a floor,
## then tune the two speeds in the Inspector.

## Upward speed when the player walks, jumps, or falls onto the pad.
@export var launch_speed := 1800.0
## Upward speed when the player stomps onto the pad.
@export var stomp_launch_speed := 2200.0


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	var player := body as CharacterBody2D
	var speed := stomp_launch_speed if player.get("is_stomping") else launch_speed
	# Keep sideways speed, replace vertical speed with the launch.
	player.velocity = player.velocity.slide(player.up_direction) + player.up_direction * speed
	# End the stomp, or player.gd would keep forcing the player downward.
	player.set("is_stomping", false)
	# Turn off the floaty held-jump gravity so every launch is the same height.
	player.set("jump_time", 999)
