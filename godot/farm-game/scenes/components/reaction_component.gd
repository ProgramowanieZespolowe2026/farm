class_name ReactionComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.Axe

signal on_action


func _on_area_entered(area: Area2D) -> void:
	var action_component = area as ActionComponent	
	if tool == action_component.current_tool:
		on_action.emit(action_component.action_power)
		
		
