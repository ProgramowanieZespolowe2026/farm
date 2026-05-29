extends Control

var buildings_data = {}    # Dane z JSON
var building_keys = []     # ["Barn", "ChickenCoop"]
var current_index = 0

@onready var building_name = %BuildingName
@onready var building_icon = %BuildingIcon
@onready var slots_container = %SlotsContainer
@onready var build_button = %Build

const SlotClass = preload("res://scripts/ui/slot.gd")

var current_building_name

func _ready():
	GlobalSignals.building_constructed.connect(_on_building_constructed)
	load_buildings_json()
	building_keys = buildings_data.keys()
	hide()

func load_buildings_json():
	var file = FileAccess.open("res://data/buildings.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		buildings_data = JSON.parse_string(content)
		file.close()
	
func update_recipe_page():
	if building_keys.size() == 0:
		return
	current_building_name = building_keys[current_index]
	var data = buildings_data[current_building_name]
	
	building_name.text = buildings_data[current_building_name]["Description"]
	building_icon.texture = load(data["IconPath"])
	
	for child in slots_container.get_children():
		slots_container.remove_child(child)
		child.queue_free() 
	
	var requirements = data["Requirements"]
	var stored_items = data["CurrentStoredItems"]
	var i = 0 # Licznik slotów
	for item_name in requirements:
		var needed_amount = requirements[item_name]
		var current_amount = stored_items.get(item_name, 0)
		
		# Struktura: VBoxContainer -> Slot, Label
		var v_box = VBoxContainer.new()
		v_box.name = "SlotBox"
		v_box.alignment = BoxContainer.ALIGNMENT_CENTER # Środkowanie w pionie
		v_box.size_flags_vertical = Control.SIZE_EXPAND_FILL # Wypełnienie wolnego miejsca
		
		var new_slot = preload("res://scenes/ui/slot.tscn").instantiate()
		new_slot.name = "Slot" # Ważne dla get_node("Slot")
		new_slot.custom_minimum_size = Vector2(22, 22)
		
		var new_label = Label.new()
		new_label.name = "RequiredAmount"
		new_label.text = str(int(needed_amount))
		new_label.add_theme_font_size_override("font_size", 10)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		v_box.add_child(new_slot)
		v_box.add_child(new_label)
		slots_container.add_child(v_box)
		
		new_slot.slot_index = i
		i += 1
		new_slot.slot_type = SlotClass.SlotType.RECIPE
		new_slot.initialize_item(item_name, current_amount)
		new_slot.gui_input.connect(slot_gui_input.bind(new_slot))
		
	# Odśwież stan przycisku i kolorów po załadowaniu strony
	check_build_conditions()


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var holding_item = find_parent("GameScreen").holding_item
			
			if holding_item != null:
				# --- BLOKADA: Sprawdzamy czy przedmiot w ręce pasuje do tego slotu ---
				# Zakładamy, że w Recipe Book slot.item zawsze istnieje (nawet z ilością 0)
				if slot.item != null and holding_item.item_name != slot.item.item_name:
					print("Niewłaściwy surowiec dla tego slotu!")
					return # Przerywamy funkcję - nic się nie dzieje, przedmiot zostaje w ręce
				
				# Jeśli przeszło test nazwy lub slot jest pusty:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					# Tutaj trafi tylko jeśli holding_item.item_name == slot.item.item_name
					left_click_same_item(slot)
					AudioManager.play_put_in_slot()
					
			elif slot.item:
				left_click_not_holding(slot)
	
	# Po każdej interakcji sprawdzamy warunki budowy i zapisujemy stan "na żywo"
	save_current_slots_state()
	check_build_conditions()

func check_build_conditions():
	var all_met = true
	current_building_name = building_keys[current_index]
	var data = buildings_data[current_building_name]
	
	# Pobieramy wymagania i aktualnie przechowywane przedmioty z danych
	var requirements = data["Requirements"]
	var stored_items = data["CurrentStoredItems"]
	
	# Pobieramy listę nazw przedmiotów (kluczy), np. ["Log", "Wheat_Item"]
	var req_keys = requirements.keys()
	var v_boxes = slots_container.get_children()
	
	# Iterujemy po kluczach wymagań, co gwarantuje stałą kolejność
	for i in range(req_keys.size()):
		if i >= v_boxes.size(): break
		
		var item_name = req_keys[i]
		var v_box = v_boxes[i]
		var slot = v_box.get_node("Slot")
		var label = v_box.get_node("RequiredAmount")
		
		var required_amount = int(requirements[item_name])
		var current_amount = int(stored_items.get(item_name, 0))
		
		if current_amount >= required_amount:
			slot.modulate = Color(1, 1, 1, 1) # Jasny (spełnione)
			label.add_theme_color_override("font_color", Color.GREEN)
		else:
			slot.modulate = Color(1, 1, 1, 0.6) # Przyciemniony (brak)
			label.add_theme_color_override("font_color", Color.WHITE)
			all_met = false
			
	build_button.disabled = !all_met

func save_current_slots_state():
	
	if building_keys.size() == 0: return
	
	current_building_name = building_keys[current_index]
	var current_data = buildings_data[current_building_name]
	var requirements = current_data["Requirements"]
	
	# Resetujemy stan zapisu i wypełniamy go na nowo z tego, co jest w UI
	for item_name in requirements.keys():
		current_data["CurrentStoredItems"][item_name] = 0
		
	for v_box in slots_container.get_children():
		var slot = v_box.get_node("Slot")
		if slot.item:
			current_data["CurrentStoredItems"][slot.item.item_name] = slot.item.item_value
# --- OBSŁUGA STRON ---

func _on_button_prev_pressed() -> void:
	AudioManager.next_prev_sound.play()
	save_current_slots_state()
	current_index = (current_index - 1 + building_keys.size()) % building_keys.size()
	update_recipe_page()

func _on_button_next_pressed() -> void:
	AudioManager.next_prev_sound.play()
	save_current_slots_state()
	current_index = (current_index + 1) % building_keys.size()
	update_recipe_page()
	
func _on_build_button_pressed():
	AudioManager.play_building_ready()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		print(current_building_name)
		match current_building_name:
			"Barn":
				players[0].current_tool = DataTypes.Tools.BarnBuilding
			"ChickenCoop":
				players[0].current_tool = DataTypes.Tools.ChickenCoopBuilding
			"Composer":
				players[0].current_tool = DataTypes.Tools.ComposerBuilding
			"Processing":
				players[0].current_tool = DataTypes.Tools.ProcessingBuilding
			"Shop":
				players[0].current_tool = DataTypes.Tools.ShopBuilding
			_:
				players[0].current_tool = DataTypes.Tools.None
				print("Nieznany budynek: ", building_name)
			
func _on_building_constructed(bld_name: String):
	
	if !buildings_data.has(bld_name): 
		return
	
	var data = buildings_data[bld_name]
	var stored_items = data["CurrentStoredItems"]
	var requirements = data["Requirements"]

	for item_name in requirements.keys():
		var amount_needed = int(requirements[item_name])
		var current_amount = int(stored_items.get(item_name, 0))
		
		stored_items[item_name] = max(0, current_amount - amount_needed)

	update_recipe_page()

# --- LOGIKA KLIKANIA (Inwentarz) ---

func left_click_empty_slot(slot: SlotClass):
	var holding_item = find_parent("GameScreen").holding_item
	slot.putIntoSlot(holding_item)
	find_parent("GameScreen").holding_item = null


func left_click_different_item(event: InputEvent, slot: SlotClass):
	var holding_item = find_parent("GameScreen").holding_item
	var temp_item = slot.item
	
	slot.pickFromSlot() # Zabieramy to co było w slocie
	temp_item.global_position = event.global_position # Przesuwamy do myszki
	
	slot.putIntoSlot(holding_item) # Wkładamy to co trzymaliśmy
	find_parent("GameScreen").holding_item = temp_item # Teraz trzymamy to co było w slocie

func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_value
	var holding_item = find_parent("GameScreen").holding_item
	
	var amount_to_add = 0
	if able_to_add >= holding_item.item_value:
		amount_to_add = holding_item.item_value
		slot.item.add_item_value(amount_to_add)
		holding_item.queue_free()
		find_parent("GameScreen").holding_item = null
	else:
		amount_to_add = able_to_add
		slot.item.add_item_value(amount_to_add)
		holding_item.decrease_item_value(amount_to_add)
	var current_building = building_keys[current_index]
	buildings_data[current_building]["CurrentStoredItems"][slot.item.item_name] = slot.item.item_value
	
func left_click_not_holding(slot: SlotClass):

	if slot.item == null: return

	if slot.item.item_value <= 0:
		print("Slot jest pusty, nie możesz nic zabrać.")
		AudioManager.play_error()
		return
		
	var item_name = slot.item.item_name
	var current_building = building_keys[current_index]
	var game_screen = find_parent("GameScreen")
	game_screen.holding_item = slot.item
	slot.pickFromSlot()
	buildings_data[current_building]["CurrentStoredItems"][item_name] = 0

	update_recipe_page()


	
	
