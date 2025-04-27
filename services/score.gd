extends Node

class_name Score

signal score_changed(new_score)

var score: int = 0:
	set(new_value):
		score = new_value
		score_changed.emit(score)

func pass_goal(goal: int):
	var scored = 7 - goal
	
	score += scored
