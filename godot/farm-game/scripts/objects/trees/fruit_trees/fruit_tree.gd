extends AnimatedSprite2D

@export var object_name: String
@export var item_produce_amount: int
@export var item_scene: PackedScene
@export var log_scene: PackedScene
@export var health: int

# --- USTAWIENIA CZASU W DNIACH (Wygodne dla Inspektora) ---
# Teraz wpisujesz ułamek lub wielokrotność dnia. Np. 1.0 = pełna doba gry.
@export var days_to_grow: float = 1.0  
@export var days_to_fruit: float = 0.5
@export var days_fruit_stays: float = 0.3

# Wewnętrzne zmienne przeliczane na minuty
var minutes_to_grow: int = 0
var minutes_to_fruit: int = 0
var minutes_fruit_stays: int = 0

# Liczniki minut gry
var growth_timer: int = 0
var fruit_timer: int = 0

# Indywidualne progi minutowe (z uwzględnieniem małej losowości)
var target_minutes_to_grow: int = 0
var target_minutes_to_fruit: int = 0
var target_minutes_fruit_stays: int = 0

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
	# 1. Przeliczamy dni z Inspektora na minuty Twojego managera (1 dzień = 1440 minut)
	minutes_to_grow = int(days_to_grow * 1440)
	minutes_to_fruit = int(days_to_fruit * 1440)
	minutes_fruit_stays = int(days_fruit_stays * 1440)

	# 2. Podłączamy się pod Twój główny sygnał czasu
	if TestGameTimeCycleManager.has_signal("time_tick"):
		TestGameTimeCycleManager.time_tick.connect(_on_time_tick)
	
	grid_pos = global_position / TILE_SIZE
	
	# 3. Losujemy unikalny czas wzrostu dla tego konkretnego drzewa (+/- 5%)
	_calculate_random_targets()
	
	update_appearance()

# Funkcja losująca progi z dokładnością do +- 5%
func _calculate_random_targets() -> void:
	# randf_range(-0.05, 0.05) daje dokładnie 5% odchyłu w obie strony
	var variation_grow = int(minutes_to_grow * randf_range(-0.05, 0.05))
	target_minutes_to_grow = clampi(minutes_to_grow + variation_grow, 1, 999999)
	
	var variation_fruit = int(minutes_to_fruit * randf_range(-0.05, 0.05))
	target_minutes_to_fruit = clampi(minutes_to_fruit + variation_fruit, 1, 999999)
	
	var variation_stays = int(minutes_fruit_stays * randf_range(-0.05, 0.05))
	target_minutes_fruit_stays = clampi(minutes_fruit_stays + variation_stays, 1, 999999)

# Ta funkcja odpala się z managera czasu DOKŁADNIE raz na każdą minutę gry
func _on_time_tick(_day: int, _hour: int, _minute: int) -> void:
	match current_state:
		State.SEEDLING:
			growth_timer += 1
			# Przejście do SMALL w połowie czasu
			if growth_timer >= (target_minutes_to_grow / 2):
				current_state = State.SMALL
				update_appearance()

		State.SMALL:
			growth_timer += 1
			if growth_timer >= target_minutes_to_grow:
				current_state = State.LARGE
				growth_timer = 0
				update_appearance()
		
		State.LARGE:
			if tree_is_watered:
				bloom()
		
		State.BLOOM:
			growth_timer += 1
			if growth_timer >= target_minutes_to_fruit:
				current_state = State.FRUIT
				growth_timer = 0
				update_appearance()
		
		State.FRUIT:
			fruit_timer += 1
			if fruit_timer >= target_minutes_fruit_stays:
				rot_fruits()

func bloom():
	current_state = State.BLOOM
	growth_timer = 0
	tree_is_watered = false
	update_appearance()

func rot_fruits():
	current_state = State.LARGE
	fruit_timer = 0
	_calculate_random_targets() # Nowe losowanie na kolejny cykl owocowania
	print("Owoce zgniły.")
	update_appearance()

func update_appearance():
	match current_state:
		State.SEEDLING:
			self.play("small") 
		State.SMALL:
			self.play("small")
			if shape2d: shape2d.set_deferred("disabled", false)
		State.LARGE:
			self.play("large")
			if shape2d and shape2d.shape: shape2d.shape.set_deferred("radius", 5)
		State.BLOOM:
			self.play("bloom")
		State.FRUIT:
			self.play("fruit")

func harvest():
	if current_state == State.FRUIT:
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 5.0, 0.05)
		tween.tween_property(self, "rotation_degrees", -5.0, 0.05)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.05)
		
		fruits_falling.play()
		
		current_state = State.LARGE
		fruit_timer = 0
		_calculate_random_targets() # Nowe losowanie po zbiorach
		
		if item_scene:
			for i in range(item_produce_amount):
				spawn_item(item_scene)
				new_item.play()
		
		update_appearance()

func water():
	if current_state == State.LARGE:
		tree_is_watered = true

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
	new_item.play()
	var log_scene_instance = log_scene.instantiate() as Sprite2D
	log_scene_instance.global_position = global_position
	get_parent().add_child(log_scene_instance)
