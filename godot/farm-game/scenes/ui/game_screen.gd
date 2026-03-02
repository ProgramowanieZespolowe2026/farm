extends CanvasLayer

@onready var inventory_open: AudioStreamPlayer2D = $InventoryOpen

func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		inventory_open.play()
