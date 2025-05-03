extends BaseService

class_name ScoreService

# Signaux spécifiques au score
signal score_changed(new_score)

# Données
var _score: int = 0:
	set(new_value):
		_score = new_value
		score_changed.emit(_score)

func _init():
	service_name = "score_service"
	version = "0.0.1"

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("score_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("score_service", ["service", "init"], "Initialisation", "INFO")
	
	# Initialisation du score à 0
	_score = 0
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(_dependencies: Dictionary = {}) -> void:
	if not is_initialized:
		Logger.log_message("score_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("score_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	# Pas de dépendances nécessaires pour ce service

func start() -> void:
	if not is_initialized:
		Logger.log_message("score_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("score_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("score_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service Score
func pass_goal(goal: int) -> void:
	if not is_started:
		Logger.log_message("score_service", ["score", "gameplay"], "Tentative d'ajouter un score avant le démarrage complet du service", "WARNING")
	
	if goal < 1 or goal > 6:
		Logger.log_message("score_service", ["score", "gameplay"], "Valeur de goal invalide: %d (doit être entre 1 et 6)" % goal, "WARNING")
		return
		
	var scored = 7 - goal
	_score += scored
	Logger.log_message("score_service", ["score", "gameplay"], "Passage du goal %d, ajout de %d points, nouveau score: %d" % [goal, scored, _score], "DEBUG")

func add_score(points: int) -> void:
	if not is_started:
		Logger.log_message("score_service", ["score", "gameplay"], "Tentative d'ajouter un score avant le démarrage complet du service", "WARNING")
	
	if points <= 0:
		Logger.log_message("score_service", ["score", "gameplay"], "Tentative d'ajouter un nombre de points non positif: %d" % points, "WARNING")
		return
		
	_score += points
	Logger.log_message("score_service", ["score", "gameplay"], "Ajout de %d points, nouveau score: %d" % [points, _score], "DEBUG")

func get_score() -> int:
	return _score

func set_score(new_score: int) -> void:
	if new_score < 0:
		Logger.log_message("score_service", ["score", "setting"], "Tentative de définir un score négatif: %d" % new_score, "WARNING")
		new_score = 0
		
	_score = new_score

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	if not with_persistence:
		_score = 0
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	save_data["score"] = _score
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
		
	if data.has("score"):
		_score = data["score"]
		
	return true
