class_name MainMenu
extends Control

@onready var controls_panel: PanelContainer = $Margin/ControlsModal
@onready var stage_btn: Button = $Margin/VBox/ButtonContainer/StageBtn
@onready var audio_btn: Button = $Margin/VBox/ButtonContainer/AudioBtn

const STAGE_NAMES = ["DOJO (TWILIGHT)", "BAMBOO FOREST", "BURNING TEMPLE"]

func _ready() -> void:
	if controls_panel != null:
		controls_panel.visible = false
	_update_stage_button()

func _update_stage_button() -> void:
	if stage_btn != null:
		stage_btn.text = "⛩️ STAGE: " + STAGE_NAMES[GameManager.selected_stage]

func _on_play_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://src/arena/Arena.tscn")

func _on_stage_btn_pressed() -> void:
	GameManager.selected_stage = (GameManager.selected_stage + 1) % STAGE_NAMES.size()
	_update_stage_button()
	AudioManager.play_whoosh(1.2)

func _on_audio_btn_pressed() -> void:
	var active = AudioManager.toggle_bgm()
	if audio_btn != null:
		audio_btn.text = "🎵 AUDIO: " + ("ON" if active else "OFF")

func _on_controls_pressed() -> void:
	if controls_panel != null:
		controls_panel.visible = !controls_panel.visible

func _on_close_controls_pressed() -> void:
	if controls_panel != null:
		controls_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
