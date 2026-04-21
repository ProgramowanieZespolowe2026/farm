extends Node2D
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")

@onready var shop_panel: Node2D = $"."
@onready var slot_product_to_sell: Panel = $Slot21
@onready var product_price: Label = $ProductPrice
@onready var shop_slots: GridContainer = $Control2/GridContainer

signal shop_panel_open(is_open: bool)

var product_to_sell: SlotClass


func _ready():
	var slots = shop_slots.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.SHOP
	#InventoryManager.inventory_updated.connect(initialize_inventory)
	
	slot_product_to_sell.gui_input.connect(slot_gui_input.bind(slot_product_to_sell))
	slot_product_to_sell.slot_index = 0
	slot_product_to_sell.slot_type = SlotClass.SlotType.CHICKENCOOP_FOOD

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("GameScreen").holding_item != null:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					if find_parent("GameScreen").holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else:
						left_click_same_item(slot)
			elif slot.item:
				left_click_not_holding(slot)

func left_click_empty_slot(slot: SlotClass):
	if slot.slot_type != 4:
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		
		find_parent("GameScreen").holding_item = null
		product_to_sell = slot
		calc_product_price()

func left_click_different_item(event: InputEvent, slot: SlotClass):
	if slot.slot_type != 4:
		InventoryManager.remove_item(slot)
		InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		find_parent("GameScreen").holding_item = temp_item
		product_to_sell = slot
		calc_product_price()

func left_click_same_item(slot: SlotClass):
	if slot.slot_type != 4:
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_value
		if able_to_add >= find_parent("GameScreen").holding_item.item_value:
			InventoryManager.add_item_value(slot, find_parent("GameScreen").holding_item.item_value)
			slot.item.add_item_value(find_parent("GameScreen").holding_item.item_value)
			find_parent("GameScreen").holding_item.queue_free()
			find_parent("GameScreen").holding_item = null
		else:
			InventoryManager.add_item_value(slot, able_to_add)
			slot.item.add_item_value(able_to_add)
			find_parent("GameScreen").holding_item.decrease_item_value(able_to_add)
		product_to_sell = slot
		calc_product_price()

func left_click_not_holding(slot: SlotClass):
	if slot.slot_type != 4:
		find_parent("GameScreen").holding_item = slot.item
		slot.pickFromSlot()
		InventoryManager.remove_item(slot)
		if find_parent("GameScreen").holding_item != null:
			find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
		product_to_sell = null
		calc_product_price()
	

func open_panel(coop_pos: Vector2i):
	fetch_products_price()
	setVisiblePanel(true)

func close_panel():
	setVisiblePanel(false)
			
func setVisiblePanel(is_open = null):
	if is_open == null:
		shop_panel.visible = !shop_panel.visible
	else:
		shop_panel.visible = is_open
	shop_panel_open.emit(shop_panel.visible)

func calc_product_price():
	if product_to_sell:
		print(product_to_sell.item.item_name)
		for i in JsonData.item_data:
			var item = JsonData.item_data[i]
			if i == product_to_sell.item.item_name:
				product_price.text = str(item["SellPrice"]*product_to_sell.item.item_value,"$")
				break
	else:
		print("pusto")
		product_price.text = "0$"
	
func fetch_products_price():
	var slots = shop_slots.get_children()
	var all_item_keys = JsonData.item_data.keys()
	for i in range(20):
			var item_id = all_item_keys[i]
			slots[i].initialize_item(item_id,1)
			slots[i].update_product_price_label(JsonData.item_data[item_id]["BuyPrice"])
			slots[i].hide_label_visibility()
			

func _on_sell_button_pressed() -> void:
	if product_to_sell:
		for i in JsonData.item_data:
			var item = JsonData.item_data[i]
			if i == product_to_sell.item.item_name:
				Wallet.add_money(item["SellPrice"]*product_to_sell.item.item_value)
				product_to_sell.remove_item()
				product_to_sell = null
				product_price.text = "0$"
				break
	

func _on_buy_button_pressed() -> void:
	var button = get_viewport().gui_get_focus_owner()
	var slot = button.get_parent()
	print(slot.item.item_name)
	InventoryManager.add_item(slot.item.item_name,1)
	fetch_products_price()
	Wallet.spend_money(slot.get_buy_product_price())
