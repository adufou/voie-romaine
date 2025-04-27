extends Node2D

class_name Dice

var value: int
var goal: int = 6:
	set(new_value):
		%Goal.text = str(new_value)
		goal = new_value

var tries: int = -1: # -1 => Infinite
	set(new_value):
		var tries_text = "∞"
		if (new_value > 0):
			tries_text = str(new_value)
		
		%Tries.text = tries_text
		tries = new_value

func _ready() -> void:
	reset()

func throw():
	%AnimatedSprite2D.play("throw")
	%Timer.start()

func set_value():
	%AnimatedSprite2D.animation = "white"
	%AnimatedSprite2D.pause()
	
	value = randi_range(1,6)
	%AnimatedSprite2D.frame = value - 1
	
	print(value)
	
	resolve()

func _on_timer_timeout() -> void:
	set_value()

func resolve() -> void:
	if (value == goal):
		if (goal == 1):
			win()
			return
			
		goal -= 1
		tries = goal
		
	else:
		if (tries > 1):
			tries -= 1
				
		elif (tries == 1):
			lose()
			return

func reset():
	goal = 6
	tries = -1
	throw()

func lose():
	if (goal < 5):
		goal += 1
		tries = goal
		
	else:
		goal = 6
		tries = -1
		
	on_lose()

func win():
	on_win()
	reset()

func on_lose():
	print("LOSE")
	
func on_win():
	print("WIN")
