class_name EffectComponent
extends Node2D

@export var max_effect_count = 3
@export var current_effect_count = 0

signal max_effect_count_reached

func apply_effect(effect_power: int) -> void:
	current_effect_count = clamp(current_effect_count + effect_power, 0, max_effect_count)
	print(current_effect_count)

	if current_effect_count == max_effect_count:
		max_effect_count_reached.emit()
