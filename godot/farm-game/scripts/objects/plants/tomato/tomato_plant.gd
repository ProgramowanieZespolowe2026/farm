extends Node2D
var dirt_underneath: Node2D = null
var growthPoints: int = 0
var growthPointsToCollect: int = 1880 #2dni
var growthPointsToDie: int = growthPointsToCollect*4
var current_total_minutes: int = 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const TOMATO_ITEM = preload("uid://dlwbmb4le8lh5")
const TOMATO_SEED = preload("uid://pn2ndodk5yht")

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
	if growthPoints > growthPointsToDie:
		animated_sprite_2d.play("tomato_die")
	elif growthPoints > growthPointsToCollect:
		animated_sprite_2d.play("tomato_ready_to_collect")
	elif growthPoints > (growthPointsToCollect/2):
		animated_sprite_2d.play("tomato_in_growth")

func harvest():
	if growthPoints > growthPointsToCollect and not growthPoints > growthPointsToDie:
		animated_sprite_2d.play("tomato_in_growth")
		growthPoints = growthPointsToCollect/2
		
		# Dodawanie owocu do sceny
		for i in range(2):
			var tomato = TOMATO_ITEM.instantiate() as Sprite2D
			var offset = Vector2(
				randf_range(-20, 20), 
				randf_range(-20, 20)
			)
			tomato.global_position = global_position + offset
			get_parent().add_child(tomato)
			
		# Dodawanie nasion do sceny
		var tomato_seed = TOMATO_SEED.instantiate() as Sprite2D
		var offset = Vector2(
			randf_range(-20, 20), 
			randf_range(-20, 20)
		)
		tomato_seed.global_position = global_position + offset
		get_parent().add_child(tomato_seed)
