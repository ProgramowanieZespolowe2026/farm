extends Node

const SAVE_PATH = "user://savegame.json"

var pending_load_data = null


func save_game():
	var save_data = {
		"inventory_items": InventoryManager.items,
		"inventory_hotbar": InventoryManager.hotbar,
		"wallet_balance": Wallet.balance,
		#"time": TestGameTimeCycleManager.time
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Gra zapisana")
	else:
		print("Błąd zapisu")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Brak save")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return false

	var content = file.get_as_text()
	file.close()

	var json = JSON.parse_string(content)

	if json == null:
		return false

	pending_load_data = json

	return true


func apply_loaded_data():
	var data = pending_load_data

	InventoryManager.items = data.get("inventory_items", {})
	InventoryManager.hotbar = data.get("inventory_hotbar", {})

	Wallet.balance = data.get("wallet_balance", 25000)


	#TestGameTimeCycleManager.time = data.get("time", 0.0)
	#TestGameTimeCycleManager.recalulate_time()

	pending_load_data = null

	InventoryManager.inventory_updated.emit()
	print("Gra wczytana")
