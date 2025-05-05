extends BaseService

class_name RulesService

# Signaux pour les événements de règles
signal rule_changed(rule_name, new_value)
signal goal_achieved(goal_number, reward)
signal goal_changed(goal_number)
signal beugnette_triggered(goal_number)
signal super_beugnette_triggered()
signal sequence_completed(total_reward)  # Signal émis quand une séquence complète est terminée
signal remaining_attempts_changed(new_attempts)

# Dépendances de 
var cash_service: CashService = null
var score_service: ScoreService = null
var upgrades_service: UpgradesService = null

# Configuration des règles
var rules_config = {
	"goal_attempts": {6: 6, 5: 5, 4: 4, 3: 3, 2: 2, 1: 1},
	"beugnette_enabled": true,
	"super_beugnette_enabled": true,
	"super_beugnette_goals": [1],  # Par défaut uniquement pour le but 1
	"base_rewards": {6: 6, 5: 5, 4: 4, 3: 3, 2: 2, 1: 10},  # Récompenses de base par but
	"reward_multiplier": 1.0,      # Multiplicateur global de récompense
	"critical_chance": 0.05,       # 5% de chance critique par défaut
	"critical_multiplier": 2.0     # Multiplicateur de récompense sur critique
}

# État du jeu actuel
var current_goal: int = 1:
	set(new_goal):
		goal_changed.emit(new_goal)
		current_goal = new_goal
	
var remaining_attempts: int = -1:
	set(new_attempts):
		remaining_attempts_changed.emit(new_attempts)
		remaining_attempts = new_attempts
			

func _init():
	service_name = "rules_service"
	version = "0.0.1"

	# Déclarer explicitement les dépendances
	service_dependencies.append("cash_service")
	service_dependencies.append("score_service")
	service_dependencies.append("upgrades_service")	

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("rules_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("rules_service", ["service", "init"], "Initialisation", "INFO")
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary[String, BaseService] = {}) -> void:

	if not is_initialized:
		Logger.log_message("rules_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("rules_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	
	# Récupérer les dépendances
	if dependencies.has("cash_service"):
		cash_service = dependencies["cash_service"]
	else:
		Logger.log_message("rules_service", ["service", "dependencies"], "Cash service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("score_service"):
		score_service = dependencies["score_service"]
	else:
		Logger.log_message("rules_service", ["service", "dependencies"], "Score service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("upgrades_service"):
		upgrades_service = dependencies["upgrades_service"]
	else:
		Logger.log_message("rules_service", ["service", "dependencies"], "Upgrades service non fourni dans les dépendances", "WARNING")

func start() -> void:
	if not is_initialized:
		Logger.log_message("rules_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("rules_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("rules_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au RulesService

## Réinitialise l'état du jeu pour une nouvelle partie
func reset_game_state() -> void:
	current_goal = upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
	remaining_attempts = rules_config["goal_attempts"][current_goal]
	Logger.log_message("rules_service", ["rules", "game"], "État du jeu réinitialisé: but=%d, essais=%d" % [current_goal, remaining_attempts], "INFO")

## Définit une règle spécifique
func set_rule(rule_name: String, value) -> void:
	if not rule_name in rules_config:
		Logger.log_message("rules_service", ["rules", "config"], "Tentative de définir une règle inexistante: %s" % rule_name, "WARNING")
		return
		
	var old_value = rules_config[rule_name]
	rules_config[rule_name] = value
	
	Logger.log_message("rules_service", ["rules", "config"], "Règle modifiée: %s = %s (ancienne valeur: %s)" % [rule_name, str(value), str(old_value)], "INFO")
	rule_changed.emit(rule_name, value)

## Configure le nombre d'essais pour chaque but
func set_goal_attempts(goal_number: int, attempts: int) -> void:
	if goal_number < 1 or goal_number > upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES):
		Logger.log_message("rules_service", ["rules", "config"], "Numéro de but invalide: %d" % goal_number, "WARNING")
		return
		
	if attempts < 1:
		Logger.log_message("rules_service", ["rules", "config"], "Nombre d'essais invalide: %d" % attempts, "WARNING")
		return
		
	rules_config["goal_attempts"][goal_number] = attempts
	
	# Si le but actuel est modifié, mettre à jour les essais restants
	if goal_number == current_goal:
		remaining_attempts = attempts
		
	Logger.log_message("rules_service", ["rules", "config"], "Essais pour le but %d définis à %d" % [goal_number, attempts], "INFO")
	rule_changed.emit("goal_attempts", rules_config["goal_attempts"])

## Résout un lancer de dé selon les règles actuelles
func resolve_throw(dice_value: int) -> ThrowResult:
	if not is_started:
		Logger.log_message("rules_service", ["rules", "gameplay"], "Tentative de résoudre un lancer avant le démarrage complet du service", "WARNING")
	
	if dice_value < 1 or dice_value > upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES):
		Logger.log_message("rules_service", ["rules", "gameplay"], "Valeur de dé invalide: %d" % dice_value, "WARNING")
		return ThrowResult.new()
		
	Logger.log_message("rules_service", ["rules", "gameplay"], "Résolution du lancer: dé=%d, but=%d, essais_restants=%d" % 
		[dice_value, current_goal, remaining_attempts], "DEBUG")
	
	# Résultat par défaut (échec)
	var result = ThrowResult.new()
	result.success = dice_value == current_goal
	result.new_goal = current_goal
	result.new_attempts = remaining_attempts - 1
	result.dice_value = dice_value
	
	# Vérifier si le lancer est un succès
	if result.success:
		# Calcul de la récompense basée sur la valeur du dé: (faces+1) - valeur
		result.reward = calculate_reward_from_dice_value(dice_value, upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)) 
		
		# Ajouter la récompense directement
		cash_service.add_cash(result.reward)
		
		# Vérifier si c'est un critique
		if randf() < rules_config["critical_chance"]:
			# Sauvegarder l'ancienne récompense pour calculer le bonus
			var old_reward = result.reward
			
			result.critical = true
			result.reward = int(result.reward * rules_config["critical_multiplier"])
			Logger.log_message("rules_service", ["rules", "gameplay"], "Critique! Récompense multipliée: %d" % result.reward, "INFO")
			
			# Ajouter le bonus de critique
			cash_service.add_cash(result.reward - old_reward)
		
		# Passer au but suivant (ou revenir à 6 si on était à 1)
		if current_goal > 1:
			result.new_goal = current_goal - 1
			result.new_attempts = rules_config["goal_attempts"][result.new_goal]
			
			# Signal au score service
			score_service.pass_goal(current_goal)
		else:
			# Séquence complète! Récompense bonus?
			var completion_bonus = calculate_completion_bonus()
			if completion_bonus > 0:
				cash_service.add_cash(completion_bonus)
				result.reward += completion_bonus
			
			# On vient de compléter la séquence entière! On repart au début
			result.new_goal = upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
			# Essais illimités pour le but 6 après avoir complété la séquence
			result.new_attempts = -1  # -1 signifie illimité
			
			# Signal au score service et émetttre le signal de séquence complète
			score_service.pass_goal(current_goal)
			sequence_completed.emit(result.reward)
			
			Logger.log_message("rules_service", ["rules", "gameplay"], "Séquence complète! Bonus: %d, Total: %d" %
				[completion_bonus, result.reward], "INFO")
		
		goal_achieved.emit(current_goal, result.reward)
		Logger.log_message("rules_service", ["rules", "gameplay"], "But %d atteint! Nouveau but: %d, Récompense: %d" % 
			[current_goal, result.new_goal, result.reward], "INFO")
	
	# Vérifier conditions de Beugnette (but + 1 quand plus d'essais)
	elif rules_config["beugnette_enabled"] and dice_value == current_goal + 1 and result.new_attempts <= 0:
		result.beugnette = true
		result.new_attempts = rules_config["goal_attempts"][current_goal]
		
		beugnette_triggered.emit(current_goal)
		Logger.log_message("rules_service", ["rules", "gameplay"], "Beugnette sur le but %d! Essais réinitialisés à %d" % 
			[current_goal, result.new_attempts], "INFO")
	
	# Vérifier conditions de Super Beugnette
	elif rules_config["super_beugnette_enabled"] and current_goal in rules_config["super_beugnette_goals"]:
		if dice_value == upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES) and current_goal == 1 and result.new_attempts <= 0:
			result.super_beugnette = true
			result.new_goal = upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES)
			result.new_attempts = rules_config["goal_attempts"][int(upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.NUMBER_OF_FACES))]
			
			super_beugnette_triggered.emit()
			Logger.log_message("rules_service", ["rules", "gameplay"], "Super Beugnette! Retour au but 6 avec %d essais" % 
				result.new_attempts, "INFO")
	
	# Mise à jour de l'état interne du service
	current_goal = result.new_goal
	remaining_attempts = result.new_attempts
	
	# Log du résultat final pour débogage
	Logger.log_message("rules_service", ["rules", "gameplay"], "Résultat final: %s" % result, "DEBUG")
	
	return result

## Calcule la récompense pour un but atteint (ancienne méthode, gardée pour compatibilité)
func calculate_reward(goal_number: int) -> int:
	var base_reward = rules_config["base_rewards"].get(goal_number, 1)
	var final_reward = int(base_reward * rules_config["reward_multiplier"])
	
	return max(1, final_reward) # Toujours au moins 1 de récompense

## Calcule la récompense en fonction de la valeur du dé: (faces+1) - valeur
func calculate_reward_from_dice_value(dice_value: int, faces: int) -> int:
	# Formule: (faces+1) - valeur
	var base_reward = (faces + 1) - dice_value
	
	# Application du multiplicateur global
	var final_reward = int(base_reward * rules_config["reward_multiplier"])
	
	return max(1, final_reward) # Toujours au moins 1 de récompense

## Calcule un bonus pour avoir complété une séquence entière
func calculate_completion_bonus() -> int:
	var base_bonus = 15  # Bonus de base pour une séquence
	var multiplier = rules_config["reward_multiplier"]
	
	return int(base_bonus * multiplier)

## Obtient l'état actuel de la partie
func get_game_state() -> Dictionary:
	return {
		"current_goal": current_goal,
		"remaining_attempts": remaining_attempts,
		"total_goals": rules_config["goal_attempts"].size(),
		"config": rules_config.duplicate()
	}

## Définit un multiplicateur de récompense
func set_reward_multiplier(multiplier: float) -> void:
	if multiplier <= 0:
		Logger.log_message("rules_service", ["rules", "config"], "Multiplicateur de récompense invalide: %f" % multiplier, "WARNING")
		return
		
	rules_config["reward_multiplier"] = multiplier
	Logger.log_message("rules_service", ["rules", "config"], "Multiplicateur de récompense défini à %f" % multiplier, "INFO")
	rule_changed.emit("reward_multiplier", multiplier)

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	reset_game_state()
	
	if not with_persistence:
		# Réinitialiser la configuration des règles aux valeurs par défaut
		rules_config = {
			"goal_attempts": {6: 6, 5: 5, 4: 4, 3: 3, 2: 2, 1: 1},
			"beugnette_enabled": true,
			"super_beugnette_enabled": true,
			"super_beugnette_goals": [1],
			"base_rewards": {6: 6, 5: 5, 4: 4, 3: 3, 2: 2, 1: 10},
			"reward_multiplier": 1.0,
			"critical_chance": 0.05,
			"critical_multiplier": 2.0
		}
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	save_data["rules_config"] = rules_config.duplicate()
	save_data["current_goal"] = current_goal
	save_data["remaining_attempts"] = remaining_attempts
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
		
	if data.has("rules_config") and data["rules_config"] is Dictionary:
		# Fusionner la configuration sauvegardée avec la configuration par défaut
		for key in data["rules_config"].keys():
			if rules_config.has(key):
				rules_config[key] = data["rules_config"][key]
	
	if data.has("current_goal"):
		current_goal = data["current_goal"]
		
	if data.has("remaining_attempts"):
		remaining_attempts = data["remaining_attempts"]
	
	return true
