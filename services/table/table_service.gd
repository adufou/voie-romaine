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
	
	# Ne pas créer la table automatiquement - c'est main.gd qui le fera
	# avec la scène de table correcte
	Logger.log_message("table_service", ["service", "start"], "La table sera créée explicitement par main.gd plus tard", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service de la table
func create_table() -> void:
	if table_node:
		Logger.log_message("table_service", ["table", "creation"], "La table existe déjà", "WARNING")
		return
	
	if table_scene:
		# Si une scène de table a été fournie, l'instancier
		Logger.log_message("table_service", ["table", "creation"], "Instanciation de la scène de table...", "INFO")
		table_node = table_scene.instantiate()
		
		# Log des propriétés importantes de la table
		if table_node:
			Logger.log_message("table_service", ["table", "creation"], "Table créée à partir de la scène fournie", "INFO")
			Logger.log_message("table_service", ["table", "debug"], "Type de table: %s" % table_node.get_class(), "INFO")
			Logger.log_message("table_service", ["table", "debug"], "Visibilité de la table: %s" % table_node.visible, "INFO")
			
			# Si c'est un Control, log des propriétés spécifiques
			if table_node is Control:
				Logger.log_message("table_service", ["table", "debug"], "La table est un noeud Control", "INFO")
				Logger.log_message("table_service", ["table", "debug"], "Anchors/Margins: %s, %s, %s, %s" % [
					table_node.anchor_left, table_node.anchor_top, table_node.anchor_right, table_node.anchor_bottom
				], "INFO")
				
				# Forcer certaines propriétés pour s'assurer de la visibilité
				table_node.visible = true 
		else:
			Logger.log_message("table_service", ["table", "creation"], "Erreur lors de l'instanciation de la scène de table", "ERROR")
	else:
		# Sinon, créer une table par défaut (Node2D)
		table_node = Node2D.new()
		table_node.name = "DefaultTable"
		
		# Ajouter une propriété size pour éviter les erreurs dans le service de dés
		table_node.set_meta("size", Vector2(1000, 600))
		
		Logger.log_message("table_service", ["table", "creation"], "Table par défaut créée", "WARNING")
	
	# Émettre le signal dans tous les cas
	Logger.log_message("table_service", ["table", "signal"], "Émission du signal table_created", "INFO")
	table_created.emit(table_node)

func get_table() -> Node:
	if not table_node:
		# Si table_scene n'est pas configurée, ne pas créer la table automatiquement
		if table_scene:
			Logger.log_message("table_service", ["table", "access"], "Tentative d'accès à la table avant sa création, création avec la scène configurée", "WARNING")
			# Créer la table avec la scène configurée
			create_table()
		else:
			Logger.log_message("table_service", ["table", "access"], "Tentative d'accès à la table avant sa création, mais aucune scène configurée", "WARNING")
			# Retourner null pour indiquer qu'aucune table n'est disponible
			return null
	
	return table_node
