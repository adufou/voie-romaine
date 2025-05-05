extends Control



func _ready() -> void:
	Services.cash_service.cash_changed.connect(on_cash_changed)
	Services.score_service.score_changed.connect(on_score_changed)
	Services.rules_service.goal_changed.connect(on_goal_changed)
	Services.upgrades_service.upgrade_effect_changed.connect(on_number_of_faces_changed)
	Services.rules_service.remaining_attempts_changed.connect(on_remaining_attempts_changed)
	Services.upgrades_service.upgrade_purchased.connect(on_upgrade_purchased)
	
	# Initialiser l'affichage des prix et l'état des boutons
	update_upgrade_buttons()

func on_cash_changed(new_cash: int):
	%Cash.text = "$" + str(new_cash)
	update_upgrade_buttons()

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

func on_upgrade_purchased(upgrade_type: UpgradeConstants.UpgradeType, new_level: int):
	# Mettre à jour l'interface après chaque achat d'upgrade, peu importe le type
	#Logger.log_message("Upgrade purchased: " + str(upgrade_type) + " - Level: " + str(new_level))
	update_upgrade_buttons()

func update_upgrade_buttons() -> void:
	# Mettre à jour le prix et l'état du bouton "Add Face"
	var face_cost = Services.upgrades_service.get_upgrade_cost(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
	if face_cost >= 0:
		%AddFaceLabel.text = "$" + str(face_cost)
		var can_afford = Services.cash_service.get_cash() >= face_cost
		%AddFaceButton.disabled = !can_afford
	else:
		# Niveau maximal atteint
		%AddFaceLabel.text = "MAX"
		%AddFaceButton.disabled = true
	
	# Mettre à jour le prix et l'état du bouton "Add Dice"
	var dice_cost = Services.upgrades_service.get_upgrade_cost(UpgradeConstants.UpgradeType.MULTI_DICE)
	if dice_cost >= 0:
		%AddDiceLabel.text = "$" + str(dice_cost)
		var can_afford_dice = Services.cash_service.get_cash() >= dice_cost
		%AddDiceButton.disabled = !can_afford_dice
	else:
		# Niveau maximal atteint
		%AddDiceLabel.text = "MAX"
		%AddDiceButton.disabled = true

func _on_throw_dices_button_pressed() -> void:
	Services.dices_service.throw_dices()


func _on_open_shop_button_pressed() -> void:
	%InGameHUD.hide()
	%ShopPanel.show()
	
func _on_close_shop_button_pressed() -> void:
	%ShopPanel.hide()
	%InGameHUD.show()


func _on_add_dice_button_pressed() -> void:
	Services.upgrades_service.purchase_upgrade(UpgradeConstants.UpgradeType.MULTI_DICE)


func _on_add_face_button_pressed() -> void:
	Services.upgrades_service.purchase_upgrade(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
