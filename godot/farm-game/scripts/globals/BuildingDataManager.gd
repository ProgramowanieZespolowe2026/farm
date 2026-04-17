extends Node

var buildings_data = {}

func add_new_coop(grid_pos: Vector2i):
	var new_items_array = []
	new_items_array.resize(20)
	var to_collect_array = []
	to_collect_array.resize(20)
	
	var new_data = {
		"id": buildings_data.size() + 1,
		"food_level": 0,
		"items": new_items_array,
		"food_slots": [null],
		"to_collect": to_collect_array
	}
	
	buildings_data[grid_pos] = new_data

func remove_item_from_coop(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index] = null

func add_item_to_coop(grid_pos: Vector2i, slot_index: int, item_name: String, item_value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index] = {"name": item_name, "value": item_value, "progresPoints": 0}
		buildings_data[grid_pos]["to_collect"][slot_index] = null
		
func add_value_to_coop_item(grid_pos: Vector2i, slot_index: int, value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index]["value"] += value

func update_progres_Points(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index].progresPoints = buildings_data[grid_pos]["items"][slot_index].progresPoints+1;

func get_slot_progres_points(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos) and buildings_data[grid_pos]["items"][slot_index] != null:
		return buildings_data[grid_pos]["items"][slot_index].progresPoints

func add_item_to_collect(grid_pos: Vector2i, slot_index: int, item_name: String, item_value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["to_collect"][slot_index] = ({"name": item_name, "value": item_value})
		
func increase_item_to_collect(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["to_collect"][slot_index] = null
		
func get_item_to_collect(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["to_collect"][slot_index]
