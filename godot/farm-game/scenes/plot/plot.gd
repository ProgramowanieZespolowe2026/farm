extends Area2D

# NONE - for sale
# PLAYER_TEAM - players plot 
# NPC - owned by random npc
# PUBLIC - optional not interactable plots like shop or lake etc. (not for sale, for public use)
enum OwnerType { NONE, PLAYER_TEAM, NPC, PUBLIC }

@export var plot_id: String = ""
@export var current_owner: OwnerType = OwnerType.NONE
@export var price: int = 1000
 
@onready var border = $Border
@onready var price_tag: Panel = $PriceTag

# size of plot in pixels
var plot_px
var is_target_inside: bool = false

func _ready():
	
	border.visible = false
	border.modulate.a = 0.0
	price_tag.visible = false 
	price_tag.modulate.a = 0.0
	
	var center_pos = Vector2(plot_px / 2.0, plot_px / 2.0)
	price_tag.position = center_pos
	
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
	
	var target_pos = tool_ctrl.current_target_grid_pos
	# change current grid target position to pixels
	var target_in_pixels = target_pos * 16

	# create plot rectangle
	var plot_rect = Rect2(global_position, Vector2(plot_px, plot_px))
	
	# check if target pixels are in rectangle
	var currently_inside: bool = plot_rect.has_point(target_in_pixels)
	
	# flash border only when target enters plot 
	if currently_inside and not is_target_inside:
		flash_border()
	
	is_target_inside = currently_inside
	
func set_ownership(new_owner: OwnerType):
	current_owner = new_owner
	update_visuals()

func flash_border():
	update_visuals()

	if current_owner == OwnerType.PLAYER_TEAM:
		return
	elif current_owner == OwnerType.NONE:
		price_tag.visible = true
		price_tag.modulate.a = 1.0
	else:
		price_tag.visible = false 
	
	border.visible = true
	border.modulate.a = 1.0
	
	# frame and price_tag appear animation
	var tween = create_tween().set_parallel(true) 
	tween.tween_property(border, "modulate:a", 1.0, 0.1)
	tween.tween_property(price_tag, "modulate:a", 1.0, 0.2)
	
	# frame and price_tag disappear animation
	var fade_out = create_tween().set_parallel(false)
	fade_out.tween_interval(0.8)
	fade_out.tween_property(border, "modulate:a", 0.0, 0.2)
	fade_out.tween_property(price_tag, "modulate:a", 0.0, 1.0)
	
	# turn visibility of when animation is finished
	fade_out.tween_callback(func():
		border.visible = false
		price_tag.visible = false
		)

func update_visuals():
	# set plot size
	border.size = Vector2(plot_px, plot_px)
	# get plot stylebox
	var style_box = border.get_theme_stylebox("panel").duplicate()
	# change frame color depending on owner
	match current_owner:
		OwnerType.PUBLIC:
			return 
		OwnerType.NONE:
			style_box.border_color = Color.YELLOW 
		OwnerType.PLAYER_TEAM:
			#style_box.border_color = Color.GREEN 
			## optional if it's player plot don't show any border
			return
		OwnerType.NPC:
			style_box.border_color = Color.ORANGE_RED 
			
	border.add_theme_stylebox_override("panel", style_box)
	
