class_name Arena
extends Node2D

@onready var p1: PlayerFighter = $Fighters/PlayerFighter
@onready var p2: AIFighter = $Fighters/AIFighter
@onready var camera: CameraController = $CameraController
@onready var hud: HUD = $HUD

func _ready() -> void:
	# Link opponents
	p1.opponent = p2
	p2.opponent = p1
	
	# Initial positions
	p1.global_position = Vector2(-180, 0)
	p2.global_position = Vector2(180, 0)
	p1.facing_direction = 1
	p2.facing_direction = -1
	p2.visual_root.scale.x = -1.0
	
	# Register with Game Manager
	GameManager.register_fighters(p1, p2)
	
	# Setup HUD
	hud.setup(p1, p2)
	
	# Start round
	GameManager.start_new_match()
