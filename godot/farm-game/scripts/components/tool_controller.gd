extends Node2D
class_name ToolController

const TILE_SIZE = 16
const dirt_scene = preload("uid://cnwapekbgonx0")
const tomato_scene = preload("uid://cr7exlho4r0pg")

@onready var highlight: Sprite2D = $Highlight
@onready var player = get_parent() 

var world_objects = {}
var crop_objects = {}
var current_target_grid_pos = Vector2.ZERO

func _process(_delta):
	update_highlight()

func update_highlight():
	var current_tool = player.current_tool
	
	#Tu dodajemy nowe narzędzia
	if current_tool != DataTypes.Tools.None:
		highlight.visible = true
	else:
		highlight.visible = false
		return
		
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
		elif current_tool == DataTypes.Tools.Tomato:
			plant_tomato()
			
		#func wzor_funkcji_ktora_kopiujemy():
			#if world_objects.has(current_target_grid_pos):
			#var target_object = world_objects[current_target_grid_pos]
		
			#if is_instance_valid(target_object):
				#if target_object.has_method("nazwa_funkcji_z_sceny_przedmiotu"):
					#target_object.nazwa_funkcji_z_sceny_przedmiotu()

#Dodawanie nowych bloków do mapy
func use_hoe():
	if not world_objects.has(current_target_grid_pos):
		var new_dirt = dirt_scene.instantiate()
		new_dirt.global_position = highlight.global_position 
		
		player.get_parent().add_child(new_dirt) 
		world_objects[current_target_grid_pos] = new_dirt

func use_shovel():
	if crop_objects.has(current_target_grid_pos):
		var crop_to_remove = crop_objects[current_target_grid_pos]
		
		if is_instance_valid(crop_to_remove):
			crop_to_remove.queue_free()
			
		crop_objects.erase(current_target_grid_pos)
		
	if world_objects.has(current_target_grid_pos):
		var object_to_remove = world_objects[current_target_grid_pos]
		
		if is_instance_valid(object_to_remove):
			object_to_remove.queue_free()
			
		world_objects.erase(current_target_grid_pos)

func use_watering_can():
	if world_objects.has(current_target_grid_pos):
		var target_object = world_objects[current_target_grid_pos]
		
		if is_instance_valid(target_object):
			if target_object.has_method("water"):
				target_object.water()

func use_fertilizer():
	if world_objects.has(current_target_grid_pos):
		var target_object = world_objects[current_target_grid_pos]
		
		if is_instance_valid(target_object):
			if target_object.has_method("fertilize"):
				target_object.fertilize()
				
func plant_tomato():
	if world_objects.has(current_target_grid_pos):
		var target_object = world_objects[current_target_grid_pos]
		
		if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			
			if not crop_objects.has(current_target_grid_pos):
				
				var new_tomato = tomato_scene.instantiate()
				new_tomato.global_position = highlight.global_position 
				
				player.get_parent().add_child(new_tomato) 
			
				crop_objects[current_target_grid_pos] = new_tomato
