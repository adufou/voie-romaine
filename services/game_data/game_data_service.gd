extends BaseService

class_name GameDataService

# Signaux spécifiques aux données de jeu
signal statistic_changed(statistic_name, new_value)

# Dépendances de services
var cash_service: CashService = null
var score_service: ScoreService = null
var dice_service: DiceService = null

# Statistiques organisées par catégories
var _statistics: Dictionary = {
    "game": {
        "total_games_played": 0,
        "total_time_played": 0.0,  # en secondes
        "best_score": 0,
    },
    "dice": {
        "total_throws": 0,
        "successful_throws": 0,
        "beugnettes": 0,
        "super_beugnettes": 0,
        "perfect_games": 0,
    },
    "achievements": {
        "goals_reached": 0,
        "voie_romaine_completed": 0,
    },
    "economy": {
        "total_gold_earned": 0,
        "total_gold_spent": 0,
        "upgrades_purchased": 0,
    }
}

# Suivi du temps de jeu
var _play_time_tracker: float = 0.0

func _init():
    service_name = "game_data_service"
    version = "0.0.1"

# Surcharge des méthodes de BaseService
func initialize() -> void:
    if is_initialized:
        log_message(["service", "init"], "Service déjà initialisé", "WARNING")
        return
    
    log_message(["service", "init"], "Initialisation", "INFO")
    
    # Réinitialisation des statistiques à leurs valeurs par défaut
    _reset_statistics()
    
    is_initialized = true
    initialized.emit()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
    if not is_initialized:
        log_message(["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
        return
    
    log_message(["service", "dependencies"], "Configuration des dépendances", "INFO")
    
    # Récupération des références aux services requis
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

func start() -> void:
    if not is_initialized:
        log_message(["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
        return
        
    if is_started:
        log_message(["service", "start"], "Service déjà démarré", "WARNING")
        return
    
    log_message(["service", "start"], "Démarrage", "INFO")
    
    # Connexion aux signaux des autres services pour suivre les statistiques
    if cash_service:
        # Connecter aux transactions pour suivre les statistiques économiques
        cash_service.cash_changed.connect(_on_cash_changed)
    
    if score_service:
        # Connecter aux changements de score pour suivre le meilleur score
        score_service.score_changed.connect(_on_score_changed)
    
    if dice_service:
        # Connecter aux lancers de dés pour suivre les statistiques de dés
        dice_service.dice_thrown.connect(_on_dice_thrown)
    
    is_started = true
    started.emit()

# Gestionnaires de signaux depuis d'autres services
func _on_cash_changed(new_cash: int) -> void:
    # Ce gestionnaire observe uniquement les changements, mais nous utiliserons
    # les méthodes dédiées pour suivre précisément l'or gagné vs dépensé
    pass

func _on_score_changed(new_score: int) -> void:
    # Mise à jour du meilleur score si nécessaire
    if new_score > get_statistic("game", "best_score"):
        set_statistic("game", "best_score", new_score)
        log_message(["statistics", "score"], "Nouveau meilleur score: %d" % new_score, "INFO")

func _on_dice_thrown() -> void:
    increment_statistic("dice", "total_throws")

# Gestion des statistiques
func get_statistic(category: String, name: String) -> Variant:
    if not _statistics.has(category) or not _statistics[category].has(name):
        log_message(["statistics"], "Statistique demandée inexistante: %s.%s" % [category, name], "WARNING")
        return 0
        
    return _statistics[category][name]

func set_statistic(category: String, name: String, value: Variant) -> void:
    if not _statistics.has(category):
        log_message(["statistics"], "Catégorie de statistique inexistante: %s" % category, "WARNING")
        return
        
    if not _statistics[category].has(name):
        log_message(["statistics"], "Statistique inexistante dans la catégorie %s: %s" % [category, name], "WARNING")
        return
        
    _statistics[category][name] = value
    statistic_changed.emit(category + "." + name, value)
    log_message(["statistics"], "Statistique %s.%s mise à jour: %s" % [category, name, str(value)], "DEBUG")

func increment_statistic(category: String, name: String, amount: int = 1) -> void:
    if not _statistics.has(category) or not _statistics[category].has(name):
        log_message(["statistics"], "Statistique à incrémenter inexistante: %s.%s" % [category, name], "WARNING")
        return
        
    var current_value = _statistics[category][name]
    if typeof(current_value) != TYPE_INT and typeof(current_value) != TYPE_FLOAT:
        log_message(["statistics"], "Tentative d'incrémenter une statistique non numérique: %s.%s" % [category, name], "WARNING")
        return
        
    _statistics[category][name] += amount
    statistic_changed.emit(category + "." + name, _statistics[category][name])
    log_message(["statistics"], "Statistique %s.%s incrémentée de %d: nouvelle valeur %s" % 
        [category, name, amount, str(_statistics[category][name])], "DEBUG")

func get_all_statistics() -> Dictionary:
    return _statistics.duplicate(true)

# Méthodes de suivi des événements de jeu
func record_gold_earned(amount: int) -> void:
    increment_statistic("economy", "total_gold_earned", amount)

func record_gold_spent(amount: int) -> void:
    increment_statistic("economy", "total_gold_spent", amount)

func record_upgrade_purchased() -> void:
    increment_statistic("economy", "upgrades_purchased")

func record_dice_success(is_successful: bool, is_beugnette: bool = false, is_super_beugnette: bool = false) -> void:
    if is_successful:
        increment_statistic("dice", "successful_throws")
    
    if is_beugnette:
        increment_statistic("dice", "beugnettes")
        
    if is_super_beugnette:
        increment_statistic("dice", "super_beugnettes")

func record_goal_reached() -> void:
    increment_statistic("achievements", "goals_reached")

func record_voie_romaine_completed(perfect: bool = false) -> void:
    increment_statistic("achievements", "voie_romaine_completed")
    
    if perfect:
        increment_statistic("dice", "perfect_games")

func record_game_played() -> void:
    increment_statistic("game", "total_games_played")

# Suivi du temps
func _process(delta: float) -> void:
    if is_started:
        _play_time_tracker += delta
        
        # Mettre à jour le temps de jeu total toutes les 10 secondes
        if _play_time_tracker >= 10.0:
            increment_statistic("game", "total_time_played", _play_time_tracker)
            _play_time_tracker = 0.0

# Méthodes utilitaires
func _reset_statistics() -> void:
    # Réinitialiser toutes les statistiques à leurs valeurs par défaut
    for category in _statistics.keys():
        for stat_name in _statistics[category].keys():
            var default_value = 0
            if typeof(_statistics[category][stat_name]) == TYPE_FLOAT:
                default_value = 0.0
            _statistics[category][stat_name] = default_value

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
    if not with_persistence:
        _reset_statistics()
    
    super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
    var save_data = super.get_save_data()
    save_data["statistics"] = _statistics.duplicate(true)
    return save_data

func load_save_data(data: Dictionary) -> bool:
    var success = super.load_save_data(data)
    if not success:
        return false
        
    if data.has("statistics") and data["statistics"] is Dictionary:
        # Fusionner les statistiques sauvegardées avec le template existant
        # pour éviter les problèmes si la structure a changé
        for category in data["statistics"].keys():
            if _statistics.has(category):
                for stat_name in data["statistics"][category].keys():
                    if _statistics[category].has(stat_name):
                        _statistics[category][stat_name] = data["statistics"][category][stat_name]
    
    return true
