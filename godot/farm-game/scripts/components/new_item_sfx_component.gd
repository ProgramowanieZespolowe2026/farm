extends Node2D

@onready var new_item: AudioStreamPlayer2D = $NewItem


func _ready() -> void:
	new_item.play()
