extends CanvasLayer

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen
@onready var recipe_book = %RecipeBookPanel

@export var building_entered: BuildingEntered
signal inventory_open(is_open: bool)
signal recipe_book_open(is_open: bool)

var holding_item = null

func _ready():
	inventory_open.emit(false)
	ItemTooltipManager.tooltip = $MarginContainer/ItemTooltip
func _input(event):
	if event.is_action_pressed("Inventory"):
		$MarginContainer/Inventory.visible = !$MarginContainer/Inventory.visible
		$MarginContainer/Inventory.initialize_inventory()
		menu_open.play()
		inventory_open.emit($MarginContainer/Inventory.visible)
		
	if event.is_action_pressed("open_recipe_book"):
		recipe_book.visible = !recipe_book.visible
		if recipe_book.visible:
			recipe_book.update_recipe_page()
			
		menu_open.play()
		recipe_book_open.emit(recipe_book.visible)
		
		
	if event.is_action_pressed("scroll_up"):
		InventoryManager.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		InventoryManager.active_item_scroll_down()
		
func _process(_delta):
	var tooltip = $MarginContainer/ItemTooltip
	if tooltip.visible:
		tooltip.global_position = get_viewport().get_mouse_position() + Vector2(10, -5)
