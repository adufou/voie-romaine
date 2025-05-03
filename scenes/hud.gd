extends Control



func _ready() -> void:
	Services.cash_service.cash_changed.connect(on_cash_changed)
	Services.score_service.score_changed.connect(on_score_changed)

func on_cash_changed(new_cash: int):
	%Cash.text = "$" + str(new_cash)

func on_score_changed(new_score: int):
	%Score.text = str(new_score)

func _on_throw_dices_button_pressed() -> void:
	Services.dices_service.throw_dices()


func _on_open_shop_button_pressed() -> void:
	%InGameHUD.hide()
	%ShopPanel.show()
	
func _on_close_shop_button_pressed() -> void:
	%ShopPanel.hide()
	%InGameHUD.show()


func _on_add_dice_button_pressed() -> void:
	Services.dices_service.add_dice()
