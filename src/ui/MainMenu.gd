class_name MainMenu
extends Control

@onready var controls_panel: PanelContainer = $Margin/ControlsModal

func _ready() -> void:
	if controls_panel != null:
		controls_panel.visible = false

func _on_play_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://src/arena/Arena.tscn")

func _on_controls_pressed() -> void:
	if controls_panel != null:
		controls_panel.visible = !controls_panel.visible

func _on_close_controls_pressed() -> void:
	if controls_panel != null:
		controls_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
