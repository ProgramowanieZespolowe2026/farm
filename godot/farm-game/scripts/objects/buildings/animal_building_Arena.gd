class_name BuildingEntered
extends Area2D

#@onready var menu_open: AudioStreamPlayer2D = $MenuOpen

var playerInArea = false

func _input(event):
	if event.is_action_pressed("Building") and playerInArea:
		var ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		
		if ui_panel:
			if ui_panel.visible:
				ui_panel.close_panel()
			else:
				var coop_pos = get_parent().grid_position
				if BuildingDataManager.buildings_data.has(coop_pos):
					ui_panel.open_panel(coop_pos)

func _on_body_entered(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea = true

func _on_body_exited(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea = false
		
		var ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		if ui_panel:
			ui_panel.close_panel()
