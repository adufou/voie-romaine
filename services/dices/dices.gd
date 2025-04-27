extends Node

class_name Dices

@export var dice_scene: PackedScene

var table: Table
var dices: Array[Dice]

func init_table(table_instance: Table):
	table = table_instance

func add_dice():
	var dice: Dice = dice_scene.instantiate()
	table.add_child(dice)
	
	var position = Vector2i(table.size) * 0.5
	
	dice.position = position
	
	dices.append(dice)

func throw_dices(): 
	for dice in dices:
		dice.throw()
