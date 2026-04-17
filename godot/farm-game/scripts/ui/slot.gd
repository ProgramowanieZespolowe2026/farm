extends Panel

var default_tex = preload("res://assets/ui/button1.png")
var selected_texture = preload("res://assets/ui/button2.png")

@onready var progress_bar: TextureProgressBar = get_node_or_null("TextureProgressBar")

var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://scenes/items/item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	CHICKENCOOP,
	CHICKENCOOP_FOOD
}

func _ready():
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	selected_style.texture = selected_texture
	if progress_bar:
		progress_bar.max_value = 30.0
		#progress_bar.visible = false

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
	update_progress(0)
	
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

func update_progress(current_value: int):
	if progress_bar:
		progress_bar.value = current_value
		#if progress_bar.value == 0:
			#progress_bar.visible = false
		#else:
			#progress_bar.visible = true
		
func remove_item():
	if item != null:
		item.queue_free()
		item = null
		update_progress(0)
