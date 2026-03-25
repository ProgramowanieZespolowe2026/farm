extends Control

@onready var auction_sfx_controller: Node2D = %AuctionSfxController

@onready var status_label: Label = %StatusLabel
@onready var player_winner_label: Label = %PlayerWinner
@onready var npc_winner_label: Label = %NPCWinner
@onready var price_label: Label = %PriceLabel
@onready var bid_label: Label = %BidLabel

@onready var final_label: Label = %FinalLabel
@onready var time_bar: ProgressBar = %TimeBar

@onready var npc_sprite: AnimatedSprite2D = %NPC
@onready var player_sprite: AnimatedSprite2D = %Player

@onready var cancel_button: TextureButton = %CancelButton
@onready var start_button: TextureButton = %StartBtn
@onready var bid_button: TextureButton = %BidBtn
@onready var start_box: VBoxContainer = %StartBox
@onready var bid_box: VBoxContainer = %BidBox

@export var auction_time: int = 8
@export var npc_chance: int = 0
@export var player_bid: int = 100
@export var npc_bid: int = 50

var is_fading_out: bool = false

func _ready():
	if AuctionManager:
		AuctionManager.auction_started.connect(_on_auction_started)
		AuctionManager.auction_updated.connect(_on_auction_update)
		AuctionManager.auction_ended.connect(_on_auction_end)
		AuctionManager.npc_rised_hand.connect(_on_npc_bid)
		AuctionManager.max_time = auction_time
		AuctionManager.npc_chance = npc_chance
		AuctionManager.player_bid_amount = player_bid
		AuctionManager.npc_bid_amount = npc_bid
	
	start_button.pressed.connect(_on_start_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	bid_button.pressed.connect(_on_bid_button_pressed)
	
	bid_label.text = "%s $" % [player_bid]

	hide()

func _on_auction_started(initial_bid):
	if is_fading_out: 
		return 
	if not visible:
		auction_sfx_controller.menu_open.play()
	show()
	
	cancel_button.modulate.a = 1.0
	start_box.show()
	bid_box.hide()
	npc_winner_label.modulate.a = 0.0
	player_winner_label.modulate.a = 0.0
	bid_button.disabled = false

	
	player_sprite.frame = 0 
	price_label.text = str(initial_bid) + ""
	status_label.text = "Ready..."
	time_bar.max_value = auction_time
	time_bar.value = time_bar.max_value

func _on_start_pressed():
	start_box.hide()
	bid_box.show()
	auction_sfx_controller.play_knock()
	auction_sfx_controller.start_chant()
	AuctionManager.start_confirmed()

func _on_cancel_pressed():
	auction_sfx_controller.stop_chant()
	hide()
	AuctionManager.cancel_auction()

func _on_auction_update(current_bid: int, time_left: float, last_bidder: AuctionManager.OwnerType):
	if not visible: show()
	
	price_label.text = str(current_bid) + ""
	
	time_bar.value = time_left 
	if not Wallet.can_afford(current_bid + player_bid):
		bid_button.disabled = true
		bid_label.hide()
		price_label.add_theme_color_override("font_color", Color.RED)

	match last_bidder:
		AuctionManager.OwnerType.NONE: status_label.text = "Waiting..."
		AuctionManager.OwnerType.PLAYER_TEAM: 
			status_label.text = "Winner"
			cancel_button.modulate.a = 0.0
			player_winner_label.modulate.a = 1.0
			npc_winner_label.modulate.a = 0.0
		AuctionManager.OwnerType.NPC: 
			cancel_button.modulate.a = 0.0
			status_label.text = "Winner"
			npc_winner_label.modulate.a = 1.0
			player_winner_label.modulate.a = 0.0


func _on_auction_end(plot_name: String, winner_type: AuctionManager.OwnerType, final_price: int):
	is_fading_out = true
	time_bar.hide()
	bid_box.hide()
	start_box.hide()
	cancel_button.hide()
	price_label.hide()
	player_sprite.hide()
	npc_sprite.hide()
	auction_sfx_controller.stop_chant()
	auction_sfx_controller.play_knock()
	
	var winner_text = "NONE"
	var auction_result = "FOR SALE!"
	if winner_type == AuctionManager.OwnerType.PLAYER_TEAM:
		winner_text = "player"
		auction_result = "SOLD!"
		player_sprite.show()
	elif winner_type == AuctionManager.OwnerType.NPC:
		winner_text = "npc"
		auction_result = "SOLD!"
		npc_sprite.show()
	
	status_label.text = "STATUS: %s\nOWNER: %s\nPLOT: %s\nPRICE: %d $" % [auction_result, winner_text, plot_name, final_price]
	
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)

	tween.tween_callback(func():
		hide()
		self.modulate.a = 1.0
		_reset_ui_for_next_auction()
	)

func _reset_ui_for_next_auction():
	time_bar.show()
	cancel_button.show()
	price_label.show()
	player_sprite.show()
	npc_sprite.show()
	player_winner_label.modulate.a = 0.0
	npc_winner_label.modulate.a = 0.0
	status_label.text = ""
	bid_button.disabled = false
	bid_label.show()
	price_label.add_theme_color_override("font_color", "ffc544")
	is_fading_out = false


func _on_bid_button_pressed():
	player_sprite.frame = 1
	auction_sfx_controller.play_cha_ching()
	AuctionManager.player_bid()
	
	await get_tree().create_timer(0.5).timeout
	player_sprite.frame = 0
	
func _on_npc_bid():
	npc_sprite.frame = 1
	
	await get_tree().create_timer(0.5).timeout
	npc_sprite.frame = 0
