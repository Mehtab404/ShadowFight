extends Node

## AudioManager (Autoload)
## Procedural audio engine synthesizing:
## - Taiko drums & traditional Japanese Shamisen rhythms
## - Martial arts vocal kiai shouts ("Hah!", "Sei!")
## - Blade clashes, parry deflect chimes, and chain rattles

var _sfx_players: Array[AudioStreamPlayer] = []
var _bgm_player: AudioStreamPlayer = null
const POOL_SIZE: int = 12

var is_bgm_active: bool = true
var _bgm_step: int = 0
var _bgm_timer: float = 0.0
const BGM_TEMPO: float = 0.22 # Seconds per eighth note (~136 BPM)

# Traditional Japanese Hirajoshi Scale frequencies (Shamisen/Koto in D):
# D3, Eb3, G3, A3, Bb3, D4, Eb4, G4, A4
const HIRAJOSHI_PENTATONIC: Array[float] = [
	146.83, 155.56, 196.00, 220.00, 233.08,
	293.66, 311.13, 392.00, 440.00, 466.16, 587.33
]

func _ready() -> void:
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)
		
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)

func _process(delta: float) -> void:
	if not is_bgm_active:
		return
	_bgm_timer += delta
	if _bgm_timer >= BGM_TEMPO:
		_bgm_timer -= BGM_TEMPO
		_tick_bgm_step()

func _tick_bgm_step() -> void:
	_bgm_step = (_bgm_step + 1) % 16
	
	# Taiko Drum pattern:
	# Step 0: Heavy Taiko (O-Daiko)
	# Step 4, 10: Mid Taiko (Nagado)
	# Step 6, 8, 14: Sharp Rim/Shime-Daiko
	if _bgm_step == 0:
		play_taiko_bass(1.0)
	elif _bgm_step == 4 or _bgm_step == 10:
		play_taiko_mid(0.8)
	elif _bgm_step == 6 or _bgm_step == 8 or _bgm_step == 14:
		play_taiko_rim(0.6)
		
	# Shamisen / Koto Melody notes along Hirajoshi scale
	if _bgm_step % 2 == 0:
		var note_idx = (_bgm_step * 3) % HIRAJOSHI_PENTATONIC.size()
		play_shamisen_pluck(HIRAJOSHI_PENTATONIC[note_idx], 0.35)

func play_punch_impact(pitch_scale: float = 1.0) -> void:
	_play_synth_sound(85.0, 0.12, pitch_scale, 0.8, -40.0)

func play_kick_impact(pitch_scale: float = 0.9) -> void:
	_play_synth_sound(65.0, 0.18, pitch_scale, 0.9, -30.0)

func play_blade_slash(pitch_scale: float = 1.2) -> void:
	_play_synth_sound(420.0, 0.16, pitch_scale, 0.7, -250.0, "sawtooth")

func play_block_clang(pitch_scale: float = 1.4) -> void:
	_play_synth_sound(620.0, 0.08, pitch_scale, 0.8, -400.0, "square")

func play_parry_deflect(pitch_scale: float = 1.0) -> void:
	# Resonant metallic chime with harmonic overtone
	_play_synth_sound(880.0, 0.35, pitch_scale, 1.0, -120.0, "sine")

func play_chain_rattle() -> void:
	_play_synth_sound(750.0, 0.14, 1.2, 0.6, -500.0, "square")

func play_whoosh(pitch_scale: float = 1.0) -> void:
	_play_synth_sound(130.0, 0.10, pitch_scale, 0.5, -70.0)

func play_kiai_shout(is_high: bool = false) -> void:
	var base_freq = 280.0 if is_high else 190.0
	_play_synth_sound(base_freq, 0.18, 1.0, 0.85, -60.0, "triangle")

func play_taiko_bass(vol: float = 1.0) -> void:
	_play_synth_sound(55.0, 0.28, 1.0, vol, -25.0, "sine")

func play_taiko_mid(vol: float = 0.8) -> void:
	_play_synth_sound(95.0, 0.18, 1.0, vol, -45.0, "sine")

func play_taiko_rim(vol: float = 0.6) -> void:
	_play_synth_sound(260.0, 0.06, 1.0, vol, -180.0, "square")

func play_shamisen_pluck(freq: float, vol: float = 0.4) -> void:
	_play_synth_sound(freq, 0.22, 1.0, vol, -30.0, "triangle")

func toggle_bgm() -> bool:
	is_bgm_active = !is_bgm_active
	return is_bgm_active

func _play_synth_sound(base_freq: float, duration: float, pitch: float, volume: float = 1.0, sweep: float = 0.0, waveform: String = "sine") -> void:
	var sample_hz: float = 22050.0
	var total_samples: int = int(sample_hz * duration)
	var byte_buffer: PackedByteArray = PackedByteArray()
	byte_buffer.resize(total_samples * 2)
	
	var current_freq = base_freq * pitch
	var freq_decay = sweep / float(total_samples)
	var phase: float = 0.0
	
	for i in range(total_samples):
		var t = float(i) / sample_hz
		var envelope = pow(1.0 - (float(i) / float(total_samples)), 1.5)
		current_freq = maxf(20.0, current_freq + freq_decay)
		phase += 2.0 * PI * current_freq / sample_hz
		
		var wave: float = 0.0
		if waveform == "sawtooth":
			wave = fmod(phase / PI, 2.0) - 1.0
		elif waveform == "square":
			wave = 1.0 if sin(phase) >= 0.0 else -1.0
		elif waveform == "triangle":
			wave = 2.0 * absf(fmod(phase / PI, 2.0) - 1.0) - 1.0
		else: # sine
			wave = sin(phase)
			
		var sample_val = int(clampf(wave * envelope * volume, -1.0, 1.0) * 32767.0)
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
