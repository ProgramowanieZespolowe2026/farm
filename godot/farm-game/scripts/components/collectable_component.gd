class_name CollectableComponent
extends Area2D

@export var collectable_name: String
# export for testing

func _on_body_entered(body: Node2D) -> void:
	# need to change temporaryplayer to player when player is ready !!!
	if body is TemporaryPlayer:  
		#print("collected")
		if body.has_node("PlayerSfxController"):
			body.get_node("PlayerSfxController").play_pick_up_item()
		InventoryManager.add_item(get_parent().item_name, get_parent().item_value)
		get_parent().queue_free()
