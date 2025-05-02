# Implémentation du système de services via Autoload pour La Voie Romaine

Ce document décrit l'approche d'implémentation des services système pour La Voie Romaine en utilisant le mécanisme d'Autoload de Godot.

## Objectifs

- Créer une architecture modulaire mais facilement accessible
- Garantir un ordre d'initialisation contrôlé et prévisible
- Éviter les problèmes de dépendances circulaires
- Faciliter l'accès aux services depuis n'importe quelle partie du code
- Maintenir la testabilité du code

## Architecture globale

### 1. Service principal - Autoload "Services"

Le point d'entrée principal sera un autoload nommé "Services" qui contiendra et initialisera tous les autres services.

**Fichier:** `/autoload/services.gd`

```gdscript
extends Node

# Services existants
var cash: Cash
var score: Score
var dices: Dices

# Nouveaux services
var game_data: GameDataService
var rules: RulesService
var upgrades: UpgradeService
var game: GameService

func _ready() -> void:
    # 1. Création des services dans un ordre spécifique
    _create_services()
    
    # 2. Initialisation de base des services
    _initialize_services()
    
    # 3. Configuration des dépendances entre services
    _setup_dependencies()
    
    # 4. Démarrage des services après initialisation complète
    _start_services()
    
    # 5. Connexions entre services existants et nouveaux
    _connect_signals()

# Étape 1: Création de tous les services
func _create_services() -> void:
    # Services existants
    cash = Cash.new()
    score = Score.new()
    dices = preload("res://services/dices/dices.tscn").instantiate()
    
    # Nouveaux services
    game_data = GameDataService.new()
    rules = RulesService.new()
    upgrades = UpgradeService.new()
    game = GameService.new()
    
    # Ajout comme enfants pour recevoir _process, etc.
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
    # Sans accéder aux autres services à ce stade
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

### 2. Classe de base pour les services

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

### 3. Configuration de l'Autoload dans Godot

Pour configurer l'autoload dans le projet Godot:

1. Ouvrir le projet dans l'éditeur Godot
2. Aller dans Project > Project Settings > AutoLoad
3. Ajouter l'entrée:
   - Path: `res://autoload/services.gd`
   - Name: `Services`
   - Activer "Singleton"
4. Cliquer sur "Add" pour ajouter l'autoload

## Utilisation des services dans le code

### Accès aux services

Tous les services sont accessibles globalement via le singleton `Services`:

```gdscript
# Accéder au service de données
var current_gold = Services.game_data.gold

# Utiliser le service de règles
var result = Services.rules.resolve_throw(dice, value)

# Acheter une amélioration
Services.upgrades.purchase_upgrade("speed")

# Sauvegarder le jeu
Services.game.save_game()
```

### Exemple dans un script de dé

```gdscript
# Dans le script Dice
func throw_resolve() -> void:
    var result = Services.rules.resolve_throw(self, value)
    
    # Appliquer les résultats
    if result.new_goal != goal:
        goal = result.new_goal
    
    if result.new_tries != tries:
        tries = result.new_tries
    
    if result.gold_reward > 0:
        Services.game_data.add_gold(result.gold_reward)
    
    # Afficher les messages
    for message in result.messages:
        pop_up_message(message)
```

## Gestion des dépendances circulaires

L'approche en trois phases (`initialize`, `setup_dependencies`, `start`) permet d'éviter les problèmes de dépendances circulaires:

1. **Phase 1** (`initialize`): Chaque service configure uniquement ses propriétés internes
2. **Phase 2** (`setup_dependencies`): Les services reçoivent des références à d'autres services
3. **Phase 3** (`start`): Les services démarrent leurs fonctionnalités qui dépendent d'autres services

Cette approche permet également de changer les implémentations des services sans modifier le code client.

## Avantages de cette architecture

1. **Ordre d'initialisation contrôlé**: Les services sont créés et initialisés dans un ordre précis
2. **Accès global**: Tous les services sont accessibles via l'autoload Services
3. **Dépendances explicites**: Chaque service déclare ses dépendances dans setup_dependencies
4. **Modularité**: Les services peuvent être développés et testés indépendamment
5. **Évitement des dépendances circulaires**: L'initialisation en trois phases évite les problèmes de dépendances circulaires

## Conseils d'implémentation

1. **Accès discipliné**: Bien que tous les services soient accessibles globalement, essayez de documenter clairement quels services sont utilisés par quels composants.

2. **Communication par signaux**: Privilégiez la communication par signaux plutôt que par appels directs quand c'est possible pour réduire le couplage.

3. **Tests unitaires**: Pour tester les services individuellement, vous pouvez créer des mocks ou des stubs des autres services:

```gdscript
# Exemple de test unitaire pour UpgradeService
func test_purchase_upgrade():
    var mock_game_data = MockGameDataService.new()
    mock_game_data.gold = 1000
    
    var upgrade_service = UpgradeService.new()
    upgrade_service.initialize()
    upgrade_service.setup_dependencies({
        "game_data": mock_game_data
    })
    
    var result = upgrade_service.purchase_upgrade("speed")
    
    assert(result == true)
    assert(mock_game_data.gold < 1000)
    assert(upgrade_service.upgrades["speed"] == 1)
```

## Conclusion

Cette architecture utilisant les autoloads de Godot combine à la fois l'accessibilité des services globaux et la rigueur d'une architecture modulaire avec initialisation contrôlée. Elle offre une solution robuste aux problèmes de dépendances tout en gardant le code maintenable et évolutif.
