class_name DashState
extends State

## DashState: Rapid tactical forward sliding dash or evasive backward hop.

var is_backdash: bool = false
var dash_timer: float = 0.0
const DASH_FORWARD_SPEED: float = 460.0
const BACKDASH_SPEED: float = 340.0

func enter(params: Dictionary = {}) -> void:
	is_backdash = params.get("is_backdash", false)
	dash_timer = 0.22 if not is_backdash else 0.26
	
	if is_backdash:
		fighter.velocity.x = -BACKDASH_SPEED * fighter.facing_direction
		fighter.velocity.y = -140.0 # Small evasive hop
		AudioManager.play_whoosh(1.3)
	else:
		fighter.velocity.x = DASH_FORWARD_SPEED * fighter.facing_direction
		AudioManager.play_whoosh(1.1)
		
	if fighter.has_method("play_animation"):
		fighter.play_animation("dash_back" if is_backdash else "dash_forward")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 750.0 * delta)
	fighter.move_and_slide()
	
	dash_timer -= delta
	if dash_timer <= 0.0 and fighter.is_on_floor():
		if fighter.get_movement_input() != 0.0:
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")

func handle_input(_event: InputEvent) -> void:
	# Enable attack cancels out of dash!
	if fighter.check_attack_inputs():
		return
