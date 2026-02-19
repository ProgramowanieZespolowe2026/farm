class_name CollectableComponent
extends Area2D

@export var collectable_name: String

func _on_body_entered(body: Node2D) -> void:
	# need to change treeplayer to player when player is ready
	if body is TreePlayer:  
		print("collected")
		get_parent().queue_free()
