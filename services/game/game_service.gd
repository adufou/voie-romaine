extends BaseService

class_name GameService

# Signaux
signal game_started
signal game_ended(stats)
signal game_paused(is_paused)
signal game_reset
signal game_state_changed(state)

# États du jeu
enum GameState {
	MENU,       # Dans les menus
	PLAYING,    # En cours de partie
	PAUSED,     # Jeu en pause
	GAME_OVER   # Partie terminée
}

# Dépendances aux autres services
var cash_service: CashService = null
var score_service: ScoreService = null
var dices_service: DicesService = null
var statistics_service: StatisticsService = null
var rules_service: RulesService = null
var upgrades_service: UpgradesService = null


# État actuel du jeu
var game_state: GameState = GameState.MENU
var is_auto_throw_enabled: bool = false
var auto_throw_timer: float = 0.0
var auto_throw_interval: float = 1.0  # Intervalle entre les lancers automatiques
var current_dice_count: int = 1
var current_table = null # Référence à la table de jeu

func _init():
	service_name = "game_service"
	version = "0.0.1"

	# Déclarer explicitement les dépendances
	service_dependencies.append("cash_service")
	service_dependencies.append("score_service")
	service_dependencies.append("dices_service")
	service_dependencies.append("statistics_service")
	service_dependencies.append("rules_service")
	service_dependencies.append("upgrades_service")

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("game_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("game_service", ["service", "init"], "Initialisation", "INFO")
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary[String, BaseService] = {}) -> void:
	if not is_initialized:
		Logger.log_message("game_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("game_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	
	# Récupérer les références aux services requis
	if dependencies.has("cash_service"):
		cash_service = dependencies["cash_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Cash service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("score_service"):
		score_service = dependencies["score_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Score service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("dices_service"):
		dices_service = dependencies["dices_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Dices service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("statistics_service"):
		statistics_service = dependencies["statistics_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Statistics service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("rules_service"):
		rules_service = dependencies["rules_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Rules service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("upgrades_service"):
		upgrades_service = dependencies["upgrades_service"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Upgrade service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("table"):
		current_table = dependencies["table"]
	else:
		Logger.log_message("game_service", ["service", "dependencies"], "Table non fournie dans les dépendances", "WARNING")

func start() -> void:
	# Diagnostic pour débugging
	Logger.log_message("game_service", ["debug"], "game_service.start() appelé", "DEBUG")
	
	if not is_initialized:
		Logger.log_message("game_service", ["debug"], "game_service non initialisé!", "DEBUG")
		Logger.log_message("game_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("game_service", ["debug"], "game_service déjà démarré!", "DEBUG")
		Logger.log_message("game_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("game_service", ["debug"], "game_service démarrage en cours...", "DEBUG")
	Logger.log_message("game_service", ["service", "start"], "Démarrage", "INFO")
	
	# Skip signal connection for now to debug
	Logger.log_message("game_service", ["debug"], "Skipping signal connections for troubleshooting", "DEBUG")
	# Connecter aux signaux des autres services - DISABLED FOR DEBUGGING
	#if rules_service:
	#	Logger.log_message("game_service", ["service", "start"], "Connexion aux signaux de rules_service", "INFO")
	#	# Vérifications pour éviter les erreurs
	#	if rules_service.has_signal("goal_achieved") and has_method("_on_goal_achieved"):
	#		rules_service.goal_achieved.connect(_on_goal_achieved)
	#	
	#	if rules_service.has_signal("beugnette_triggered") and has_method("_on_beugnette_triggered"):
	#		rules_service.beugnette_triggered.connect(_on_beugnette_triggered)
	#	
	#	if rules_service.has_signal("super_beugnette_triggered") and has_method("_on_super_beugnette_triggered"):
	#		rules_service.super_beugnette_triggered.connect(_on_super_beugnette_triggered)
	#
	#if upgrades_service:
	#	Logger.log_message("game_service", ["service", "start"], "Connexion aux signaux de upgrades_service", "INFO")
	#	if upgrades_service.has_signal("upgrade_purchased") and has_method("_on_upgrade_purchased"):
	#		upgrades_service.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Debug game state initialization
	Logger.log_message("game_service", ["debug"], "Avant _set_game_state", "DEBUG")
	
	# Initialiser l'état du jeu - simple version for debugging
	game_state = GameState.MENU
	Logger.log_message("game_service", ["game", "state"], "Début en état MENU", "INFO")
	
	Logger.log_message("game_service", ["debug"], "Après _set_game_state simplifié", "DEBUG")
	
	is_started = true
	started.emit()

func _process(delta: float) -> void:
	if not is_started or game_state != GameState.PLAYING:
		return
	
	# Gestion du lancer automatique de dés
	if is_auto_throw_enabled:
		auto_throw_timer += delta
		
		if auto_throw_timer >= auto_throw_interval:
			auto_throw_timer = 0.0
			throw_dice()

# Méthodes spécifiques au GameService

## Change l'état du jeu
func _set_game_state(new_state: GameState) -> void:
	if game_state == new_state:
		return
		
	var old_state = game_state
	game_state = new_state
	game_state_changed.emit(new_state)
	Logger.log_message("game_service", ["game", "state"], "État du jeu changé: %d -> %d" % [old_state, new_state], "INFO")


## Démarre une nouvelle partie
func start_game() -> void:
	if not is_started:
		Logger.log_message("game_service", ["game", "gameplay"], "Tentative de démarrer une partie avant le démarrage complet du service", "WARNING")
		return
	
	Logger.log_message("game_service", ["game", "gameplay"], "Démarrage d'une nouvelle partie", "INFO")
	
	# Réinitialiser l'état des services
	if rules_service:
		rules_service.reset_game_state()
	
	# Créer les dés initiaux
	reset_dice()
	
	# Démarrer la partie
	_set_game_state(GameState.PLAYING)
	game_started.emit()
	
	# Enregistrer une partie jouée dans les statistiques
	if statistics_service:
		statistics_service.record_game_played()

## Met en pause ou reprend la partie
func toggle_pause() -> void:
	if game_state == GameState.PLAYING:
		_set_game_state(GameState.PAUSED)
		game_paused.emit(true)
	elif game_state == GameState.PAUSED:
		_set_game_state(GameState.PLAYING)
		game_paused.emit(false)

## Termine la partie et affiche les résultats
func end_game() -> void:
	if game_state != GameState.PLAYING and game_state != GameState.PAUSED:
		return
	
	Logger.log_message("game_service", ["game", "gameplay"], "Fin de partie", "INFO")
	
	# Collecter les statistiques de fin de partie
	var stats = {
		"score": score_service.get_score() if score_service else 0,
		"cash": cash_service.get_cash() if cash_service else 0,
		"dice_throws": statistics_service.get_statistic("dice", "total_throws") if statistics_service else 0,
		"goals_reached": statistics_service.get_statistic("achievements", "goals_reached") if statistics_service else 0
	}
	
	_set_game_state(GameState.GAME_OVER)
	game_ended.emit(stats)

## Réinitialise les dés en fonction des améliorations
func reset_dice() -> void:
	if not dices_service or not current_table:
		Logger.log_message("game_service", ["game", "dice"], "Impossible de réinitialiser les dés: services requis manquants", "WARNING")
		return
	
	# Supprimer tous les dés existants
	for dice in dices_service.get_dices():
		dices_service.remove_dice(dice)
	
	# Déterminer le nombre de dés en fonction des améliorations
	current_dice_count = 1
	if upgrades_service and upgrades_service.is_upgrade_unlocked(UpgradeConstants.UpgradeType.MULTI_DICE):
		current_dice_count += int(upgrades_service.get_upgrade_effect(UpgradeConstants.UpgradeType.MULTI_DICE))
	
	# Créer les nouveaux dés
	for i in range(current_dice_count):
		dices_service.add_dice()
	
	Logger.log_message("game_service", ["game", "dice"], "%d dés créés" % current_dice_count, "DEBUG")

## Lance tous les dés disponibles
func throw_dice() -> void:
	if game_state != GameState.PLAYING:
		return
	
	if not dices_service or not rules_service:
		Logger.log_message("game_service", ["game", "gameplay"], "Impossible de lancer les dés: services requis manquants", "WARNING")
		return
	
	Logger.log_message("game_service", ["game", "gameplay"], "Lancement des dés", "DEBUG")
	
	# Lancer tous les dés
	dices_service.throw_dices()
	
	# Attendre que les dés s'arrêtent de rouler et récupérer les valeurs
	await get_tree().create_timer(1.0).timeout
	
	var dice_values = dices_service.get_dice_values()
	if dice_values.is_empty():
		return
	
	# Pour l'instant, on ne traite que le premier dé (extension future pour les multi-dés)
	var result = rules_service.resolve_throw(dice_values[0])
	
	# Traiter le résultat
	if "success" in result and result.success:
		# Ajouter le score
		if score_service and "reward" in result:
			score_service.add_score(result.reward)
		
		# Ajouter l'or
		if cash_service and "reward" in result:
			cash_service.add_cash(result.reward)
			
			if statistics_service:
				statistics_service.record_gold_earned(result.reward)
		
		# Enregistrer le succès dans les statistiques
		if statistics_service:
			statistics_service.record_dice_success(true, false, false)
			statistics_service.record_goal_reached()
	
	# Enregistrer une beugnette dans les statistiques
	if "beugnette" in result and result.beugnette and statistics_service:
		statistics_service.record_dice_success(false, true, false)
	
	# Enregistrer une super beugnette dans les statistiques
	if "super_beugnette" in result and result.super_beugnette and statistics_service:
		statistics_service.record_dice_success(false, false, true)

## Active/désactive le lancer automatique de dés
func toggle_auto_throw(enabled: bool = true) -> void:
	# Vérifier si l'auto-throw est débloqué
	if enabled and upgrades_service and not upgrades_service.is_upgrade_unlocked(UpgradeConstants.UpgradeType.AUTO_THROW):
		Logger.log_message("game_service", ["game", "gameplay"], "Tentative d'activer le lancer automatique alors qu'il n'est pas débloqué", "WARNING")
		return
	
	is_auto_throw_enabled = enabled
	auto_throw_timer = 0.0
	
	Logger.log_message("game_service", ["game", "gameplay"], "Lancer automatique %s" % ("activé" if enabled else "désactivé"), "INFO")

## Définit l'intervalle entre les lancers automatiques
func set_auto_throw_interval(interval: float) -> void:
	if interval <= 0:
		Logger.log_message("game_service", ["game", "config"], "Intervalle de lancer automatique invalide: %f" % interval, "WARNING")
		return
	
	auto_throw_interval = interval
	Logger.log_message("game_service", ["game", "config"], "Intervalle de lancer automatique défini à %f secondes" % interval, "DEBUG")

# Gestionnaires de signaux des autres services
func _on_goal_achieved(goal_number: int, reward: int) -> void:
	Logger.log_message("game_service", ["game", "callback"], "But %d atteint, récompense: %d" % [goal_number, reward], "DEBUG")
	
	# Extensions futures possibles ici

func _on_beugnette_triggered(goal_number: int) -> void:
	Logger.log_message("game_service", ["game", "callback"], "Beugnette sur le but %d" % goal_number, "DEBUG")
	
	# Extensions futures possibles ici

func _on_super_beugnette_triggered() -> void:
	Logger.log_message("game_service", ["game", "callback"], "Super Beugnette déclenchée", "DEBUG")
	
	# Extensions futures possibles ici

func _on_upgrade_purchased(upgrade_type: UpgradeConstants.UpgradeType, new_level: int) -> void:
	Logger.log_message("game_service", ["game", "callback"], "Amélioration %s achetée (niveau %d)" % [upgrade_type, new_level], "DEBUG")
	
	# Appliquer les effets des améliorations
	match upgrade_type:
		UpgradeConstants.UpgradeType.THROW_SPEED:
			# Augmenter la vitesse de lancer (réduire l'intervalle)
			if upgrades_service:
				var speed_boost = upgrades_service.get_upgrade_effect(upgrade_type)
				set_auto_throw_interval(max(0.1, 1.0 / (1.0 + speed_boost)))
		
		UpgradeConstants.UpgradeType.MULTI_DICE:
			# Mettre à jour le nombre de dés
			reset_dice()
		
		UpgradeConstants.UpgradeType.CRITICAL_CHANCE:
			# Mettre à jour la chance critique dans les règles
			if rules_service and upgrades_service:
				var crit_chance = upgrades_service.get_upgrade_effect(upgrade_type)
				rules_service.set_rule("critical_chance", crit_chance)
		
		UpgradeConstants.UpgradeType.REWARD_MULTIPLIER:
			# Mettre à jour le multiplicateur de récompense dans les règles
			if rules_service and upgrades_service:
				var multiplier = 1.0 + upgrades_service.get_upgrade_effect(upgrade_type)
				rules_service.set_rule("reward_multiplier", multiplier)

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	_set_game_state(GameState.MENU)
	is_auto_throw_enabled = false
	auto_throw_timer = 0.0
	auto_throw_interval = 1.0
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	save_data["game_state"] = game_state
	save_data["is_auto_throw_enabled"] = is_auto_throw_enabled
	save_data["auto_throw_interval"] = auto_throw_interval
	save_data["current_dice_count"] = current_dice_count
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
		
	if data.has("game_state"):
		_set_game_state(data["game_state"])
		
	if data.has("is_auto_throw_enabled"):
		is_auto_throw_enabled = data["is_auto_throw_enabled"]
		
	if data.has("auto_throw_interval"):
		auto_throw_interval = data["auto_throw_interval"]
		
	if data.has("current_dice_count"):
		current_dice_count = data["current_dice_count"]
	
	return true
