extends Node

signal balance_changed(new_amount)

var balance: int = 25000:
	set(value):
		balance = max(0, value)
		balance_changed.emit(balance)

func add_money(amount: int):
	if amount > 0:
		balance += amount

func spend_money(amount: int) -> bool:
	if can_afford(amount):
		balance -= amount
		return true 
	else:
		return false 

func can_afford(amount: int) -> bool:
	return balance >= amount
