extends MarginContainer

@onready var label = $%NotificationLabel
@onready var button = %EventNotification

var tween: Tween
var current_event_data: Dictionary 

func _ready():
	self.visible = false
	self.modulate.a = 0
	GlobalSignals.request_notification.connect(display_event)
	GlobalSignals.event_ended.connect(_on_event_ended)
	button.pressed.connect(_on_button_pressed)

func display_event(event_data: Dictionary):
	current_event_data = event_data
	
	var notif_text = event_data.get("notification", "Nowe wydarzenie!")
	AudioManager.new_notification.play()
	if self.visible and self.modulate.a > 0.5:
		_quick_reset(notif_text)
	else:
		_show_new(notif_text)

func _show_new(message: String):
	label.text = message
	self.visible = true
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func _quick_reset(new_message: String):
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): label.text = new_message)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)

func _on_button_pressed():
	GlobalSignals.open_event_details.emit(current_event_data)
	AudioManager.next_prev_sound.play()
	
	
func _on_event_ended():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): self.visible = false)
	AudioManager.new_notification.play()
