extends CanvasLayer

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen

func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		menu_open.play()
