class_name CrouchState
extends State

func enter(_params: Dictionary = {}) -> void:
	fighter.velocity.x = 0.0
	if fighter.has_method("play_animation"):
		fighter.play_animation("crouch")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 400.0 * delta)
	fighter.move_and_slide()
	fighter.face_opponent()
	
	if not fighter.is_crouch_requested():
		if fighter.get_movement_input() != 0.0:
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")

func handle_input(_event: InputEvent) -> void:
	if fighter.check_crouch_attacks():
		return
