class_name MoveState
extends State

@export var forward_speed: float = 240.0
@export var backward_speed: float = 180.0

func enter(_params: Dictionary = {}) -> void:
	pass

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	var move_dir = fighter.get_movement_input()
	
	if move_dir == 0.0:
		state_machine.change_state("idle")
		return
		
	if fighter.is_crouch_requested():
		state_machine.change_state("crouch")
		return
	if fighter.is_jump_requested():
		state_machine.change_state("jump")
		return
		
	fighter.face_opponent()
	var is_moving_forward = (move_dir > 0 and fighter.facing_direction > 0) or (move_dir < 0 and fighter.facing_direction < 0)
	var speed = forward_speed if is_moving_forward else backward_speed
	
	fighter.velocity.x = move_dir * speed
	fighter.move_and_slide()
	
	if fighter.has_method("play_animation"):
		if is_moving_forward:
			fighter.play_animation("walk_forward")
		else:
			fighter.play_animation("walk_backward")

func handle_input(_event: InputEvent) -> void:
	if fighter.check_attack_inputs():
		return
