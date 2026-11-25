class_name HUD
extends CanvasLayer

@onready var p1_bar: ProgressBar = $Margin/TopBar/P1Container/P1HealthBar
@onready var p1_damage_trail: ProgressBar = $Margin/TopBar/P1Container/P1HealthBar/DamageTrail
@onready var p1_shadow_bar: ProgressBar = $Margin/TopBar/P1Container/P1ShadowBar
@onready var p1_name_label: Label = $Margin/TopBar/P1Container/P1Name

@onready var p2_bar: ProgressBar = $Margin/TopBar/P2Container/P2HealthBar
@onready var p2_damage_trail: ProgressBar = $Margin/TopBar/P2Container/P2HealthBar/DamageTrail
@onready var p2_shadow_bar: ProgressBar = $Margin/TopBar/P2Container/P2ShadowBar
@onready var p2_name_label: Label = $Margin/TopBar/P2Container/P2Name

@onready var timer_label: Label = $Margin/TopBar/TimerCenter/TimerLabel
@onready var round_p1_wins: HBoxContainer = $Margin/TopBar/P1Container/WinMarkers
@onready var round_p2_wins: HBoxContainer = $Margin/TopBar/P2Container/WinMarkers

@onready var combo_label: Label = $Margin/ComboBanner/ComboLabel
@onready var announcement_label: Label = $Margin/Announcement/BigLabel
@onready var feedback_label: Label = $Margin/CombatFeedback/FeedbackLabel
@onready var shadow_ready_label: Label = $Margin/ShadowReady/ReadyLabel

var p1_ref: Fighter = null
var p2_ref: Fighter = null

func _ready() -> void:
	announcement_label.text = ""
	combo_label.text = ""
	if feedback_label != null:
		feedback_label.text = ""
	GameManager.timer_updated.connect(_on_timer_updated)
	GameManager.round_started.connect(_on_round_started)
	GameManager.round_ended.connect(_on_round_ended)
	GameManager.match_ended.connect(_on_match_ended)

func setup(p1: Fighter, p2: Fighter) -> void:
	p1_ref = p1
	p2_ref = p2
	
	p1_name_label.text = p1.fighter_name.to_upper()
	p2_name_label.text = p2.fighter_name.to_upper()
	
	p1.health_changed.connect(_on_p1_health_changed)
	p2.health_changed.connect(_on_p2_health_changed)
	
	p1.shadow_energy_changed.connect(_on_p1_shadow_changed)
	p2.shadow_energy_changed.connect(_on_p2_shadow_changed)
	
	p1.combo_updated.connect(func(c): _on_combo_updated(p1, c))
	p2.combo_updated.connect(func(c): _on_combo_updated(p2, c))
	
	p1.parry_performed.connect(func(): _show_feedback("PARRY DEFLECT!", Color(0.2, 0.9, 1.0)))
	p2.parry_performed.connect(func(): _show_feedback("ENEMY PARRY!", Color(1.0, 0.3, 0.3)))
	
	p1.hit_taken_event.connect(func(_d, z, b): _on_fighter_hit_feedback(p1, z, b))
	p2.hit_taken_event.connect(func(_d, z, b): _on_fighter_hit_feedback(p2, z, b))

func _on_fighter_hit_feedback(_target: Fighter, zone: DamageCalculator.HitZone, is_blocked: bool) -> void:
	if is_blocked:
		return
	if zone == DamageCalculator.HitZone.HEAD:
		_show_feedback("CRITICAL HEAD HIT!", Color(1.0, 0.85, 0.2))

func _show_feedback(txt: String, col: Color) -> void:
	if feedback_label == null:
		return
	feedback_label.text = txt
	feedback_label.modulate = col
	feedback_label.scale = Vector2(1.3, 1.3)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.15)
	await get_tree().create_timer(0.6).timeout
	var fade = create_tween()
	fade.tween_property(feedback_label, "modulate:a", 0.0, 0.25)

func _on_p1_health_changed(current: float, max_val: float) -> void:
	var target_val = (current / max_val) * 100.0
	p1_bar.value = target_val
	var tween = create_tween()
	tween.tween_property(p1_damage_trail, "value", target_val, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_p2_health_changed(current: float, max_val: float) -> void:
	var target_val = (current / max_val) * 100.0
	p2_bar.value = target_val
	var tween = create_tween()
	tween.tween_property(p2_damage_trail, "value", target_val, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_p1_shadow_changed(curr: float, max_val: float) -> void:
	if p1_shadow_bar != null:
		p1_shadow_bar.value = (curr / max_val) * 100.0
	if shadow_ready_label != null:
		if curr >= max_val:
			shadow_ready_label.text = "⚡ SHADOW ABILITY READY [SPACE / U] ⚡"
			shadow_ready_label.modulate = Color(0.85, 0.4, 1.0)
		else:
			shadow_ready_label.text = ""

func _on_p2_shadow_changed(curr: float, max_val: float) -> void:
	if p2_shadow_bar != null:
		p2_shadow_bar.value = (curr / max_val) * 100.0

func _on_timer_updated(seconds: int) -> void:
	timer_label.text = str(seconds)
	if seconds <= 10:
		timer_label.modulate = Color(1.0, 0.25, 0.25)
	else:
		timer_label.modulate = Color(1.0, 1.0, 1.0)

func _on_combo_updated(fighter: Fighter, count: int) -> void:
	if count >= 2:
		combo_label.text = "%s\n%d HITS!" % [fighter.fighter_name.to_upper(), count]
		combo_label.scale = Vector2(1.35, 1.35)
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15)
	else:
		combo_label.text = ""

func _on_round_started(round_num: int) -> void:
	_update_win_markers()
	if GameManager.game_mode == 1:
		_show_announcement("TIER %d: ROUND %d" % [GameManager.tournament_tier, round_num])
	else:
		_show_announcement("ROUND %d" % round_num)
	await get_tree().create_timer(1.0).timeout
	_show_announcement("FIGHT!")

func _on_round_ended(winner: Node) -> void:
	_update_win_markers()
	if winner != null and winner is Fighter:
		_show_announcement("K.O.!\n%s WINS ROUND" % winner.fighter_name.to_upper())
	else:
		_show_announcement("TIME UP!\nDRAW")

func _on_match_ended(champion: Node) -> void:
	_update_win_markers()
	if champion != null and champion is Fighter:
		if GameManager.game_mode == 1:
			if champion == p1_ref:
				_show_announcement("🏆 TOURNAMENT CHAMPION!\n%s CONQUERS ALL!" % champion.fighter_name.to_upper())
			else:
				_show_announcement("DEFEATED IN TIER %d!\nTRAIN AND RETURN" % GameManager.tournament_tier)
		else:
			_show_announcement("VICTORY!\n%s IS THE SHADOW RONIN" % champion.fighter_name.to_upper())

func _update_win_markers() -> void:
	# Refresh round win tokens
	for c in round_p1_wins.get_children():
		c.queue_free()
	for c in round_p2_wins.get_children():
		c.queue_free()
		
	for i in range(GameManager.p1_round_wins):
		var token = Label.new()
		token.text = "🔴"
		token.theme_override_font_sizes.font_size = 14
		round_p1_wins.add_child(token)
		
	for i in range(GameManager.p2_round_wins):
		var token = Label.new()
		token.text = "🔴"
		token.theme_override_font_sizes.font_size = 14
		round_p2_wins.add_child(token)

func _show_announcement(txt: String) -> void:
	announcement_label.text = txt
	announcement_label.modulate.a = 0.0
	announcement_label.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(announcement_label, "modulate:a", 1.0, 0.25)
	tween.tween_property(announcement_label, "scale", Vector2(1.1, 1.1), 0.35)
	
	await get_tree().create_timer(1.2).timeout
	var fade = create_tween()
	fade.tween_property(announcement_label, "modulate:a", 0.0, 0.3)
