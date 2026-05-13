extends AnimatedSprite2D

@export var object_name: String
@export var item_produce_amount: int
@export var item_scene: PackedScene
@export var log_scene: PackedScene
@export var health: int

@export var days_to_grow: int = 14    # Dni od sadzonki do Large
@export var days_to_fruit: int = 7    # Dni od podlania (Bloom) do Fruit
@export var days_fruit_stays: int = 3 # Dni życia owoców

# Liczniki dni
var current_day_count: int = 0
var fruit_timer: int = 0

# Stany drzewa
enum State { SEEDLING, SMALL, LARGE, BLOOM, FRUIT }
var current_state = State.SEEDLING

var tree_is_watered: bool = false
var grid_pos: Vector2i
const TILE_SIZE = 16

@onready var fruits_falling: AudioStreamPlayer2D = $FruitsFalling
@onready var new_item: AudioStreamPlayer2D = $NewItem
@onready var shape2d = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	TestGameTimeCycleManager.time_tick_day.connect(_on_day_tick)
	grid_pos = global_position / TILE_SIZE
	update_appearance()

func _on_day_tick(_day: int):
	match current_state:
		State.SEEDLING, State.SMALL:
			current_day_count += 1
			# Prosta logika: połowa czasu to 'small', reszta to 'large'
			if current_day_count >= days_to_grow:
				current_state = State.LARGE
				current_day_count = 0
			elif current_day_count >= days_to_grow / 2:
				current_state = State.SMALL
		
		State.LARGE:
			if tree_is_watered:
				bloom() # Przechodzi w stan kwitnienia
		
		State.BLOOM:
			current_day_count += 1
			if current_day_count >= days_to_fruit:
				current_state = State.FRUIT
				current_day_count = 0
		
		State.FRUIT:
			fruit_timer += 1
			if fruit_timer >= days_fruit_stays:
				rot_fruits()

	update_appearance()

func bloom():
	current_state = State.BLOOM
	current_day_count = 0
	tree_is_watered = false # Woda zużyta na zakwitnięcie
	update_appearance()

func rot_fruits():
	current_state = State.LARGE
	fruit_timer = 0
	print("Owoce zgniły.")
	update_appearance()

func update_appearance():
	match current_state:
		State.SEEDLING:
			self.play("small") # Możesz dodać animację sadzonki jeśli masz
		State.SMALL:
			self.play("small")
			shape2d.set_deferred("disabled", false)
		State.LARGE:
			self.play("large")
			shape2d.shape.set_deferred("radius", 5)
		State.BLOOM:
			self.play("bloom")
		State.FRUIT:
			self.play("fruit")

func harvest():
	if current_state == State.FRUIT:
		# Animacja trzęsienia
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 5.0, 0.05)
		tween.tween_property(self, "rotation_degrees", -5.0, 0.05)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.05)
		
		fruits_falling.play()
		
		# Powrót do fazy LARGE
		current_state = State.LARGE
		fruit_timer = 0
		
		if item_scene:
			for i in range(item_produce_amount):
				spawn_item(item_scene)
				new_item.play()
		
		update_appearance()

func water():
	# Podlewanie działa tylko na duże drzewo, które jeszcze nie kwitnie
	if current_state == State.LARGE:
		tree_is_watered = true

# ... reszta funkcji (spawn_item, hit, die, load_log_scene) pozostaje bez zmian ...

func spawn_item(scene_to_spawn: PackedScene):
	var item = scene_to_spawn.instantiate() as Node2D
	var new_offset = Vector2(
		randf_range(-20, 20), 
		randf_range(-20, 20)
	)
	item.global_position = global_position + new_offset
	get_parent().add_child(item)
	
func hit(chop_sound: AudioStreamPlayer2D):
	if current_state != State.SEEDLING:
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
	
