extends BaseService

class_name TableService

@export var table_scene: PackedScene  # Scène de la table à instancier

# Référence à la table de jeu
var table_node: Node = null

signal table_created(table)

func _init():
	service_name = "table_service"
	version = "0.0.1"

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("table_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("table_service", ["service", "init"], "Initialisation", "INFO")
	
	# Vérification que la scène de table est correctement assignée
	if not table_scene:
		Logger.log_message("table_service", ["table", "resources"], "Scène de table non assignée, une table par défaut sera créée au démarrage", "WARNING")
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary[String, BaseService] = {}) -> void:
	if not is_initialized:
		Logger.log_message("table_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("table_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")

func start() -> void:
	if not is_initialized:
		Logger.log_message("table_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("table_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("table_service", ["service", "start"], "Démarrage", "INFO")
	
	# Création de la table à ce moment
	create_table()
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service de la table
func create_table() -> void:
	if table_node:
		Logger.log_message("table_service", ["table", "creation"], "La table existe déjà", "WARNING")
		return
	
	if table_scene:
		# Si une scène de table a été fournie, l'instancier
		table_node = table_scene.instantiate()
		Logger.log_message("table_service", ["table", "creation"], "Table créée à partir de la scène fournie", "INFO")
	else:
		# Sinon, créer une table par défaut (Node2D)
		table_node = Node2D.new()
		table_node.name = "DefaultTable"
		
		# Ajouter une propriété size pour éviter les erreurs dans le service de dés
		table_node.set_meta("size", Vector2(1000, 600))
		
		Logger.log_message("table_service", ["table", "creation"], "Table par défaut créée", "WARNING")
	
	# Émettre le signal dans tous les cas
	table_created.emit(table_node)

func get_table() -> Node:
	if not table_node:
		Logger.log_message("table_service", ["table", "access"], "Tentative d'accès à la table avant sa création, création forcée", "WARNING")
		# Créer la table si elle n'existe pas encore
		create_table()
	
	return table_node
