extends CanvasLayer

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen
var holding_item = null

@export var building_entered: BuildingEntered
signal inventory_open(is_open: bool)

func _ready():
	inventory_open.emit(false)
	ItemTooltipManager.tooltip = $MarginContainer/ItemTooltip
func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		menu_open.play()
		inventory_open.emit($MarginContainer/Inventory.visible)
		
	if event.is_action_pressed("scroll_up"):
		InventoryManager.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		InventoryManager.active_item_scroll_down()
		
func _process(_delta):
	var tooltip = $MarginContainer/ItemTooltip
	if tooltip.visible:
		tooltip.global_position = get_viewport().get_mouse_position() + Vector2(10, -5)
