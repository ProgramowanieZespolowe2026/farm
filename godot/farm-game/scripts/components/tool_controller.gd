extends Node2D
class_name ToolController

const TILE_SIZE = 16
const dirt_scene = preload("uid://cnwapekbgonx0")
const tomato_scene = preload("uid://cr7exlho4r0pg")
const wheat_scene = preload("uid://b618f3t6eq1vl")
const potato_scene = preload("uid://bboxssfxh5d70")
const corn_scene = preload("uid://dn8j0kg051qv0")
const carrot_scene = preload("uid://dqdme10exp2k8")
const beet_scene = preload("uid://dyka3kbunmshh")

@onready var highlight: Sprite2D = $Highlight
@onready var player = get_parent() 
@onready var player_sfx_controller: PlayerSfxController = $"../PlayerSfxController"

var map_tiles = {}
var current_target_grid_pos = Vector2.ZERO

func _process(_delta):
	update_highlight()

func update_highlight():
	
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
		#Tu dodajemy wywoływanie funkcji narzędzia ( ktora ma byc na dole )
		if current_tool == DataTypes.Tools.Hoe:
			use_hoe()
		elif current_tool == DataTypes.Tools.Shovel:
			use_shovel()
		elif current_tool == DataTypes.Tools.Watering:
			use_watering_can()
		elif current_tool == DataTypes.Tools.Fertilizer:
			use_fertilizer()
		elif current_tool == DataTypes.Tools.Axe:
			use_axe()
		elif current_tool == DataTypes.Tools.None:
			collect_plant()
			
		elif current_tool == DataTypes.Tools.Tomato_Seed:
			plant(tomato_scene)
		elif current_tool == DataTypes.Tools.Wheat_Seed:
			plant(wheat_scene)
		elif current_tool == DataTypes.Tools.Corn_Seed:
			plant(corn_scene)
		elif current_tool == DataTypes.Tools.Potato_Item:
			plant(potato_scene)
		elif current_tool == DataTypes.Tools.Carrot_Seed:
			plant(carrot_scene)
		elif current_tool == DataTypes.Tools.Beet_Seed:
			plant(beet_scene)
			
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
		
		#Niszczenie rosliny
		if tile["crop"] != null and is_instance_valid(tile["crop"]):
			tile["crop"].queue_free()
			tile["crop"] = null
			return 
			
		#Niszczenie ziemi
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
				
func use_axe():
	var target_grid_pos_i = Vector2i(current_target_grid_pos)
	
	if WorldObjects.objects.has(target_grid_pos_i):
		var target_object = WorldObjects.objects[target_grid_pos_i]
		
		if is_instance_valid(target_object) and target_object.has_method("hit"):
			target_object.hit()
			player_sfx_controller.chop_wood.play()
			return 

#AUTOMATYCZNIE DZIALA FUNKCJA ZBIERANIA OWOCOW Z ROSLIN
#!!!! ALE KAZDA TAKA ROSLINA MUSI MIEC FUNKCJE "harvest()"
func collect_plant():
	if map_tiles.has(current_target_grid_pos):
		var target_crop = map_tiles[current_target_grid_pos]["crop"]
		if is_instance_valid(target_crop):
			
			if target_crop.has_method("harvest"):
				target_crop.harvest()
			if not target_crop.regrowing:
				var tile = map_tiles[current_target_grid_pos]
				if tile["crop"] != null and is_instance_valid(tile["crop"]):
					tile["crop"].queue_free()
					tile["crop"] = null

#func plant_tomato():
	#if map_tiles.has(current_target_grid_pos):
		#var tile = map_tiles[current_target_grid_pos]
		#var target_object = tile["dirt"]
		#
		#if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			#
			#if tile["crop"] == null:
				#var new_tomato = tomato_scene.instantiate()
				#new_tomato.global_position = highlight.global_position 
				#
				#new_tomato.dirt_underneath = target_object
				#
				#player.get_parent().add_child(new_tomato) 
				#tile["crop"] = new_tomato
				
#func plant_wheat():
	#if map_tiles.has(current_target_grid_pos):
		#var tile = map_tiles[current_target_grid_pos]
		#var target_object = tile["dirt"]
		#
		#if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			#
			#if tile["crop"] == null:
				#var new_wheat = wheat_scene.instantiate()
				#new_wheat.global_position = highlight.global_position 
				#
				#new_wheat.dirt_underneath = target_object
				#
				#player.get_parent().add_child(new_wheat) 
				#tile["crop"] = new_wheat
#
#func plant_potato():
	#if map_tiles.has(current_target_grid_pos):
		#var tile = map_tiles[current_target_grid_pos]
		#var target_object = tile["dirt"]
		#
		#if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			#
			#if tile["crop"] == null:
				#var new_potato = potato_scene.instantiate()
				#new_potato.global_position = highlight.global_position 
				#
				#new_potato.dirt_underneath = target_object
				#
				#player.get_parent().add_child(new_potato) 
				#tile["crop"] = new_potato

func plant(scene):
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		var target_object = tile["dirt"]
		
		if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			
			if tile["crop"] == null:
				var new_plant = scene.instantiate()
				new_plant.global_position = highlight.global_position 
				
				new_plant.dirt_underneath = target_object
				
				player.get_parent().add_child(new_plant) 
				tile["crop"] = new_plant
