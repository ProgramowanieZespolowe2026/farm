extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options


func _ready() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map/main_map.tscn")


func _on_continue_pressed() -> void:
	if SaveManager.load_game():
		get_tree().change_scene_to_file("res://scenes/map/test_level.tscn")
		SaveManager.apply_loaded_data()


func _on_multi_player_pressed() -> void:
	pass # Replace with function body.


func _on_dlc_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_to_menu_pressed() -> void:
	_ready()
