extends Node

signal inventory_updated

var items: Array = []

func add_item(item_name: String, item_value: int = 1):
	for item in items:
		if item["name"] == item_name:
			item["value"] += item_value
			inventory_updated.emit()
			#print(items)
			return
			
	items.append({"name": item_name, "value": item_value})
	inventory_updated.emit()
	#print(items)

func remove_item(item_name: String, item_value: int = 1):
	for i in range(items.size()):
		if items[i]["name"] == item_name:
			items[i]["value"] -= item_value
			if items[i]["value"] <= 0:
				items.remove_at(i)
			inventory_updated.emit()
			return
