extends Control



func _ready() -> void:
	Services.cash_service.cash_changed.connect(on_cash_changed)
	Services.score_service.score_changed.connect(on_score_changed)
	Services.rules_service.goal_changed.connect(on_goal_changed)
	Services.upgrades_service.upgrade_effect_changed.connect(on_number_of_faces_changed)
	Services.rules_service.remaining_attempts_changed.connect(on_remaining_attempts_changed)

func on_cash_changed(new_cash: int):
	%Cash.text = "$" + str(new_cash)

func on_score_changed(new_score: int):
	%Score.text = str(new_score)

func on_goal_changed(new_goal: int):
	%Goal.text = "Goal: " + str(new_goal)

func on_remaining_attempts_changed(new_attempts: int):
	var tries_text = "∞"
	if (new_attempts > 0):
		tries_text = str(new_attempts)
	%Attempts.text = "Attempts: " + tries_text

func on_number_of_faces_changed(upgrade_type: UpgradeConstants.UpgradeType, new_effect: float):
	if upgrade_type != UpgradeConstants.UpgradeType.NUMBER_OF_FACES:
		return
	%Faces.text = "Faces: " + str(new_effect)

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


func _on_add_face_button_pressed() -> void:
	Services.upgrades_service.purchase_upgrade(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
