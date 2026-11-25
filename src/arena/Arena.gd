class_name Arena
extends Node2D

enum StageTheme {
	TWILIGHT_DOJO,
	BAMBOO_FOREST,
	BURNING_TEMPLE
}

@onready var p1: PlayerFighter = $Fighters/PlayerFighter
@onready var p2: AIFighter = $Fighters/AIFighter
@onready var camera: CameraController = $CameraController
@onready var hud: HUD = $HUD
@onready var sky_backdrop: Polygon2D = $ParallaxBackground/ParallaxLayerSky/SkyBackdrop
@onready var moon_graphic: Polygon2D = $ParallaxBackground/ParallaxLayerSky/CrimsonMoon
@onready var particles: CPUParticles2D = $AtmosphericParticles

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
	
	apply_stage_theme(GameManager.selected_stage)
	
	# Register with Game Manager
	GameManager.register_fighters(p1, p2)
	
	# Setup HUD
	hud.setup(p1, p2)
	
	# Start round
	GameManager.start_new_match()

func apply_stage_theme(stage_id: int) -> void:
	match stage_id:
		StageTheme.TWILIGHT_DOJO:
			if sky_backdrop: sky_backdrop.color = Color(0.11, 0.08, 0.14)
			if moon_graphic: moon_graphic.color = Color(0.85, 0.18, 0.18, 0.9)
			if particles:
				particles.color = Color(0.9, 0.45, 0.55, 0.75) # Sakura petals
				particles.gravity = Vector2(40, 60)
		StageTheme.BAMBOO_FOREST:
			if sky_backdrop: sky_backdrop.color = Color(0.04, 0.08, 0.12)
			if moon_graphic: moon_graphic.color = Color(0.88, 0.92, 1.0, 0.95) # Silver moon
			if particles:
				particles.color = Color(0.35, 0.75, 0.5, 0.65) # Green bamboo leaves
				particles.gravity = Vector2(-50, 45)
		StageTheme.BURNING_TEMPLE:
			if sky_backdrop: sky_backdrop.color = Color(0.18, 0.05, 0.03)
			if moon_graphic: moon_graphic.color = Color(1.0, 0.4, 0.1, 0.95) # Blazing sky
			if particles:
				particles.color = Color(1.0, 0.65, 0.18, 0.9) # Fiery embers
				particles.gravity = Vector2(60, -80) # Embers rising!
