class_name WorldEventControler
extends Node

var events: Dictionary = {}
var items: Dictionary = {}
var active_event = null
var end_day = -1
var last_event_key: String = ""

func _ready():
	
	load_events()

	if TestGameTimeCycleManager:
		TestGameTimeCycleManager.time_tick_day.connect(_on_day_changed)

func _on_day_changed(day: int) -> void:

	if active_event != null and day >= end_day:
		stop_active_event()
		
	if active_event == null and day > 3:
		if randf() <= 1:
			trigger_random_event(day)
	
func load_events():
	var file = FileAccess.open("res://data/world_events.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	
	if json_data is Dictionary:
		events = json_data

func trigger_random_event(start_day: int):
	if events.is_empty():
		return
	
	var keys = events.keys()
	var random_key = keys.pick_random()
	
	if last_event_key == random_key:
		trigger_random_event(start_day)
		
	last_event_key = random_key
	
	active_event = events[random_key]
	end_day = start_day + active_event["day_duration"]

	GlobalSignals.request_notification.emit(active_event)
	apply_event_effects(active_event)
	
func apply_event_effects(current_event: Dictionary):
	var items_to_change = current_event["affected_items"]
	
	MarketManager.clear_modifiers()
	
	for item_name in items_to_change.keys():
		var multiplier = items_to_change[item_name]
		MarketManager.set_modifier(item_name, multiplier)
	
	get_tree().call_group("ShopPanel", "fetch_products_price")
	print("Event Aktywny: ", current_event["notification"])


func stop_active_event():

	active_event = null
	MarketManager.clear_modifiers()
	get_tree().call_group("ShopPanel", "fetch_products_price")
