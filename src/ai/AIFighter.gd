class_name AIFighter
extends Fighter

## AIFighter implements a smart martial arts bot with:
## - Adaptive spacing / neutral footsies
## - Reactive blocking to incoming attacks
## - Whiff punishing and combo chains

enum AIDifficulty { EASY, MEDIUM, MASTER }

@export var difficulty: AIDifficulty = AIDifficulty.MASTER

var ai_move_dir: float = 0.0
var ai_crouch: bool = false
var ai_jump: bool = false
var ai_blocking: bool = false

var decision_timer: float = 0.0
var block_reaction_delay: float = 0.08
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	# Randomize AI weapon choice for variety
	var choice = rng.randi_range(0, 2)
	match choice:
		0: equip_weapon(WeaponData.create_bare_hands())
		1: equip_weapon(WeaponData.create_katana())
		2: equip_weapon(WeaponData.create_naginata())
	super._ready()

func _physics_process(delta: float) -> void:
	if GameManager.game_mode == 2:
		_handle_player2_input()
	else:
		_update_ai_decisions(delta)
	super._physics_process(delta)

func _handle_player2_input() -> void:
	ai_move_dir = Input.get_axis("p2_move_left", "p2_move_right")
	ai_jump = Input.is_action_just_pressed("p2_jump")
	ai_crouch = Input.is_action_pressed("p2_crouch")
	ai_blocking = Input.is_action_pressed("p2_block") or (facing_direction > 0 and ai_move_dir < 0) or (facing_direction < 0 and ai_move_dir > 0)

	# P2 Weapon hotkeys
	if Input.is_key_pressed(KEY_7):
		equip_weapon(WeaponData.create_bare_hands())
	elif Input.is_key_pressed(KEY_8):
		equip_weapon(WeaponData.create_katana())
	elif Input.is_key_pressed(KEY_9):
		equip_weapon(WeaponData.create_naginata())
	elif Input.is_key_pressed(KEY_0):
		equip_weapon(WeaponData.create_kusarigama())

	# P2 Super Move (O or Enter)
	if Input.is_key_pressed(KEY_O) or Input.is_key_pressed(KEY_ENTER):
		try_activate_shadow_ability()

func get_movement_input() -> float:
	if GameManager.game_mode == 2:
		return ai_move_dir
	return super.get_movement_input()

func is_jump_requested() -> bool:
	if GameManager.game_mode == 2:
		return ai_jump
	return super.is_jump_requested()

func is_crouch_requested() -> bool:
	if GameManager.game_mode == 2:
		return ai_crouch
	return super.is_crouch_requested()

func is_holding_block() -> bool:
	if GameManager.game_mode == 2:
		return ai_blocking
	return super.is_holding_block()

func check_attack_inputs(airborne: bool = false) -> bool:
	if GameManager.game_mode == 2:
		if Input.is_action_just_pressed("p2_weapon"):
			_try_katana_thrust()
			return true
		if Input.is_action_just_pressed("p2_punch"):
			_try_punch_jab()
			return true
		if Input.is_action_just_pressed("p2_kick"):
			_try_roundhouse_kick()
			return true
		return false
	return super.check_attack_inputs(airborne)

func check_crouch_attacks() -> bool:
	if GameManager.game_mode == 2:
		if Input.is_action_just_pressed("p2_kick"):
			_try_crouch_sweep()
			return true
		return false
	return super.check_crouch_attacks()

func _update_ai_decisions(delta: float) -> void:
	if opponent == null:
		return
		
	decision_timer -= delta
	var dist = absf(opponent.global_position.x - global_position.x)
	var opponent_attacking = (opponent.state_machine.current_state is AttackState)
	
	# Reactive Block
	if opponent_attacking and dist < 220.0:
		var block_chance = 0.85 if difficulty == AIDifficulty.MASTER else 0.5
		if rng.randf() < block_chance:
			ai_blocking = true
	else:
		ai_blocking = false
		
	# Shadow Ability Activation when charged
	if shadow_energy >= max_shadow_energy and dist < 280.0:
		if try_activate_shadow_ability():
			return
		
	if decision_timer > 0.0:
		return
		
	# New decision tick
	decision_timer = rng.randf_range(0.12, 0.28)
	ai_jump = false
	ai_crouch = false
	
	# Spacing & Footsies Logic
	if dist > 280.0:
		# Approach opponent
		ai_move_dir = 1.0 if opponent.global_position.x > global_position.x else -1.0
	elif dist < 120.0:
		# Close range mixup: back up, crouch sweep, or quick jab
		var r = rng.randf()
		if r < 0.35:
			# Back dash
			ai_move_dir = -1.0 if opponent.global_position.x > global_position.x else 1.0
		elif r < 0.70:
			# Low sweep
			ai_crouch = true
			_try_crouch_sweep()
		else:
			# Quick jab
			_try_quick_jab()
	else:
		# Mid-range sweet spot: Katana thrust or roundhouse kick
		ai_move_dir = 0.0
		var r = rng.randf()
		if r < 0.40:
			_try_katana_thrust()
		elif r < 0.70:
			_try_roundhouse_kick()
		else:
			# Subtle spacing shimmy
			ai_move_dir = rng.randf_range(-1.0, 1.0)

func get_movement_input() -> float:
	return ai_move_dir

func is_jump_requested() -> bool:
	return ai_jump

func is_crouch_requested() -> bool:
	return ai_crouch

func is_holding_block() -> bool:
	return ai_blocking

func _try_quick_jab() -> void:
	if state_machine.current_state is IdleState or state_machine.current_state is MoveState:
		state_machine.change_state("attack", {
			"anim": "punch_jab",
			"hitbox_name": "PunchHitbox",
			"damage": 12.0,
			"startup_f": 6, "active_f": 3, "recovery_f": 8,
			"knockback": Vector2(140, -30),
			"target_zone": DamageCalculator.HitZone.HEAD,
			"is_knockdown": false
		})

func _try_roundhouse_kick() -> void:
	if state_machine.current_state is IdleState or state_machine.current_state is MoveState:
		state_machine.change_state("attack", {
			"anim": "kick_roundhouse",
			"hitbox_name": "KickHitbox",
			"damage": 28.0,
			"startup_f": 12, "active_f": 5, "recovery_f": 14,
			"knockback": Vector2(260, -140),
			"target_zone": DamageCalculator.HitZone.HEAD,
			"is_knockdown": true
		})

func _try_katana_thrust() -> void:
	if state_machine.current_state is IdleState or state_machine.current_state is MoveState:
		state_machine.change_state("attack", {
			"anim": "katana_thrust",
			"hitbox_name": "WeaponHitbox",
			"damage": 30.0,
			"startup_f": 13, "active_f": 4, "recovery_f": 16,
			"knockback": Vector2(200, -50),
			"target_zone": DamageCalculator.HitZone.TORSO,
			"is_knockdown": false
		})

func _try_crouch_sweep() -> void:
	state_machine.change_state("attack", {
		"anim": "kick_sweep",
		"hitbox_name": "KickHitbox",
		"damage": 20.0,
		"startup_f": 10, "active_f": 4, "recovery_f": 15,
		"knockback": Vector2(220, -120),
		"target_zone": DamageCalculator.HitZone.LEGS,
		"is_knockdown": true
	})
