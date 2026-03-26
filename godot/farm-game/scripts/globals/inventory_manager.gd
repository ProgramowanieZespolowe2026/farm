extends Node

signal inventory_updated
signal active_item_updated

const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")
const NUM_INVENTORY_SLOTS = 20
const NUM_HOTBAR_SLOTS = 10

var items: Array = []
var hotbar: Array = []

func _ready():
	items.resize(NUM_INVENTORY_SLOTS)
	hotbar.resize(NUM_HOTBAR_SLOTS)

var active_item_slot = 0

func add_item(item_name: String, value_to_add: int):
	var remaining = value_to_add
	
	for i in range(items.size()):
		if items[i] != null and items[i]["name"] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var can_add = stack_size - items[i]["value"]
		
			if can_add > 0:
				if remaining <= can_add:
					items[i]["value"] += remaining
					remaining = 0
				else:
					items[i]["value"] += can_add
					remaining -= can_add
				
			if remaining == 0:
				inventory_updated.emit()
				return
	
	for i in range(items.size()):
		if items[i] == null:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var add_here = min(stack_size, remaining)
			items[i] = {
				"name": item_name,
				"value": add_here
			}
			remaining -= add_here
			
			if remaining == 0:
				inventory_updated.emit()
				return

	if remaining > 0:
		print("Nie ma wystarczająco miejsca w ekwipunku, pozostało:", remaining)

	inventory_updated.emit()


func remove_item(slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index] = null
	else:
		items[slot.slot_index] = null
#	inventory_updated.emit()

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index] = {
		"name": item.item_name,
		"value": item.item_value
	}
	else:
		items[slot.slot_index] = {
			"name": item.item_name,
			"value": item.item_value
		}
#	inventory_updated.emit()

func add_item_value (slot: SlotClass, value_to_add: int, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index]["value"] += value_to_add
	else:
		items[slot.slot_index]["value"] += value_to_add

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	active_item_updated.emit()

func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS -1
	else:
		active_item_slot -= 1
	active_item_updated.emit()
