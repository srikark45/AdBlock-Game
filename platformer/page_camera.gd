extends Camera2D

@export var player: CharacterBody2D

const TOP_TRIGGER := 0.20
const BOTTOM_TRIGGER := 0.84
const FOLLOW_TIME := 0.16
# Half the tallest sprite frame, rounded up.
const SPRITE_MARGIN := 49.0

func _physics_process(delta: float) -> void:
	var height := get_viewport_rect().size.y / zoom.y
	var top := global_position.y - height * 0.5
	var player_y := player.global_position.y - top
	var scroll := player_y - clampf(player_y, height * TOP_TRIGGER, height * BOTTOM_TRIGGER)
	var next_top := top + scroll * (1.0 - exp(-delta / FOLLOW_TIME))
	# A fast stomp can outrun the easing. Keep the whole sprite in view.
	var margin := minf(SPRITE_MARGIN, height * 0.5)
	next_top = clampf(next_top, player.global_position.y - height + margin, player.global_position.y - margin)
	global_position.y = next_top + height * 0.5
