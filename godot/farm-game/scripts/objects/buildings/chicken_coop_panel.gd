extends Node2D

const SlotClass = preload("res://scripts/ui/slot.gd")
@onready var chickenCoopItems: GridContainer = $GridContainer
@onready var food_slot: Panel = $Slot21

var current_coop_pos: Vector2i
var active_coop_data = {} 
var foodLevel = 0
var availabilityFood = [
  "Apple_Item",
  "Cherry_Item",
  "Peach_Item",
  "Beet_Item",
  "Carrot_Item",
  "Corn_Item",
  "Corn_Seed",
  "Potato_Item",
  "Tomato_Item",
  "Tomato_Seed",
  "Wheat_Item",
  "Wheat_Seed"
]
var animals = [
  "Egg",
  "Chicken_Baby",
  "Chicken_Adult",
  "Cow_Baby",
  "Cow_Adult",
  "Pig_Baby",
  "Pig_Adult",
  "Sheep_Baby",
  "Sheep_Adult",
  "Sheep_Adult_HairCut"
]
const requiredPointsToFirstUpgrade:int = 30
const progresPointsToDie:int = 1009

@onready var food_level_amount_text: Label = $FoodLevelAmountText
@onready var chicken_coop_panel: Node2D = $"."
@onready var chicken_coop_id: Label = $ChickenCoopId

func _ready():
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	var slots = chickenCoopItems.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.CHICKENCOOP
	
	food_slot.gui_input.connect(slot_gui_input.bind(food_slot))
	food_slot.slot_index = 0
	food_slot.slot_type = SlotClass.SlotType.CHICKENCOOP_FOOD
	
func _on_time_tick(day: int, hour: int, minute: int) -> void:
	updateUI()
	
func initialize_inventory():
	var slots = chickenCoopItems.get_children()
	
	for slot in slots:
		if slot.item != null:
			slot.item.queue_free()
			slot.item = null
	
	if active_coop_data.is_empty():
		return

	var coop_items = active_coop_data["items"]
	for i in range(slots.size()):
		if i < coop_items.size() and coop_items[i] != null:
			var data = coop_items[i]
			slots[i].initialize_item(data["name"], data["value"])

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
	var is_food = (slot.slot_type == SlotClass.SlotType.CHICKENCOOP_FOOD)
	var holding_item = find_parent("GameScreen").holding_item
	
	if is_food:
		if holding_item.item_name in availabilityFood:
			add_food(holding_item.item_value)
			holding_item.queue_free()
			find_parent("GameScreen").holding_item = null
		return
	if holding_item.item_name in animals:
		if holding_item.item_value > 1:
			BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, holding_item.item_name, 1)
			
			slot.initialize_item(holding_item.item_name, 1)
			holding_item.decrease_item_value(1)
			
		else:
			
			BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, holding_item.item_name, holding_item.item_value)
			slot.putIntoSlot(holding_item)
			find_parent("GameScreen").holding_item = null

func left_click_different_item(event: InputEvent, slot: SlotClass):
	var holding_item = find_parent("GameScreen").holding_item
	
	BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, holding_item.item_name, holding_item.item_value)
	
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(holding_item)
	find_parent("GameScreen").holding_item = temp_item

func left_click_same_item(slot: SlotClass):
	#print("teraz")
	null
	#var holding_item = find_parent("GameScreen").holding_item
	#var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	#var able_to_add = stack_size - slot.item.item_value
	#
	#if able_to_add >= holding_item.item_value:
		#BuildingDataManager.add_value_to_coop_item(current_coop_pos, slot.slot_index, holding_item.item_value)
		#slot.item.add_item_value(holding_item.item_value)
		#holding_item.queue_free()
		#find_parent("GameScreen").holding_item = null
	#else:
		#BuildingDataManager.add_value_to_coop_item(current_coop_pos, slot.slot_index, able_to_add)
		#slot.item.add_item_value(able_to_add)
		#holding_item.decrease_item_value(able_to_add)

func left_click_not_holding(slot: SlotClass):
	
	var item_to_collect = BuildingDataManager.get_item_to_collect(current_coop_pos, slot.slot_index)
	if item_to_collect == null:
		find_parent("GameScreen").holding_item = slot.item
		slot.pickFromSlot()
		
		BuildingDataManager.remove_item_from_coop(current_coop_pos, slot.slot_index)
		
		if find_parent("GameScreen").holding_item != null:
			find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
	else:
		print("zbieram jajko")
		BuildingDataManager.increase_item_to_collect(current_coop_pos, slot.slot_index)
		var egg_node = slot.get_node_or_null("Egg")
		if egg_node:
			egg_node.queue_free()
		InventoryManager.add_item(item_to_collect.name, item_to_collect.value)

func setVisiblePanel(is_open = null):
	if is_open == null:
		chicken_coop_panel.visible = !chicken_coop_panel.visible
	else:
		chicken_coop_panel.visible = is_open

func open_coop(coop_pos: Vector2i):
	current_coop_pos = coop_pos
	active_coop_data = BuildingDataManager.buildings_data[coop_pos]
	
	foodLevel = active_coop_data["food_level"]
	food_level_amount_text.text = str(foodLevel)
	
	if chicken_coop_id != null:
		chicken_coop_id.text = str(active_coop_data["id"])
	
	initialize_inventory()
	setVisiblePanel(true)

func close_coop():
	setVisiblePanel(false)
	current_coop_pos = Vector2i.ZERO
	active_coop_data = {}
	
	var slots = chickenCoopItems.get_children()
	for slot in slots:
		if slot.item != null:
			slot.item.queue_free()
			slot.item = null

func add_food(item_value: int):
	foodLevel += item_value
	food_level_amount_text.text = str(foodLevel)
	if !active_coop_data.is_empty():
		active_coop_data["food_level"] = foodLevel

func updateUI():
	var slots = chickenCoopItems.get_children()
	for i in range(slots.size()):
		if slots[i].item != null:
			
			var slot = slots[i];
			var itemName = slots[i].item.item_name
			
			#print("do zebrania ",BuildingDataManager.get_item_to_collect(current_coop_pos, slot.slot_index))
			if BuildingDataManager.get_item_to_collect(current_coop_pos, slot.slot_index) != null:
				if not slot.has_node("Egg"):
					var egg_icon = TextureRect.new()
					egg_icon.texture = preload("uid://cs1gdd8apg456")
					egg_icon.name = "Egg"
					slot.add_child(egg_icon)
					egg_icon.position = Vector2(slot.size.x - 10, slot.size.y - 25)
			
			if itemName == "Chicken_Adult":
				slot.update_progress(BuildingDataManager.get_slot_progres_points(current_coop_pos, slot.slot_index) % requiredPointsToFirstUpgrade)
			else:
				slot.update_progress(BuildingDataManager.get_slot_progres_points(current_coop_pos, slot.slot_index))
			
			var currentPoints = BuildingDataManager.get_slot_progres_points(current_coop_pos,slot.slot_index)
			
			if currentPoints > requiredPointsToFirstUpgrade:
				if itemName == "Egg":
					BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, "Chicken_Baby", 1)
					slot.initialize_item("Chicken_Baby", 1)
					slot.update_progress(0)	
				if itemName == "Chicken_Baby":
					BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, "Chicken_Adult", 1)
					slot.initialize_item("Chicken_Adult", 1)
					#print("dorosle")
					slot.update_progress(0)	
				if itemName == "Chicken_Adult" and currentPoints % requiredPointsToFirstUpgrade == 0:
					print("jajo do zbioru")
					BuildingDataManager.add_item_to_collect(current_coop_pos,slot.slot_index,"Egg",1)
					slot.update_progress(0)	
				if currentPoints > progresPointsToDie:
					BuildingDataManager.add_item_to_coop(current_coop_pos, slot.slot_index, "Chicken_Died", 1)
					slot.initialize_item("Chicken_Died", 1)
					slot.update_progress(0)	
				
			
			
			
			
			
			
			
			
			
			
