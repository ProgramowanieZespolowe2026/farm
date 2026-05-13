extends Node


@onready var pick_from_slot: AudioStreamPlayer = %PickFromSlot
@onready var put_in_slot: AudioStreamPlayer = %PutInSlot
@onready var error: AudioStreamPlayer2D = %Error
@onready var building_ready: AudioStreamPlayer = %BuildingReady
@onready var shop_close: AudioStreamPlayer = %ShopClose
@onready var shop_open: AudioStreamPlayer = %ShopOpen
@onready var animal_building_open: AudioStreamPlayer = %AnimalBuildingOpen
@onready var menu_open: AudioStreamPlayer2D = %MenuOpen
@onready var fly_sound: AudioStreamPlayer2D = %FlySound
@onready var chicken_sound: AudioStreamPlayer2D = %ChickenSound
@onready var cha_ching: AudioStreamPlayer2D = %ChaChing
@onready var next_prev_sound: AudioStreamPlayer = %NextPrevSound
@onready var pick_up_item: AudioStreamPlayer2D = %PickUpItem
@onready var new_item: AudioStreamPlayer2D = %NewItem
@onready var barn_sfx: Node = %BarnSfx
@onready var new_notification: AudioStreamPlayer = %Notification


func play_put_in_slot():
	if put_in_slot:
		put_in_slot.play()

func play_pick_from_slot():
	if pick_from_slot:
		pick_from_slot.play()

func play_error():
	if error:
		error.play()
		
func play_building_ready():
	if building_ready:
		building_ready.play()
		
func play_barn_sound(global_position):
	if barn_sfx.pig_sound && barn_sfx.cow_sound && barn_sfx.sheep_sound:
		AudioManager.barn_sfx.pig_sound.global_position = global_position
		barn_sfx.pig_sound.play()
		AudioManager.barn_sfx.cow_sound.global_position = global_position
		barn_sfx.cow_sound.play()
		AudioManager.barn_sfx.sheep_sound.global_position = global_position
		barn_sfx.sheep_sound.play()
