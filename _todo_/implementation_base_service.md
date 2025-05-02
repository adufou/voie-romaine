# Architecture de base des services pour La Voie Romaine

Ce document décrit l'architecture de base du système de services pour La Voie Romaine, en utilisant une approche modulaire via le mécanisme d'Autoload de Godot.

## Objectifs

- Créer une architecture modulaire basée sur des services indépendants
- Maintenir la compatibilité avec le système existant
- Centraliser la gestion des sauvegardes
- Faciliter l'extension du jeu avec de nouveaux systèmes
- Assurer une initialisation ordonnée sans dépendances circulaires

## Architecture des services

### 1. Classe de base pour les services

Tous les services héritent d'une classe commune qui fournit les fonctionnalités de base et une initialisation en trois phases.

**Fichier:** `/services/base_service.gd`

```gdscript
extends Node
class_name BaseService

# Signaux communs que tous les services peuvent émettre
signal initialized
signal started
signal reset(with_persistence)

# Version du service pour la gestion de compatibilité des sauvegardes
var version: String = "0.0.1"

# Initialisation en trois phases pour éviter les problèmes de dépendances
func initialize() -> void:
    # Phase 1: Configuration de base
    # Ne pas accéder aux autres services ici
    initialized.emit()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
    # Phase 2: Configuration des dépendances
    # Configurer les liens avec les autres services
    pass

func start() -> void:
    # Phase 3: Démarrage
    # Démarrer les fonctionnalités qui requièrent d'autres services
    started.emit()
    
# Réinitialise l'état du service
func reset(with_persistence: bool = false) -> void:
    # Logique de réinitialisation
    reset.emit(with_persistence)
    
# Méthode pour récupérer les données à sauvegarder
func get_save_data() -> Dictionary:
    return {
        "version": version
    }
    
# Méthode pour restaurer les données sauvegardées
func load_save_data(data: Dictionary) -> bool:
    if data.has("version"):
        version = data.version
        return true
    return false
```

### Modification du fichier services.gd existant

**Fichier:** `/autoload/services.gd` (modifié)

```gdscript
extends Node

# Services existants
var cash: Cash = Cash.new()
var score: Score = Score.new()
var dices: Dices = preload("res://services/dices/dices.tscn").instantiate()

# Nouveaux services
var game_data: GameDataService = GameDataService.new()
var rules: RulesService = RulesService.new()
var upgrades: UpgradeService = UpgradeService.new()
var game: GameService = GameService.new()

func _ready() -> void:
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

# Étape 1: Création des services
func _create_services() -> void:
    # Les services sont déjà créés comme propriétés de la classe
    # Ajouter comme enfants pour qu'ils reçoivent _process
    add_child(dices)
    add_child(cash)
    add_child(score)
    add_child(game_data)
    add_child(rules)
    add_child(upgrades)
    add_child(game)

# Étape 2: Initialisation de base des services
func _initialize_services() -> void:
    # Initialisation uniquement des propriétés internes
    game_data.initialize()
    rules.initialize()
    upgrades.initialize()
    game.initialize()

# Étape 3: Configuration des dépendances
func _setup_dependencies() -> void:
    # Configurer les références entre services
    rules.setup_dependencies({})
    game_data.setup_dependencies({})
    upgrades.setup_dependencies({
        "game_data": game_data
    })
    game.setup_dependencies({
        "data_service": game_data,
        "rules_service": rules,
        "upgrade_service": upgrades
    })

# Étape 4: Démarrage des services
func _start_services() -> void:
    # Démarrer les fonctionnalités qui dépendent d'autres services
    game_data.start()
    rules.start()
    upgrades.start()
    game.start()

# Étape 5: Connexion des signaux
func _connect_signals() -> void:
    # Connecter les signaux entre anciens et nouveaux services
    game_data.gold_changed.connect(_on_gold_changed)
    game_data.score_changed.connect(_on_score_changed)

# Handlers pour assurer la compatibilité avec le système existant
func _on_gold_changed(new_gold: int) -> void:
    cash.set_amount(new_gold)
    
func _on_score_changed(new_score: int) -> void:
    score.set_amount(new_score)
```
