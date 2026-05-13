extends Panel

var default_tex = preload("res://assets/ui/button1.png")
var selected_texture = preload("res://assets/ui/button2.png")

@onready var product_icon: TextureRect = get_node_or_null("ProductIcon")
@onready var progress_bar: TextureProgressBar = get_node_or_null("TextureProgressBar")
@onready var buy_button: Button = get_node_or_null("BuyButton")

var pick_from_slot_sound = preload("res://audio/sfx/pick_from_slot.tscn")


var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://scenes/items/item.tscn")
var item = null
var slot_index
var slot_type
var item_size = Vector2(16, 16)

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	CHICKENCOOP,
	CHICKENCOOP_FOOD,
	SHOP,
	PRODUCT_FOR_SELL,
	COMPOSER,
	RECIPE
}

func _ready():
	InventoryManager.inventory_updated.connect(refresh_data)
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	selected_style.texture = selected_texture
	if progress_bar:
		progress_bar.visible = false
	if product_icon:
		product_icon.visible = false
		
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
		

func refresh_style():
	if SlotType.HOTBAR == slot_type and InventoryManager.active_item_slot == slot_index:
		add_theme_stylebox_override("panel", selected_style)
	else:
		add_theme_stylebox_override("panel", default_style)


func pickFromSlot():
	if item == null:
		return
	AudioManager.pick_from_slot.play()
	remove_child(item)
	var inventoryNode = find_parent("GameScreen")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	update_progress(0)
	if product_icon:
		product_icon.visible = false
	
func putIntoSlot(new_item):
	
	AudioManager.put_in_slot.play()
	item = new_item
	item.position = (size / 2) - (item_size / 2)
	var inventoryNode = find_parent("GameScreen")
	inventoryNode.remove_child(item)
	add_child(item)
	if progress_bar:
		progress_bar.visible = true
	refresh_style()
	
func initialize_item(item_name, item_value):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.set_item(item_name, item_value)
	else:
		item.set_item(item_name, item_value)
	
	item.position = Vector2.ZERO
	await get_tree().process_frame
	
	if item != null:
		item.position = (size / 2) - (item_size / 2)
		refresh_style()

func update_progress(current_value: int):
	if progress_bar:
		progress_bar.value = current_value
		if progress_bar.value == 0:
			progress_bar.visible = false
		else:
			progress_bar.visible = true
		

func update_product_price_label(price:int):
	if buy_button:
		buy_button.text = str(price," $")

func get_buy_product_price():
	if item:
		for i in JsonData.item_data:
				if item.item_name == i:
					return JsonData.item_data[i]["BuyPrice"]
					

func remove_item():
	if item != null:
		item.queue_free()
		item = null
		update_progress(0)
		if progress_bar:
			progress_bar.visible = false
		if product_icon:
			product_icon.visible = false

func refresh_data():
	var item = null
	if slot_type != SlotType.HOTBAR and slot_type != SlotType.INVENTORY:
		return
		
	if slot_type == SlotType.HOTBAR:
		item = InventoryManager.hotbar[slot_index]
	elif slot_type == SlotType.INVENTORY:
		item = InventoryManager.items[slot_index]
	if item != null:
		initialize_item(item["name"], item["value"])
	else:
		remove_item()

func change_visibility_product_icon(is_visible:bool):
	if product_icon:
		product_icon.visible = is_visible
func set_product_icon_texture(texture_path: String):
	if product_icon:
		product_icon.texture = load(texture_path)
		product_icon.visible = true
		

func change_visibility_buy_button(is_visible:bool):
	if buy_button:
		buy_button.visible = is_visible

func hide_label_visibility():
	item.hide_label_visibility()

func _on_mouse_entered():
	if item != null:
		var description = JsonData.item_data[item.item_name]["Description"]
		ItemTooltipManager.show(description, get_viewport().get_mouse_position() + Vector2(10, -20))

func _on_mouse_exited():

	ItemTooltipManager.hide()
