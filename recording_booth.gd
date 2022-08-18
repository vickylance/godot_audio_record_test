extends Control


onready var record_btn := $"%record_button" as Button
onready var play_btn := $"%play_button" as Button
onready var status_txt := $"%status" as Label
onready var audio_player := $"%audio_player" as AudioStreamPlayer

var record_bus_index: int
var record_effect: AudioEffectRecord
var recording: AudioStreamSample

func _ready() -> void:
	record_bus_index = AudioServer.get_bus_index("Record")
	record_effect = AudioServer.get_bus_effect(record_bus_index, 0)
	assert(record_btn.connect("pressed", self, "_on_record_button_pressed") == OK)
	assert(play_btn.connect("pressed", self, "_on_play_button_pressed") == OK)
	status_txt.text = "Idle"
	pass

func _process(_delta: float) -> void:
	if !recording or audio_player.playing:
		play_btn.disabled = true
	else:
		play_btn.disabled = false
	pass

func start_recording():
	record_effect.set_recording_active(true)
	status_txt.text = "Recording"
	record_btn.text = "Stop recording"
	pass

func stop_recording():
	record_effect.set_recording_active(false)
	status_txt.text = "Idle"
	record_btn.text = "Record"
	recording = record_effect.get_recording()
	pass

func _on_record_button_pressed() -> void:
	if record_effect.is_recording_active():
		stop_recording()
	else:
		start_recording()
	pass

func start_playing():
	audio_player.stream = recording
	audio_player.play()
	play_btn.disabled = true
	status_txt.text = "Playing"
	play_btn.text = "Playing"
	pass

func stop_playing():
	audio_player.stream = null
	play_btn.disabled = false
	status_txt.text = "Idle"
	play_btn.text = "Play"
	pass

func _on_play_button_pressed() -> void:
	if !recording:
		status_txt.text = "No recording available"
		return
	start_playing()
	yield(audio_player, "finished")
	stop_playing()

