extends Node

var buildings_data = {}

func add_new_building(grid_pos: Vector2i, buildingName: String):
	var new_data = {}
	var new_items_array = []
	new_items_array.resize(20)
	var building_type_size =0
	
	if buildingName == "Shop":
		building_type_size = count_building_type(buildingName)
		new_data = {
			"id": buildings_data.size() + 1,
			"buildingTypeId": building_type_size +1,
			"name": buildingName,
		}
	elif buildingName == "Composer":
		building_type_size = count_building_type(buildingName)
		new_data = {
			"id": buildings_data.size() + 1,
			"buildingTypeId": building_type_size +1,
			"name": buildingName,
			"progressPoints": 0,
			"plantsLevel": 0,
			"to_collect": null
		}
	else:
		# dla kurnika i stodoły
		var to_collect_array = []
		to_collect_array.resize(20)
		building_type_size = count_building_type(buildingName)
		
		new_data = {
			"id": buildings_data.size() + 1,
			"buildingTypeId": building_type_size +1,
			"name": buildingName,
			"food_level": 0,
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

func add_item(grid_pos: Vector2i, slot_index: int, item_name: String, item_value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index] = {"name": item_name, "value": item_value, "progresPoints": 0,"collectedAmount": 0}
		buildings_data[grid_pos]["to_collect"][slot_index] = null
		
func add_value_to_item(grid_pos: Vector2i, slot_index: int, value: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index]["value"] += value




func increase_progres_Points(grid_pos: Vector2i, slot_index: int = -1):
	if buildings_data.has(grid_pos) and slot_index != -1:
		if buildings_data[grid_pos]["food_level"] > 0:
			buildings_data[grid_pos]["items"][slot_index].progresPoints = buildings_data[grid_pos]["items"][slot_index].progresPoints+1;
			buildings_data[grid_pos]["food_level"] = snapped(buildings_data[grid_pos]["food_level"]-0.1, 0.01)
	
	elif buildings_data.has(grid_pos) and slot_index == -1:
		#dla kompostownika
		if buildings_data[grid_pos]["plantsLevel"] > 0:
			buildings_data[grid_pos]["plantsLevel"] -=1
			buildings_data[grid_pos]["progressPoints"] += 1
	
		
func get_slot_progres_points(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos) and buildings_data[grid_pos]["items"][slot_index] != null:
		return buildings_data[grid_pos]["items"][slot_index].progresPoints
func get_progres_points(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["progressPoints"]


func increase_plants_level(grid_pos: Vector2i, value:int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["plantsLevel"] +=value
func decrease_plants_level(grid_pos: Vector2i, value:int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["plantsLevel"] -=value
func get_plants_level(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["plantsLevel"]

func increase_food_level(grid_pos: Vector2i, added_food: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["food_level"] = buildings_data[grid_pos]["food_level"] + added_food
func reduce_food_level(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["food_level"] = buildings_data[grid_pos]["food_level"] + -1
func get_food_level(grid_pos: Vector2i):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["food_level"]	
		
		

func add_item_to_collect(grid_pos: Vector2i, item_name: String, item_value: int, slot_index: int = -1):
	if buildings_data.has(grid_pos) and slot_index != -1:
		buildings_data[grid_pos]["to_collect"][slot_index] = ({"name": item_name, "value": item_value})
		buildings_data[grid_pos]["items"][slot_index].progresPoints = 0;
		
	elif buildings_data.has(grid_pos) and slot_index == -1:
		#dla kompostownika
		if buildings_data[grid_pos]["to_collect"]:
			buildings_data[grid_pos]["to_collect"]["value"] += item_value
		else:
			buildings_data[grid_pos]["to_collect"] = {"name": item_name, "value": item_value}
		buildings_data[grid_pos]["progressPoints"] =0
		
func reduce_item_to_collect(grid_pos: Vector2i, slot_index: int =-1):
	if buildings_data.has(grid_pos) and slot_index != -1:
		buildings_data[grid_pos]["to_collect"][slot_index] = null
		
	if buildings_data.has(grid_pos) and slot_index == -1:
		buildings_data[grid_pos]["to_collect"] = null
		
func get_item_to_collect(grid_pos: Vector2i, slot_index: int = -1):
	
	if buildings_data.has(grid_pos) and slot_index != -1:
		if buildings_data[grid_pos]["to_collect"][slot_index]:
			return buildings_data[grid_pos]["to_collect"][slot_index]
		
	elif buildings_data.has(grid_pos) and slot_index == -1:
		if buildings_data[grid_pos]["to_collect"]:
			return buildings_data[grid_pos]["to_collect"]



func increase_collected_amount_item(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		buildings_data[grid_pos]["items"][slot_index].collectedAmount = buildings_data[grid_pos]["items"][slot_index].collectedAmount +1
		
func get_collected_amount_item(grid_pos: Vector2i, slot_index: int):
	if buildings_data.has(grid_pos):
		return buildings_data[grid_pos]["items"][slot_index].collectedAmount


func count_building_type(building_name: String) -> int:
	var count: int = 0
	
	for building in buildings_data:
		if buildings_data[building]["name"] == building_name:
			count += 1
			
	return count
func get_building_type_id(grid_pos: Vector2i):
	return buildings_data[grid_pos]["buildingTypeId"]
	
# Przygotowuje dane do zapisu, zamieniając Vector2i na bezpieczny String "x,y"
func get_buildings_save_data() -> Dictionary:
	var save_dict = {}
	for grid_pos in buildings_data.keys():
		var pos_string = str(grid_pos.x) + "," + str(grid_pos.y)
		save_dict[pos_string] = buildings_data[grid_pos]
	return save_dict


func load_buildings_from_save(loaded_buildings: Dictionary):
	buildings_data.clear()
	
	for pos_string in loaded_buildings.keys():
		var coords = pos_string.split(",")
		if coords.size() == 2:
			var grid_pos = Vector2i(int(coords[0]), int(coords[1]))
			var b_data = loaded_buildings[pos_string]
			
			if b_data.has("id"):
				b_data["id"] = int(b_data["id"])
			if b_data.has("buildingTypeId"):
				b_data["buildingTypeId"] = int(b_data["buildingTypeId"])
				
			if b_data.has("progressPoints"):
				b_data["progressPoints"] = int(b_data["progressPoints"])
			if b_data.has("plantsLevel"):
				b_data["plantsLevel"] = int(b_data["plantsLevel"])
			if b_data.has("food_level"):
				b_data["food_level"] = float(b_data["food_level"])
			
			buildings_data[grid_pos] = b_data
			
	GlobalSignals.reconstruct_buildings_in_world.emit()
