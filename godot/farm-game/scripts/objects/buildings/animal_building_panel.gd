extends Node2D

const SlotClass = preload("res://scripts/ui/slot.gd")
@onready var animalBuildingItems: GridContainer = $GridContainer
@onready var food_slot: Panel = $Slot21
signal animal_building_panel_open(is_open: bool)

var current_animal_building_pos: Vector2i
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
var chickenCoopAnimals = [
  "Egg",
  "Chicken_Baby",
  "Chicken_Adult",
]
var barnAnimals = [
  "Cow_Baby",
  "Cow_Adult",
  "Pig_Baby",
  "Pig_Adult",
  "Sheep_Baby",
  "Sheep_Adult",
  "Sheep_Adult_HairCut"
]
const requiredPointsToFirstUpgrade:int = 10
const remaningCycleAnimal = 10 #po tylu zbiorach zwierze umiera

@onready var food_level_amount_text: Label = $FoodLevelAmountText
@onready var chicken_coop_panel: Node2D = $"."
@onready var building_name_text: Label = $BuildingNameText

var buildingName = "";


func _ready():
	animal_building_panel_open.emit(false)
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	
	var slots = animalBuildingItems.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slot.slot_index = i
		slot.slot_type = SlotClass.SlotType.CHICKENCOOP
		if slot.progress_bar:
			slot.progress_bar.max_value = requiredPointsToFirstUpgrade
	
	food_slot.gui_input.connect(slot_gui_input.bind(food_slot))
	food_slot.slot_index = 0
	food_slot.slot_type = SlotClass.SlotType.CHICKENCOOP_FOOD
	
func _on_time_tick(day: int, hour: int, minute: int) -> void:
	updateUI()
	
func initialize_slots():
	var slots = animalBuildingItems.get_children()
	
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
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			var animalName = slot.item.item_name
			
			if animalName == "Chicken_Adult":
				collect_product(slot)
				slot.remove_item()
				BuildingDataManager.remove_item(current_animal_building_pos, slot.slot_index)
				InventoryManager.add_item("Feather", 3)
				InventoryManager.add_item("Chicken_Meat", 1)
					
			if animalName == "Cow_Adult":
				collect_product(slot)
				slot.remove_item()
				BuildingDataManager.remove_item(current_animal_building_pos, slot.slot_index)
				InventoryManager.add_item("Cow_Meat", 3)
					
			if animalName == "Sheep_Adult" or animalName == "Sheep_Adult_HairCut":
				collect_product(slot)
				slot.remove_item()
				BuildingDataManager.remove_item(current_animal_building_pos, slot.slot_index)
				InventoryManager.add_item("Sheep_Meat", 3)
				
					
			if animalName == "Pig_Adult":
				slot.remove_item()
				BuildingDataManager.remove_item(current_animal_building_pos, slot.slot_index)
				InventoryManager.add_item("Pig_Meat", 3)
			
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
	if (buildingName == "ChickenCoop" and holding_item.item_name in chickenCoopAnimals) or (buildingName == "Barn" and holding_item.item_name in barnAnimals):
		if holding_item.item_value > 1:
			BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, holding_item.item_name, 1)
			
			slot.initialize_item(holding_item.item_name, 1)
			holding_item.decrease_item_value(1)
			
		else:
			
			BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, holding_item.item_name, holding_item.item_value)
			slot.putIntoSlot(holding_item)
			find_parent("GameScreen").holding_item = null

func left_click_different_item(event: InputEvent, slot: SlotClass):
	collect_product(slot)
	
	var holding_item = find_parent("GameScreen").holding_item
	if holding_item.item_value == 1:
	
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		
		BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, holding_item.item_name, holding_item.item_value)
		slot.putIntoSlot(holding_item)
		find_parent("GameScreen").holding_item = temp_item

func left_click_same_item(slot: SlotClass):
	pass

func left_click_not_holding(slot: SlotClass):
	
	var item_to_collect = BuildingDataManager.get_item_to_collect(current_animal_building_pos, slot.slot_index)
	if item_to_collect == null:
		var itemName = slot.item.item_name
		
		if itemName == "Chicken_Died" or itemName == "Cow_Died" or itemName == "Pig_Died" or itemName == "Sheep_Died":
			slot.remove_item()
		else:
			find_parent("GameScreen").holding_item = slot.item
			slot.pickFromSlot()
			
			if find_parent("GameScreen").holding_item != null:
				find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
				
		BuildingDataManager.remove_item(current_animal_building_pos, slot.slot_index)
		
	else:
		collect_product(slot)

func setVisiblePanel(is_open = null):
	if is_open == null:
		chicken_coop_panel.visible = !chicken_coop_panel.visible
	else:
		chicken_coop_panel.visible = is_open
	animal_building_panel_open.emit(chicken_coop_panel.visible)

func open_panel(coop_pos: Vector2i):
	current_animal_building_pos = coop_pos
	active_coop_data = BuildingDataManager.buildings_data[coop_pos]
	
	buildingName = BuildingDataManager.get_building_name(current_animal_building_pos)
	if(buildingName == "ChickenCoop"):
		building_name_text.text = str("Chicken Coop ",BuildingDataManager.get_building_type_id(coop_pos))
	else:
		building_name_text.text = str(buildingName," ",BuildingDataManager.get_building_type_id(coop_pos))
	
	foodLevel = active_coop_data["food_level"]
	food_level_amount_text.text = str(foodLevel)
	
	initialize_slots()
	setVisiblePanel(true)

func close_panel():
	setVisiblePanel(false)
	
	
	var slots = animalBuildingItems.get_children()
	for slot in slots:
		if slot.item != null:
			slot.remove_item()
			#slot.item.queue_free()
			#slot.item = null
	current_animal_building_pos = Vector2i.ZERO
	active_coop_data = {}

func add_food(item_value: int):
	AudioManager.put_in_slot.play()
	BuildingDataManager.increase_food_level(current_animal_building_pos,item_value*10)

func updateUI():
	food_level_amount_text.text = str(BuildingDataManager.get_food_level(current_animal_building_pos))
	
	var slots = animalBuildingItems.get_children()
	for i in range(slots.size()):
		var slot = slots[i];
		if slot.item != null:
			
			check_item_to_collect(slot)
			
			slot.update_progress(BuildingDataManager.get_slot_progres_points(current_animal_building_pos, slot.slot_index))
			
			update_animal_state(slot)
			
		else:
			slot.update_progress(0)	
			
func check_item_to_collect(slot: SlotClass):
	var item = BuildingDataManager.get_item_to_collect(current_animal_building_pos, slot.slot_index)
	
	
	if item != null:
		# Dodajemy jajko tylko jeśli go tam jeszcze nie ma
		if item.name == "Egg":
			slot.set_product_icon_texture("uid://cs1gdd8apg456")
			slot.change_visibility_product_icon(true)
		if item.name == "Milk":
			slot.set_product_icon_texture("uid://ccyaeiyyu6ju1")
			slot.change_visibility_product_icon(true)
		
func update_animal_state(slot: SlotClass):
	var currentPoints = BuildingDataManager.get_slot_progres_points(current_animal_building_pos,slot.slot_index)
	var itemName = slot.item.item_name
	
	if itemName == "Chicken_Died" or itemName == "Cow_Died" or itemName == "Pig_Died" or itemName == "Pig_Adult" or itemName == "Sheep_Died":
					slot.update_progress(0)	
					return
	if currentPoints > requiredPointsToFirstUpgrade:
				if itemName == "Egg":
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Chicken_Baby", 1)
					slot.initialize_item("Chicken_Baby", 1)
					slot.update_progress(0)	
				if itemName == "Chicken_Baby":
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Chicken_Adult", 1)
					slot.initialize_item("Chicken_Adult", 1)
					slot.update_progress(0)	
				if itemName == "Chicken_Adult":
					#print("jajo do zbioru")
					AudioManager.new_item.play()
					BuildingDataManager.add_item_to_collect(current_animal_building_pos,"Egg",1,slot.slot_index)
					slot.update_progress(0)	
					
				if itemName == "Cow_Baby":
					slot.initialize_item("Cow_Adult", 1)
					slot.update_progress(0)	
				if itemName == "Cow_Adult":
					#print("mleko do zbioru")
					AudioManager.new_item.play()
					BuildingDataManager.add_item_to_collect(current_animal_building_pos,"Milk",1,slot.slot_index)
					slot.update_progress(0)
					
				if itemName == "Pig_Baby":
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Pig_Adult", 1)
					slot.initialize_item("Pig_Adult", 1)
					slot.update_progress(0)	
				#if itemName == "Pig_Adult":
					#print("mleko do zbioru")
					#BuildingDataManager.add_item_to_collect(current_animal_building_pos,slot.slot_index,"Milk",1)
					#slot.update_progress(0)	
				if itemName == "Sheep_Baby":
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Sheep_Adult_HairCut", 1)
					slot.initialize_item("Sheep_Adult_HairCut", 1)
					slot.update_progress(0)	
				if itemName == "Sheep_Adult_HairCut":
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Sheep_Adult", 1)
					slot.initialize_item("Sheep_Adult", 1)
					BuildingDataManager.add_item_to_collect(current_animal_building_pos,"Wool",1,slot.slot_index)
					slot.update_progress(0)
					#slot.update_progress(0)	
				#if itemName == "Sheep_Adult":
					#print("mleko do zbioru")
					#BuildingDataManager.add_item_to_collect(current_animal_building_pos,slot.slot_index,"Wool",1)
					#slot.update_progress(0)
				
				if BuildingDataManager.get_collected_amount_item(current_animal_building_pos,slot.slot_index) >= remaningCycleAnimal:
					#zwierze umiera
					BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Chicken_Died", 1)
					slot.initialize_item("Chicken_Died", 1)
					slot.update_progress(0)	
			
func collect_product(slot:SlotClass):
	var item_to_collect = BuildingDataManager.get_item_to_collect(current_animal_building_pos, slot.slot_index)
	
	if not item_to_collect == null:
		AudioManager.pick_up_item.play()
		BuildingDataManager.reduce_item_to_collect(current_animal_building_pos, slot.slot_index)
		BuildingDataManager.increase_collected_amount_item(current_animal_building_pos, slot.slot_index)
	
		slot.change_visibility_product_icon(false)
			
		
		if item_to_collect.name == "Wool":
			BuildingDataManager.add_item(current_animal_building_pos, slot.slot_index, "Sheep_Adult_HairCut", 1)
			slot.initialize_item("Sheep_Adult_HairCut", 1)
			
		InventoryManager.add_item(item_to_collect.name, item_to_collect.value)
			
			
			
			
