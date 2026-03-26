extends Panel

var default_tex = preload("res://assets/ui/button1.png")
var selected_texture = preload("res://assets/ui/button2.png")

var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://scenes/items/item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
}

func _ready():
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	selected_style.texture = selected_texture

func refresh_style():
	if SlotType.HOTBAR == slot_type and InventoryManager.active_item_slot == slot_index:
		add_theme_stylebox_override("panel", selected_style)
	else:
		add_theme_stylebox_override("panel", default_style)


func pickFromSlot():
	if item == null:
		return
		
	remove_child(item)
	var inventoryNode = find_parent("GameScreen")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0,0)
	var inventoryNode = find_parent("GameScreen")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()
	
func initialize_item(item_name, item_value):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.set_item(item_name, item_value)
	else:
		item.set_item(item_name, item_value)
	refresh_style()
