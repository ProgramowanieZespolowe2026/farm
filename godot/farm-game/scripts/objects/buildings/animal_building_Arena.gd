class_name BuildingEntered
extends Area2D

#@onready var menu_open: AudioStreamPlayer2D = $MenuOpen

var playerInArea = false
var buildingName:String = ""

func _input(event):
	if event.is_action_pressed("Building") and playerInArea:
		var animal_ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		var shop_ui_panel = get_tree().get_first_node_in_group("ShopPanel")
		var panel = null
		
		if animal_ui_panel and (buildingName == "ChickenCoop" or buildingName == "Barn"):
			panel = animal_ui_panel
		if shop_ui_panel and buildingName == "Shop":
			panel = shop_ui_panel
			
			
		if panel:
			if panel.visible:
				panel.close_panel()
			else:
				var building_pos = get_parent().grid_position
				if BuildingDataManager.buildings_data.has(building_pos):
					panel.open_panel(building_pos)
			
			
func _on_body_entered(body: Node2D) -> void:
	if body is TemporaryPlayer:
		var parent = get_parent()
		if "object_name" in parent:
			buildingName = parent.object_name
			
		playerInArea = true

func _on_body_exited(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea = false
		var animal_ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		var shop_ui_panel = get_tree().get_first_node_in_group("ShopPanel")
		
		if animal_ui_panel:
			animal_ui_panel.close_panel()
		if shop_ui_panel:
			shop_ui_panel.close_panel()
