extends Sprite2D

var is_watered: bool = false
var current_total_minutes: int = 0
var dry_out_time_in_minutes: int = 0

var waiting_for_first_tick: bool = false 

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	current_total_minutes = (day * 1440) + (hour * 60) + minute
	
	if waiting_for_first_tick:
		dry_out_time_in_minutes = current_total_minutes + 1440
		waiting_for_first_tick = false
		
	if is_watered and not waiting_for_first_tick:
		if current_total_minutes >= dry_out_time_in_minutes:
			dry_out()

func water() -> void:
	if not is_watered:
		is_watered = true
		
		if current_total_minutes > 0:
			dry_out_time_in_minutes = current_total_minutes + 1440
		else:
			waiting_for_first_tick = true
			
		modulate = Color(0.6, 0.4, 0.2)

func dry_out() -> void:
	is_watered = false
	modulate = Color(1.0, 1.0, 1.0)
