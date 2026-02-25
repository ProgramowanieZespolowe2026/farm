extends Node

var item_data : Dictionary

func _ready():
	item_data = load_data("res://data/ItemData.json")
	
func load_data(file_path : String):
	var file_data = FileAccess.get_file_as_string(file_path)
	var json_data = JSON.parse_string(file_data)
	return json_data
