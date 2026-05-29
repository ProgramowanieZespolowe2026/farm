extends Node

var tooltip: Control = null


func show(text: String, pos: Vector2):
	if tooltip == null:
		return
		
	if tooltip.has_method("set_text"):
		tooltip.set_text(text)
	else:
		tooltip.get_node("Panel/MarginContainer/Label").text = text

	tooltip.global_position = pos
	tooltip.visible = true


func hide():
	if tooltip:
		tooltip.visible = false
