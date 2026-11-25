class_name GetUpState
extends State

var getup_timer: float = 0.5

func enter(_params: Dictionary = {}) -> void:
	getup_timer = 0.5
	fighter.velocity = Vector2.ZERO
	fighter.set_invulnerable(true)
	
	if fighter.has_method("play_animation"):
		fighter.play_animation("get_up")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.move_and_slide()
	
	getup_timer -= delta
	if getup_timer <= 0.0:
		state_machine.change_state("idle")

func exit() -> void:
	fighter.set_invulnerable(false)
