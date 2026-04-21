extends Node2D
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")

@onready var shop_panel: Node2D = $"."
@onready var slot_product_to_sell: Panel = $Slot21
@onready var product_price: Label = $ProductPrice

signal shop_panel_open(is_open: bool)

var product_to_sell: SlotClass


func _ready():
	#animal_building_panel_open.emit(false)
	#TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	#
	#var slots = animalBuildingItems.get_children()
	#for i in range(slots.size()):
		#var slot = slots[i]
		#slot.gui_input.connect(slot_gui_input.bind(slot))
		#slots[i].slot_index = i
		#slots[i].slot_type = SlotClass.SlotType.CHICKENCOOP
	#product_to_sell.resize(1)
	
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
	var item = find_parent("GameScreen").holding_item
	
	slot.putIntoSlot(find_parent("GameScreen").holding_item)
	
	find_parent("GameScreen").holding_item = null
	product_to_sell = slot
	calc_product_price()

func left_click_different_item(event: InputEvent, slot: SlotClass):
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
	find_parent("GameScreen").holding_item = slot.item
	slot.pickFromSlot()
	InventoryManager.remove_item(slot)
	if find_parent("GameScreen").holding_item != null:
		find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
	product_to_sell = null
	calc_product_price()
	

func open_panel(coop_pos: Vector2i):
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
	
	#print(new_item.name)
	if product_to_sell:
		print(product_to_sell.item.item_name)
		for i in JsonData.item_data:
			var item = JsonData.item_data[i]
			if i == product_to_sell.item.item_name:
				#print(item["Price"])
				product_price.text = str(item["Price"]*product_to_sell.item.item_value)
				break
	else:
		print("pusto")
		product_price.text = "0"
	#if product_to_sell[0] == null:
		#product_price.text = "0"
	#else:
		#for i in JsonData.item_data:
			#var item = JsonData.item_data[i]
			#if i == product_to_sell[0].name:
				##print(item["Price"])
				#product_price.text = str(item["Price"])
				#break
	
