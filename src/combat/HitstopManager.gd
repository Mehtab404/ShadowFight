extends Node

## HitstopManager (Autoload)
## Controls impact freezes, screen shake, and slow-motion KO finishers.

signal camera_shake_requested(intensity: float, duration: float)
signal hitstop_started(frames: int)
signal hitstop_ended()

var is_in_hitstop: bool = false
var _shake_strength: float = 0.0

func trigger_hitstop(frames: int = 5, shake_intensity: float = 6.0) -> void:
	if is_in_hitstop:
		return
	is_in_hitstop = true
	hitstop_started.emit(frames)
	
	if shake_intensity > 0.0:
		camera_shake_requested.emit(shake_intensity, float(frames) / 60.0 + 0.1)
	
	# Freeze physics execution briefly to convey attack weight (impact freeze)
	Engine.time_scale = 0.05
	var wait_time = (float(frames) / 60.0) * 0.05
	await get_tree().create_timer(wait_time, true, false, true).timeout
	Engine.time_scale = 1.0
	is_in_hitstop = false
	hitstop_ended.emit()

func trigger_slowmo_ko(duration: float = 1.5, target_scale: float = 0.25) -> void:
	camera_shake_requested.emit(12.0, 0.4)
	Engine.time_scale = target_scale
	await get_tree().create_timer(duration * target_scale, true, false, true).timeout
	Engine.time_scale = 1.0
