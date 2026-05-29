extends PanelContainer

@onready var money_label: Label = %MoneyLabel

func _ready():
	if Wallet.has_signal("balance_changed"):
		Wallet.balance_changed.connect(_on_balance_updated)
	_update_money_text(Wallet.balance)

func _on_balance_updated(new_amount: int):
	_update_money_text(new_amount)
	_flash_effect()

func _update_money_text(amount: int):
	money_label.text = str(amount) + " $"

func _flash_effect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	tween.parallel().tween_property(self, "modulate", Color(3, 3, 3), 0.05)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	
	

	

	
