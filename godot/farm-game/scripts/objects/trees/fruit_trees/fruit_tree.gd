extends AnimatedSprite2D

var growth_points_to_collect: int = 1000
@export var tree_name: String
@export var item_produce_amount: int
@export var item_scene: PackedScene
@export var log_scene: PackedScene
@export var health: int

@onready var growth_points_to_die: int = growth_points_to_collect * 4
@onready var fruits_falling: AudioStreamPlayer2D = $FruitsFalling
@onready var new_item: AudioStreamPlayer2D = $NewItem
@onready var shape2d = $StaticBody2D/CollisionShape2D

var grid_pos: Vector2i
const TILE_SIZE = 16
var growth_points: int = 0
var tree_has_grown: bool = false
var tree_is_watered: bool = false

func _ready() -> void:
	TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	grid_pos = global_position / TILE_SIZE

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	grow()
	bloom()
	update_sprite()
	print(growth_points)
	
func grow() -> void:
	
	if growth_points < growth_points_to_collect / 3.0:
		growth_points += 5
	else:
		tree_has_grown = true
		#tree_is_watered = false
		
	
func bloom() -> void:
	if tree_has_grown and tree_is_watered: 
		growth_points += 5
		
func update_sprite():
	if growth_points > growth_points_to_collect:
		self.play("fruit")
	elif growth_points > growth_points_to_collect / 2.0:
		self.play("bloom")
	elif growth_points > growth_points_to_collect / 3.0:
		self.play("large")
		shape2d.shape.set_deferred("radius", 5)
	elif growth_points > growth_points_to_collect / 4.0:
		self.play("small")
		shape2d.set_deferred("disabled", false)
		shape2d.shape.set_deferred("radius", 4)

func harvest():
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 5.0, 0.05)
	tween.tween_property(self, "rotation_degrees", -5.0, 0.05)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.05)
	fruits_falling.play()
	
	growth_points = ceil(growth_points_to_collect / 3.0)
	self.play("large")
	tree_is_watered = false
	
	if item_scene:
		for i in range(item_produce_amount):
			spawn_item(item_scene)
			new_item.play()

func spawn_item(scene_to_spawn: PackedScene):
	var item = scene_to_spawn.instantiate() as Node2D
	var new_offset = Vector2(
		randf_range(-20, 20), 
		randf_range(-20, 20)
	)
	item.global_position = global_position + new_offset
	get_parent().add_child(item)
	
func hit(chop_sound: AudioStreamPlayer2D):
	if growth_points > growth_points_to_collect / 4.0:
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
	call_deferred("load_log_scene")
	
func load_log_scene() -> void:
	var log_scene_instance = log_scene.instantiate() as Sprite2D
	log_scene_instance.global_position = global_position
	get_parent().add_child(log_scene_instance)
	
func water():
	tree_is_watered = true
