extends Node2D

var item_name
var item_value

func _ready():
	pass

func set_item(nm, qt):
	item_name = nm
	item_value = qt
	$TextureRect.texture = load("res://assets/items/Icons/" + item_name + ".png")
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
		$Label.text = str(item_value)
	
	
func add_item_value(amount_to_add):
	item_value += amount_to_add
	$Label.text = str(item_value)
	
func decrease_item_value(amount_to_remove):
	item_value -= amount_to_remove
	$Label.text = str(item_value)
