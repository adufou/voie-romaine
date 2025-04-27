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
	
	var throw_number = "?" if goal == 6 else str(goal - tries + 1)
	print("N°", throw_number, " of ", goal, " | Rolled ", value)
	
	throw_resolve()

func _on_timer_timeout() -> void:
	set_value()

func throw_resolve() -> void:
	if (value == goal):
		throw_win()
		if (goal == 1):
			win()
			return
			
		goal -= 1
		tries = goal
		
	else:
		if (goal == 1 and value == 6): # Super beugnette
			goal = 6
			tries = -1
			print("Super beugnette...")
		
		elif (tries > 1):
			tries -= 1
				
		elif (tries == 1):
			if (value == goal + 1): # Beugnette
				tries = goal
				print("Beugnette !")
				return
			
			throw_lose()

func reset():
	goal = 6
	tries = -1
	throw()

func throw_lose():
	if (goal < 5):
		goal += 1
		tries = goal
		
	else:
		goal = 6
		tries = -1
		
	on_throw_lose()

func throw_win():
	on_throw_win()

func win():
	print("WIN")
	reset()

func on_throw_lose():
	pass
	# print("THROW LOSE")
	
func on_throw_win():
	# print("THROW WIN")
	Services.score.pass_goal(goal)
