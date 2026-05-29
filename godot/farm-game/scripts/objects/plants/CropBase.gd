extends Node2D
class_name CropBase

var dirt_underneath: Node2D = null
var growth_points_to_collect: int = 1880
@export var plant_name: String = "Name"
@export var item_produce_amount: int = 1
@export var seed_produce_amount: int = 1
@export var item_scene: PackedScene
@export var seed_scene: PackedScene
@export var regrowing: bool = false


var growth_points: int = 0
@onready var growth_points_to_die: int = growth_points_to_collect * 4
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	add_growth_points()
	update_sprite()

func add_growth_points():
	if dirt_underneath.is_watered and dirt_underneath.is_fertilized:
		growth_points += 5
	elif dirt_underneath.is_watered or dirt_underneath.is_fertilized:
		growth_points += 2
	else:
		growth_points += 1
		
func update_sprite():
	if growth_points > growth_points_to_die:
		animated_sprite_2d.play("die")
	elif growth_points > growth_points_to_collect:
		animated_sprite_2d.play("ready_to_collect")
	elif growth_points > (growth_points_to_collect / 2):
		animated_sprite_2d.play("in_growth")

func harvest():
	if growth_points > growth_points_to_collect and not growth_points > growth_points_to_die:
		if regrowing:
			animated_sprite_2d.play("in_growth")
			growth_points = growth_points_to_collect / 2
			
		
		if item_scene:
			for i in range(item_produce_amount):
				spawn_item(item_scene)
		
		if seed_scene:
			for i in range(seed_produce_amount):
				spawn_item(seed_scene)

func spawn_item(scene_to_spawn: PackedScene):
	var item = scene_to_spawn.instantiate() as Node2D
	var offset = Vector2(
		randf_range(-20, 20), 
		randf_range(-20, 20)
	)
	item.global_position = global_position + offset
	get_parent().add_child(item)
