extends Node

# Version de l'autoload Services
const VERSION: String = "0.0.1"

# Préchargement des dépendances
const SaveManagerClass = preload("res://utils/save_manager.gd")
const CashServiceClass = preload("res://services/cash/cash_service.gd")
const ScoreServiceClass = preload("res://services/score/score_service.gd")
const DiceServiceClass = preload("res://services/dices/dice_service.gd")

# Signaux globaux
signal services_ready
signal save_game_started
signal save_game_completed
signal load_game_started
signal load_game_completed(success)

# Services existants (pour la rétrocompatibilité)
var cash: Cash 
var score: Score 
var dices: Dices 

# Services intégrés avec BaseService
var cash_service: CashService
var score_service: ScoreService
var dice_service: DiceService

# Nouveaux services (à instancier plus tard)
var game_data = null # GameDataService
var rules = null # RulesService
var upgrades = null # UpgradeService
var game = null # GameService

# Informations d'état
var is_initialized: bool = false
var is_loading: bool = false
var is_saving: bool = false

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
	
	# Services existants (pour la rétrocompatibilité)
	cash = Cash.new()
	score = Score.new()
	dices = preload("res://services/dices/dices.tscn").instantiate()
	
	# Services intégrés avec BaseService
	cash_service = CashServiceClass.new()
	score_service = ScoreServiceClass.new()
	dice_service = DiceServiceClass.new()
	
	# Les nouveaux services seront ajoutés ici dans une future tâche
	# game_data = GameDataService.new()
	# rules = RulesService.new()
	# upgrades = UpgradeService.new()
	# game = GameService.new()
	
	# Ajouter comme enfants pour qu'ils reçoivent _process, etc.
	add_child(cash)
	add_child(score)
	add_child(dices)
	
	# Ajouter les nouveaux services BaseService
	add_child(cash_service)
	add_child(score_service)
	add_child(dice_service)
	
	# Ajouter les nouveaux services quand ils seront implémentés
	# add_child(game_data)
	# add_child(rules)
	# add_child(upgrades)
	# add_child(game)

# Étape 2: Initialisation de base des services
func _initialize_services() -> void:
	print("Initialisation des services...")
	
	# Les services hérités de BaseService ont une méthode initialize()
	cash_service.initialize()
	score_service.initialize()
	dice_service.initialize()
	
	# Les nouveaux services seront initialisés ici dans une future tâche
	# game_data.initialize()
	# rules.initialize()
	# upgrades.initialize()
	# game.initialize()

# Étape 3: Configuration des dépendances
func _setup_dependencies() -> void:
	print("Configuration des dépendances entre services...")
	
	# Pour DiceService, nous devons lui fournir une référence à la table de jeu
	# Cette référence sera mise à jour lorsque la table sera disponible
	dice_service.setup_dependencies({})
	
	# Pas de dépendances pour CashService et ScoreService pour le moment
	cash_service.setup_dependencies({})
	score_service.setup_dependencies({})
	
	# Les autres services seront configurés dans une future tâche
	# rules.setup_dependencies({})
	# game_data.setup_dependencies({})
	# upgrades.setup_dependencies({
	#     "game_data": game_data
	# })
	# game.setup_dependencies({
	#     "data_service": game_data,
	#     "rules_service": rules,
	#     "upgrade_service": upgrades
	# })

# Étape 4: Démarrage des services
func _start_services() -> void:
	print("Démarrage des services...")
	
	# Démarrage des services BaseService
	cash_service.start()
	score_service.start()
	dice_service.start()
	
	# Les autres services seront démarrés dans une future tâche
	# game_data.start()
	# rules.start()
	# upgrades.start()
	# game.start()

# Étape 5: Connexion des signaux entre services
func _connect_signals() -> void:
	print("Connexion des signaux entre services...")
	
	# Connecter les signaux des nouveaux services aux anciens pour la rétrocompatibilité
	cash_service.cash_changed.connect(_on_cash_service_changed)
	score_service.score_changed.connect(_on_score_service_changed)
	
	# Les autres connexions seront ajoutées dans une future tâche
	# game_data.gold_changed.connect(_on_gold_changed)
	# game_data.score_changed.connect(_on_score_changed)

# Handlers pour assurer la compatibilité avec le système existant
func _on_cash_service_changed(new_cash: int) -> void:
	# Mettre à jour l'ancien service cash pour la rétrocompatibilité
	cash._cash = new_cash
	cash.emit_signal("cash_changed", new_cash)
	
func _on_score_service_changed(new_score: int) -> void:
	# Mettre à jour l'ancien service score pour la rétrocompatibilité
	score._score = new_score
	score.emit_signal("score_changed", new_score)

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
	save_data["services"]["dice_service"] = dice_service.get_save_data()
	
	# Pour la rétrocompatibilité, aussi enregistrer dans l'ancien format
	save_data["services"]["cash"] = { "amount": cash._cash }
	save_data["services"]["score"] = { "score": score._score }
	save_data["services"]["dices"] = dices.get_save_data() if "get_save_data" in dices else {}
	
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
		
		# Charger les données dans chaque service
		if "services" in load_data:
			var services_data = load_data["services"]
			
			# Chargement des données dans les services BaseService
			if "cash_service" in services_data:
				cash_service.load_save_data(services_data["cash_service"])
			elif "cash" in services_data:
				# Fallback vers l'ancien format
				cash_service.set_cash(services_data["cash"].get("amount", 0))
			
			if "score_service" in services_data:
				score_service.load_save_data(services_data["score_service"])
			elif "score" in services_data:
				# Fallback vers l'ancien format
				score_service.set_score(services_data["score"].get("score", 0))
			
			if "dice_service" in services_data:
				dice_service.load_save_data(services_data["dice_service"])
			
			# Mise à jour des services existants pour la rétrocompatibilité
			if "score" in services_data:
				score._score = services_data["score"].get("score", 0)
				score.emit_signal("score_changed", score._score)  # Forcer l'émission du signal
			
			if "dices" in services_data:
				if "load_save_data" in dices:
					dices.load_save_data(services_data["dices"])
			
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
	
	# Réinitialiser les services existants
	cash._cash = 0
	score._score = 0
	
	# Réinitialiser les nouveaux services quand ils seront implémentés
	# game_data.reset(with_persistence)
	# rules.reset(with_persistence)
	# upgrades.reset(with_persistence)
	# game.reset(with_persistence)

# Réinitialise le jeu sans charger de sauvegarde
func reset_game(with_persistence: bool = false) -> void:
	print("Réinitialisation du jeu (persistance: %s)" % with_persistence)
	
	# Les services existants seront réinitialisés directement
	cash._cash = 0
	cash.emit_signal("changed")
	
	score._score = 0
	score.emit_signal("changed")
	
	if "perform_reset" in dices:
		dices.perform_reset(with_persistence)
	
	# Réinitialiser les nouveaux services
	# game_data.perform_reset(with_persistence)
	# rules.perform_reset(with_persistence)
	# upgrades.perform_reset(with_persistence)
	# game.perform_reset(with_persistence)
	
	# Si we_persistence est false, supprimer également les fichiers de sauvegarde
	if not with_persistence:
		SaveManagerClass.delete_save_data()
	
	print("Jeu réinitialisé")
