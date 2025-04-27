extends Node

class_name Cash

signal cash_changed(new_chash)

var _cash: int = 0:
	set(new_value):
		_cash = new_value
		cash_changed.emit(_cash)

func pass_goal(goal: int):
	var cashed_out = 7 - goal
	
	_cash += cashed_out

func use_cash(quantity: int):
	_cash -= quantity
