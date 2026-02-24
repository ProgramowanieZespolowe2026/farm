extends Node2D
var dirt_underneath: Node2D = null
var growthPoints: int = 0
var maxGrowthPoints: int = 1880 #2dni
var current_total_minutes: int = 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var tomato_item: Sprite2D = $"."

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)


func _on_time_tick(day: int, hour: int, minute: int) -> void:
	eraseGrowthPoints()
	changeSprite()

func eraseGrowthPoints():
	if dirt_underneath.is_watered and dirt_underneath.is_fertilized:
		growthPoints += 5
	elif dirt_underneath.is_watered:
		growthPoints += 2
	elif dirt_underneath.is_fertilized:
		growthPoints += 2
	else:
		growthPoints += 1
		
		
func changeSprite():
	#if growthPoints > (maxGrowthPoints *3):
		#animated_sprite_2d.play("tomato_ready_to_collect")
	if growthPoints > maxGrowthPoints:
		animated_sprite_2d.play("tomato_ready_to_collect")
	elif growthPoints > (maxGrowthPoints/2):
		animated_sprite_2d.play("tomato_in_growth")

func harvest():
	if growthPoints > maxGrowthPoints:
		#collectable
		print("Collected from tomato gd")
		animated_sprite_2d.play("tomato_in_growth")
		growthPoints = maxGrowthPoints/2
		
		#var tomato_item_scene_instance = tomato_item.instantiate() as Sprite2D
		#tomato_item_scene_instance.global_position = global_position
		#get_parent().add_child(tomato_item)
