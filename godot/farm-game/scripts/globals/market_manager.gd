extends Node

var price_modifiers = {} 

func set_modifier(item_name: String, multiplier: float):
	price_modifiers[item_name] = multiplier

func get_price(item_name: String, base_price: int) -> int:
	if price_modifiers.has(item_name):
		return int(base_price * price_modifiers[item_name])
	return base_price

func clear_modifiers():
	price_modifiers.clear()
