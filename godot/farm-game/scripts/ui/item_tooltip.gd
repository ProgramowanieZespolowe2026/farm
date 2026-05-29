extends Control

@onready var label: Label = $Panel/MarginContainer/Label

func set_text(text: String):
	label.text = text
