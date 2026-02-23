extends CharacterBody2D

var watered_multiplier: int = 1
var fertilize_multiplier: int = 1
var growthPoints: int = 0


#var watered_time = 1440
#var fertilize_time = 1440
var current_total_minutes: int = 0
#var dry_out_time_in_minutes: int = 0
#var fertilize_out_time_in_minutes: int = 0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var waiting_for_first_tick: bool = false 

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	
	
	

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	var dirt = get_parent()
	#if dirt.has_signal("dirt_condition"):
		#dirt.dirt_condition.connect(eraseGrowthPoints)
	if dirt.is_watered:
		growthPoints= growthPoints+2
		print(growthPoints)
	current_total_minutes = (day * 1440) + (hour * 60) + minute
	#
	#if waiting_for_first_tick:
		#if is_watered:
			#dry_out_time_in_minutes = current_total_minutes + watered_time
			#
		#if is_fertilized:
			#fertilize_out_time_in_minutes = current_total_minutes + fertilize_time
			#
		#waiting_for_first_tick = false
		#
	#if is_watered and not waiting_for_first_tick:
		#if current_total_minutes >= dry_out_time_in_minutes:
			#dry_out()
	#if is_fertilized and not waiting_for_first_tick:
		#if current_total_minutes >= fertilize_out_time_in_minutes:
			#fertilize_out()

func eraseGrowthPoints(is_watered: bool, is_fertilized: bool):
	if is_watered:
		growthPoints= growthPoints+2
	if is_fertilized:
		growthPoints= growthPoints+2
	if !is_watered && !is_fertilized:
		growthPoints= growthPoints+1
		
	print(growthPoints)
		
	
