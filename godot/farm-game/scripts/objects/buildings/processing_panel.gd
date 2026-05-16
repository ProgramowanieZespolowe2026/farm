extends Node2D
const SlotClass = preload("res://scripts/ui/slot.gd")
const ItemClass = preload("res://scripts/items/item.gd")
signal processing_panel_open(is_open: bool)

@onready var processing_panel: Node2D = $"."
@onready var crafting_grid_container: GridContainer = $CraftingGridContainer
@onready var slot_out: Panel = $Slot_out

@onready var recipes_container: Node2D = $RecipesContainer
@onready var recipes_grid_container: GridContainer = $RecipesContainer/RecipesGridContainer
@onready var slot_out_recipes: Panel = $RecipesContainer/Slot_out_crafting
@onready var product_name: Label = $RecipesContainer/ProductName

var recipes_current_page: int = 0

var recipes = [
	{
		"required":["Apple_Item","Carrot_Item",null,null],
		"product":"Beet_Item"
	},
	{
		"required":["Carrot_Item","Apple_Item","Carrot_Item",null],
		"product":"Carrot_Item"
	}
]

func _ready():
	#TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	for slot in crafting_grid_container.get_children():
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slot.slot_index = 0
		slot.slot_type = SlotClass.SlotType.PROCESSING
		
	slot_out.gui_input.connect(slot_gui_input.bind(slot_out))
	slot_out.slot_index = 0
	slot_out.slot_type = SlotClass.SlotType.PROCESSING
		
	for slot in recipes_grid_container.get_children():
		slot.gui_input.connect(slot_gui_input.bind(slot))
		slot.slot_index = 0
		slot.slot_type = SlotClass.SlotType.PROCESSING
		
	slot_out_recipes.gui_input.connect(slot_gui_input.bind(slot_out_recipes))
	slot_out_recipes.slot_index = 0
	slot_out_recipes.slot_type = SlotClass.SlotType.PROCESSING
	
	
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
		slot.putIntoSlot(holding_item)
		find_parent("GameScreen").holding_item = null
		fetch_crafting_output()

func left_click_not_holding(slot: SlotClass):
	if slot.get_parent() == crafting_grid_container or slot == slot_out:
		if slot == slot_out:
			decrease_items_crafting(slot.item.item_value)
			
		find_parent("GameScreen").holding_item = slot.item
		slot.pickFromSlot()
		
		if find_parent("GameScreen").holding_item != null:
			find_parent("GameScreen").holding_item.global_position = get_viewport().get_mouse_position()
		
		#fetch_crafting_output()

func left_click_different_item(event: InputEvent, slot: SlotClass):
	if slot.get_parent() == crafting_grid_container:
		InventoryManager.remove_item(slot)
		InventoryManager.add_item_to_empty_slot(find_parent("GameScreen").holding_item, slot)
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		slot.putIntoSlot(find_parent("GameScreen").holding_item)
		find_parent("GameScreen").holding_item = temp_item
		fetch_crafting_output()

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
		fetch_crafting_output()

func open_panel(building_pos: Vector2i):
	recipes_current_page = 0
	setVisiblePanel(true)

func close_panel():
	var crafting_slots = crafting_grid_container.get_children()
	for slot in crafting_slots:
		if slot.item != null:
			InventoryManager.add_item(slot.item.item_name, slot.item.item_value)
			slot.remove_item()
	if slot_out != null:
		slot_out.remove_item()
	
	recipes_container.visible = false
	setVisiblePanel(false)
	
			
func setVisiblePanel(is_open = null):
	if is_open == null:
		processing_panel.visible = !processing_panel.visible
	else:
		processing_panel.visible = is_open
	processing_panel_open.emit(processing_panel.visible)

func fetch_crafting_output():
	var crafting_slots = crafting_grid_container.get_children()
	var finded:bool = false
	var item_count:int = 0
	
	for slot in crafting_slots:
		if slot.item != null:
			var slot_value = slot.item.item_value 
			if item_count == 0:
				item_count = slot_value
			elif item_count > slot_value:
					item_count = slot_value
			
			
	for i in range(recipes.size()):
		for index in range(crafting_slots.size()):
			var crafting_slot = crafting_slots[index]
			if crafting_slot.item != null:
				
				if recipes[i].required[index] == crafting_slot.item.item_name:
					finded = true
				else:
					finded = false
					break;
			else:
				if recipes[i].required[index] == crafting_slot.item:
					finded = true
				else:
					finded = false
					break;
		if finded:
			#print("Pasuje ", recipes[i].product)
			slot_out.initialize_item(recipes[i].product,item_count)
			return
		else:
			slot_out.remove_item()

func fetch_recipe_data():
	product_name.text = JsonData.item_data[recipes[recipes_current_page].product]["Description"]
	var slots = recipes_grid_container.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if recipes[recipes_current_page].required[i] != null:
			slot.initialize_item(recipes[recipes_current_page].required[i],1)
		
	
	slot_out_recipes.initialize_item(recipes[recipes_current_page].product, 1)

func decrease_items_crafting(item_value:int):
	var crafting_slots = crafting_grid_container.get_children()
	for slot in crafting_slots:
		if slot.item != null:
			slot.item.item_value = slot.item.item_value - item_value
			if slot.item.item_value == 0:
				slot.remove_item()
			else:
				slot.initialize_item(slot.item.item_name, slot.item.item_value)

func _on_recipes_button_pressed() -> void:
	if !recipes_container.visible:
		fetch_recipe_data()
	recipes_container.visible = !recipes_container.visible

func _on_previous_product_pressed() -> void:
	if recipes_current_page != 0:
		recipes_current_page -= 1
		fetch_recipe_data()
	
func _on_next_product_pressed() -> void:
	if recipes_current_page != recipes.size()-1:
		recipes_current_page += 1
		fetch_recipe_data()
