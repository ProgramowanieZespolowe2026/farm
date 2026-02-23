extends CharacterBody2D

var is_watered: bool = false
var is_fertilized: bool = false
var watered_time = 1440
var fertilize_time = 1440
var current_total_minutes: int = 0
var dry_out_time_in_minutes: int = 0
var fertilize_out_time_in_minutes: int = 0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var waiting_for_first_tick: bool = false 
signal dirt_condition(is_watered: bool, is_fertilized: bool)

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	current_total_minutes = (day * 1440) + (hour * 60) + minute
	
	if waiting_for_first_tick:
		if is_watered:
			dry_out_time_in_minutes = current_total_minutes + watered_time
			
		if is_fertilized:
			fertilize_out_time_in_minutes = current_total_minutes + fertilize_time
			
		waiting_for_first_tick = false
		
	if is_watered and not waiting_for_first_tick:
		if current_total_minutes >= dry_out_time_in_minutes:
			dry_out()
	if is_fertilized and not waiting_for_first_tick:
		if current_total_minutes >= fertilize_out_time_in_minutes:
			fertilize_out()

func water() -> void:
	is_watered = true
	dirt_condition.emit(is_watered,is_fertilized)
	if is_fertilized:
		animated_sprite_2d.play("Wet_with_fertilize")
	else:
		animated_sprite_2d.play("Wet_without_fertilize")
	
	if current_total_minutes > 0:
		dry_out_time_in_minutes = current_total_minutes + watered_time
	else:
		waiting_for_first_tick = true
			
func dry_out() -> void:
	is_watered = false
	dirt_condition.emit(is_watered,is_fertilized)
	if is_fertilized:
		animated_sprite_2d.play("Dry_with_fertilize")
	else:
		animated_sprite_2d.play("Dry_without_fertilize")
		
func fertilize() -> void:
	is_fertilized = true
	dirt_condition.emit(is_watered,is_fertilized)
	if is_watered:
		animated_sprite_2d.play("Wet_with_fertilize")
	else:
		animated_sprite_2d.play("Dry_with_fertilize")
	
	if current_total_minutes > 0:
		fertilize_out_time_in_minutes = current_total_minutes + fertilize_time
	else:
		waiting_for_first_tick = true
		
func fertilize_out() -> void:
	is_fertilized = false
	dirt_condition.emit(is_watered,is_fertilized)
	if is_watered:
		animated_sprite_2d.play("Wet_without_fertilize")
	else:
		animated_sprite_2d.play("Dry_without_fertilize")
