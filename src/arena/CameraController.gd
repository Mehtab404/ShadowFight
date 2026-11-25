class_name CameraController
extends Camera2D

## Dynamic Fighting Game Tracking Camera
## Features:
## - Midpoint tracking between Player 1 and Player 2
## - Dynamic zoom based on fighter separation distance
## - Stage bounds clamping
## - Trauma-based camera shake on heavy impacts

@export var p1: Node2D
@export var p2: Node2D
@export var min_zoom: float = 0.85
@export var max_zoom: float = 1.25
@export var min_distance: float = 240.0
@export var max_distance: float = 960.0
@export var min_stage_x: float = -600.0
@export var max_stage_x: float = 600.0
@export var stage_y_offset: float = -40.0
@export var follow_smooth_speed: float = 7.0

var _trauma: float = 0.0
var _trauma_decay: float = 1.8
var _noise: FastNoiseLite = FastNoiseLite.new()
var _noise_y: float = 0.0

func _ready() -> void:
	_noise.seed = randi()
	_noise.frequency = 0.5
	HitstopManager.camera_shake_requested.connect(add_trauma)

func add_trauma(intensity: float, _duration: float = 0.2) -> void:
	_trauma = clampf(_trauma + intensity * 0.1, 0.0, 1.0)

func _process(delta: float) -> void:
	_update_tracking(delta)
	_update_shake(delta)

func _update_tracking(delta: float) -> void:
	if p1 == null or p2 == null:
		return
		
	var midpoint_x = (p1.global_position.x + p2.global_position.x) * 0.5
	midpoint_x = clampf(midpoint_x, min_stage_x, max_stage_x)
	var target_pos = Vector2(midpoint_x, stage_y_offset)
	global_position = global_position.lerp(target_pos, follow_smooth_speed * delta)
	
	var dist = absf(p1.global_position.x - p2.global_position.x)
	var zoom_t = clampf((dist - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	var target_zoom_val = lerpf(max_zoom, min_zoom, zoom_t)
	zoom = zoom.lerp(Vector2(target_zoom_val, target_zoom_val), follow_smooth_speed * delta)

func _update_shake(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = maxf(0.0, _trauma - _trauma_decay * delta)
		var shake_amount = _trauma * _trauma * 24.0
		_noise_y += delta * 60.0
		offset.x = _noise.get_noise_2d(0.0, _noise_y) * shake_amount
		offset.y = _noise.get_noise_2d(100.0, _noise_y) * shake_amount
	else:
		offset = Vector2.ZERO
