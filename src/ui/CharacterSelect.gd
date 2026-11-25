class_name CharacterSelect
extends Control

@onready var name_label: Label = $Margin/VBox/Content/Details/VBox/Name
@onready var desc_label: Label = $Margin/VBox/Content/Details/VBox/Desc
@onready var health_stat: Label = $Margin/VBox/Content/Details/VBox/Stats/HealthVal
@onready var speed_stat: Label = $Margin/VBox/Content/Details/VBox/Stats/SpeedVal
@onready var weapon_stat: Label = $Margin/VBox/Content/Details/VBox/Stats/WeaponVal

const ROSTER = [
	{
		"name": "SHADOW RONIN",
		"weapon": "Katana",
		"weapon_type": 1,
		"health": 100.0,
		"speed": "Normal (1.0x)",
		"desc": "Balanced martial artist mastering mid-range katana footsies and lethal overhead slashes."
	},
	{
		"name": "KUNOICHI",
		"weapon": "Kusarigama",
		"weapon_type": 3,
		"health": 90.0,
		"speed": "Agile (1.25x)",
		"desc": "Swift shadow assassin wielding a chained sickle to trip and pull enemies from afar."
	},
	{
		"name": "IRON MONK",
		"weapon": "Bare Hands",
		"weapon_type": 0,
		"health": 120.0,
		"speed": "Heavy (0.85x)",
		"desc": "Resilient mountain brawler with iron body constitution, high poise, and bone-crushing strikes."
	}
]

var current_idx: int = 0

func _ready() -> void:
	current_idx = GameManager.selected_character
	_update_ui()

func _update_ui() -> void:
	var char_data = ROSTER[current_idx]
	if name_label != null:
		name_label.text = char_data["name"]
	desc_label.text = char_data["desc"]
	health_stat.text = "HEALTH: " + str(char_data["health"]) + " HP"
	speed_stat.text = "SPEED: " + char_data["speed"]
	weapon_stat.text = "STARTING WEAPON: " + char_data["weapon"]

func _on_prev_pressed() -> void:
	current_idx = (current_idx - 1 + ROSTER.size()) % ROSTER.size()
	GameManager.selected_character = current_idx
	_update_ui()
	AudioManager.play_whoosh(1.2)

func _on_next_pressed() -> void:
	current_idx = (current_idx + 1) % ROSTER.size()
	GameManager.selected_character = current_idx
	_update_ui()
	AudioManager.play_whoosh(1.2)

func _on_select_pressed() -> void:
	AudioManager.play_blade_slash(1.1)
	get_tree().change_scene_to_file("res://src/arena/Arena.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
