extends Node

var buildings_data = {}

func add_new_building(grid_pos: Vector2i, buildingName: String):
	var new_data = {}
	var new_items_array = []
	new_items_array.resize(20)
		
	if buildingName == "Shop":
		new_data = {
			"id": buildings_data.size() + 1,
			"name": buildingName,
			"items": new_items_array,
			"sell_slots": [null],
		}
	else:
		# dla kurnika i stodoły
		var to_collect_array = []
		to_collect_array.resize(20)
		
		new_data = {
			"id": buildings_data.size() + 1,
			"name": buildingName,
			"food_level": 500,
			"items": new_items_array,
			"food_slots": [null],
			"to_collect": to_collect_array
		}
	
	buildings_data[grid_pos] = new_data

func get_building_name(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["name"]



func remove_item(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index] = null

func add_item(grid_pos: Vector2i, slot_index: int, item_name: String, item_value: int, item_price: int = 0):
	if buildings_data.has(grid_pos):
		if(buildings_data[grid_pos]["name"] == "Shop"):
			buildings_data[grid_pos]["items"][slot_index] = {"name": item_name, "value": item_value,"price": item_price}
		else:
			buildings_data[grid_pos]["items"][slot_index] = {"name": item_name, "value": item_value, "progresPoints": 0,"collectedAmount": 0}
			buildings_data[grid_pos]["to_collect"][slot_index] = null
		
func add_value_to_item(grid_pos: Vector2i, slot_index: int, value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index]["value"] += value




func increase_progres_Points(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		if buildings_data[grid_pos]["food_level"] > 0:
			buildings_data[grid_pos]["items"][slot_index].progresPoints = buildings_data[grid_pos]["items"][slot_index].progresPoints+1;
			buildings_data[grid_pos]["food_level"] = snapped(buildings_data[grid_pos]["food_level"]-0.1, 0.01)
			
func get_slot_progres_points(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos) and buildings_data[grid_pos]["items"][slot_index] != null:
		return buildings_data[grid_pos]["items"][slot_index].progresPoints



func increase_food_level(grid_pos: Vector2i, added_food: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["food_level"] = buildings_data[grid_pos]["food_level"] + added_food
func reduce_food_level(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["food_level"] = buildings_data[grid_pos]["food_level"] + -1
func get_food_level(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["food_level"]	
		
		

func add_item_to_collect(grid_pos: Vector2i, slot_index: int, item_name: String, item_value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["to_collect"][slot_index] = ({"name": item_name, "value": item_value})
		buildings_data[grid_pos]["items"][slot_index].progresPoints = 0;
		
func reduce_item_to_collect(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["to_collect"][slot_index] = null
		
func get_item_to_collect(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["to_collect"][slot_index]




func increase_collected_amount_item(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index].collectedAmount = buildings_data[grid_pos]["items"][slot_index].collectedAmount +1
		
func get_collected_amount_item(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["items"][slot_index].collectedAmount
