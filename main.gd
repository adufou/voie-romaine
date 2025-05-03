extends Node

@export var table_scene: PackedScene
@export var hud_scene: PackedScene

var table
var hud

func _ready() -> void:
	Logger.add_filter("dice", Logger.LogLevel.DEBUG)
	
	# Connect to loading completion
	Logger.log_message("main", ["system", "loading"], "Connexion au signal loading_completed...", "INFO")
	%LoadingScreen.loading_completed.connect(_on_loading_completed)
	Logger.log_message("main", ["system", "loading"], "Signal connecté avec succès", "INFO")

func _on_loading_completed() -> void:
	Logger.log_message("main", ["system", "loading"], "Signal loading_completed reçu!", "INFO")
	# Remove loading screen
	%LoadingScreen.loading_completed.disconnect(_on_loading_completed)
	%LoadingScreen.queue_free()
	
	# Now initialize game components
	_initialize_game()

func _initialize_game() -> void:
	# Récupérer la référence au table_service
	var table_service = Services.table_service
	if table_service:
		# Configurer la scène de table dans le service
		table_service.table_scene = table_scene
		
		# Créer la table via le service
		table_service.create_table()
		table = table_service.get_table()
		
		# Ajouter la table à la scène principale
		if table:
			add_child(table)
			Logger.log_message("main", ["system", "table"], "Table ajoutée à la scène principale", "INFO")
		else:
			Logger.log_message("main", ["system", "table"], "Impossible d'obtenir la table du service", "ERROR")
	else:
		Logger.log_message("main", ["system", "table"], "Service de table non trouvé", "ERROR")
		# Fallback au cas où le service n'est pas disponible
		table = table_scene.instantiate()
		add_child(table)
	
	hud = hud_scene.instantiate()
	add_child(hud)
	
	# Additional game initialization can happen here
	Logger.log_message("main", ["system", "loading"], "Game fully initialized!", "INFO")
