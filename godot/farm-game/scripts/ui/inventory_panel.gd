extends Node2D

const SlotClass = preload("res://scripts/ui/slot.gd")
@onready var inventory_slots = $GridContainer
#@onready var equip_slots = $EquipSlots.get_children()


func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	InventoryManager.inventory_updated.connect(initialize_inventory)
	
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if InventoryManager.items[i] != null:
			var data = InventoryManager.items[i]
			slots[i].initialize_item(data["name"], data["value"])
		else:
			slots[i].item = null

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
func _input(_event):
	if find_parent("GameScreen").holding_item:
		find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
func left_click_empty_slot(slot: SlotClass):
	InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
	slot.putIntoSlot(find_parent("GameScreen").holding_item)
	find_parent("GameScreen").holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	InventoryManager.remove_item(slot)
	InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(find_parent("GameScreen").holding_item)
	find_parent("GameScreen").holding_item = temp_item

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

func left_click_not_holding(slot: SlotClass):
	find_parent("GameScreen").holding_item = slot.item
	slot.pickFromSlot()
	InventoryManager.remove_item(slot)
	if find_parent("GameScreen").holding_item != null:
		find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
