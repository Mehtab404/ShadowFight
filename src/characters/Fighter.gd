class_name Fighter
extends CharacterBody2D

signal health_changed(current: float, max_val: float)
signal shadow_energy_changed(current: float, max_val: float)
signal hit_taken_event(damage: float, zone: DamageCalculator.HitZone, is_blocked: bool)
signal parry_performed()
signal defeated()
signal combo_updated(count: int)

@export var fighter_name: String = "Ronin"
@export var max_health: float = 100.0
@export var gravity: float = 980.0

var health: float = 100.0
var shadow_energy: float = 0.0
var max_shadow_energy: float = 100.0
var opponent: Fighter = null
var facing_direction: int = 1 # 1 = right, -1 = left
var is_invulnerable: bool = false
var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_RESET_WINDOW: float = 1.2
var current_weapon: WeaponData = null
var time_alive: float = 0.0
var base_torso_pos_y: float = -64.0
var base_head_pos_y: float = -100.0
var guard_start_time: float = -1.0
var was_guarding_last_frame: bool = false

@onready var state_machine: StateMachine = $StateMachine
@onready var visual_root: Node2D = $VisualRoot
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox_head: Hurtbox = $VisualRoot/HurtboxHead
@onready var hurtbox_torso: Hurtbox = $VisualRoot/HurtboxTorso
@onready var hurtbox_legs: Hurtbox = $VisualRoot/HurtboxLegs
@onready var katana_blade: Line2D = $VisualRoot/KatanaBlade
@onready var weapon_hitbox: Hitbox = $VisualRoot/WeaponHitbox

func _ready() -> void:
	health = max_health
	shadow_energy = 0.0
	if current_weapon == null:
		equip_weapon(WeaponData.create_katana())
	if state_machine != null:
		state_machine.init(self)
	health_changed.emit(health, max_health)
	shadow_energy_changed.emit(shadow_energy, max_shadow_energy)

func add_shadow_energy(amount: float) -> void:
	shadow_energy = clampf(shadow_energy + amount, 0.0, max_shadow_energy)
	shadow_energy_changed.emit(shadow_energy, max_shadow_energy)

func try_activate_shadow_ability() -> bool:
	if shadow_energy >= max_shadow_energy and state_machine != null:
		if state_machine.current_state is IdleState or state_machine.current_state is MoveState:
			shadow_energy = 0.0
			shadow_energy_changed.emit(shadow_energy, max_shadow_energy)
			state_machine.change_state("shadowability")
			return true
	return false

func equip_weapon(weapon: WeaponData) -> void:
	current_weapon = weapon
	if katana_blade != null:
		if weapon.weapon_type == WeaponData.WeaponType.BARE_HANDS:
			katana_blade.visible = false
		elif weapon.weapon_type == WeaponData.WeaponType.KATANA:
			katana_blade.visible = true
			katana_blade.points = PackedVector2Array([Vector2(0, 0), Vector2(28, -24), Vector2(52, -44)])
			katana_blade.default_color = weapon.weapon_color
			katana_blade.width = 4.0
		elif weapon.weapon_type == WeaponData.WeaponType.NAGINATA:
			katana_blade.visible = true
			katana_blade.points = PackedVector2Array([Vector2(-15, 10), Vector2(35, -25), Vector2(85, -60)])
			katana_blade.default_color = weapon.weapon_color
			katana_blade.width = 5.0
		elif weapon.weapon_type == WeaponData.WeaponType.KUSARIGAMA:
			katana_blade.visible = true
			katana_blade.points = PackedVector2Array([Vector2(0, 0), Vector2(25, -15), Vector2(60, -25), Vector2(85, -55), Vector2(100, -45)])
			katana_blade.default_color = weapon.weapon_color
			katana_blade.width = 3.5

func _physics_process(delta: float) -> void:
	var currently_guarding = is_holding_block()
	if currently_guarding and not was_guarding_last_frame:
		guard_start_time = float(Time.get_ticks_msec()) / 1000.0
	was_guarding_last_frame = currently_guarding

	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			reset_combo()
			
	if state_machine != null:
		state_machine.physics_update(delta)

func _process(delta: float) -> void:
	time_alive += delta
	_update_procedural_motion(delta)
	if state_machine != null:
		state_machine.update(delta)

func _update_procedural_motion(delta: float) -> void:
	if visual_root == null:
		return
		
	# 1. Smooth facing direction flip (eliminates 1-frame pop)
	visual_root.scale.x = move_toward(visual_root.scale.x, float(facing_direction), 16.0 * delta)
	
	# 2. Dynamic Torso lean into velocity
	var target_lean = clampf((velocity.x * float(facing_direction)) * 0.0007, -0.14, 0.22)
	visual_root.rotation = lerpf(visual_root.rotation, target_lean, 10.0 * delta)
	
	# 3. Organic breathing & stride bobbing
	var is_idle = state_machine != null and state_machine.current_state is IdleState
	var is_moving = state_machine != null and state_machine.current_state is MoveState
	
	var bob: float = 0.0
	if is_idle:
		bob = sin(time_alive * 3.2) * 1.6
	elif is_moving:
		bob = absf(sin(time_alive * 9.0)) * 3.5
		
	var torso = visual_root.get_node_or_null("Torso")
	var head = visual_root.get_node_or_null("Head")
	if torso != null:
		torso.position.y = bob
	if head != null:
		head.position.y = base_head_pos_y + bob * 1.15

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0:
			velocity.y = 0.0

func face_opponent() -> void:
	if opponent == null:
		return
	var diff = opponent.global_position.x - global_position.x
	if absf(diff) > 8.0:
		var target_facing = 1 if diff > 0 else -1
		if target_facing != facing_direction:
			facing_direction = target_facing
			visual_root.scale.x = float(facing_direction)

func is_holding_block() -> bool:
	return false

func is_crouch_requested() -> bool:
	return false

func is_jump_requested() -> bool:
	return false

func get_movement_input() -> float:
	return 0.0

func check_attack_inputs(_airborne: bool = false) -> bool:
	return false

func check_crouch_attacks() -> bool:
	return false

func take_hit(hitbox: Hitbox, zone: DamageCalculator.HitZone) -> void:
	if is_invulnerable or health <= 0.0:
		return
		
	var attacker_facing = 1
	if hitbox.attacker != null:
		attacker_facing = hitbox.attacker.facing_direction
		
	# Check for block: holding away from attacker or explicit block action
	var is_blocked = is_holding_block() and not hitbox.is_unblockable
	
	if is_blocked:
		var guard_elapsed = float(Time.get_ticks_msec()) / 1000.0 - guard_start_time
		var is_parry = guard_elapsed >= 0.0 and guard_elapsed <= 0.14
		
		if is_parry:
			# JUST-FRAME PARRY DEFLECTION: Zero chip damage, attacker staggered, defender advantage!
			AudioManager.play_parry_deflect()
			add_shadow_energy(30.0)
			if get_parent() != null:
				HitSparks.spawn_at(get_parent(), global_position + Vector2(0, -60), true)
			HitstopManager.trigger_hitstop(8, 12.0)
			parry_performed.emit()
			
			if hitbox.attacker != null and hitbox.attacker is Fighter:
				var att = hitbox.attacker
				if att.state_machine != null:
					att.state_machine.change_state("hitstun", {
						"duration": 0.45,
						"knockback": Vector2(-180.0 * attacker_facing, 0.0),
						"zone": DamageCalculator.HitZone.TORSO
					})
			return

		var chip_damage = maxf(1.0, hitbox.base_damage * 0.15)
		health -= chip_damage
		add_shadow_energy(8.0)
		health_changed.emit(health, max_health)
		hit_taken_event.emit(chip_damage, zone, true)
		if get_parent() != null:
			DamageNumber.spawn(get_parent(), global_position + Vector2(0, -75), chip_damage, false, true)
		
		HitstopManager.trigger_hitstop(2, 2.0)
		state_machine.change_state("blockstun", {
			"duration": hitbox.block_stun_duration,
			"attacker_facing": attacker_facing
		})
		return
		
	# Unblocked clean hit
	add_shadow_energy(14.0)
	if hitbox.attacker != null and hitbox.attacker is Fighter:
		var att_fighter: Fighter = hitbox.attacker
		att_fighter.increment_combo()
		att_fighter.add_shadow_energy(18.0)
		combo_count = att_fighter.combo_count
	else:
		combo_count += 1
		
	var final_damage = DamageCalculator.calculate_final_damage(hitbox.base_damage, zone, combo_count)
	health -= final_damage
	health = maxf(0.0, health)
	health_changed.emit(health, max_health)
	hit_taken_event.emit(final_damage, zone, false)
	if get_parent() != null:
		DamageNumber.spawn(get_parent(), global_position + Vector2(0, -85), final_damage, zone == DamageCalculator.HitZone.HEAD, false)
	
	# Audio dispatch based on zone
	if zone == DamageCalculator.HitZone.HEAD:
		AudioManager.play_kick_impact(1.2)
	else:
		AudioManager.play_punch_impact(1.0)
		
	HitstopManager.trigger_hitstop(hitbox.hitstop_frames, 6.0 if not hitbox.is_knockdown else 10.0)
	
	if get_parent() != null:
		HitSparks.spawn_at(get_parent(), global_position + Vector2(0, -50), true)
	
	if health <= 0.0:
		defeated.emit()
		GameManager.on_fighter_defeated(self)
		state_machine.change_state("knockdown", {
			"knockback": Vector2(-280.0 * attacker_facing, -240.0)
		})
		return
		
	if hitbox.is_knockdown:
		state_machine.change_state("knockdown", {
			"knockback": Vector2(hitbox.knockback.x * attacker_facing, hitbox.knockback.y)
		})
	else:
		state_machine.change_state("hitstun", {
			"duration": hitbox.hit_stun_duration,
			"knockback": Vector2(hitbox.knockback.x * attacker_facing, hitbox.knockback.y),
			"zone": zone
		})

func increment_combo() -> void:
	combo_count += 1
	combo_timer = COMBO_RESET_WINDOW
	combo_updated.emit(combo_count)

func reset_combo() -> void:
	combo_count = 0
	combo_timer = 0.0
	combo_updated.emit(0)

func set_invulnerable(val: bool) -> void:
	is_invulnerable = val
	if hurtbox_head: hurtbox_head.is_invulnerable = val
	if hurtbox_torso: hurtbox_torso.is_invulnerable = val
	if hurtbox_legs: hurtbox_legs.is_invulnerable = val

func play_animation(anim_name: String) -> void:
	if anim_player != null and anim_player.has_animation(anim_name):
		anim_player.play(anim_name)

func flash_hit_effect() -> void:
	var tween = create_tween()
	modulate = Color(3.0, 1.2, 1.2, 1.0) # Flash highlight
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)

func reset_for_round() -> void:
	health = max_health
	shadow_energy = 0.0
	reset_combo()
	set_invulnerable(false)
	velocity = Vector2.ZERO
	health_changed.emit(health, max_health)
	shadow_energy_changed.emit(shadow_energy, max_shadow_energy)
	if state_machine != null:
		state_machine.change_state("idle")
