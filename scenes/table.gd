extends Control

class_name Table

func _ready() -> void:
	Services.dices_service.init_table(self)
	Services.dices_service.add_dice()
