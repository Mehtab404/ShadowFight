extends Node

## GameManager (Autoload)
## Coordinates round loop, match scoring, fighter registrations, and timers.

signal round_started(round_number: int)
signal round_ended(winner: Node)
signal match_ended(champion: Node)
signal timer_updated(time_remaining: int)
signal combo_scored(fighter: Node, combo_count: int, damage: float)

enum MatchState {
	INITIALIZING,
	ROUND_START,
	FIGHTING,
	ROUND_OVER,
	MATCH_OVER
}

@export var round_time_limit: int = 99
@export var rounds_to_win: int = 2

var current_state: MatchState = MatchState.INITIALIZING
var current_round: int = 1
var time_remaining: float = 99.0
var p1_fighter: CharacterBody2D = null
var p2_fighter: CharacterBody2D = null
var p1_round_wins: int = 0
var p2_round_wins: int = 0

func _ready() -> void:
	time_remaining = float(round_time_limit)

func register_fighters(p1: CharacterBody2D, p2: CharacterBody2D) -> void:
	p1_fighter = p1
	p2_fighter = p2

func start_new_match() -> void:
	current_round = 1
	p1_round_wins = 0
	p2_round_wins = 0
	start_round()

func start_round() -> void:
	time_remaining = float(round_time_limit)
	current_state = MatchState.ROUND_START
	round_started.emit(current_round)
	
	if p1_fighter != null and p1_fighter.has_method("reset_for_round"):
		p1_fighter.reset_for_round()
	if p2_fighter != null and p2_fighter.has_method("reset_for_round"):
		p2_fighter.reset_for_round()
		
	# Countdown delay before fight commences
	await get_tree().create_timer(1.2).timeout
	current_state = MatchState.FIGHTING

func _physics_process(delta: float) -> void:
	if current_state != MatchState.FIGHTING:
		return
		
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_on_timeout()
	timer_updated.emit(ceili(time_remaining))

func _on_timeout() -> void:
	if current_state != MatchState.FIGHTING:
		return
	var winner = null
	if p1_fighter != null and p2_fighter != null:
		if p1_fighter.health > p2_fighter.health:
			winner = p1_fighter
		elif p2_fighter.health > p1_fighter.health:
			winner = p2_fighter
	finish_round(winner)

func on_fighter_defeated(defeated_fighter: CharacterBody2D) -> void:
	if current_state != MatchState.FIGHTING:
		return
	var winner = p1_fighter if defeated_fighter == p2_fighter else p2_fighter
	HitstopManager.trigger_slowmo_ko()
	finish_round(winner)

func finish_round(winner: Node) -> void:
	current_state = MatchState.ROUND_OVER
	if winner == p1_fighter:
		p1_round_wins += 1
	elif winner == p2_fighter:
		p2_round_wins += 1
		
	round_ended.emit(winner)
	
	await get_tree().create_timer(2.5).timeout
	
	if p1_round_wins >= rounds_to_win:
		current_state = MatchState.MATCH_OVER
		match_ended.emit(p1_fighter)
	elif p2_round_wins >= rounds_to_win:
		current_state = MatchState.MATCH_OVER
		match_ended.emit(p2_fighter)
	else:
		current_round += 1
		start_round()
