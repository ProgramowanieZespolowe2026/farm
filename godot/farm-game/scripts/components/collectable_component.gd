class_name CollectableComponent
extends Area2D

@export var collectable_name: String
# export for testing
# var collectable_name: String = get

func _on_body_entered(body: Node2D) -> void:
	# need to change treeplayer to player when player is ready !!!
	if body is TemporaryPlayer:  
		print("collected")
		InventoryManager.add_item(get_parent().item_name, get_parent().item_value)
		get_parent().queue_free()
