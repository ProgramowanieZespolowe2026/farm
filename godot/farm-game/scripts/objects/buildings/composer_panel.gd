extends Node
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")

@onready var composer_panel: Node2D = $"."
signal composer_panel_open(is_open: bool)
@onready var plant_slot: Panel = $PlantSlot
@onready var fertlizer_slot: Panel = $FertlizerSlot
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var composer_data = {} 

func _ready():
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	plant_slot.gui_input.connect(slot_gui_input.bind(plant_slot))
	plant_slot.slot_index = 0
	plant_slot.slot_type = SlotClass.SlotType.COMPOSER
	
	fertlizer_slot.gui_input.connect(slot_gui_input.bind(fertlizer_slot))
	fertlizer_slot.slot_index = 1
	fertlizer_slot.slot_type = SlotClass.SlotType.COMPOSER
	
	texture_progress_bar.value =0
	
func _on_time_tick(day: int, hour: int, minute: int) -> void:
	fetchData()

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
				
#func _input(_event):
	#if find_parent("GameScreen").holding_item:
		#find_parent("GameScreen").holding_item.global_position = get_global_mouse_position()
		
func left_click_empty_slot(slot: SlotClass):
	print(find_parent("GameScreen").holding_item)
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
		find_parent("GameScreen").holding_item.global_position = get_viewport().get_mouse_position()

func open_panel(coop_pos: Vector2i):
	composer_data = BuildingDataManager.buildings_data[coop_pos]
	print(composer_data)
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
	print()
