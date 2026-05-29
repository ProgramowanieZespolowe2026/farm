extends Area2D

@export var plot_id: String
@export var current_owner: AuctionManager.OwnerType = AuctionManager.OwnerType.NONE
@export var price: int = 1000

@onready var border: Panel = %Border
@onready var price_tag: Panel = %PriceTag
@onready var private_property: Panel = %PrivateProperty

# size of plot in pixels
var plot_px
var is_target_inside: bool = false

func _ready():
	
	border.visible = false
	border.modulate.a = 0.0
	price_tag.visible = false 
	price_tag.modulate.a = 0.0
	private_property.visible = false
	private_property.modulate.a = 0.0
	
	var center_pos = Vector2(plot_px / 2.0, plot_px / 2.0)
	price_tag.position = center_pos
	private_property.position = center_pos
	
	# price_tag animation up and down
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	var original_y = price_tag.position.y
	tween.tween_property(price_tag, "position:y", original_y - 4, 1.0) 
	tween.tween_property(price_tag, "position:y", original_y, 1.0)   
	 
	# turn of signals like body_entered etc. (no need for them)
	monitoring = false

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var tool_ctrl = player.get_node_or_null("ToolController")
	if not tool_ctrl: return
	
	# POBIERAMY CAŁY RECT Z HIGHLIGHTA (to co widzi gracz)
	var b_size = tool_ctrl.highlight.scale * tool_ctrl.TILE_SIZE
	var b_pos = tool_ctrl.current_target_grid_pos * tool_ctrl.TILE_SIZE
	var building_rect = Rect2(b_pos, b_size).grow(-0.1)

	var plot_rect = Rect2(global_position, Vector2(plot_px, plot_px))
	
	# Używamy intersects zamiast has_point!
	var currently_inside: bool = plot_rect.intersects(building_rect)
	
	if currently_inside and not is_target_inside:
		flash_border()
	
	is_target_inside = currently_inside
	
func set_ownership(new_owner: AuctionManager.OwnerType):
	current_owner = new_owner
	update_visuals()

func flash_border():
	update_visuals()

	if current_owner == AuctionManager.OwnerType.PLAYER_TEAM:
		return
	elif current_owner == AuctionManager.OwnerType.NONE:
		price_tag.visible = true
		price_tag.modulate.a = 1.0
	elif current_owner == AuctionManager.OwnerType.NPC:
		private_property.visible = true
		private_property.modulate.a = 1.0
	else:
		price_tag.visible = false 
		private_property.visible = false
	
	border.visible = true
	border.modulate.a = 1.0
	
	# frame and price_tag appear animation
	var tween = create_tween().set_parallel(true) 
	tween.tween_property(border, "modulate:a", 1.0, 0.1)
	tween.tween_property(price_tag, "modulate:a", 1.0, 0.2)
	tween.tween_property(private_property, "modulate:a", 1.0, 0.2)
	
	# frame and price_tag disappear animation
	var fade_out = create_tween().set_parallel(false)
	fade_out.tween_interval(0.8)
	fade_out.tween_property(border, "modulate:a", 0.0, 0.2)
	fade_out.tween_property(price_tag, "modulate:a", 0.0, 1.0)
	fade_out.parallel().tween_property(private_property, "modulate:a", 0.0, 1.0)
	
	# turn visibility of when animation is finished
	fade_out.tween_callback(func():
		border.visible = false
		price_tag.visible = false
		private_property.visible = false
		)

func update_visuals():
	var margin = 2
	
	border.size = Vector2(plot_px - (margin * 2), plot_px - (margin * 2))
	border.position = Vector2(margin, margin)

	var style_box = border.get_theme_stylebox("panel").duplicate()
	
	match current_owner:
		AuctionManager.OwnerType.PUBLIC:
			border.visible = false # Lepiej ukryć, jeśli publiczne
			return 
		AuctionManager.OwnerType.NONE:
			style_box.border_color = Color.YELLOW 
		AuctionManager.OwnerType.PLAYER_TEAM:
			return
		AuctionManager.OwnerType.NPC:
			style_box.border_color = Color.ORANGE_RED 
			
	border.add_theme_stylebox_override("panel", style_box)

# Funkcja do trwałego podświetlenia (np. podczas licytacji)
