extends Node

# Version de l'autoload Services
const VERSION: String = "0.0.1"

# Signaux globaux
signal services_ready
signal save_game_started
signal save_game_completed
signal load_game_started
signal load_game_completed(success)

# Services existants
var cash: Cash 
var score: Score 
var dices: Dices 

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
    # Cette étape sera activée plus tard quand les nouveaux services seront implémentés
    # _connect_signals()
    
    is_initialized = true
    print("Système de services initialisé avec succès")
    services_ready.emit()

# Étape 1: Création des services
func _create_services() -> void:
    print("Création des services...")
    
    # Services existants
    cash = Cash.new()
    score = Score.new()
    dices = preload("res://services/dices/dices.tscn").instantiate()
    
    # Les nouveaux services seront ajoutés ici dans une future tâche
    # game_data = GameDataService.new()
    # rules = RulesService.new()
    # upgrades = UpgradeService.new()
    # game = GameService.new()
    
    # Ajouter comme enfants pour qu'ils reçoivent _process, etc.
    add_child(cash)
    add_child(score)
    add_child(dices)
    
    # Ajouter les nouveaux services quand ils seront implémentés
    # add_child(game_data)
    # add_child(rules)
    # add_child(upgrades)
    # add_child(game)

# Étape 2: Initialisation de base des services
func _initialize_services() -> void:
    print("Initialisation des services...")
    
    # Les services hérités de BaseService auront une méthode initialize()
    # Les services existants seront traités différemment car ils n'héritent pas de BaseService
    
    # Les nouveaux services seront initialisés ici dans une future tâche
    # game_data.initialize()
    # rules.initialize()
    # upgrades.initialize()
    # game.initialize()

# Étape 3: Configuration des dépendances
func _setup_dependencies() -> void:
    print("Configuration des dépendances entre services...")
    
    # Les services hérités de BaseService auront une méthode setup_dependencies()
    # Les dépendances seront configurées ici dans une future tâche
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
    
    # Les services hérités de BaseService auront une méthode start()
    # Les services seront démarrés ici dans une future tâche
    # game_data.start()
    # rules.start()
    # upgrades.start()
    # game.start()

# Étape 5: Connexion des signaux entre services
func _connect_signals() -> void:
    print("Connexion des signaux entre services...")
    
    # Les connexions seront ajoutées ici dans une future tâche
    # game_data.gold_changed.connect(_on_gold_changed)
    # game_data.score_changed.connect(_on_score_changed)

# Handlers pour assurer la compatibilité avec le système existant
func _on_gold_changed(new_gold: int) -> void:
    cash.set_amount(new_gold)
    
func _on_score_changed(new_score: int) -> void:
    score.set_amount(new_score)

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
    
    # Les données des services seront ajoutées ici dans une future tâche
    # Exemple avec des données pour les services qui existent déjà:
    save_data["services"]["cash"] = { "amount": cash._cash }
    save_data["services"]["score"] = { "score": score._score }
    
    # Les nouveaux services utiliseront leur méthode get_save_data()
    # save_data["services"]["game_data"] = game_data.get_save_data()
    # save_data["services"]["rules"] = rules.get_save_data()
    # save_data["services"]["upgrades"] = upgrades.get_save_data()
    # save_data["services"]["game"] = game.get_save_data()
    
    # TODO: Implémenter la sauvegarde des données dans un fichier
    # Cela sera fait dans une future tâche (ARCH-04)
    print("Jeu sauvegardé")
    
    is_saving = false
    save_game_completed.emit()

func load_game() -> bool:
    if is_loading:
        push_warning("Chargement déjà en cours")
        return false
    
    print("Début du chargement du jeu...")
    is_loading = true
    load_game_started.emit()
    
    # TODO: Charger les données depuis un fichier
    # Cela sera fait dans une future tâche (ARCH-04)
    var success = false
    var load_data = null  # Ceci sera remplacé par les données réelles chargées
    
    if load_data != null:
        # Charger les données dans chaque service
        # Les services existants seront mis à jour directement
        if "services" in load_data:
            var services_data = load_data["services"]
            
            # Exemple avec des données pour les services qui existent déjà:
            if "cash" in services_data:
                cash._cash = services_data["cash"].get("amount", 0)
            
            if "score" in services_data:
                score._score = services_data["score"].get("score", 0)
            
            # Les nouveaux services utiliseront leur méthode load_save_data()
            # if "game_data" in services_data:
            #     game_data.load_save_data(services_data["game_data"])
            # if "rules" in services_data:
            #     rules.load_save_data(services_data["rules"])
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
