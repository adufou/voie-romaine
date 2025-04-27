extends Node

class_name Score

signal score_changed(new_score)

var _score: int = 0:
	set(new_value):
		_score = new_value
		score_changed.emit(_score)

func pass_goal(goal: int):
	var scored = 7 - goal
	
	_score += scored
