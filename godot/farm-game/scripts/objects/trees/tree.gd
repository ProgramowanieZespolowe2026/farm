extends Sprite2D

@export var object_name: String
@export var item_scene: PackedScene
@export var health: int

var grid_pos: Vector2i
const TILE_SIZE = 16



func _ready() -> void:
	grid_pos = global_position / TILE_SIZE
	WorldObjects.objects[grid_pos] = self
	
func hit(chop_sound: AudioStreamPlayer2D):
	health -= 1
	chop_sound.play()
	# EFEKT WIZUALNY: Lekkie drżenie (Tween)
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 5.0, 0.05)
	tween.tween_property(self, "rotation_degrees", -5.0, 0.05)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.05)
	
	if health <= 0:
		die()

func die():
	WorldObjects.objects.erase(grid_pos)
	queue_free()
	call_deferred("load_item_scene")
	
func load_item_scene() -> void:
	var item_scene_instance = item_scene.instantiate() as Sprite2D
	item_scene_instance.global_position = global_position
	get_parent().add_child(item_scene_instance)
