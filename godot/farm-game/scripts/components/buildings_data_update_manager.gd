extends Node

var buildings_data = BuildingDataManager.buildings_data


func _ready():
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	
func _on_time_tick(day: int, hour: int, minute: int) -> void:
	updateAnimalsGrowth();

func updateAnimalsGrowth():
	for grid_pos in buildings_data:
		var items_array = buildings_data[grid_pos]["items"]
		
		for slot_index in range(items_array.size()):
			var slot = items_array[slot_index]
			if slot != null:
				if BuildingDataManager.get_item_to_collect(grid_pos,slot_index) == null:
					#Nie ma itemu do zebrania
					
					BuildingDataManager.increase_progres_Points(grid_pos,slot_index)
					#print("slot ",slot_index, " ",BuildingDataManager.get_slot_progres_points(grid_pos,slot_index))
				#else:
					#print("jajo ", slot_index)
