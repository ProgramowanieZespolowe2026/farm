extends Area2D

@export var plot_id: String = ""
@export var is_owned: bool = false
@export var price: int = 1000
 
@onready var border = $Border
@onready var price_tag: Panel = $PriceTag

# size of plot in pixels
var plot_px

var is_target_inside: bool = false

func _ready():
	# Wyłączamy dziedziczenie Z-Indexu od rodzica
	border.z_as_relative = false
	border.z_index = -1
	price_tag.visible = false # Ukrywamy na starcie
	price_tag.modulate.a = 0.0 # Ustawiamy przezroczystość na zero
	
	var center_pos = Vector2(plot_px / 2.0, plot_px / 2.0)
	price_tag.position = center_pos
	
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	var original_y = price_tag.position.y
	tween.tween_property(price_tag, "position:y", original_y - 4, 1.0) # Move up 4px in 1 second
	tween.tween_property(price_tag, "position:y", original_y, 1.0)     # Move back in 1 second
	# turn of signals like body_entered etc. and set frame visibility to 0
	monitoring = false
	border.visible = false
	border.modulate.a = 0.0
	update_visuals()

func _process(_delta):

	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var tool_ctrl = player.get_node_or_null("ToolController")
	if not tool_ctrl: return
	
	var target_pos = tool_ctrl.current_target_grid_pos
	# change current grid target position to pixels
	var target_in_pixels = target_pos * 16

	# create plot rectangle
	var plot_rect = Rect2(global_position, Vector2(plot_px, plot_px))
	
	# check if target pixels are in rectangle
	var currently_inside = plot_rect.has_point(target_in_pixels)
	
	# flash if target is inside
	if currently_inside and not is_target_inside:
		flash_border()
	# set variable to true
	is_target_inside = currently_inside

func flash_border():
	update_visuals()
	border.visible = true
	border.modulate.a = 0.0
	
	# flash logic
	var tween = create_tween().set_parallel(true) # Parallel pozwala animować oba naraz
	
	# --- ANIMACJA POJAWIANIA SIĘ ---
	tween.tween_property(border, "modulate:a", 1.0, 0.1)
	tween.tween_property(price_tag, "modulate:a", 1.0, 0.2) # Moneta pojawia się ciut wolniej
	
	# --- ANIMACJA ZNIKANIA (Z OPÓŹNIENIEM) ---
	# Używamy chain(), żeby te animacje ruszyły PO tych powyżej
	var fade_out = create_tween().set_parallel(false)
	fade_out.tween_interval(0.8) # Czas, przez który moneta "stoi" i jest widoczna
	
	# Ramka znika szybko
	fade_out.tween_property(border, "modulate:a", 0.0, 0.2)
	
	# Moneta znika troszkę później i wolniej (np. 0.8 sekundy po ramce)
	fade_out.tween_property(price_tag, "modulate:a", 0.0, 1.0)
	
	# Na koniec sprzątamy (ukrywamy węzły)
	fade_out.tween_callback(func():
		border.visible = false
		price_tag.visible = false
		)

func update_visuals():
	# set plot size
	border.size = Vector2(plot_px, plot_px)
	# get plot stylebox
	var style_box = border.get_theme_stylebox("panel").duplicate()
	# if player own plot change color
	style_box.border_color = Color.GREEN if is_owned else Color.RED
	# override stylebox
	border.add_theme_stylebox_override("panel", style_box)
	
	if is_owned:
		price_tag.visible = false # Kupiona - tabliczka znika
	else:
		price_tag.visible = true  # Do kupienia - tabliczka stoi
