class_name IdleState
extends State

## IdleState: Neutral martial arts stance with momentum settling and breathing settle.

@export var friction: float = 750.0

func enter(_params: Dictionary = {}) -> void:
	if fighter.has_method("play_animation"):
		fighter.play_animation("idle")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	# Organic deceleration to standstill
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, friction * delta)
	fighter.move_and_slide()
	fighter.face_opponent()
	
	if fighter.is_crouch_requested():
		state_machine.change_state("crouch")
		return
	if fighter.is_jump_requested():
		state_machine.change_state("jump")
		return
	if fighter.get_movement_input() != 0.0:
		state_machine.change_state("move")
		return

func handle_input(_event: InputEvent) -> void:
	if fighter.check_attack_inputs():
		return
