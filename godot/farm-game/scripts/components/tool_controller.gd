extends Node2D
class_name ToolController

const TILE_SIZE = 16
const dirt_scene = preload("uid://cnwapekbgonx0")

@onready var highlight: Sprite2D = $Highlight
@onready var player = get_parent() 

var world_objects = {}
var current_target_grid_pos = Vector2.ZERO

func _process(_delta):
	update_highlight()

func update_highlight():
	var current_tool = player.current_tool
	
	if current_tool in [DataTypes.Tools.Hoe, DataTypes.Tools.Shovel, DataTypes.Tools.Axe, DataTypes.Tools.Watering]:
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
		if current_tool == DataTypes.Tools.Hoe:
			use_hoe()
		elif current_tool == DataTypes.Tools.Shovel:
			use_shovel()
		elif current_tool == DataTypes.Tools.Watering:
			use_watering_can()

func use_hoe():
	if not world_objects.has(current_target_grid_pos):
		var new_dirt = dirt_scene.instantiate()
		new_dirt.global_position = highlight.global_position 
		
		player.get_parent().add_child(new_dirt) 
		world_objects[current_target_grid_pos] = new_dirt

func use_shovel():
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
