class_name PauseMenu
extends CanvasLayer

@onready var panel: Control = $Panel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	var paused = !get_tree().paused
	get_tree().paused = paused
	panel.visible = paused

func _on_resume_pressed() -> void:
	get_tree().paused = false
	panel.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
