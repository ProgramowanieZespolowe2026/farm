class_name DayNightCycleComponent
extends CanvasModulate

@export var initial_day: int =1:
	set(id):
		initial_day = id
		TestGameTimeCycleManager.initial_day = id
		TestGameTimeCycleManager.set_initial_time()
		
@export var initial_hour: int =12:
	set(ih):
		initial_hour = ih;
		TestGameTimeCycleManager.initital_hour = ih
		TestGameTimeCycleManager.set_initial_time()
		
@export var initial_minute: int = 30:
	set(im):
		initial_minute = im
		TestGameTimeCycleManager.initial_minute = im
		TestGameTimeCycleManager.set_initial_time()

@export var day_nigh_gradient_texture: GradientTexture1D

func _ready() -> void:
	TestGameTimeCycleManager.initial_day = initial_day
	TestGameTimeCycleManager.initial_hour = initial_hour
	TestGameTimeCycleManager.initial_minute = initial_minute
	TestGameTimeCycleManager.set_initial_time()
	
	TestGameTimeCycleManager.game_time.connect(on_game_time)
	
func on_game_time(time: float) -> void:
	var sample_value = 0.5*(sin(time - PI * 0.5) + 1.0)
	color = day_nigh_gradient_texture.gradient.sample(sample_value)
	
	
	
	
	
	
	
	
