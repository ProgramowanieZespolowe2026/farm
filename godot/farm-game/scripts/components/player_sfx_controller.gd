class_name PlayerSfxController
extends Node2D


@onready var walk_on_dirt: AudioStreamPlayer2D = $WalkOnDirt
@onready var walk_on_grass: AudioStreamPlayer2D = $WalkOnGrass
@onready var chop_wood: AudioStreamPlayer2D = $ChopWood
@onready var pick_up_item: AudioStreamPlayer2D = $PickUpItem

var map_layers = [] 

func _ready():
	var layer_container = owner.get_parent().get_node_or_null("test-scene-tile-map")
	
	if layer_container:
		var found_layers = []
		for child in layer_container.get_children():
			if child is TileMapLayer:
				found_layers.append(child)
		
		found_layers.reverse()
		map_layers = found_layers
		
func play_walk_audio():
	var layer = get_layer_type()
	
	if layer == "grass":
		if not walk_on_grass.playing:
			walk_on_grass.pitch_scale = randf_range(1.6, 2.0)
			walk_on_grass.play()
			walk_on_dirt.stop()
	elif layer == "dirt":
		if not walk_on_dirt.playing:
			walk_on_dirt.pitch_scale = randf_range(1.6, 2.0)
			walk_on_dirt.play()
			walk_on_grass.stop()
	else:
		walk_on_grass.stop()
		walk_on_dirt.stop()
		
func get_layer_type() -> String:
	if map_layers.is_empty():
		return "none"
		
	for layer in map_layers:
		var map_pos = layer.local_to_map(global_position)
		var data = layer.get_cell_tile_data(map_pos)
		
		if data:
			var sound = data.get_custom_data("walk_sound")
			if sound != "":
				return sound 
			   
	return "none"
	
func play_pick_up_item():
	pick_up_item.play()
