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
const peach_scene = preload("uid://cnndi0w44wqr6")
const cherry_scene = preload("uid://c02001sr6d7g7")
const apple_scene = preload("uid://cr71x7drir8lg")

const chicken_coop_scene = preload("uid://d23cpav84ureu")
const barn_scene = preload("uid://3jfpkgoxyfij")
const shop_scene = preload("uid://dp06kgowl326l")
const composer_scene = preload("uid://baxl2ua0yor8x")

const inventory = preload("uid://y3lcfv2dd6wt")


@onready var highlight: Sprite2D = $Highlight
@onready var chicken_coop_highlight: Sprite2D = $ChickenCoopHighlight
@onready var barn_highlight: Sprite2D = $BarnHighlight

@onready var player = get_parent() 
@onready var player_sfx_controller: PlayerSfxController = $"../PlayerSfxController"


var map_tiles = {}
var current_target_grid_pos = Vector2.ZERO

var inventory_visible = false;
var animal_building_panel_visible = false;
var shop_panel_visible = false
var recipe_book_visible = false
var is_building_placed: bool = false


func _ready():
	call_deferred("place_building_at", shop_scene, Vector2(16, 4), "Shop", Vector2i(4, 4))
	var game_screen = get_tree().get_first_node_in_group("GameScreen")
	var animal_building_panel = get_tree().get_first_node_in_group("AnimalBuildingPanel")
	var shop_panel = get_tree().get_first_node_in_group("ShopPanel")
	
	if game_screen:
		game_screen.inventory_open.connect(getInventoryVisible)
		animal_building_panel.animal_building_panel_open.connect(getAnimalBuildingPanelVisible)
		shop_panel.shop_panel_open.connect(getShopPanelVisible)
		game_screen.recipe_book_open.connect(getRecipeBookVisible)

func getInventoryVisible(is_open: bool):
	inventory_visible = is_open
func getAnimalBuildingPanelVisible(is_open: bool):
	animal_building_panel_visible = is_open
func getShopPanelVisible(is_open: bool):
	shop_panel_visible = is_open
func getRecipeBookVisible(is_open: bool):
	recipe_book_visible = is_open

func _process(_delta):
	update_highlight()
	update_highlight_color() # Nowa funkcja do kolo

func update_highlight():
	var current_tool = player.current_tool
	var facing_dir = player.last_facing_direction
	
	var height_offset = Vector2(0, -TILE_SIZE / 2.0)
	var player_grid_pos = ((player.global_position + height_offset) / TILE_SIZE).floor()
	
	var building_tiles = Vector2(1, 1)
	var is_building = false

	match current_tool:
		DataTypes.Tools.ChickenCoopBuilding:
			building_tiles = Vector2(3, 4)
			is_building = true
		DataTypes.Tools.BarnBuilding:
			building_tiles = Vector2(4, 5)
			is_building = true
		DataTypes.Tools.ShopBuilding:
			building_tiles = Vector2(4, 4)
			is_building = true
		DataTypes.Tools.ComposerBuilding:
			building_tiles = Vector2(2, 2)
			is_building = true
		_:
			is_building = false

	highlight.scale = building_tiles
	var building_pixel_size = building_tiles * TILE_SIZE

	if not is_building:
		current_target_grid_pos = player_grid_pos + facing_dir
		highlight.global_position = (current_target_grid_pos * TILE_SIZE) + (building_pixel_size / 2.0)
		return

	var offset_tiles = Vector2.ZERO
	
	if facing_dir == Vector2.RIGHT:
		offset_tiles = Vector2(1, -floor(building_tiles.y / 2.0))
	elif facing_dir == Vector2.LEFT:
		offset_tiles = Vector2(-building_tiles.x, -floor(building_tiles.y / 2.0))
	elif facing_dir == Vector2.DOWN:
		offset_tiles = Vector2(-floor(building_tiles.x / 2.0), 1)
	elif facing_dir == Vector2.UP:
		offset_tiles = Vector2(-floor(building_tiles.x / 2.0), -building_tiles.y)
	else:
		offset_tiles = Vector2(-floor(building_tiles.x / 2.0), 1)
		
	current_target_grid_pos = player_grid_pos + offset_tiles
	
	highlight.global_position = (current_target_grid_pos * TILE_SIZE) + (building_pixel_size / 2.0)

#   WAZNA ZMIANA ZMIENILEM  _input NA _unhandled_input. PODCZAS KLIKANIA NA PANELE I GUZIKI SYGNAL 
#   PRZECHODZIL DO GRY I GRACZ WYKONYWAL SWOJE FUNKCJE. JESLI COS NIE BEDZIE DZIALALO WARTO TO SPRAWDZIC
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not highlight.visible:
			return 
		
		if inventory_visible or animal_building_panel_visible or shop_panel_visible or recipe_book_visible:
			return
			
		if not is_plot_owned_at_target():
			return 
			
		var current_tool = player.current_tool
		#Tu dodajemy wywoływanie funkcji narzędzia ( ktora ma byc na dole )
		if current_tool == DataTypes.Tools.Hoe:
			collect_plant(DataTypes.Tools.Hoe)
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
			collect_plant(DataTypes.Tools.None)
			
		elif current_tool == DataTypes.Tools.Tomato_Seed:
			plant(tomato_scene)
		elif current_tool == DataTypes.Tools.Wheat_Seed:
			plant(wheat_scene)
		elif current_tool == DataTypes.Tools.Corn_Seed:
			plant(corn_scene)
		elif current_tool == DataTypes.Tools.Potato_Item:
			plant(potato_scene)
		elif current_tool == DataTypes.Tools.Carrot_Item:
			plant(carrot_scene)
		elif current_tool == DataTypes.Tools.Beet_Item:
			plant(beet_scene)
		elif current_tool == DataTypes.Tools.Peach_Plant:
			plant_tree(peach_scene)
		elif current_tool == DataTypes.Tools.Cherry_Plant:
			plant_tree(cherry_scene)
		elif current_tool == DataTypes.Tools.Apple_Plant:
			plant_tree(apple_scene)
			
		elif current_tool == DataTypes.Tools.ChickenCoopBuilding:
			place_building(chicken_coop_scene, "ChickenCoop", Vector2i(3, 4))
			if is_building_placed:
				GlobalSignals.building_constructed.emit("ChickenCoop")
				player.current_tool = DataTypes.Tools.None
		elif current_tool == DataTypes.Tools.BarnBuilding:
			place_building(barn_scene, "Barn", Vector2i(4, 5))
			if is_building_placed:
				GlobalSignals.building_constructed.emit("Barn")
				player.current_tool = DataTypes.Tools.None
		elif current_tool == DataTypes.Tools.ShopBuilding:
			place_building(shop_scene, "Shop", Vector2i(4, 4))
			if is_building_placed:
				GlobalSignals.building_constructed.emit("Shop")
				player.current_tool = DataTypes.Tools.None
		elif current_tool == DataTypes.Tools.ComposerBuilding:
			place_building(composer_scene, "Composer", Vector2i(2, 2))
			if is_building_placed:
				GlobalSignals.building_constructed.emit("Composer")
				player.current_tool = DataTypes.Tools.None
			
func use_hoe():
	#Jesli jest zaorana ziemia i jakas roslina to zniszcz sama rosline
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		
		if tile["crop"] != null and is_instance_valid(tile["crop"]):
			tile["crop"].queue_free() 
			tile["crop"] = null      
			return
	
	#Jesli pole jest puste stworz slownik
	if not map_tiles.has(current_target_grid_pos) and not WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		map_tiles[current_target_grid_pos] = {"dirt": null, "crop": null}
		
	#Jesli nie ma zaoranej ziemi to ja dodaj
	if not WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		if map_tiles[current_target_grid_pos]["dirt"] == null:
			var new_dirt = dirt_scene.instantiate()
			new_dirt.global_position = highlight.global_position 
			
			player.get_parent().add_child(new_dirt) 
			map_tiles[current_target_grid_pos]["dirt"] = new_dirt
		
		player_sfx_controller.play_hoe_sound()
	else:
		player_sfx_controller.play_error()
		
func use_shovel():
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		
		#Niszczenie rosliny
		if tile["crop"] != null and is_instance_valid(tile["crop"]):
			tile["crop"].queue_free()
			tile["crop"] = null
			player_sfx_controller.play_shovel_sound()
			return 
			
		#Niszczenie ziemi
		if tile["dirt"] != null and is_instance_valid(tile["dirt"]):
			tile["dirt"].queue_free()
			tile["dirt"] = null
			
		if tile["dirt"] == null and tile["crop"] == null:
			map_tiles.erase(current_target_grid_pos)
			
		player_sfx_controller.play_shovel_sound()
		
	elif WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
		var tree = WorldObjects.objects[Vector2i(current_target_grid_pos)]
		if tree.object_name == "Fruit_Tree":
			if tree.animation == "plant":
				tree.queue_free()
				WorldObjects.objects.erase(Vector2i(current_target_grid_pos))
				player_sfx_controller.play_shovel_sound()
		
func use_watering_can():
	if map_tiles.has(current_target_grid_pos):
		var target_object = map_tiles[current_target_grid_pos]["dirt"]
		
		if is_instance_valid(target_object):
			if target_object.has_method("water"):
				target_object.water()
				player_sfx_controller.play_water_plants_sound()
				
	else:
		if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
			var target_tree = WorldObjects.objects[Vector2i(current_target_grid_pos)]
			if target_tree.has_method("water"):
				target_tree.water()
				player_sfx_controller.play_water_plants_sound()
				
func use_fertilizer():
	if map_tiles.has(current_target_grid_pos):
		var target_object = map_tiles[current_target_grid_pos]["dirt"]
		
		if is_instance_valid(target_object):
			if target_object.has_method("fertilize"):
				target_object.fertilize()
				player_sfx_controller.play_fertilize_plants_sound()
				InventoryManager.decrease_item_value()
func use_axe():
	var target_grid_pos_i = Vector2i(current_target_grid_pos)
	
	if WorldObjects.objects.has(target_grid_pos_i):
		var target_object = WorldObjects.objects[target_grid_pos_i]
		
		if is_instance_valid(target_object) and target_object.has_method("hit"):
			target_object.hit(player_sfx_controller.chop_wood)
			#player_sfx_controller.chop_wood.play()
			return 

#AUTOMATYCZNIE DZIALA FUNKCJA ZBIERANIA OWOCOW Z ROSLIN
#!!!! ALE KAZDA TAKA ROSLINA MUSI MIEC FUNKCJE "harvest()"
func collect_plant(currentTool: DataTypes.Tools):
	if map_tiles.has(current_target_grid_pos):
		var target_crop = map_tiles[current_target_grid_pos]["crop"]
		if is_instance_valid(target_crop):
			#print(target_crop.plant_name)
			
			if (currentTool == DataTypes.Tools.None and target_crop.regrowing == true) or (currentTool == DataTypes.Tools.Hoe and target_crop.regrowing == false)  :
				if target_crop.has_method("harvest"):
					target_crop.harvest()
					player_sfx_controller.play_pick_up_item()
#	zbieranie owocow z drzew
	else:
		if WorldObjects.objects.has(Vector2i(current_target_grid_pos)):
			var target_tree = WorldObjects.objects[Vector2i(current_target_grid_pos)]
			if target_tree.has_method("harvest"):
				target_tree.harvest()


func plant(scene):
	if map_tiles.has(current_target_grid_pos):
		var tile = map_tiles[current_target_grid_pos]
		var target_object = tile["dirt"]
		
		if is_instance_valid(target_object) and target_object.is_in_group("dirt"):
			
			if tile["crop"] == null:
				InventoryManager.decrease_item_value()
				var new_plant = scene.instantiate()
				new_plant.global_position = highlight.global_position 
				
				new_plant.dirt_underneath = target_object
				
				player.get_parent().add_child(new_plant) 
				tile["crop"] = new_plant
				player_sfx_controller.play_plant_sound()
				
func plant_tree(scene):
	if WorldObjects.objects.has(Vector2i(current_target_grid_pos)) or map_tiles.has(current_target_grid_pos):
		return
	else:
		var new_tree = scene.instantiate()
		new_tree.global_position = highlight.global_position
		WorldObjects.objects[Vector2i(current_target_grid_pos)] = new_tree
		player.get_parent().add_child(new_tree) 
		player_sfx_controller.play_plant_sound()
		
func is_plot_owned_at_target() -> bool:
	var b_size = highlight.scale * TILE_SIZE
	var b_pos = current_target_grid_pos * TILE_SIZE
	var building_rect = Rect2(b_pos, b_size).grow(-0.1)
	
	var plots = get_tree().get_nodes_in_group("plots")
	
	var touches_any_plot = false
	
	for plot in plots:
		var plot_rect = Rect2(plot.global_position, Vector2(plot.plot_px, plot.plot_px))
		
		if plot_rect.intersects(building_rect):
			touches_any_plot = true # Budynek na czymś stoi
			
			if plot.current_owner != AuctionManager.OwnerType.PLAYER_TEAM:
				if plot.current_owner == AuctionManager.OwnerType.NONE:
					AuctionManager.select_plot(plot)
				elif plot.current_owner == AuctionManager.OwnerType.NPC:
					player_sfx_controller.play_error()
					plot.flash_border()
				
				return false
					
	return touches_any_plot
	
func place_building(scene, building_name: String = "Building", size_in_tiles: Vector2i = Vector2i(1, 1)):
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var check_pos = current_target_grid_pos + Vector2(x, y)
			var check_pos_i = Vector2i(check_pos)
			
			if WorldObjects.objects.has(check_pos_i) or map_tiles.has(check_pos):
				player_sfx_controller.play_error() 
				is_building_placed = false
				return

	is_building_placed = true
	var new_building = scene.instantiate()
	var grid_pos_i = Vector2i(current_target_grid_pos)
	
	if "object_name" in new_building:
		new_building.object_name = building_name
		
	var pixel_pos = current_target_grid_pos * TILE_SIZE
	
	var size_in_pixels = Vector2(size_in_tiles) * TILE_SIZE
	new_building.global_position = pixel_pos + (size_in_pixels / 2.0)
	
	#if building_name == "ChickenCoop" or building_name == "Barn":
	BuildingDataManager.add_new_building(grid_pos_i, building_name)

	if "grid_position" in new_building:
		new_building.grid_position = grid_pos_i

	player.get_parent().add_child(new_building)
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var tile_pos_i = Vector2i(current_target_grid_pos + Vector2(x, y))
			WorldObjects.objects[tile_pos_i] = new_building
	
	if player_sfx_controller.has_method("play_build_sound"):
		player_sfx_controller.play_build_sound()
	else:
		player_sfx_controller.play_plant_sound()

func place_building_at(scene, target_grid_pos: Vector2, building_name: String = "Building", size_in_tiles: Vector2i = Vector2i(1, 1)):
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var check_pos = target_grid_pos + Vector2(x, y)
			var check_pos_i = Vector2i(check_pos)
			
			if WorldObjects.objects.has(check_pos_i) or map_tiles.has(check_pos):
				player_sfx_controller.play_error() 
				return

	var new_building = scene.instantiate()
	var grid_pos_i = Vector2i(target_grid_pos)
	
	if "object_name" in new_building:
		new_building.object_name = building_name
		
	var pixel_pos = target_grid_pos * TILE_SIZE
	
	var size_in_pixels = Vector2(size_in_tiles) * TILE_SIZE
	new_building.global_position = pixel_pos + (size_in_pixels / 2.0)
	
	BuildingDataManager.add_new_building(grid_pos_i, building_name)

	if "grid_position" in new_building:
		new_building.grid_position = grid_pos_i

	player.get_parent().add_child(new_building)
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var tile_pos_i = Vector2i(target_grid_pos + Vector2(x, y))
			WorldObjects.objects[tile_pos_i] = new_building

func update_highlight_color():
	var current_tool = player.current_tool
	var is_building = current_tool in [
		DataTypes.Tools.ChickenCoopBuilding, 
		DataTypes.Tools.BarnBuilding, 
		DataTypes.Tools.ShopBuilding, 
		DataTypes.Tools.ComposerBuilding
	]
	
	if not is_building:
		highlight.modulate = Color.WHITE
		return

	# Sprawdzamy, czy miejsce jest poprawne
	if can_place_building_at_current_pos():
		highlight.modulate = Color.WHITE
	else:
		highlight.modulate = Color.RED

# Pomocnicza funkcja testująca, czy można budować (bez wywoływania licytacji!)
func can_place_building_at_current_pos() -> bool:
	var b_size = highlight.scale * TILE_SIZE
	var b_pos = current_target_grid_pos * TILE_SIZE
	var building_rect = Rect2(b_pos, b_size).grow(-0.1)
	#
	# 1. TEST DZIAŁEK (Tylko własne!)
	var plots = get_tree().get_nodes_in_group("plots")
	var on_valid_plot = false
	
	for plot in plots:
		var plot_rect = Rect2(plot.global_position, Vector2(plot.plot_px, plot.plot_px))
		if plot_rect.intersects(building_rect):
			# Jeśli dotknie jakiejkolwiek działki, która NIE jest gracza -> RED
			if plot.current_owner != AuctionManager.OwnerType.PLAYER_TEAM:
				return false
			on_valid_plot = true
	
	if not on_valid_plot: return false

	# 2. TEST OBIEKTÓW (Drzewa, kamienie, inne budynki)
	# Sprawdzamy każdy kafel, który zajmie budynek
	var tiles_x = int(highlight.scale.x)
	var tiles_y = int(highlight.scale.y)
	
	for x in range(tiles_x):
		for y in range(tiles_y):
			var check_pos = Vector2i(current_target_grid_pos) + Vector2i(x, y)
			if WorldObjects.objects.has(check_pos) or map_tiles.has(Vector2(check_pos)):
				return false # Coś stoi na drodze -> RED
				
	return true
