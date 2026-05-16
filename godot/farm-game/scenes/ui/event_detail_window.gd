extends Control

@onready var title_label = %Title
@onready var event_image = %NewsImage
@onready var desc_label = %Description
@onready var close_button = %Close

func _ready():
	self.visible = false
	GlobalSignals.open_event_details.connect(_on_open_requested)
	close_button.pressed.connect(_on_close_pressed)

func _on_open_requested(event: Dictionary):
	title_label.text = event.get("name", "Breaking News!")
	var description = _generate_event_text(event)
	desc_label.text = description
	
	self.visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2).from(0.0)

func _on_close_pressed():
	self.visible = false
	
func _generate_event_text(event_data: Dictionary) -> String:
	
	var full_text = event_data.get("description", "") + "\n\n"
	var duration = event_data.get("day_duration", 0)
	
	full_text += "Event duration: %d days\n\n" % duration
	
	full_text += "Market Changes:\n"
	
	var changes = event_data.get("affected_items", {})
	if changes.is_empty():
		full_text += "No price changes."
	else:
		for item_key in changes.keys():
			var multiplier = changes[item_key]
			var percentage = (multiplier - 1.0) * 100
			
			var item_display_name = item_key.replace("_Item", "").replace("_", " ")
			
			var calculation = "+" if percentage >= 0 else ""
			
			full_text += "- %s: %s%.0f%%\n" % [item_display_name, calculation, percentage]
	
	return full_text
