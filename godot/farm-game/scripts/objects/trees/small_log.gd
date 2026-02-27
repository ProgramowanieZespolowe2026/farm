extends Sprite2D


@export var item_name: String = "Wood"
@export var item_value: int = 1
@onready var new_item: AudioStreamPlayer2D = $NewItem

func _ready() -> void:
	new_item.play()
