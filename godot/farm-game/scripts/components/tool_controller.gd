extends Node2D
class_name ToolController

const TILE_SIZE = 16
const dirt_scene = preload("uid://cnwapekbgonx0")

@onready var highlight: Sprite2D = $Highlight
@onready var player = get_parent() 

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
	#print(current_target_grid_pos)
	color_target_by_tool(current_tool)
	

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
		elif current_tool == DataTypes.Tools.Axe:
			use_Axe()
		elif current_tool == DataTypes.Tools.Watering:
			use_watering_can()
		elif current_tool == DataTypes.Tools.Fertilizer:
			use_fertilizer()
			
		#func wzor_funkcji_ktora_kopiujemy():
			#if world_objects.has(current_target_grid_pos):
			#var target_object = world_objects[current_target_grid_pos]
		
			#if is_instance_valid(target_object):
				#if target_object.has_method("nazwa_funkcji_z_sceny_przedmiotu"):
					#target_object.nazwa_funkcji_z_sceny_przedmiotu()

func use_hoe():
	if not WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var new_dirt = dirt_scene.instantiate()
		new_dirt.global_position = highlight.global_position 
		
		player.get_parent().add_child(new_dirt) 
		WorldObjects.objects[Vector2i(current_target_grid_pos)] = new_dirt

func use_shovel():
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var object_to_remove = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		
		if is_instance_valid(object_to_remove):
			object_to_remove.queue_free()
			
		WorldObjects.objects.erase(Vector2i(current_target_grid_pos))

func use_watering_can():
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var target_object = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		
		if is_instance_valid(target_object):
			if target_object.has_method("water"):
				target_object.water()

func use_fertilizer():
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var target_object = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		
		if is_instance_valid(target_object):
			if target_object.has_method("fertilize"):
				target_object.fertilize()
				
func use_Axe():
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var target_object = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		
		if is_instance_valid(target_object):
			if target_object.has_method("hit"):
				target_object.hit()
				
func color_target_by_tool(current_tool):
	var target_object
	highlight.modulate = Color(1, 1, 1, 0.5)
	
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		target_object = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		if current_tool == DataTypes.Tools.Hoe:
			highlight.modulate = Color(1, 0, 0, 0.5)
		elif current_tool == DataTypes.Tools.Shovel:
			highlight.modulate = Color(1, 0, 0, 0.5)
		elif current_tool == DataTypes.Tools.Axe and target_object.type == "Wood":
			highlight.modulate = Color(0.0, 0.557, 0.125, 0.502)
		elif current_tool == DataTypes.Tools.Watering and target_object.type == "Plant":
			highlight.modulate = Color(1, 0, 0, 0.5)
		elif current_tool == DataTypes.Tools.Fertilizer and target_object.type == "Soil":
			highlight.modulate = Color(1, 0, 0, 0.5)
