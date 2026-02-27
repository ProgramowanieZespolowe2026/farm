extends Node

signal inventory_updated
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")
const NUM_INVENTORY_SLOTS = 20


var items: Array = []

func _ready():
	items.resize(NUM_INVENTORY_SLOTS)

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


func remove_item(slot: SlotClass):
	items[slot.slot_index] = null
#	inventory_updated.emit()

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
	items[slot.slot_index] = {
		"name": item.item_name,
		"value": item.item_value
	}
#	inventory_updated.emit()

func add_item_value (slot: SlotClass, value_to_add: int):
	items[slot.slot_index]["value"] += value_to_add
