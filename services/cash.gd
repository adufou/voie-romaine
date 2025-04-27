extends Node

class_name Cash

signal cash_changed(new_chash)

var _cash: int = 0:
	set(new_value):
		_cash = new_value
		cash_changed.emit(_cash)

func add_cash(added_cash: int):	
	_cash += added_cash

func use_cash(quantity: int):
	_cash -= quantity
