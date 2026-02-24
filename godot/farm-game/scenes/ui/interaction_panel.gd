extends PanelContainer

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

func setup(supported_interactions: Array):
	for button in h_box_container.get_children():
		if button is Button:
			if supported_interactions.has(button.name):
				button.show()
			else:
				button.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
