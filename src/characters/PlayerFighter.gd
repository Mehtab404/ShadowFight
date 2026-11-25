class_name PlayerFighter
extends Fighter

@export var player_id: int = 1 # 1 or 2

var prefix: String = "p1_"
var last_press_time_left: float = -1.0
var last_press_time_right: float = -1.0
const DOUBLE_TAP_WINDOW: float = 0.24

func _ready() -> void:
	prefix = "p1_" if player_id == 1 else "p2_"
	super._ready()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(prefix + "move_right"):
		var curr_time = float(Time.get_ticks_msec()) / 1000.0
		if curr_time - last_press_time_right < DOUBLE_TAP_WINDOW:
			_try_dash(1)
		last_press_time_right = curr_time
	elif event.is_action_pressed(prefix + "move_left"):
		var curr_time = float(Time.get_ticks_msec()) / 1000.0
		if curr_time - last_press_time_left < DOUBLE_TAP_WINDOW:
			_try_dash(-1)
		last_press_time_left = curr_time

func _try_dash(dir: int) -> void:
	if state_machine != null and (state_machine.current_state is IdleState or state_machine.current_state is MoveState):
		var is_forward = (dir == facing_direction)
		state_machine.change_state("dash", {"is_backdash": not is_forward})

func get_movement_input() -> float:
	var left = Input.is_action_pressed(prefix + "move_left")
	var right = Input.is_action_pressed(prefix + "move_right")
	if left and not right:
		return -1.0
	elif right and not left:
		return 1.0
	return 0.0

func is_jump_requested() -> bool:
	return Input.is_action_just_pressed(prefix + "jump")

func is_crouch_requested() -> bool:
	return Input.is_action_pressed(prefix + "crouch")

func is_holding_block() -> bool:
	# Block button OR holding direction opposite to facing direction
	if Input.is_action_pressed(prefix + "block"):
		return true
	var move = get_movement_input()
	if facing_direction > 0 and move < 0:
		return true
	if facing_direction < 0 and move > 0:
		return true
	return false

func check_attack_inputs(airborne: bool = false) -> bool:
	# Weapon Switch Hotkeys (1: Bare Hands, 2: Katana, 3: Naginata, 4: Kusarigama)
	if Input.is_key_pressed(KEY_1):
		equip_weapon(WeaponData.create_bare_hands())
	elif Input.is_key_pressed(KEY_2):
		equip_weapon(WeaponData.create_katana())
	elif Input.is_key_pressed(KEY_3):
		equip_weapon(WeaponData.create_naginata())
	elif Input.is_key_pressed(KEY_4):
		equip_weapon(WeaponData.create_kusarigama())

	if airborne:
		if Input.is_action_just_pressed(prefix + "kick"):
			_start_attack({
				"anim": "jump_kick",
				"hitbox_name": "KickHitbox",
				"damage": 16.0,
				"startup_f": 5, "active_f": 6, "recovery_f": 10,
				"knockback": Vector2(160, -40),
				"target_zone": DamageCalculator.HitZone.HEAD,
				"is_knockdown": false
			})
			return true
		return false

	var move = get_movement_input()
	var forward_held = (move > 0 and facing_direction > 0) or (move < 0 and facing_direction < 0)
	var up_held = Input.is_action_pressed(prefix + "jump")
	var down_held = Input.is_action_pressed(prefix + "crouch")

	# Weapon Moves depending on equipped weapon
	if current_weapon != null and current_weapon.weapon_type == WeaponData.WeaponType.NAGINATA:
		# Naginata Moves: Extended reach, sweeping attacks
		if down_held and Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "naginata_sweep",
				"hitbox_name": "WeaponHitbox",
				"damage": 32.0,
				"startup_f": 14, "active_f": 6, "recovery_f": 20,
				"knockback": Vector2(240, -110),
				"target_zone": DamageCalculator.HitZone.LEGS,
				"is_knockdown": true
			})
			return true
		if forward_held and Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "naginata_thrust",
				"hitbox_name": "WeaponHitbox",
				"damage": 35.0,
				"startup_f": 15, "active_f": 5, "recovery_f": 19,
				"knockback": Vector2(260, -60),
				"target_zone": DamageCalculator.HitZone.TORSO,
				"is_knockdown": false
			})
			return true
		if Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "naginata_spin",
				"hitbox_name": "WeaponHitbox",
				"damage": 26.0,
				"startup_f": 11, "active_f": 5, "recovery_f": 14,
				"knockback": Vector2(210, -50),
				"target_zone": DamageCalculator.HitZone.HEAD,
				"is_knockdown": false
			})
			return true
	elif current_weapon != null and current_weapon.weapon_type == WeaponData.WeaponType.KUSARIGAMA:
		# Kusarigama Sickle & Chain Moves
		if down_held and Input.is_action_just_pressed(prefix + "weapon"):
			AudioManager.play_chain_rattle()
			_start_attack({
				"anim": "kusarigama_sweep",
				"hitbox_name": "WeaponHitbox",
				"damage": 28.0,
				"startup_f": 12, "active_f": 6, "recovery_f": 18,
				"knockback": Vector2(230, -90),
				"target_zone": DamageCalculator.HitZone.LEGS,
				"is_knockdown": true
			})
			return true
		if forward_held and Input.is_action_just_pressed(prefix + "weapon"):
			AudioManager.play_chain_rattle()
			_start_attack({
				"anim": "kusarigama_chain_thrust",
				"hitbox_name": "WeaponHitbox",
				"damage": 34.0,
				"startup_f": 14, "active_f": 5, "recovery_f": 17,
				"knockback": Vector2(240, -40),
				"target_zone": DamageCalculator.HitZone.TORSO,
				"is_knockdown": false
			})
			return true
		if Input.is_action_just_pressed(prefix + "weapon"):
			AudioManager.play_blade_slash()
			_start_attack({
				"anim": "kusarigama_slash",
				"hitbox_name": "WeaponHitbox",
				"damage": 25.0,
				"startup_f": 9, "active_f": 4, "recovery_f": 12,
				"knockback": Vector2(170, -30),
				"target_zone": DamageCalculator.HitZone.HEAD,
				"is_knockdown": false
			})
			return true
	elif current_weapon != null and current_weapon.weapon_type == WeaponData.WeaponType.BARE_HANDS:
		# Bare Hands Martial Arts: Rapid combo punches
		if Input.is_action_just_pressed(prefix + "weapon") or Input.is_action_just_pressed(prefix + "punch"):
			_start_attack({
				"anim": "punch_straight",
				"hitbox_name": "PunchHitbox",
				"damage": 18.0 * current_weapon.base_damage_mult,
				"startup_f": 5, "active_f": 3, "recovery_f": 7,
				"knockback": Vector2(160, -40),
				"target_zone": DamageCalculator.HitZone.HEAD,
				"is_knockdown": false
			})
			return true
	else:
		# Katana Moves (Standard)
		# Up + Weapon: Katana Overhead Slash
		if up_held and Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "katana_overhead",
				"hitbox_name": "WeaponHitbox",
				"damage": 42.0,
				"startup_f": 16, "active_f": 6, "recovery_f": 18,
				"knockback": Vector2(240, -100),
				"target_zone": DamageCalculator.HitZone.HEAD,
				"is_knockdown": true
			})
			return true

		# Forward + Weapon: Katana Thrust
		if forward_held and Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "katana_thrust",
				"hitbox_name": "WeaponHitbox",
				"damage": 30.0,
				"startup_f": 13, "active_f": 4, "recovery_f": 16,
				"knockback": Vector2(200, -50),
				"target_zone": DamageCalculator.HitZone.TORSO,
				"is_knockdown": false
			})
			return true

		# Neutral Weapon: Katana Quick Draw
		if Input.is_action_just_pressed(prefix + "weapon"):
			_start_attack({
				"anim": "katana_slash",
				"hitbox_name": "WeaponHitbox",
				"damage": 22.0,
				"startup_f": 8, "active_f": 4, "recovery_f": 11,
				"knockback": Vector2(160, -40),
				"target_zone": DamageCalculator.HitZone.TORSO,
				"is_knockdown": false
			})
			return true

	# Forward + Kick: Roundhouse Kick
	if forward_held and Input.is_action_just_pressed(prefix + "kick"):
		_start_attack({
			"anim": "kick_roundhouse",
			"hitbox_name": "KickHitbox",
			"damage": 28.0,
			"startup_f": 12, "active_f": 5, "recovery_f": 14,
			"knockback": Vector2(260, -140),
			"target_zone": DamageCalculator.HitZone.HEAD,
			"is_knockdown": true
		})
		return true

	# Forward + Punch: Straight Punch
	if forward_held and Input.is_action_just_pressed(prefix + "punch"):
		_start_attack({
			"anim": "punch_straight",
			"hitbox_name": "PunchHitbox",
			"damage": 18.0,
			"startup_f": 9, "active_f": 4, "recovery_f": 12,
			"knockback": Vector2(190, -50),
			"target_zone": DamageCalculator.HitZone.TORSO,
			"is_knockdown": false
		})
		return true

	# Neutral Punch: Quick Jab
	if Input.is_action_just_pressed(prefix + "punch"):
		_start_attack({
			"anim": "punch_jab",
			"hitbox_name": "PunchHitbox",
			"damage": 12.0,
			"startup_f": 6, "active_f": 3, "recovery_f": 8,
			"knockback": Vector2(140, -30),
			"target_zone": DamageCalculator.HitZone.HEAD,
			"is_knockdown": false
		})
		return true

	# Neutral Kick: Low Shin Kick
	if Input.is_action_just_pressed(prefix + "kick"):
		_start_attack({
			"anim": "kick_low",
			"hitbox_name": "KickHitbox",
			"damage": 14.0,
			"startup_f": 7, "active_f": 3, "recovery_f": 10,
			"knockback": Vector2(130, -20),
			"target_zone": DamageCalculator.HitZone.LEGS,
			"is_knockdown": false
		})
		return true

	return false

func check_crouch_attacks() -> bool:
	if Input.is_action_just_pressed(prefix + "kick"):
		# Low Sweep
		_start_attack({
			"anim": "kick_sweep",
			"hitbox_name": "KickHitbox",
			"damage": 20.0,
			"startup_f": 10, "active_f": 4, "recovery_f": 15,
			"knockback": Vector2(220, -120),
			"target_zone": DamageCalculator.HitZone.LEGS,
			"is_knockdown": true
		})
		return true
		
	if Input.is_action_just_pressed(prefix + "punch"):
		# Crouch Jab
		_start_attack({
			"anim": "punch_crouch",
			"hitbox_name": "PunchHitbox",
			"damage": 10.0,
			"startup_f": 5, "active_f": 3, "recovery_f": 7,
			"knockback": Vector2(100, -20),
			"target_zone": DamageCalculator.HitZone.TORSO,
			"is_knockdown": false
		})
		return true
	return false

func _start_attack(data: Dictionary) -> void:
	state_machine.change_state("attack", data)
