class_name HUD
extends CanvasLayer

@onready var p1_bar: ProgressBar = $Margin/TopBar/P1Container/P1HealthBar
@onready var p1_damage_trail: ProgressBar = $Margin/TopBar/P1Container/P1HealthBar/DamageTrail
@onready var p1_name_label: Label = $Margin/TopBar/P1Container/P1Name

@onready var p2_bar: ProgressBar = $Margin/TopBar/P2Container/P2HealthBar
@onready var p2_damage_trail: ProgressBar = $Margin/TopBar/P2Container/P2HealthBar/DamageTrail
@onready var p2_name_label: Label = $Margin/TopBar/P2Container/P2Name

@onready var timer_label: Label = $Margin/TopBar/TimerCenter/TimerLabel
@onready var round_p1_wins: HBoxContainer = $Margin/TopBar/P1Container/WinMarkers
@onready var round_p2_wins: HBoxContainer = $Margin/TopBar/P2Container/WinMarkers

@onready var combo_label: Label = $Margin/ComboBanner/ComboLabel
@onready var announcement_label: Label = $Margin/Announcement/BigLabel

var p1_ref: Fighter = null
var p2_ref: Fighter = null

func _ready() -> void:
	announcement_label.text = ""
	combo_label.text = ""
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
	
	p1.combo_updated.connect(func(c): _on_combo_updated(p1, c))
	p2.combo_updated.connect(func(c): _on_combo_updated(p2, c))

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
	_show_announcement("ROUND %d" % round_num)
	await get_tree().create_timer(1.0).timeout
	_show_announcement("FIGHT!")

func _on_round_ended(winner: Node) -> void:
	if winner != null and winner is Fighter:
		_show_announcement("K.O.!\n%s WINS ROUND" % winner.fighter_name.to_upper())
	else:
		_show_announcement("TIME UP!\nDRAW")

func _on_match_ended(champion: Node) -> void:
	if champion != null and champion is Fighter:
		_show_announcement("VICTORY!\n%s IS THE SHADOW RONIN" % champion.fighter_name.to_upper())

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
