extends Node

## AudioManager (Autoload)
## Procedural audio synthesizer and sound effect distributor for impacts and martial arts foley.

var _sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 8

func _ready() -> void:
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

func play_punch_impact(pitch_scale: float = 1.0) -> void:
	_play_synth_sound(80.0, 0.12, pitch_scale)

func play_kick_impact(pitch_scale: float = 0.9) -> void:
	_play_synth_sound(60.0, 0.18, pitch_scale)

func play_blade_slash(pitch_scale: float = 1.2) -> void:
	_play_synth_sound(350.0, 0.15, pitch_scale)

func play_block_clang(pitch_scale: float = 1.4) -> void:
	_play_synth_sound(500.0, 0.08, pitch_scale)

func play_whoosh(pitch_scale: float = 1.0) -> void:
	_play_synth_sound(120.0, 0.09, pitch_scale)

func _play_synth_sound(base_freq: float, duration: float, pitch: float) -> void:
	# Creates a procedural tone impact stream if audio file assets are loading
	var sample_hz: float = 22050.0
	var total_samples: int = int(sample_hz * duration)
	var byte_buffer: PackedByteArray = PackedByteArray()
	byte_buffer.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / sample_hz
		var envelope = 1.0 - (float(i) / float(total_samples))
		var wave = sin(2.0 * PI * (base_freq * pitch) * t) * envelope
		var sample_val = int(clampf(wave, -1.0, 1.0) * 32767.0)
		byte_buffer.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = int(sample_hz)
	stream.data = byte_buffer
	
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
