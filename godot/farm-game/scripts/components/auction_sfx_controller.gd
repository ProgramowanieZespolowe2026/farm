extends Node2D

@onready var menu_open: AudioStreamPlayer2D = %MenuOpen
@onready var auction: AudioStreamPlayer2D = %Auction
@onready var knock: AudioStreamPlayer2D = %Knock
@onready var cha_ching: AudioStreamPlayer2D = %ChaChing
@onready var error: AudioStreamPlayer2D = %Error


var is_auction_running: bool = false

func start_chant():
	is_auction_running = true
	if not auction.playing:
		auction.play() 

func stop_chant():
	is_auction_running = false
	
	var tween = create_tween()
	tween.tween_property(auction, "volume_db", -80, 2)
	tween.tween_callback(func():
		auction.stop()
		auction.volume_db = -20
	)
		
func play_knock():
	knock.play()
	
func play_menu_open():
	menu_open.play()
	
func play_cha_ching():
	cha_ching.play()
	
func play_error():
	error.play()
