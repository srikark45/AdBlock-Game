extends CanvasLayer

@export_file("*.tscn") var level_select_scene := "res://ui/level_select.tscn"

@onready var panel: Control = $Panel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps working while the tree is paused
	panel.hide()
	$Panel/VBox/Resume.pressed.connect(_resume)
	$Panel/VBox/Restart.pressed.connect(_restart)
	$Panel/VBox/Quit.pressed.connect(_quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	get_tree().paused = true
	panel.show()
	$Panel/VBox/Resume.grab_focus()

func _resume() -> void:
	get_tree().paused = false
	panel.hide()

func _restart() -> void:
	get_tree().paused = false  # unpause first, or the reloaded scene stays frozen
	get_tree().reload_current_scene()

func _quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(level_select_scene)
