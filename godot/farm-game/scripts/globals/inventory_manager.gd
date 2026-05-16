extends Node

signal inventory_updated
signal active_item_updated

const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")
const NUM_INVENTORY_SLOTS = 20
const NUM_HOTBAR_SLOTS = 10

var items: Array = []
var hotbar: Array = []

var active_coop_data_ref = null

func _ready():
	items.resize(NUM_INVENTORY_SLOTS)
	hotbar.resize(NUM_HOTBAR_SLOTS)
	
	items[0] = {
			"name": "Egg",
			"value": 5}
	items[1] = {
			"name": "Chicken_Baby",
			"value": 1}
	items[2] = {
			"name": "Chicken_Adult",
			"value": 1}
	items[3] = {
			"name": "Carrot_Item",
			"value": 4}
	items[4] = {
			"name": "Carrot_Item",
			"value": 50}
	items[5] = {
			"name": "Cow_Baby",
			"value": 1}
	items[6] = {
			"name": "Cow_Adult",
			"value": 1}
	items[7] = {
			"name": "Sheep_Adult_HairCut",
			"value": 1}
	items[8] = {
			"name": "Pig_Adult",
			"value": 1}
	items[9] = {
			"name": "Pig_Baby",
			"value": 1}
	items[10] = {
			"name": "Apple_Item",
			"value": 1}
	hotbar[1] = {
			"name": "Hoe",
			"value": 1}
	hotbar[4] = {
			"name": "Fertilizer",
			"value": 1}

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
		check_slot_for_tools()
	else:
		items[slot.slot_index] = null

func decrease_item_value():
	hotbar[active_item_slot]["value"] -= 1
	if hotbar[active_item_slot]["value"] == 0:
			hotbar[active_item_slot] = null
			check_slot_for_tools()

	inventory_updated.emit()

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index] = {"name": item.item_name, "value": item.item_value}
		check_slot_for_tools()
	else:
		items[slot.slot_index] = {"name": item.item_name, "value": item.item_value}

func add_item_value (slot: SlotClass, value_to_add: int, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index]["value"] += value_to_add
		check_slot_for_tools()
	else:
		items[slot.slot_index]["value"] += value_to_add

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	print(active_item_slot)
	active_item_updated.emit()
	check_slot_for_tools()

func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS -1
	else:
		active_item_slot -= 1
	print(active_item_slot)
	active_item_updated.emit()
	check_slot_for_tools()
	
func check_slot_for_tools():
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if hotbar[active_item_slot]:
			var item_name = hotbar[active_item_slot].name
			
			if item_name in DataTypes.Tools:
				player.current_tool = DataTypes.Tools[item_name]
			else:
				player.current_tool = DataTypes.Tools.None
		else:
				player.current_tool = DataTypes.Tools.None
