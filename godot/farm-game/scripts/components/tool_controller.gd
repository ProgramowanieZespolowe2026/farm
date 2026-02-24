extends Node2D
class_name ToolController

const TILE_SIZE = 16
const dirt_scene = preload("uid://cnwapekbgonx0")
const tomato_scene = preload("uid://cr7exlho4r0pg")

@onready var highlight: Sprite2D = $Highlight
@onready var player = get_parent() 

var map_tiles = {}
var current_target_grid_pos = Vector2.ZERO

func _process(_delta):
	update_highlight()

func update_highlight():
	#var current_tool = player.current_tool
	
	#if current_tool != DataTypes.Tools.None:
		#highlight.visible = true
	#else:
		#highlight.visible = false
		#return
	
	highlight.visible = true
	
	var facing_dir = player.last_facing_direction
	
	var height_offset = Vector2(0, -TILE_SIZE / 2.0)
	var player_grid_pos = ((player.global_position + height_offset) / TILE_SIZE).floor()
	
	current_target_grid_pos = player_grid_pos + facing_dir
	highlight.global_position = (current_target_grid_pos * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not highlight.visible:
			return 
			
		var current_tool = player.current_tool
		#Tu dodajemy wywoływanie funkcji ( ktora ma byc na samym dole )
		if current_tool == DataTypes.Tools.Hoe:
			use_hoe()
		elif current_tool == DataTypes.Tools.Shovel:
			use_shovel()
		elif current_tool == DataTypes.Tools.Watering:
			use_watering_can()
		elif current_tool == DataTypes.Tools.Fertilizer:
			use_fertilizer()
		elif current_tool == DataTypes.Tools.None:
			collect_plant()
		elif current_tool == DataTypes.Tools.Tomato_Seed:
			plant_tomato()
			
func use_hoe():
	#Jesli jest zaorana ziemia i jakas roslina to zniszcz sama rosline
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		
		if tile["crop"] != null and is_instance_valid(tile["crop"]):
			tile["crop"].queue_free() 
			tile["crop"] = null      
			return
	
	#Jesli pole jest puste stworz slownik
	if not map_tiles.has(current_target_grid_pos):
		map_tiles[current_target_grid_pos] = {"dirt": null, "crop": null}
		
	#Jesli nie ma zaoranej ziemi to ja dodaj
	if map_tiles[current_target_grid_pos]["dirt"] == null:
		var new_dirt = dirt_scene.instantiate()
		new_dirt.global_position = highlight.global_position 
		
		player.get_parent().add_child(new_dirt) 
		map_tiles[current_target_grid_pos]["dirt"] = new_dirt
		
func use_shovel():
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		
		if tile["crop"] != null and is_instance_valid(tile["crop"]):
			tile["crop"].queue_free()
			tile["crop"] = null
			return 
			
		if tile["dirt"] != null and is_instance_valid(tile["dirt"]):
			tile["dirt"].queue_free()
			tile["dirt"] = null
			
		if tile["dirt"] == null and tile["crop"] == null:
			map_tiles.erase(current_target_grid_pos)
		
func use_watering_can():
	if map_tiles.has(current_target_grid_pos):
		var target_object = map_tiles[current_target_grid_pos]["dirt"]
		
		if is_instance_valid(target_object):
			if target_object.has_method("water"):
				target_object.water()

func use_fertilizer():
	if map_tiles.has(current_target_grid_pos):
		var target_object = map_tiles[current_target_grid_pos]["dirt"]
		
		if is_instance_valid(target_object):
			if target_object.has_method("fertilize"):
				target_object.fertilize()
				

func collect_plant():
	if map_tiles.has(current_target_grid_pos):
		var target_crop = map_tiles[current_target_grid_pos]["crop"]
		if is_instance_valid(target_crop):
			
			if target_crop.has_method("harvest"):
				target_crop.harvest()

func plant_tomato():
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		var target_object = tile["dirt"]
		
		if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			
			if tile["crop"] == null:
				var new_tomato = tomato_scene.instantiate()
				new_tomato.global_position = highlight.global_position 
				
				new_tomato.dirt_underneath = target_object
				
				player.get_parent().add_child(new_tomato) 
				tile["crop"] = new_tomato
