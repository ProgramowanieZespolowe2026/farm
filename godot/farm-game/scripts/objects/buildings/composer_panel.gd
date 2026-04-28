extends Node
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")

@onready var composer_panel: Node2D = $"."
signal composer_panel_open(is_open: bool)
@onready var plant_slot: Panel = $PlantSlot
@onready var fertlizer_slot: Panel = $FertlizerSlot
@onready var fertilizer_progress_bar: TextureProgressBar = $FertilizerProgressBar
@onready var plants_progress_bar: TextureProgressBar = $PlantsProgressBar
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar


@onready var building_name_text: Label = $BuildingNameText

var current_building_pos: Vector2i
var composer_data = {} 
var progress =0
var plants_level =0
var availabilityPlants = [
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
var requiredProgressPointsToCollect = 100

func _ready():
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	plant_slot.gui_input.connect(slot_gui_input.bind(plant_slot))
	plant_slot.slot_index = 0
	plant_slot.slot_type = SlotClass.SlotType.COMPOSER
	
	fertlizer_slot.gui_input.connect(slot_gui_input.bind(fertlizer_slot))
	fertlizer_slot.slot_index = 1
	fertlizer_slot.slot_type = SlotClass.SlotType.COMPOSER
	
	fertilizer_progress_bar.max_value = requiredProgressPointsToCollect
	fertilizer_progress_bar.value = 0
	plants_progress_bar.max_value = requiredProgressPointsToCollect
	plants_progress_bar.value = 0
	
func _on_time_tick(day: int, hour: int, minute: int) -> void:
	fetchData()

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("GameScreen").holding_item != null:
				if !slot.item:
					left_click_empty_slot(slot)
			elif slot.item:
				left_click_not_holding(slot)
				
		
func left_click_empty_slot(slot: SlotClass):
	if slot.name == "PlantSlot":
		var holding_item = find_parent("GameScreen").holding_item
		if holding_item.item_name in availabilityPlants:
			InventoryManager.add_item_to_empty_slot(holding_item, slot)
			slot.putIntoSlot(holding_item)
			find_parent("GameScreen").holding_item = null
			add_plant()

func left_click_not_holding(slot: SlotClass):
	find_parent("GameScreen").holding_item = slot.item
	slot.pickFromSlot()
	InventoryManager.remove_item(slot)
	if find_parent("GameScreen").holding_item != null:
		find_parent("GameScreen").holding_item.global_position = get_viewport().get_mouse_position()
	if slot.name == "FertlizerSlot":
		BuildingDataManager.reduce_item_to_collect(current_building_pos)

func open_panel(building_pos: Vector2i):
	composer_data = BuildingDataManager.buildings_data[building_pos]
	current_building_pos = building_pos
	
	building_name_text.text = str("Composer ",BuildingDataManager.get_building_type_id(building_pos))
	
	plant_slot.remove_item()
	fertlizer_slot.remove_item()
	fertilizer_progress_bar.value = 0
	plants_progress_bar.value = 0
	setVisiblePanel(true)

func close_panel():
	setVisiblePanel(false)
			
func setVisiblePanel(is_open = null):
	if is_open == null:
		composer_panel.visible = !composer_panel.visible
	else:
		composer_panel.visible = is_open
	composer_panel_open.emit(composer_panel.visible)

func fetchData():
		
	progress = BuildingDataManager.get_progres_points(current_building_pos)
	plants_level = BuildingDataManager.get_plants_level(current_building_pos)
	if plants_level:
		plants_progress_bar.value = plants_level
	if progress:
		if progress >= requiredProgressPointsToCollect:
			BuildingDataManager.add_item_to_collect(current_building_pos,"Fertilizer", 1)
			fertilizer_progress_bar.value = 0
		else:
			fertilizer_progress_bar.value = progress
		
		
	var item_to_collect = BuildingDataManager.get_item_to_collect(current_building_pos)
	if item_to_collect:
		fertlizer_slot.initialize_item(item_to_collect.name,item_to_collect.value)
	else:
		if fertlizer_slot.item != null:
			fertlizer_slot.remove_item()
	

func add_plant():
	if plant_slot:
		BuildingDataManager.increase_plants_level(current_building_pos, plant_slot.item.item_value*25)
		plant_slot.remove_item()
