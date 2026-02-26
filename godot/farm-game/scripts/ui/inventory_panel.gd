extends Node2D

const SlotClass = preload("res://scripts/ui/slot.gd")
@onready var inventory_slots = $GridContainer
#@onready var equip_slots = $EquipSlots.get_children()
var holding_item = null

func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slots[i].slot_index = i
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
			if holding_item != null:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					if holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else:
						left_click_same_item(slot)
			elif slot.item:
				left_click_not_holding(slot)
func _input(_event):
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
func left_click_empty_slot(slot: SlotClass):
	InventoryManager.add_item_to_empty_slot(holding_item, slot)
	slot.putIntoSlot(holding_item)
	holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	InventoryManager.remove_item(slot)
	InventoryManager.add_item_to_empty_slot(holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(holding_item)
	holding_item = temp_item

func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_value
	if able_to_add >= holding_item.item_value:
		InventoryManager.add_item_value(slot, holding_item.item_value)
		slot.item.add_item_value(holding_item.item_value)
		holding_item.queue_free()
		holding_item = null
	else:
		InventoryManager.add_item_value(slot, able_to_add)
		slot.item.add_item_value(able_to_add)
		holding_item.decrease_item_value(able_to_add)

func left_click_not_holding(slot: SlotClass):
	holding_item = slot.item
	slot.pickFromSlot()
	InventoryManager.remove_item(slot)
	if holding_item != null:
		holding_item.global_position = get_global_mouse_position()
