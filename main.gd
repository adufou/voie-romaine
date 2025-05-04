extends Node

@export var table_scene: PackedScene
@export var hud_scene: PackedScene

var table
var hud

func _ready() -> void:
	#Logger.add_filter("dice", Logger.LogLevel.DEBUG)
	
	# S'assurer que le noeud LoadingScreen est prêt avant de connecter le signal
	call_deferred("_connect_loading_screen_signal")

# Fonction appelée après que tous les noeuds soient prêts
func _connect_loading_screen_signal() -> void:
	Logger.log_message("main", ["system", "loading"], "Connexion au signal loading_completed (deferred)...", "INFO")
	
	if has_node("%LoadingScreen"):
		var loading_screen = %LoadingScreen
		
		# Vérifier si le signal existe dans le noeud
		var signals = loading_screen.get_signal_list()
		var has_loading_completed = false
		for s in signals:
			if s["name"] == "loading_completed":
				has_loading_completed = true
				break
		
		if has_loading_completed:
			# Déconnecter d'abord toute connexion existante
			if loading_screen.loading_completed.is_connected(_on_loading_completed):
				loading_screen.loading_completed.disconnect(_on_loading_completed)
			
			# Connecter le signal avec un identifiant unique
			loading_screen.loading_completed.connect(_on_loading_completed)
			Logger.log_message("main", ["system", "loading"], "Signal connecté avec succès", "INFO")
		else:
			Logger.log_message("main", ["system", "loading"], "Le signal loading_completed n'existe pas dans le noeud LoadingScreen!", "ERROR")
	else:
		Logger.log_message("main", ["system", "loading"], "LoadingScreen introuvable pour connecter le signal!", "ERROR")

func _on_loading_completed() -> void:
	Logger.log_message("main", ["system", "loading"], "Signal loading_completed reçu dans main.gd!", "INFO")
	
	# Afficher des informations de débogage sur LoadingScreen
	if has_node("%LoadingScreen"):
		Logger.log_message("main", ["system", "loading"], "LoadingScreen existe dans l'arbre", "INFO")
		
		# Déconnecter le signal
		if %LoadingScreen.loading_completed.is_connected(_on_loading_completed):
			%LoadingScreen.loading_completed.disconnect(_on_loading_completed)
			Logger.log_message("main", ["system", "loading"], "Signal déconnecté avec succès", "INFO")
		else:
			Logger.log_message("main", ["system", "loading"], "Le signal n'est pas connecté", "WARNING")
		
		# Libérer l'écran de chargement
		%LoadingScreen.queue_free()
		Logger.log_message("main", ["system", "loading"], "LoadingScreen marqué pour suppression", "INFO")
	else:
		Logger.log_message("main", ["system", "loading"], "LoadingScreen introuvable!", "ERROR")
	
	Logger.log_message("main", ["system", "loading"], "Début de l'initialisation du jeu", "INFO")
	# Now initialize game components
	_initialize_game()
	Logger.log_message("main", ["system", "loading"], "Initialisation du jeu terminée", "INFO")

func _initialize_game() -> void:
	Logger.log_message("main", ["system", "game"], "Début de l'initialisation du jeu (_initialize_game)", "INFO")
	
	# Récupérer la référence au table_service
	var table_service = Services.table_service
	if table_service:
		Logger.log_message("main", ["system", "table"], "Service de table trouvé", "INFO")
		
		# Vérifier la scène de table exportée
		if table_scene:
			Logger.log_message("main", ["system", "table"], "Scène de table définie dans Main", "INFO")
		else:
			Logger.log_message("main", ["system", "table"], "Scène de table non définie dans Main!", "ERROR")
		
		# Configurer la scène de table dans le service
		table_service.table_scene = table_scene
		
		# Déboguer si la table a déjà été créée par le service
		if table_service.get_table():
			Logger.log_message("main", ["system", "table"], "Une table existe déjà dans le service", "WARNING")
		else:
			Logger.log_message("main", ["system", "table"], "Aucune table n'existe encore dans le service", "INFO")
			# Créer la table via le service si elle n'existe pas encore
			Logger.log_message("main", ["system", "table"], "Création de la table via le service...", "INFO")
			table_service.create_table()
		
		# Récupérer la table du service
		Logger.log_message("main", ["system", "table"], "Récupération de la table du service...", "INFO")
		table = table_service.get_table()
		
		if table:
			Logger.log_message("main", ["system", "table"], "Table récupérée du service avec succès", "INFO")
		else:
			Logger.log_message("main", ["system", "table"], "get_table() a retourné null!", "ERROR")
		
		# Ajouter la table à la scène principale
		if table:
			# Déboguer la visibilité et les propriétés de la table
			Logger.log_message("main", ["system", "table"], "Type de table: %s" % table.get_class(), "INFO")
			
			# Déboguer la hiérarchie de la scène
			if table.get_parent():
				Logger.log_message("main", ["system", "table"], "La table a déjà un parent: %s" % table.get_parent().name, "WARNING")
				# Retirer du parent actuel avant d'ajouter
				table.get_parent().remove_child(table)
			
			# Configuration spécifique pour différents types de nœuds
			if table is Control:
				Logger.log_message("main", ["system", "table"], "Configuration d'un nœud Control", "INFO")
				# Réparer les propriétés pour Control
				table.visible = true
				# Configuration des anchors pour couvrir tout l'écran
				table.anchors_preset = Control.PRESET_FULL_RECT
				table.size_flags_horizontal = Control.SIZE_FILL
				table.size_flags_vertical = Control.SIZE_FILL
			elif table is Node2D:
				Logger.log_message("main", ["system", "table"], "Configuration d'un nœud Node2D", "INFO")
				# Configuration pour Node2D
				table.visible = true
				table.position = Vector2(0, 0)
				table.z_index = 0
			else:
				Logger.log_message("main", ["system", "table"], "Type de nœud non spécifique, s'assurer qu'il est visible", "INFO")
				table.visible = true
			
			# Ajouter à la scène principale mais dans un endroit approprié
			# Pour un Control, il vaut mieux l'ajouter dans un conteneur UI
			add_child(table)
			
			# Vérifier que la table est maintenant dans l'arbre de scène
			if table.is_inside_tree():
				Logger.log_message("main", ["system", "table"], "Table ajoutée à l'arbre de scène", "INFO")
			else:
				Logger.log_message("main", ["system", "table"], "La table n'est pas dans l'arbre de scène après ajout", "ERROR")
			
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
