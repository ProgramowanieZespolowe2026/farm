extends Control

@onready var music_slider = $WoodenPanel/MarginContainer/Control/AudioControl
@onready var sfx_slider = $WoodenPanel/MarginContainer/Control/SFXControl
@onready var music_mute = $WoodenPanel/MarginContainer/Control/MusicMuteCheckbox
@onready var sfx_mute = $WoodenPanel/MarginContainer/Control/SFXMuteCheckbox

var music_bus
var sfx_bus

func _ready():
	visible = false
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("Sfx")

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

	music_mute.button_pressed = AudioServer.is_bus_mute(music_bus)
	sfx_mute.button_pressed = AudioServer.is_bus_mute(sfx_bus)


func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		if visible:
			close()
		else:
			open()
			
	elif event.is_action_pressed("ui_cancel") and visible:
		close()


func open():
	visible = true
	AudioManager.menu_open.play()
	get_tree().paused = true
	

func close():
	visible = false
	AudioManager.menu_open.play()
	get_tree().paused = false

func _on_audio_control_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	AudioManager.next_prev_sound.play()

func _on_sfx_control_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	AudioManager.next_prev_sound.play()
func _on_music_mute_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_bus, toggled_on)
	AudioManager.next_prev_sound.play()
func _on_sfx_mute_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(sfx_bus, toggled_on)
	AudioManager.next_prev_sound.play()
func _on_back_to_menu_pressed():
	close()
	#SaveManager.save_game()
	#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	
func _on_full_screen_toggled(toggled_on: bool) -> void:
	print("Fullscreen toggled: ", toggled_on)
	AudioManager.next_prev_sound.play()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_save_pressed() -> void:
	SaveManager.save_game()
