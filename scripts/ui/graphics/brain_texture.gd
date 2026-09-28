extends TextureRect

@onready var AudioStreamA : AudioStreamPlayer2D = $AudioStreamPlayer2D_A

var t: float = 0.0
var base_scale := 2.4
var beat_strength := 0.05
var bpm := 36.0
var heartbeat_threshold := 1.005
var heartbeat_triggered := false



func _process(delta: float) -> void:
	# --- Init ---
	t += delta  # accumulate time
	var value = base_scale + 0.01 * sin(t)  # oscillates between 1.9 and 2.9
	self.scale = Vector2(value,value)
	self.rotation = 0.01 * sin(t * 0.2)
	
	# --- Heartbeat ---
	var beat_freq = bpm / 60.0  
	var beat1 = exp(-8.0 * fposmod(t * beat_freq, 2.0)) * sin(t * beat_freq * PI * 3.0)
	var beat2 = exp(-8.0 * fposmod(t * beat_freq - 0.2, 2.0)) * sin((t * beat_freq - 0.2) * PI * 3.0)

	var heartbeat = ((beat1 + beat2) * beat_strength) * .50 + 1
	self.scale *= heartbeat
	
	# --- sfx ---
	if heartbeat > heartbeat_threshold and not heartbeat_triggered:
		heartbeat_triggered = true
		# pause sound if graphic is not visible
		if self.visible:
			AudioStreamA.play()
	elif heartbeat < heartbeat_threshold:
		heartbeat_triggered = false
	
