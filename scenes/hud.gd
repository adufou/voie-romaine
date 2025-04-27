extends Control

func _on_spawn_dice_button_pressed() -> void:
	Services.dices.add_dice()


func _on_throw_dices_button_pressed() -> void:
	Services.dices.throw_dices()
