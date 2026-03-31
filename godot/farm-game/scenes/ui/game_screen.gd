extends CanvasLayer

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen

var holding_item = null

func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		menu_open.play()
		
	if event.is_action_pressed("Building"):
		$MarginContainer/ChickenCoopPanel.visible = !$MarginContainer/ChickenCoopPanel.visible
		$MarginContainer/ChickenCoopPanel.initialize_inventory()
		menu_open.play()
		
		
	if event.is_action_pressed("scroll_up"):
		InventoryManager.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		InventoryManager.active_item_scroll_down()
