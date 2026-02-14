extends Sprite2D

@onready var reaction_component: ReactionComponent = $ReactionComponent
@onready var effect_component: EffectComponent = $EffectComponent

var log_scene = preload("res://scenes/objects/trees/big_log_scene.tscn")

func _ready() -> void:
	reaction_component.on_action.connect(add_effect)
	effect_component.max_effect_count_reached.connect(on_max_effect_count)
	
func on_max_effect_count() -> void:
	call_deferred("load_log_scene")
	print("max reached")
	queue_free()
	
func add_effect(effect_power: int) -> void:
	effect_component.apply_effect(effect_power)
	material.set_shader_parameter("shake_intensity", 0.5)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)
	
func load_log_scene() -> void:
	var log_scene_instance = log_scene.instantiate() as Sprite2D
	log_scene_instance.global_position = global_position
	get_parent().add_child(log_scene_instance)
