extends BaseService

class_name CashService

# Signaux spécifiques au cash
signal cash_changed(new_cash)

# Données
var _cash: int = 0:
	set(new_value):
		_cash = new_value
		cash_changed.emit(_cash)

func _init():
	service_name = "cash_service"
	version = "0.0.1"

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("cash_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("cash_service", ["service", "init"], "Initialisation", "INFO")
	
	# Initialisation du cash à 0
	_cash = 0
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary[String, BaseService] = {}) -> void:
	if not is_initialized:
		Logger.log_message("cash_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("cash_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	# Pas de dépendances nécessaires pour ce service

func start() -> void:
	if not is_initialized:
		Logger.log_message("cash_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("cash_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("cash_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service Cash
func add_cash(added_cash: int) -> void:
	if not is_started:
		Logger.log_message("cash_service", ["cash", "currency"], "Tentative d'ajouter du cash avant le démarrage complet du service", "WARNING")
	
	if added_cash <= 0:
		Logger.log_message("cash_service", ["cash", "currency"], "Tentative d'ajouter une valeur de cash non positive: %d" % added_cash, "WARNING")
		return
		
	_cash += added_cash
	Logger.log_message("cash_service", ["cash", "currency"], "Ajout de %d cash, nouveau total: %d" % [added_cash, _cash], "DEBUG")

func use_cash(quantity: int) -> bool:
	if not is_started:
		Logger.log_message("cash_service", ["cash", "transaction"], "Tentative d'utiliser du cash avant le démarrage complet du service", "WARNING")
	
	if quantity <= 0:
		Logger.log_message("cash_service", ["cash", "transaction"], "Tentative d'utiliser une quantité de cash non positive: %d" % quantity, "WARNING")
		return false
		
	if _cash < quantity:
		Logger.log_message("cash_service", ["cash", "transaction"], "Cash insuffisant: %d demandé, %d disponible" % [quantity, _cash], "INFO")
		return false
		
	_cash -= quantity
	Logger.log_message("cash_service", ["cash", "transaction"], "Utilisation de %d cash, nouveau total: %d" % [quantity, _cash], "DEBUG")
	return true

func has_enough(quantity: int) -> bool:
	return _cash >= quantity

func get_cash() -> int:
	return _cash

func set_cash(new_cash: int) -> void:
	if new_cash < 0:
		Logger.log_message("cash_service", ["cash", "setting"], "Tentative de définir un cash négatif: %d" % new_cash, "WARNING")
		new_cash = 0
		
	_cash = new_cash

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	if not with_persistence:
		_cash = 0
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	save_data["cash"] = _cash
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
		
	if data.has("cash"):
		_cash = data["cash"]
		
	return true
