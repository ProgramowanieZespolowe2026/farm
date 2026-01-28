extends CharacterBody2D

@export var speed := 200.0
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
   
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	
	velocity = input_vector * speed
	move_and_slide()
	
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
