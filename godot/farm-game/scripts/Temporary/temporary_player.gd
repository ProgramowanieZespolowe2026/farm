extends CharacterBody2D
class_name TemporaryPlayer

@export var speed := 200.0
@export var current_tool = DataTypes.Tools.None
@onready var sprite = $AnimatedSprite2D
@onready var player_sfx_controller: Node2D = $PlayerSfxController


var last_facing_direction = Vector2.DOWN


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
   
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_facing_direction = Vector2(sign(input_vector.x), sign(input_vector.y))
	
	velocity = input_vector * speed
	move_and_slide()

			
	if velocity.length() > 0:
		player_sfx_controller.play_walk_audio()
	
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
