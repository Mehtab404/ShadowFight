class_name HitSparks
extends CPUParticles2D

func _ready() -> void:
	emitting = true
	one_shot = true
	# Auto remove after completion
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()

static func spawn_at(parent: Node, spawn_pos: Vector2, is_slash: bool = false) -> void:
	var sparks = preload("res://src/vfx/HitSparks.tscn").instantiate()
	sparks.global_position = spawn_pos
	if is_slash:
		sparks.color = Color(1.0, 0.95, 0.5, 1.0)
		sparks.initial_velocity_min = 280.0
		sparks.initial_velocity_max = 420.0
	parent.add_child(sparks)
