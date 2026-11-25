class_name MoveState
extends State

## MoveState: Natural martial arts locomotion with acceleration,
## momentum inertia, and guarded retreat pacing.

@export var forward_speed: float = 230.0
@export var backward_speed: float = 160.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 850.0

func enter(_params: Dictionary = {}) -> void:
	pass

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	var move_dir = fighter.get_movement_input()
	
	if fighter.is_crouch_requested():
		state_machine.change_state("crouch")
		return
	if fighter.is_jump_requested():
		state_machine.change_state("jump")
		return
		
	fighter.face_opponent()
	
	if move_dir == 0.0:
		# Smooth deceleration into idle
		fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, deceleration * delta)
		fighter.move_and_slide()
		if absf(fighter.velocity.x) < 8.0:
			fighter.velocity.x = 0.0
			state_machine.change_state("idle")
		return
		
	var is_moving_forward = (move_dir > 0 and fighter.facing_direction > 0) or (move_dir < 0 and fighter.facing_direction < 0)
	var target_speed = (forward_speed if is_moving_forward else backward_speed) * move_dir
	
	# Smooth martial arts acceleration
	fighter.velocity.x = move_toward(fighter.velocity.x, target_speed, acceleration * delta)
	fighter.move_and_slide()
	
	if fighter.has_method("play_animation"):
		if is_moving_forward:
			fighter.play_animation("walk_forward")
		else:
			fighter.play_animation("walk_backward")

func handle_input(_event: InputEvent) -> void:
	if fighter.check_attack_inputs():
		return
