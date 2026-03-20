extends Node2D

@export var plot_scene: PackedScene
# this variable will allow us to change size of plots
@export var plot_size: int = 8
var tile_size: int = 16

# use bottom layer - grass, as its base layer and its biger than any other layer
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
	var plot_px = tile_size * plot_size # 256px
	
	# Przeliczamy współrzędne kafelkowe na piksele globalne
	# Uwzględniamy, że mapa może nie zaczynać się w punkcie (0,0)
	var start_x = map_rect.position.x * tile_size
	var start_y = map_rect.position.y * tile_size
	var end_x = map_rect.end.x * tile_size
	var end_y = map_rect.end.y * tile_size

	# create container for plots - GeneratedPlots
	var plots_container = Node2D.new()
	plots_container.name = "GeneratedPlots"
	add_child(plots_container)
	

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
			
			# we check if player is inside of the plot
			# when game starts player becomes owner of plot he stands in
			if plot_rect.has_point(player.global_position):
				new_plot.is_owned = true
			else:
				new_plot.is_owned = false
