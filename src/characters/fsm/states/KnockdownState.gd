class_name KnockdownState
extends State

var ground_time: float = 0.8

func enter(params: Dictionary = {}) -> void:
	ground_time = 0.8
	var impulse = params.get("knockback", Vector2(-220, -180))
	fighter.velocity = impulse
	
	if fighter.has_method("play_animation"):
		fighter.play_animation("knockdown")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 200.0 * delta)
	fighter.move_and_slide()
	
	if fighter.is_on_floor():
		ground_time -= delta
		if ground_time <= 0.0:
			state_machine.change_state("getup")
