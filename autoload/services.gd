extends Node

# Version de l'autoload Services
const VERSION: String = "0.0.1"

# Préchargement des dépendances
const SaveManagerClass = preload("res://utils/save_manager.gd")
const CashServiceClass = preload("res://services/cash/cash_service.gd")
const ScoreServiceClass = preload("res://services/score/score_service.gd")
const DicesServiceClass = preload("res://services/dices/dices_service.gd")
const DiceSyntaxServiceClass = preload("res://services/dice_syntax/dice_syntax_service.gd")
const StatisticsServiceClass = preload("res://services/statistics/statistics_service.gd")
const RulesServiceClass = preload("res://services/rules/rules_service.gd")
const TableServiceClass = preload("res://services/table/table_service.gd")
const UpgradesServiceClass = preload("res://services/upgrades/upgrades_service.gd")
const GameServiceClass = preload("res://services/game/game_service.gd")

# Signaux globaux
signal services_ready
signal save_game_started
signal save_game_completed
signal load_game_started
signal load_game_completed(success)

# Services intégrés avec BaseService
var cash_service: CashService
var score_service: ScoreService
var dices_service: DicesService
var dice_syntax_service: DiceSyntaxService

# Nouveaux services (à instancier plus tard)
var statistics_service: StatisticsServiceClass = null
var rules_service: RulesServiceClass = null
var table_service: TableServiceClass = null
var upgrades_service: UpgradesServiceClass = null
var game_service: GameServiceClass = null

# Informations d'état
var is_initialized: bool = false
var is_loading: bool = false
var is_saving: bool = false

# Arbre de dépendances entre services
var service_dependencies = {}
var service_startup_order = []

func _ready() -> void:
	print("Initialisation du système de services (version %s)" % VERSION)
	
	# Étape 1: Création des services
	_create_services()
	
	# Étape 2: Initialisation de base des services
	_initialize_services()
	
	# Étape 3: Configuration des dépendances entre services
	_setup_dependencies()
	
	# Étape 4: Démarrage des services après initialisation complète
	_start_services()
	
	# Étape 5: Connexions entre services existants et nouveaux
	_connect_signals()
	
	is_initialized = true
	print("Système de services initialisé avec succès")
	services_ready.emit()

# Étape 1: Création des services
func _create_services() -> void:
	Logger.info(["services"], "Création des services...")
	
	# Services intégrés avec BaseService
	cash_service = CashServiceClass.new()
	score_service = ScoreServiceClass.new()
	dices_service = preload("res://services/dices/dices_service.tscn").instantiate() # Instancier à partir de la scène pour avoir dice_scene
	dice_syntax_service = DiceSyntaxServiceClass.new()
	
	# Instantiation des nouveaux services
	statistics_service = StatisticsServiceClass.new()
	rules_service = RulesServiceClass.new()
	table_service = TableServiceClass.new()
	upgrades_service = UpgradesServiceClass.new()
	game_service = GameServiceClass.new()
	
	# Ajouter les services BaseService
	add_child(cash_service)
	add_child(score_service)
	add_child(dices_service)
	add_child(dice_syntax_service)
	add_child(statistics_service)
	add_child(rules_service)
	add_child(table_service)
	add_child(upgrades_service)
	add_child(game_service)

# Étape 2: Initialisation de base des services
func _initialize_services() -> void:
	print("Initialisation des services...")
	
	# Les services hérités de BaseService ont une méthode initialize()
	cash_service.initialize()
	score_service.initialize()
	dices_service.initialize()
	dice_syntax_service.initialize()
	statistics_service.initialize()
	rules_service.initialize()
	table_service.initialize()
	upgrades_service.initialize()
	game_service.initialize()

# Étape 3: Configuration des dépendances
func _setup_dependencies() -> void:
	print("Configuration des dépendances entre services...")
	
	# Réinitialiser l'arbre de dépendances
	service_dependencies.clear()
	service_startup_order.clear()
	
	# Configuration du service table (pas de dépendances)
	table_service.setup_dependencies({})
	
	# Configuration des dépendances pour DiceSyntaxService (pas de dépendances)
	dice_syntax_service.setup_dependencies({})
	
	# Configuration des dépendances pour DicesService
	dices_service.setup_dependencies({
		"table_service": table_service
	})
	
	# Configuration des dépendances pour CashService (pas de dépendances)
	cash_service.setup_dependencies({})
	
	# Configuration des dépendances pour ScoreService (pas de dépendances)
	score_service.setup_dependencies({})
	
	# Configuration des dépendances pour StatisticsService
	statistics_service.setup_dependencies({
		"cash_service": cash_service,
		"score_service": score_service,
		"dices_service": dices_service
	})
	
	# Configuration des dépendances pour UpgradesService
	upgrades_service.setup_dependencies({
		"cash_service": cash_service,
		"score_service": score_service
	})

	# Configuration des dépendances pour RulesService
	rules_service.setup_dependencies({
		"cash_service": cash_service,
		"score_service": score_service,
		"upgrades_service": upgrades_service
	})
	
	# Configuration des dépendances pour GameService
	game_service.setup_dependencies({
		"dices_service": dices_service,
		"rules_service": rules_service,
		"upgrades_service": upgrades_service,
		"statistics_service": statistics_service
	})
	
	# Construire l'arbre de dépendances à partir des informations des services
	_build_dependency_tree_from_services()
	
	# Calculer l'ordre de démarrage des services
	service_startup_order = _calculate_startup_order()
	print("Ordre de démarrage des services calculé: %s" % [service_startup_order])

# Étape 4: Démarrage des services
func _start_services() -> void:
	print("Démarrage des services dans l'ordre calculé...")
	
	# Démarrer les services selon l'ordre de dépendances calculé
	for service_name in service_startup_order:
		print("Démarrage du service: %s" % service_name)
		
		if service_name == "cash_service":
			cash_service.start()
		elif service_name == "score_service":
			score_service.start()
		elif service_name == "dices_service":
			dices_service.start()
		elif service_name == "dice_syntax_service":
			dice_syntax_service.start()
		elif service_name == "statistics_service":
			statistics_service.start()
		elif service_name == "rules_service":
			rules_service.start()
		elif service_name == "table_service":
			table_service.start()
		elif service_name == "upgrades_service":
			upgrades_service.start()
		elif service_name == "game_service":
			game_service.start()

# Étape 5: Connexion des signaux entre services
func _connect_signals() -> void:
	print("Connexion des signaux entre services...")
	
	# Connecter les signaux des nouveaux services aux anciens pour la rétrocompatibilité
	# Plus besoin de mise à jour de rétrocompatibilité pour cash
	score_service.score_changed.connect(_on_score_service_changed)
	
	# Les autres connexions seront ajoutées dans une future tâche
	# game_data.gold_changed.connect(_on_gold_changed)
	# game_data.score_changed.connect(_on_score_changed)

# Construction de l'arbre de dépendances à partir des informations des services
func _build_dependency_tree_from_services() -> void:
	print("Construction de l'arbre de dépendances à partir des informations des services...")
	
	# Réinitialiser les dépendances
	service_dependencies.clear()
	
	# Collecter tous les services disponibles
	var available_services = [
		cash_service,
		score_service,
		dices_service,
		statistics_service,
		rules_service,
		table_service,
		upgrades_service,
		game_service
	]
	
	# Initialiser toutes les entrées dans le dictionnaire de dépendances
	# Et créer une map inverse pour chercher les services par nom
	var services_by_name = {}
	for service in available_services:
		if service == null:
			continue
		
		# Utiliser directement le nom défini dans chaque service
		var service_key = service.service_name
		service_dependencies[service_key] = []
		services_by_name[service_key] = service
	
	# Récupérer les dépendances déclarées par chaque service
	for service in available_services:
		if service == null:
			continue
			
		var service_key = service.service_name
		
		# Ajouter les dépendances déclarées par le service
		for dependency_name in service.service_dependencies:
			if services_by_name.has(dependency_name):
				service_dependencies[service_key].append(dependency_name)
				print("Service %s dépend de %s" % [service_key, dependency_name])
			else:
				push_warning("Dépendance inconnue '%s' pour le service '%s'" % [dependency_name, service_key])
	
	# Afficher l'arbre de dépendances pour le débogage
	print("Arbre de dépendances construit:")
	for service_name in service_dependencies.keys():
		print("  %s dépend de: %s" % [service_name, service_dependencies[service_name]])

# Calcule l'ordre de démarrage des services en fonction de leurs dépendances
# Utilise un parcours DFS postorder pour s'assurer que les dépendances sont démarrées avant les services qui en dépendent
func _calculate_startup_order() -> Array:
	var visited = {}
	var order = []
	
	# Initialiser tous les services comme non visités
	for service_name in service_dependencies.keys():
		visited[service_name] = false
	
	# Parcourir chaque service non visité
	for service_name in service_dependencies.keys():
		if not visited[service_name]:
			_visit_service(service_name, visited, order)
	
	# L'ordre est déjà correct (dépendances en premier) grâce au DFS postorder
	return order

# Fonction récursive pour visiter les services et leurs dépendances (DFS postorder)
func _visit_service(service_name: String, visited: Dictionary, order: Array) -> void:
	# Marquer comme en cours de visite
	visited[service_name] = true
	
	# Visiter d'abord toutes les dépendances
	if service_dependencies.has(service_name):
		for dependency in service_dependencies[service_name]:
			if not visited.has(dependency) or not visited[dependency]:
				_visit_service(dependency, visited, order)
	
	# Ajouter ce service à l'ordre après ses dépendances
	order.append(service_name)

# Handlers pour assurer la compatibilité avec le système existant
	
func _on_score_service_changed(new_score: int) -> void:
	# L'ancien service score n'est plus utilisé
	pass

# Fonctions de sauvegarde et chargement
func save_game() -> void:
	if is_saving:
		push_warning("Sauvegarde déjà en cours")
		return
	
	print("Début de la sauvegarde du jeu...")
	is_saving = true
	save_game_started.emit()
	
	# Récupérer les données de tous les services
	var save_data = {
		"version": VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"services": {}
	}
	
	# Collecte des données des services BaseService
	save_data["services"]["cash_service"] = cash_service.get_save_data()
	save_data["services"]["score_service"] = score_service.get_save_data()
	save_data["services"]["dice_service"] = dices_service.get_save_data()
	save_data["services"]["statistics_service"] = statistics_service.get_save_data()
	
	# Pour la rétrocompatibilité, aussi enregistrer dans l'ancien format
	# cash est maintenant géré par cash_service
	# Score ancien service retiré
	# save_data["services"]["score"] = { "score": score._score }
	# La rétrocompatibilité avec l'ancien service dices a été supprimée
	
	# Les autres nouveaux services utiliseront leur méthode get_save_data()
	# save_data["services"]["game_data"] = game_data.get_save_data()
	# save_data["services"]["rules"] = rules.get_save_data()
	# save_data["services"]["upgrades"] = upgrades.get_save_data()
	# save_data["services"]["game"] = game.get_save_data()
	
	# Sauvegarde des données dans un fichier avec le SaveManager
	var success = SaveManagerClass.save_data(save_data)
	if not success:
		push_error("Échec de la sauvegarde du jeu")
	
	is_saving = false
	save_game_completed.emit()

func load_game() -> bool:
	if is_loading:
		push_warning("Chargement déjà en cours")
		return false
	
	print("Début du chargement du jeu...")
	is_loading = true
	load_game_started.emit()
	
	# Charger les données depuis un fichier avec le SaveManager
	var load_data = SaveManagerClass.load_data()
	var success = not load_data.is_empty()
	
	if success:
		# Vérifier la compatibilité de version
		if "version" in load_data and load_data["version"] != VERSION:
			print("Version de sauvegarde différente: %s (actuelle: %s)" % [load_data["version"], VERSION])
			# Pour l'instant, on continue le chargement même si les versions sont différentes
		
		# Chargement des données dans les services BaseService
		var service_success = true
		
		if "services" in load_data:
			var services_data = load_data["services"]
			
			if services_data.has("cash_service"):
				print("Chargement des données du service CashService")
				service_success = service_success and cash_service.load_save_data(services_data["cash_service"])
			
			if services_data.has("score_service"):
				print("Chargement des données du service ScoreService")
				service_success = service_success and score_service.load_save_data(services_data["score_service"])
			
			if services_data.has("dice_service"):
				print("Chargement des données du service DiceService")
				service_success = service_success and dices_service.load_save_data(services_data["dice_service"])
			
			if services_data.has("statistics_service"):
				print("Chargement des données du service StatisticsService")
				service_success = service_success and statistics_service.load_save_data(services_data["statistics_service"])
			
			# La rétrocompatibilité avec les anciens services a été supprimée
			
			# Les autres nouveaux services utiliseront leur méthode load_save_data()
			# if "game_data" in services_data:
			# 	game_data.load_save_data(services_data["game_data"])
			# if "rules" in services_data:
			# 	rules.load_save_data(services_data["rules"])
			# if "upgrades" in services_data:
			# 	upgrades.load_save_data(services_data["upgrades"])
			# if "game" in services_data:
			# 	game.load_save_data(services_data["game"])
			# if "upgrades" in services_data:
			#     upgrades.load_save_data(services_data["upgrades"])
			# if "game" in services_data:
			#     game.load_save_data(services_data["game"])
		
		success = true
		print("Jeu chargé avec succès")
	else:
		push_error("Échec du chargement du jeu: aucune donnée trouvée")
	
	is_loading = false
	load_game_completed.emit(success)
	if success:
		print("Jeu chargé avec succès")
	else:
		print("Aucune sauvegarde trouvée ou échec du chargement")
	return success

# Réinitialiser tous les services (utile pour le prestige ou le redémarrage)
func reset_all_services(with_persistence: bool = false) -> void:
	print("Réinitialisation de tous les services (persistance: %s)" % with_persistence)
	
	# Les services existants ont été remplacés par les services héritant de BaseService
	# cash_service gère maintenant le cash
	
	# Réinitialiser les nouveaux services quand ils seront implémentés
	# game_data.reset(with_persistence)
	# rules.reset(with_persistence)
	# upgrades.reset(with_persistence)
	# game.reset(with_persistence)

# Réinitialise le jeu sans charger de sauvegarde
func reset_game(with_persistence: bool = false) -> void:
	print("Réinitialisation du jeu (persistance: %s)" % with_persistence)
	
	# Les services existants seront réinitialisés directement
	# cash_service gère maintenant le cash
	
	# La rétrocompatibilité avec l'ancien service dices a été supprimée
	
	# Réinitialiser les services BaseService
	cash_service.perform_reset(with_persistence)
	score_service.perform_reset(with_persistence)
	dices_service.perform_reset(with_persistence)
	statistics_service.perform_reset(with_persistence)
	# game.perform_reset(with_persistence)
	
	# Si we_persistence est false, supprimer également les fichiers de sauvegarde
	if not with_persistence:
		SaveManagerClass.delete_save_data()
	
	print("Jeu réinitialisé")
