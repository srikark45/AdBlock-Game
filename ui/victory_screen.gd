extends CanvasLayer

@export_file("*.tscn") var level_select_scene := "res://ui/level_select.tscn"
@export_file("*.tscn") var next_level_scene := ""  # set per level; empty hides the Next button

@onready var panel: Control = $Panel
@onready var time_label: Label = $Panel/VBox/TimeLabel
@onready var rank_label: Label = $Panel/VBox/RankLabel
@onready var next_button: Button = $Panel/VBox/Next

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps working while the tree is paused
	panel.hide()
	next_button.pressed.connect(_next)
	$Panel/VBox/Restart.pressed.connect(_restart)
	$Panel/VBox/Quit.pressed.connect(_quit)

func show_results(clear_time: float, target_time: float) -> void:
	add_to_group("end_screen")  
	time_label.text = "Time: %s (target %s)" % [_fmt(clear_time), _fmt(target_time)]
	rank_label.text = "Rank: %s" % _rank_for(clear_time, target_time)
	next_button.visible = next_level_scene != ""
	get_tree().paused = true
	panel.show()
	if next_button.visible:
		next_button.grab_focus()
	else:
		$Panel/VBox/Restart.grab_focus()

func _fmt(t: float) -> String:
	var m := floori(t / 60.0)
	return "%d:%05.2f" % [m, t - m * 60.0]

# Placeholder cutoffs (clear time / target time). Tune once real levels exist.
func _rank_for(clear_time: float, target_time: float) -> String:
	if target_time <= 0.0:
		return "-"
	var ratio := clear_time / target_time
	if ratio <= 1.0:
		return "S"
	elif ratio <= 1.25:
		return "A"
	elif ratio <= 1.5:
		return "B"
	return "C"

func _next() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(next_level_scene)

func _restart() -> void:
	get_tree().paused = false  # unpause first, or the reloaded scene stays frozen
	get_tree().reload_current_scene()

func _quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(level_select_scene)
