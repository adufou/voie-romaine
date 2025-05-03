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
var dice_service: DiceService = null
var statistics_service = null # StatisticsService
var rules_service: RulesService = null
var upgrade_service: UpgradeService = null

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

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		log_message(["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	log_message(["service", "init"], "Initialisation", "INFO")
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
	if not is_initialized:
		log_message(["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	log_message(["service", "dependencies"], "Configuration des dépendances", "INFO")
	
	# Récupérer les références aux services requis
	if dependencies.has("cash_service"):
		cash_service = dependencies["cash_service"]
	else:
		log_message(["service", "dependencies"], "Cash service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("score_service"):
		score_service = dependencies["score_service"]
	else:
		log_message(["service", "dependencies"], "Score service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("dice_service"):
		dice_service = dependencies["dice_service"]
	else:
		log_message(["service", "dependencies"], "Dice service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("statistics_service"):
		statistics_service = dependencies["statistics_service"]
	else:
		log_message(["service", "dependencies"], "Statistics service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("rules_service"):
		rules_service = dependencies["rules_service"]
	else:
		log_message(["service", "dependencies"], "Rules service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("upgrade_service"):
		upgrade_service = dependencies["upgrade_service"]
	else:
		log_message(["service", "dependencies"], "Upgrade service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("table"):
		current_table = dependencies["table"]
	else:
		log_message(["service", "dependencies"], "Table non fournie dans les dépendances", "WARNING")

func start() -> void:
	if not is_initialized:
		log_message(["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		log_message(["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	log_message(["service", "start"], "Démarrage", "INFO")
	
	# Connecter aux signaux des autres services
	if rules_service:
		rules_service.goal_achieved.connect(_on_goal_achieved)
		rules_service.beugnette_triggered.connect(_on_beugnette_triggered)
		rules_service.super_beugnette_triggered.connect(_on_super_beugnette_triggered)
	
	if upgrade_service:
		upgrade_service.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Initialiser l'état du jeu
	_set_game_state(GameState.MENU)
	
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
	
	log_message(["game", "state"], "État du jeu changé: %s -> %s" % [old_state, new_state], "INFO")
	game_state_changed.emit(new_state)

## Démarre une nouvelle partie
func start_game() -> void:
	if not is_started:
		log_message(["game", "gameplay"], "Tentative de démarrer une partie avant le démarrage complet du service", "WARNING")
		return
	
	log_message(["game", "gameplay"], "Démarrage d'une nouvelle partie", "INFO")
	
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
	
	log_message(["game", "gameplay"], "Fin de partie", "INFO")
	
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
	if not dice_service or not current_table:
		log_message(["game", "dice"], "Impossible de réinitialiser les dés: services requis manquants", "WARNING")
		return
	
	# Supprimer tous les dés existants
	for dice in dice_service.get_dices():
		dice_service.remove_dice(dice)
	
	# Déterminer le nombre de dés en fonction des améliorations
	current_dice_count = 1
	if upgrade_service and upgrade_service.is_upgrade_unlocked("multi_dice"):
		current_dice_count += int(upgrade_service.get_upgrade_effect("multi_dice"))
	
	# Créer les nouveaux dés
	for i in range(current_dice_count):
		dice_service.add_dice()
	
	log_message(["game", "dice"], "%d dés créés" % current_dice_count, "DEBUG")

## Lance tous les dés disponibles
func throw_dice() -> void:
	if game_state != GameState.PLAYING:
		return
	
	if not dice_service or not rules_service:
		log_message(["game", "gameplay"], "Impossible de lancer les dés: services requis manquants", "WARNING")
		return
	
	log_message(["game", "gameplay"], "Lancement des dés", "DEBUG")
	
	# Lancer tous les dés
	dice_service.throw_dices()
	
	# Attendre que les dés s'arrêtent de rouler et récupérer les valeurs
	await get_tree().create_timer(1.0).timeout
	
	var dice_values = dice_service.get_dice_values()
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
	if enabled and upgrade_service and not upgrade_service.is_upgrade_unlocked("auto_throw"):
		log_message(["game", "gameplay"], "Tentative d'activer le lancer automatique alors qu'il n'est pas débloqué", "WARNING")
		return
	
	is_auto_throw_enabled = enabled
	auto_throw_timer = 0.0
	
	log_message(["game", "gameplay"], "Lancer automatique %s" % ("activé" if enabled else "désactivé"), "INFO")

## Définit l'intervalle entre les lancers automatiques
func set_auto_throw_interval(interval: float) -> void:
	if interval <= 0:
		log_message(["game", "config"], "Intervalle de lancer automatique invalide: %f" % interval, "WARNING")
		return
	
	auto_throw_interval = interval
	log_message(["game", "config"], "Intervalle de lancer automatique défini à %f secondes" % interval, "DEBUG")

# Gestionnaires de signaux des autres services
func _on_goal_achieved(goal_number: int, reward: int) -> void:
	log_message(["game", "callback"], "But %d atteint, récompense: %d" % [goal_number, reward], "DEBUG")
	
	# Extensions futures possibles ici

func _on_beugnette_triggered(goal_number: int) -> void:
	log_message(["game", "callback"], "Beugnette sur le but %d" % goal_number, "DEBUG")
	
	# Extensions futures possibles ici

func _on_super_beugnette_triggered() -> void:
	log_message(["game", "callback"], "Super Beugnette déclenchée", "DEBUG")
	
	# Extensions futures possibles ici

func _on_upgrade_purchased(upgrade_id: String, new_level: int) -> void:
	log_message(["game", "callback"], "Amélioration %s achetée (niveau %d)" % [upgrade_id, new_level], "DEBUG")
	
	# Appliquer les effets des améliorations
	match upgrade_id:
		"throw_speed":
			# Augmenter la vitesse de lancer (réduire l'intervalle)
			if upgrade_service:
				var speed_boost = upgrade_service.get_upgrade_effect(upgrade_id)
				set_auto_throw_interval(max(0.1, 1.0 / (1.0 + speed_boost)))
		
		"multi_dice":
			# Mettre à jour le nombre de dés
			reset_dice()
		
		"critical_chance":
			# Mettre à jour la chance critique dans les règles
			if rules_service and upgrade_service:
				var crit_chance = upgrade_service.get_upgrade_effect(upgrade_id)
				rules_service.set_rule("critical_chance", crit_chance)
		
		"reward_multiplier":
			# Mettre à jour le multiplicateur de récompense dans les règles
			if rules_service and upgrade_service:
				var multiplier = 1.0 + upgrade_service.get_upgrade_effect(upgrade_id)
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
