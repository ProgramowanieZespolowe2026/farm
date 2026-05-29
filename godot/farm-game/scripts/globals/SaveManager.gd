extends Node

const SAVE_PATH = "user://savegame.json"

var pending_load_data = null

func _ready():
	if TestGameTimeCycleManager.has_signal("time_tick"):
		TestGameTimeCycleManager.time_tick.connect(_on_time_tick)

func _on_time_tick(day: int, hour: int, minute: int):
	if hour == 6 and minute == 0:
		print("[Autozapis]")
		save_game()

	
func save_game():
	var tool_controller = get_tree().get_first_node_in_group("tool_controller")
	var tiles_save_data = {}
	var trees_save_data = {}
	
	if tool_controller:
		tiles_save_data = tool_controller.get_tiles_save_data()
		trees_save_data = tool_controller.get_trees_save_data()

	var plots_save_data = {}
	var plots = get_tree().get_nodes_in_group("plots")
	for plot in plots:
		if "plot_id" in plot and "current_owner" in plot:
			plots_save_data[plot.plot_id] = plot.current_owner

	var save_data = {
		"inventory_items": InventoryManager.items,
		"inventory_hotbar": InventoryManager.hotbar,
		"wallet_balance": Wallet.balance,
		"time": TestGameTimeCycleManager.time,
		"owned_plots": plots_save_data,
		"buildings": BuildingDataManager.get_buildings_save_data(),
		"map_tiles": tiles_save_data,
		"fruit_trees": trees_save_data
		}
	

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Gra zapisana pomyślnie.")
	else:
		print("Błąd zapisu! Kod błędu: ", FileAccess.get_open_error())


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Brak pliku zapisu.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("Nie udało się otworzyć pliku do odczytu. Kod błędu: ", FileAccess.get_open_error())
		return false

	var content = file.get_as_text()
	file.close()

	var json = JSON.parse_string(content)
	
	if json == null or typeof(json) != TYPE_DICTIONARY:
		print("Błąd parsowania pliku zapisu lub plik jest uszkodzony.")
		return false

	pending_load_data = json
	return true

func load_and_switch_scene(scene_path: String):
	if not load_game():
		print("Błąd: Nie można załadować pliku zapisu.")
		return
		
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	apply_loaded_data()

func apply_loaded_data():
	if not pending_load_data:
		print("Brak danych do zaaplikowania.")
		return

	var data = pending_load_data

	if data.has("inventory_items"):
		InventoryManager.items = data["inventory_items"]
	
	if data.has("inventory_hotbar"):
		InventoryManager.hotbar = data["inventory_hotbar"]

	Wallet.balance = int(data.get("wallet_balance", 25000))

	if data.has("time"):
		var raw_time = data["time"]
		var parsed_time: float = float(raw_time) if typeof(raw_time) != TYPE_STRING else raw_time.to_float()
		TestGameTimeCycleManager.load_saved_time(parsed_time)
		
		TestGameTimeCycleManager.recalculate_time()
	if data.has("owned_plots"):
		_load_plots_ownership(data["owned_plots"])
		
	if data.has("map_tiles"):
		var tool_controller = get_tree().get_first_node_in_group("tool_controller")
		if tool_controller:
			tool_controller.reconstruct_tiles(data["map_tiles"])
		
	if data.has("buildings"):
		BuildingDataManager.load_buildings_from_save(data["buildings"])
		
	if data.has("fruit_trees"):
		var tool_controller = get_tree().get_first_node_in_group("tool_controller")
		if tool_controller:
			tool_controller.reconstruct_trees(data["fruit_trees"])

	pending_load_data = null

	InventoryManager.inventory_updated.emit()
	print("Stan gry został pomyślnie wczytany!")

func _load_plots_ownership(loaded_plots: Dictionary):
	var plots = get_tree().get_nodes_in_group("plots")
	
	for plot in plots:
		if "plot_id" in plot and loaded_plots.has(plot.plot_id):
			var raw_owner = loaded_plots[plot.plot_id]
			var owner_int: int = int(raw_owner)
			
			if plot.has_method("set_ownership"):
				plot.set_ownership(owner_int as AuctionManager.OwnerType)
			else:
				plot.current_owner = owner_int as AuctionManager.OwnerType

func _fix_json_keys(dict: Dictionary) -> Dictionary:
	var fixed_dict = {}
	for key in dict.keys():
		if str(key).is_valid_int():
			fixed_dict[int(str(key))] = dict[key]
		else:
			fixed_dict[key] = dict[key]
	return fixed_dict
