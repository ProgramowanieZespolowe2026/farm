class_name BuildingEntered
extends Area2D

#@onready var menu_open: AudioStreamPlayer2D = $MenuOpen

var playerInArea = false
var buildingName:String = ""

func _unhandled_input(event):
	if event.is_action_pressed("Building") and playerInArea:
		var animal_ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		var shop_ui_panel = get_tree().get_first_node_in_group("ShopPanel")
		var composer_ui_panel = get_tree().get_first_node_in_group("ComposerBuildingPanel")
		var panel = null
		
		if animal_ui_panel and (buildingName == "ChickenCoop" or buildingName == "Barn"):
			panel = animal_ui_panel
			AudioManager.animal_building_open.play()
		if shop_ui_panel and buildingName == "Shop":
			panel = shop_ui_panel
			AudioManager.shop_open.play()
		if composer_ui_panel and buildingName == "Composer":
			panel = composer_ui_panel
			AudioManager.menu_open.play()
			
			
		if panel:
			if panel.visible:
				panel.close_panel()
			else:
				var building_pos = get_parent().grid_position
				if BuildingDataManager.buildings_data.has(building_pos):
					panel.open_panel(building_pos)
			get_viewport().set_input_as_handled()
			
			
func _on_body_entered(body: Node2D) -> void:
	if body is TemporaryPlayer:
		var parent = get_parent()
		if "object_name" in parent:
			buildingName = parent.object_name
			
		playerInArea = true
		
		match buildingName:
			"Barn":
				AudioManager.play_barn_sound(body.global_position)
			"ChickenCoop":
				AudioManager.chicken_sound.global_position = body.global_position
				AudioManager.chicken_sound.play()
			"Composer":
				AudioManager.fly_sound.global_position = body.global_position
				AudioManager.fly_sound.play()
			_:
				print("Nieznany stan (to jest domyślny 'default')")

func _on_body_exited(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea = false
		var animal_ui_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
		var shop_ui_panel = get_tree().get_first_node_in_group("ShopPanel")
		var composer_ui_panel = get_tree().get_first_node_in_group("ComposerBuildingPanel")
		
		if animal_ui_panel:
			animal_ui_panel.close_panel()
		if shop_ui_panel:
			shop_ui_panel.close_panel()
		if composer_ui_panel:
			composer_ui_panel.close_panel()
