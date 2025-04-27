extends Control

class_name Table

func _ready() -> void:
	Services.dices.init_table(self)
	Services.dices.add_dice()
