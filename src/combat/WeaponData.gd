class_name WeaponData
extends Resource

## Data definition for weapons in Shadow Ronin
## Covers Bare Hands, Katana, and Naginata with distinct ranges and frame data

enum WeaponType {
	BARE_HANDS,
	KATANA,
	NAGINATA
}

@export var weapon_type: WeaponType = WeaponType.KATANA
@export var weapon_name: String = "Katana"
@export var base_damage_mult: float = 1.0
@export var reach: float = 120.0
@export var speed_scale: float = 1.0
@export var weapon_color: Color = Color(0.8, 0.82, 0.9, 1.0)
@export var trail_color: Color = Color(0.9, 0.8, 0.3, 0.8)

static func create_bare_hands() -> WeaponData:
	var w = WeaponData.new()
	w.weapon_type = WeaponType.BARE_HANDS
	w.weapon_name = "Bare Hands"
	w.base_damage_mult = 0.85
	w.reach = 65.0
	w.speed_scale = 1.25
	w.weapon_color = Color(0.1, 0.1, 0.1, 0.0) # Hidden blade
	w.trail_color = Color(0.9, 0.9, 1.0, 0.5)
	return w

static func create_katana() -> WeaponData:
	var w = WeaponData.new()
	w.weapon_type = WeaponType.KATANA
	w.weapon_name = "Katana"
	w.base_damage_mult = 1.15
	w.reach = 110.0
	w.speed_scale = 1.0
	w.weapon_color = Color(0.78, 0.82, 0.9, 1.0)
	w.trail_color = Color(0.95, 0.75, 0.25, 0.85)
	return w

static func create_naginata() -> WeaponData:
	var w = WeaponData.new()
	w.weapon_type = WeaponType.NAGINATA
	w.weapon_name = "Naginata"
	w.base_damage_mult = 1.35
	w.reach = 165.0
	w.speed_scale = 0.82
	w.weapon_color = Color(0.85, 0.6, 0.3, 1.0)
	w.trail_color = Color(0.9, 0.3, 0.2, 0.85)
	return w
