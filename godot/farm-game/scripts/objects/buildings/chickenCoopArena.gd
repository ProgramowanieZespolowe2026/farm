class_name BuildingEntered
extends Area2D

@onready var menu_open: AudioStreamPlayer2D = $MenuOpen


signal playerInArea(is_open: bool)

func _ready():
	playerInArea.emit(false)

func _on_body_entered(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea.emit(true)

func _on_body_exited(body: Node2D) -> void:
	if body is TemporaryPlayer:
		playerInArea.emit(false)

		
		
		
		
		
		
		
		
		
