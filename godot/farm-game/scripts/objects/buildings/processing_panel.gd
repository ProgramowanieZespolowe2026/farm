extends Node2D
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")
signal processing_panel_open(is_open: bool)

@onready var processing_panel: Node2D = $"."
@onready var crafting_grid_container: GridContainer = $CraftingGridContainer
@onready var slot_out: Panel = $Slot_out

@onready var recipes: Node2D = $Recipes
@onready var recipes_grid_container: GridContainer = $Recipes/RecipesGridContainer
@onready var slot_out_crafting: Panel = $Recipes/Slot_out_crafting
@onready var product_name: Label = $Recipes/ProductName

func _ready():
	#TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	for slot in crafting_grid_container.get_children():
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slot.slot_index = 0
		slot.slot_type = SlotClass.SlotType.PROCESSING
		
	slot_out.gui_input.connect(slot_gui_input.bind(slot_out))
	slot_out.slot_index = 0
	slot_out.slot_type = SlotClass.SlotType.PROCESSING
	slot_out.initialize_item("Egg",1)
		
	for slot in recipes_grid_container.get_children():
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slot.slot_index = 0
		slot.slot_type = SlotClass.SlotType.PROCESSING
		
	slot_out_crafting.gui_input.connect(slot_gui_input.bind(slot_out_crafting))
	slot_out_crafting.slot_index = 0
	slot_out_crafting.slot_type = SlotClass.SlotType.PROCESSING
	
	
#func _on_time_tick(day: int, hour: int, minute: int) -> void:
	#fetchData()

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
				
		
func left_click_empty_slot(slot: SlotClass):
	var holding_item = find_parent("GameScreen").holding_item
	if slot.get_parent() == crafting_grid_container and not slot == slot_out:
		InventoryManager.add_item_to_empty_slot(holding_item, slot)
		slot.putIntoSlot(holding_item)
		find_parent("GameScreen").holding_item = null

func left_click_not_holding(slot: SlotClass):
	if slot.get_parent() == crafting_grid_container or slot == slot_out:
		find_parent("GameScreen").holding_item = slot.item
		slot.pickFromSlot()
		InventoryManager.remove_item(slot)
		if find_parent("GameScreen").holding_item != null:
			find_parent("GameScreen").holding_item.global_position = get_viewport().get_mouse_position()

func left_click_different_item(event: InputEvent, slot: SlotClass):
	if slot.get_parent() == crafting_grid_container:
		InventoryManager.remove_item(slot)
		InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		find_parent("GameScreen").holding_item = temp_item

func left_click_same_item(slot: SlotClass):
	if slot.get_parent() == crafting_grid_container:
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

func open_panel(building_pos: Vector2i):
	#composer_data = BuildingDataManager.buildings_data[building_pos]
	#current_building_pos = building_pos
	#
	#building_name_text.text = str("Composer ",BuildingDataManager.get_building_type_id(building_pos))
	#
	#plant_slot.remove_item()
	#fertlizer_slot.remove_item()
	#fertilizer_progress_bar.value = 0
	#plants_progress_bar.value = 0
	setVisiblePanel(true)

func close_panel():
	setVisiblePanel(false)
			
func setVisiblePanel(is_open = null):
	if is_open == null:
		processing_panel.visible = !processing_panel.visible
	else:
		processing_panel.visible = is_open
	processing_panel_open.emit(processing_panel.visible)
