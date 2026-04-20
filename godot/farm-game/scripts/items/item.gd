extends Node2D

var item_name: String
var item_value: int

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP

func set_item(nm: String, qt: int) -> void:
	item_name = nm
	item_value = qt
	
	var tex: Texture2D = load("res://assets/items/Icons/" + item_name + ".png")
	texture_rect.texture = tex
	
	if tex != null:
		var tex_size = tex.get_size()
		
		if tex_size != Vector2(16, 16):
			var scale_x: float = 16.0 / tex_size.x
			var scale_y: float = 16.0 / tex_size.y
			texture_rect.scale = Vector2(scale_x, scale_y)
		else:
			texture_rect.scale = Vector2(1, 1)
	
	var stack_size: int = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		label.visible = false
	else:
		label.visible = true
		label.text = str(item_value)
	
func add_item_value(amount_to_add: int) -> void:
	item_value += amount_to_add
	label.text = str(item_value)
	
func decrease_item_value(amount_to_remove: int) -> void:
	item_value -= amount_to_remove
	label.text = str(item_value)
