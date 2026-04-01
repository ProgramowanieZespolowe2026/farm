extends CanvasLayer

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen
var holding_item = null

@export var building_entered: BuildingEntered
signal inventory_open(is_open: bool)
signal chicken_coop_panel_open(is_open: bool)

var playerInAreaChickenCoop = false;

func _process(delta):
	if !playerInAreaChickenCoop:
			$MarginContainer/ChickenCoopPanel.visible = false
			menu_open.play()
			chicken_coop_panel_open.emit($MarginContainer/ChickenCoopPanel.visible)

func _ready():
	inventory_open.emit(false)
	
	var ChickenCoop = get_tree().get_first_node_in_group("ChickenCoop")
	
	if ChickenCoop:
		ChickenCoop.playerInArea.connect(getPlayerInAreaChickenCoop)
	
func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		menu_open.play()
		inventory_open.emit($MarginContainer/Inventory.visible)
		
	if event.is_action_pressed("Building"):
		
		if playerInAreaChickenCoop:
			$MarginContainer/ChickenCoopPanel.visible = !$MarginContainer/ChickenCoopPanel.visible
			$MarginContainer/ChickenCoopPanel.initialize_inventory()
			menu_open.play()
			chicken_coop_panel_open.emit($MarginContainer/ChickenCoopPanel.visible)
		

		
	if event.is_action_pressed("scroll_up"):
		InventoryManager.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		InventoryManager.active_item_scroll_down()
		
func getPlayerInAreaChickenCoop(is_open: bool):
	playerInAreaChickenCoop = is_open
