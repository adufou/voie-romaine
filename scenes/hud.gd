extends Control

func _ready() -> void:
	Services.score.score_changed.connect(on_score_changed)

func on_score_changed(new_score: int):
	%Score.text = str(new_score)

func _on_spawn_dice_button_pressed() -> void:
	Services.dices.add_dice()

func _on_throw_dices_button_pressed() -> void:
	Services.dices.throw_dices()
