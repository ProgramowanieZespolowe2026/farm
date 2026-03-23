extends Node2D

@export var plot_scene: PackedScene
@export var plot_size: int = 8
var tile_size: int = 16

# use bottom layer - base layer like grass if its under other layers
# based on this layer map is split into plots. !!! May changnge with new map !!!
@onready var tilemap_grass: TileMapLayer = $"../test-scene-tile-map/Grass"
@onready var player: TemporaryPlayer = $"../TemporaryPlayer"

func _ready():
	# we wait until every node is loaded and than load plots
	call_deferred("generate_plots")
	
func generate_plots():
	# get bottom layer size. 
	var map_rect = tilemap_grass.get_used_rect()
	# create plot size in pixels
	var plot_px = tile_size * plot_size 
	
	# calculate global pixels
	var start_x = map_rect.position.x * tile_size
	var start_y = map_rect.position.y * tile_size
	var end_x = map_rect.end.x * tile_size
	var end_y = map_rect.end.y * tile_size

	# create container for plots - GeneratedPlots
	var plots_container = Node2D.new()
	plots_container.name = "GeneratedPlots"
	add_child(plots_container)
	
	## variable for checking PUBLIC plots
	# var building_tiles = tilemap_buildings.get_used_cells(0)
	
	# generate plots loop
	for x in range(start_x, end_x, plot_px):
		for y in range(start_y, end_y, plot_px):
			var new_plot = plot_scene.instantiate()
			# give plot its plot size in pixels
			new_plot.plot_px = plot_px
			plots_container.add_child(new_plot)
			# set plot position
			new_plot.global_position = Vector2(x, y)
			new_plot.plot_id = "plot_%d_%d" % [x/plot_px, y/plot_px]
			
			# create plot rectangle
			var plot_rect = Rect2(Vector2(x, y), Vector2(plot_px, plot_px))
			
			## logic to check if plot is PUBLIC  !!! TO DO when buildings will be ready
			#var is_public = false
			#for tile_pos in building_tiles:
				## change for global position
				#var tile_global_pos = tilemap_buildings.to_global(tilemap_buildings.map_to_local(tile_pos))
				#if plot_rect.has_point(tile_global_pos):
					#is_public = true
					## if at least one tile in plot rectangle is public building stop
					#break 
			
			# make player owner of plot he stands on
			if plot_rect.has_point(player.global_position):
				new_plot.set_ownership(new_plot.OwnerType.PLAYER_TEAM)
			# optional make some npc's own some random plots
			elif randf() < 0.15: 
				new_plot.set_ownership(new_plot.OwnerType.NPC)
			## optional make some plots public - not to use by players or npc's
			#elif is_public:
				#new_plot.set_ownership(new_plot.OwnerType.PUBLIC)
			# rest of the plots are ready to be bought on auction
			else:
				new_plot.set_ownership(new_plot.OwnerType.NONE)
