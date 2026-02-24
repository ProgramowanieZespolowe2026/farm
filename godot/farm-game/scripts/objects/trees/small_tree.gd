extends Sprite2D

var type = "Wood"
var health = 3
var grid_pos: Vector2i
const TILE_SIZE = 16

var log_scene = preload("res://scenes/objects/trees/small_log.tscn")

func _ready() -> void:
	grid_pos = global_position / TILE_SIZE
	WorldObjects.objects[grid_pos] = self
	#print(WorldObjects.objects)
	
func hit():
	health -= 1
	
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
	call_deferred("load_log_scene")
	
func load_log_scene() -> void:
	var log_scene_instance = log_scene.instantiate() as Sprite2D
	log_scene_instance.global_position = global_position
	get_parent().add_child(log_scene_instance)
