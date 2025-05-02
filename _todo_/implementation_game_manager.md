# Implémentation du système Game Manager pour La Voie Romaine

Ce document décrit l'implémentation du système Game Manager pour La Voie Romaine, en utilisant une approche modulaire avec des services via le mécanisme d'Autoload de Godot.

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

### 2. Services spécifiques

#### 2.1 Service de Données de Jeu

**Fichier:** `/services/game_data_service.gd`

```gdscript
extends BaseService
class_name GameDataService

signal gold_changed(new_amount)
signal score_changed(new_amount)
signal relics_changed(new_amount)

# --- Données économiques ---
var gold: int = 0
var score: int = 0
var total_gold_earned: int = 0

# --- Données de prestige ---
var relics: int = 0
var talent_points: int = 0
var talents_purchased: Dictionary = {}

# --- Statistiques ---
var total_throws: int = 0
var total_goals_reached: int = 0
var total_beugnettes: int = 0
var total_super_beugnettes: int = 0
var highest_score: int = 0
var total_prestiges: int = 0

# --- Métadonnées ---
var last_saved: int = 0  # Timestamp

func initialize() -> void:
    # Initialiser uniquement les propriétés internes
    # sans accéder à d'autres services
    super.initialize()

func setup_dependencies(_dependencies: Dictionary = {}) -> void:
    # Ce service n'a pas de dépendances directes
    pass

func start() -> void:
    # Démarrer les fonctionnalités qui pourraient nécessiter d'autres services
    # Par exemple, calculer les gains hors-ligne au démarrage
    super.start()

func add_gold(amount: int) -> void:
    gold += amount
    total_gold_earned += amount
    gold_changed.emit(gold)
    
func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        gold_changed.emit(gold)
        return true
    return false

func add_score(amount: int) -> void:
    score += amount
    highest_score = max(highest_score, score)
    score_changed.emit(score)

func add_relics(amount: int) -> void:
    relics += amount
    relics_changed.emit(relics)

func reset(with_persistence: bool = false) -> void:
    # Conserver certaines données si with_persistence est vrai
    if not with_persistence:
        relics = 0
        talent_points = 0
        talents_purchased.clear()
        total_prestiges = 0
    
    # Toujours réinitialiser ces valeurs
    gold = 0
    score = 0
    
    # Augmenter le compteur de prestiges si c'est une réinitialisation avec prestige
    if with_persistence:
        total_prestiges += 1
        
    super.reset(with_persistence)

# Remplace get_save_data de la classe parente
func get_save_data() -> Dictionary:
    var base_data = super.get_save_data()
    
    # Ajouter nos données spécifiques
    var data = {
        "gold": gold,
        "score": score,
        "total_gold_earned": total_gold_earned,
        "relics": relics,
        "talent_points": talent_points,
        "talents_purchased": talents_purchased,
        "total_throws": total_throws,
        "total_goals_reached": total_goals_reached,
        "total_beugnettes": total_beugnettes,
        "total_super_beugnettes": total_super_beugnettes,
        "highest_score": highest_score,
        "total_prestiges": total_prestiges,
        "last_saved": Time.get_unix_time_from_system()
    }
    
    # Fusionner avec les données de base
    base_data.merge(data)
    return base_data
    
# Remplace load_save_data de la classe parente
func load_save_data(data: Dictionary) -> bool:
    if not super.load_save_data(data):
        return false
        
    # Charger nos données spécifiques si elles existent
    if data.has("gold"):
        gold = data.gold
    if data.has("score"):
        score = data.score
    if data.has("total_gold_earned"):
        total_gold_earned = data.total_gold_earned
    if data.has("relics"):
        relics = data.relics
    if data.has("talent_points"):
        talent_points = data.talent_points
    if data.has("talents_purchased"):
        talents_purchased = data.talents_purchased
    if data.has("total_throws"):
        total_throws = data.total_throws
    if data.has("total_goals_reached"):
        total_goals_reached = data.total_goals_reached
    if data.has("total_beugnettes"):
        total_beugnettes = data.total_beugnettes
    if data.has("total_super_beugnettes"):
        total_super_beugnettes = data.total_super_beugnettes
    if data.has("highest_score"):
        highest_score = data.highest_score
    if data.has("total_prestiges"):
        total_prestiges = data.total_prestiges
        
    return true
```

#### 2.2 Service de Règles du Jeu

**Fichier:** `/services/rules_service.gd`

```gdscript
extends BaseService
class_name RulesService

signal rules_changed

# Collection de règles actives
var active_rules: Array = []
var active_challenge_id: String = ""

# Initialisation en trois phases
func initialize() -> void:
    # Ne pas appliquer les règles ici pour éviter les dépendances prématurées
    super.initialize()

func setup_dependencies(_dependencies: Dictionary = {}) -> void:
    # Configuration des dépendances (si nécessaire pour des règles spéciales)
    pass

func start() -> void:
    # Appliquer les règles standard au démarrage
    apply_standard_rules()
    super.start()

# Ajoute une règle
func add_rule(rule: DiceRule) -> void:
    active_rules.append(rule)
    rules_changed.emit()

# Retire une règle
func remove_rule(rule: DiceRule) -> void:
    active_rules.erase(rule)
    rules_changed.emit()

# Remplace toutes les règles
func set_rules(rules: Array) -> void:
    active_rules = rules.duplicate()
    rules_changed.emit()

# Méthodes pour résoudre les lancers
func resolve_throw(dice, value: int) -> ThrowResult:
    # Créer un résultat initial basé sur l'état actuel du dé
    var result = ThrowResult.new(dice.goal, dice.tries)
    
    # Appliquer chaque règle, qui met à jour le résultat
    for rule in active_rules:
        if rule.is_applicable(dice, value, result):
            rule.apply(dice, value, result)
    
    return result

# Fonctions pour appliquer des presets de règles prédéfinis
func apply_standard_rules() -> void:
    set_rules([
        StandardGoalRule.new(),
        BeugnetteRule.new(),
        SuperBeugnetteRule.new()
    ])
    active_challenge_id = ""

func apply_challenge_no_beugnette() -> void:
    set_rules([
        StandardGoalRule.new(),
        SuperBeugnetteRule.new()
        # Notez l'absence de BeugnetteRule
    ])
    active_challenge_id = "no_beugnette"

func apply_challenge_generalized_super_beugnette() -> void:
    set_rules([
        StandardGoalRule.new(),
        BeugnetteRule.new(),
        GeneralizedSuperBeugnetteRule.new()
    ])
    active_challenge_id = "generalized_super_beugnette"

# Gestion des sauvegardes
func get_save_data() -> Dictionary:
    var base_data = super.get_save_data()
    base_data["active_challenge_id"] = active_challenge_id
    return base_data
    
func load_save_data(data: Dictionary) -> bool:
    if not super.load_save_data(data):
        return false
        
    if data.has("active_challenge_id"):
        var challenge_id = data.active_challenge_id
        match challenge_id:
            "no_beugnette":
                apply_challenge_no_beugnette()
            "generalized_super_beugnette":
                apply_challenge_generalized_super_beugnette()
            _:
                apply_standard_rules()
    else:
        apply_standard_rules()
        
    return true
```

#### 2.3 Service de Gestion des Upgrades

**Fichier:** `/services/upgrade_service.gd`

```gdscript
extends BaseService
class_name UpgradeService

signal upgrade_purchased(upgrade_id, new_level)
signal dice_type_unlocked(dice_type)

# Données des upgrades et dés
var upgrades: Dictionary = {}
var unlocked_dice_types: Array[String] = ["standard"]

# Dépendances
var game_data: GameDataService

# Définition des upgrades disponibles avec leurs coûts de base et taux de croissance
var upgrade_definitions: Dictionary = {
    "speed": {"base_cost": 50, "growth_rate": 1.5, "name": "Vitesse de lancer", "description": "+10% vitesse/niveau"},
    "crit_chance": {"base_cost": 100, "growth_rate": 2.0, "name": "Chance critique", "description": "+1% chance/niveau"},
    "gold_mult": {"base_cost": 75, "growth_rate": 1.8, "name": "Multiplicateur d'or", "description": "+10% or/niveau"},
    "auto_throw": {"base_cost": 500, "growth_rate": 3.0, "name": "Lanceurs auto", "description": "+1 lancer auto/5s"},
    "dice_slot": {"base_cost": 1000, "growth_rate": 4.0, "name": "Emplacement de dé", "description": "+1 dé sur table"}
}

# Définition des types de dés
var dice_type_definitions: Dictionary = {
    "standard": {"cost": 0, "name": "Dé standard", "description": "Probabilités standard (1/6 pour chaque face)"},
    "gold": {"cost": 5000, "name": "Dé doré", "description": "+50% or par lancer réussi, mais -10% de chance d'obtenir le goal"},
    "lucky": {"cost": 5000, "name": "Dé chanceux", "description": "+20% de chance d'obtenir le goal, mais -25% d'or par lancer"},
    "risky": {"cost": 10000, "name": "Dé risqué", "description": "40% de chance de doubler l'or gagné, 20% de chance de tout perdre"},
    "ancient": {"cost": -1, "name": "Dé antique", "description": "Peut activer des effets spéciaux rares (extra-essais, bonus temporaires)", "requires_relics": 1}
}

# Initialisation en trois phases
func initialize() -> void:
    # Initialiser les upgrades au niveau 0
    for upgrade_id in upgrade_definitions.keys():
        upgrades[upgrade_id] = 0
    
    super.initialize()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
    # Configurer la dépendance au service de données
    if dependencies.has("game_data"):
        game_data = dependencies.game_data

func start() -> void:
    # Démarrer les fonctionnalités qui requièrent d'autres services
    # Vérifier les upgrades déjà débloqués, appliquer leurs effets, etc.
    super.start()

# Calculer le coût pour le prochain niveau d'un upgrade
func get_upgrade_cost(upgrade_id: String) -> int:
    var definition = upgrade_definitions.get(upgrade_id)
    if not definition:
        return -1
        
    var current_level = upgrades.get(upgrade_id, 0)
    return int(definition.base_cost * pow(definition.growth_rate, current_level))

# Acheter un niveau d'upgrade
func purchase_upgrade(upgrade_id: String) -> bool:
    var cost = get_upgrade_cost(upgrade_id)
    if cost <= 0 or not game_data: # Vérifier que la dépendance est configurée
        return false
        
    if game_data.spend_gold(cost):
        upgrades[upgrade_id] = upgrades.get(upgrade_id, 0) + 1
        upgrade_purchased.emit(upgrade_id, upgrades[upgrade_id])
        return true
    
    return false

# Débloquer un nouveau type de dé
func unlock_dice_type(dice_type: String) -> bool:
    if unlocked_dice_types.has(dice_type) or not game_data:
        return false
        
    var definition = dice_type_definitions.get(dice_type)
    if not definition:
        return false
        
    # Vérifier si le type nécessite des reliques
    if definition.has("requires_relics") and definition.requires_relics > 0:
        if game_data.relics < definition.requires_relics:
            return false
    else:
        # Sinon, c'est un achat en or
        var cost = definition.cost
        if cost < 0:
            return false
            
        if not game_data.spend_gold(cost):
            return false
    
    unlocked_dice_types.append(dice_type)
    dice_type_unlocked.emit(dice_type)
    return true

# Gestion des sauvegardes
func get_save_data() -> Dictionary:
    var base_data = super.get_save_data()
    base_data["upgrades"] = upgrades.duplicate()
    base_data["unlocked_dice_types"] = unlocked_dice_types.duplicate()
    return base_data
    
func load_save_data(data: Dictionary) -> bool:
    if not super.load_save_data(data):
        return false
        
    if data.has("upgrades"):
        upgrades = data.upgrades.duplicate()
        
    if data.has("unlocked_dice_types"):
        unlocked_dice_types = data.unlocked_dice_types.duplicate()
        
    return true
    
# Réinitialisation
func reset(with_persistence: bool = false) -> void:
    # Toujours réinitialiser les upgrades
    for upgrade_id in upgrade_definitions.keys():
        upgrades[upgrade_id] = 0
        
    # Réinitialiser les types de dés si ce n'est pas une persistence
    if not with_persistence:
        unlocked_dice_types = ["standard"]
        
    super.reset(with_persistence)
```

#### 2.4 Service principal de sauvegarde et gestion de jeu

**Fichier:** `/services/game_service.gd`

```gdscript
extends BaseService
class_name GameService

signal game_saved
signal game_loaded
signal game_reset(with_persistence)
signal offline_progress_calculated(progress_data)

# Références aux autres services (seront injectées via setup_dependencies)
var data_service: GameDataService
var rules_service: RulesService
var upgrade_service: UpgradeService

# Chemin pour la sauvegarde
const SAVE_PATH = "user://voie_romaine_save.json"

# Timer pour auto-sauvegarde
var auto_save_timer: Timer

func _init():
    # Créer le timer d'auto-sauvegarde
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = 60.0  # 60 secondes
    auto_save_timer.one_shot = false
    auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)

# Phase 1: Initialisation de base
func initialize() -> void:
    # Configuration de base sans dépendances
    add_child(auto_save_timer)
    super.initialize()

# Phase 2: Configuration des dépendances
func setup_dependencies(dependencies: Dictionary = {}) -> void:
    # Injecter les dépendances
    if dependencies.has("data_service"):
        data_service = dependencies.data_service
    if dependencies.has("rules_service"):
        rules_service = dependencies.rules_service
    if dependencies.has("upgrade_service"):
        upgrade_service = dependencies.upgrade_service

# Phase 3: Démarrage après configuration
func start() -> void:
    # Démarrer le timer
    auto_save_timer.start()
    
    # Essayer de charger le jeu sauvegardé, sinon initialiser un nouveau jeu
    if not load_game():
        reset(false)
    else:
        # Vérifier s'il y a eu des progrès hors-ligne
        calculate_offline_progress()
    
    super.start()

# Gestion des sauvegardes
func save_game() -> bool:
    var save_data = {
        "game_service": get_save_data(),
        "data_service": data_service.get_save_data(),
        "rules_service": rules_service.get_save_data(),
        "upgrade_service": upgrade_service.get_save_data()
    }
    
    var json_string = JSON.stringify(save_data)
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(json_string)
        file.close()
        game_saved.emit()
        return true
    
    return false

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
        
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        return false
        
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        return false
        
    var save_data = json.get_data()
    
    # Charger les données pour chaque service
    if save_data.has("data_service"):
        data_service.load_save_data(save_data.data_service)
        
    if save_data.has("rules_service"):
        rules_service.load_save_data(save_data.rules_service)
        
    if save_data.has("upgrade_service"):
        upgrade_service.load_save_data(save_data.upgrade_service)
        
    if save_data.has("game_service"):
        load_save_data(save_data.game_service)
    
    game_loaded.emit()
    
    # Vérifier s'il y a eu des progrès hors-ligne
    calculate_offline_progress()
    
    return true

# Réinitialisation du jeu (prestige ou nouveau jeu)
func reset(with_persistence: bool = false) -> void:
    # Calculer les points de prestige si nécessaire
    if with_persistence:
        var prestige_points = _calculate_prestige_points()
        data_service.add_relics(prestige_points)
    
    # Réinitialiser tous les services
    data_service.reset(with_persistence)
    rules_service.reset(with_persistence)
    upgrade_service.reset(with_persistence)
    
    super.reset(with_persistence)
    game_reset.emit(with_persistence)

# Calcul des points de prestige
func _calculate_prestige_points() -> int:
    # Formule: Log(or_total/1000)
    if data_service.total_gold_earned < 1000:
        return 0
    return int(log(data_service.total_gold_earned / 1000.0) / log(10))

# Gestion des sauvegarde / export
func export_save_data() -> String:
    var save_data = {
        "game_service": get_save_data(),
        "data_service": data_service.get_save_data(),
        "rules_service": rules_service.get_save_data(),
        "upgrade_service": upgrade_service.get_save_data()
    }
    
    return JSON.stringify(save_data)

func import_save_data(json_string: String) -> bool:
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        return false
        
    var save_data = json.get_data()
    
    # Charger les données pour chaque service
    if save_data.has("data_service"):
        data_service.load_save_data(save_data.data_service)
        
    if save_data.has("rules_service"):
        rules_service.load_save_data(save_data.rules_service)
        
    if save_data.has("upgrade_service"):
        upgrade_service.load_save_data(save_data.upgrade_service)
        
    if save_data.has("game_service"):
        load_save_data(save_data.game_service)
    
    game_loaded.emit()
    return true
    
# Calcul des progrès hors-ligne
func calculate_offline_progress() -> Dictionary:
    var last_saved = data_service.last_saved
    if last_saved <= 0:
        return {}
        
    var current_time = Time.get_unix_time_from_system()
    var time_offline = current_time - last_saved
    
    # Limiter le temps hors-ligne à 24h pour l'équilibrage
    time_offline = min(time_offline, 60 * 60 * 24)
    
    if time_offline <= 0:
        return {}
    
    # TODO: Implémenter la logique de calcul de l'or par seconde basée sur les upgrades
    var gold_per_second = _calculate_gold_per_second()
    
    var offline_gold = int(gold_per_second * time_offline)
    
    # Appliquer les gains
    if offline_gold > 0:
        data_service.add_gold(offline_gold)
    
    # Préparer les données de rapport
    var progress_data = {
        "time_away": time_offline,
        "gold_earned": offline_gold,
        "gold_per_second": gold_per_second
    }
    
    offline_progress_calculated.emit(progress_data)
    return progress_data

# Calcul de l'or par seconde (à implémenter en fonction des upgrades)
func _calculate_gold_per_second() -> float:
    # TODO: Implémenter en fonction de vos mécaniques exactes
    # Exemple simple basé sur le niveau d'auto-lancer
    var auto_throw_level = upgrade_service.upgrades.get("auto_throw", 0)
    return auto_throw_level * 0.5  # 0.5 or par seconde de base par niveau
    
# Timer de sauvegarde automatique
func _on_auto_save_timer_timeout() -> void:
    save_game()
```

### 3. Modification du fichier services.gd existant

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

## Utilisation du système

### Accès aux services

Grâce à l'utilisation des autoloads Godot, tous les services sont accessibles globalement via le singleton Services:

```gdscript
# Accéder au service de données
var current_gold = Services.game_data.gold

# Utiliser le service de règles
var result = Services.rules.resolve_throw(dice, value)

# Acheter une amélioration (plus besoin de passer le game_data explicitement)
Services.upgrades.purchase_upgrade("speed")

# Sauvegarder le jeu
Services.game.save_game()
```

### Exemple d'utilisation dans un script de dé

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

### Sauvegarde et chargement

La sauvegarde est centralisée dans le GameService qui coordonne les données de tous les services:

```gdscript
# Sauvegarder manuellement
Services.game.save_game()

# Pour les sauvegardes automatiques, elles sont gérées par le timer interne
# qui s'active toutes les 60 secondes

# Exporter la sauvegarde (pour partage entre appareils)
var save_string = Services.game.export_save_data()

# Importer une sauvegarde
Services.game.import_save_data(save_string)
```

### Prestige et réinitialisation

```gdscript
# Réinitialiser sans prestige (nouveau jeu)
Services.game.reset(false)

# Réinitialiser avec prestige (conserver reliques)
Services.game.reset(true)
```

### Gestion des challenges

```gdscript
# Activer un challenge spécifique
Services.rules.apply_challenge_no_beugnette()

# Revenir aux règles standard
Services.rules.apply_standard_rules()
```

## Installation

1. Créer les fichiers:
   - `/services/base_service.gd`
   - `/services/game_data_service.gd`
   - `/services/rules_service.gd` 
   - `/services/upgrade_service.gd`
   - `/services/game_service.gd`

2. Modifier `/autoload/services.gd` pour intégrer les nouveaux services

3. Créer les classes nécessaires pour les règles (comme décrit dans l'implémentation du rules_manager)

## Avantages de cette architecture

1. **Découplage**: Chaque service gère uniquement sa propre responsabilité
2. **Extensibilité**: Ajoutez facilement de nouveaux services sans modifier les existants
3. **Testabilité**: Testez chaque service indépendamment
4. **Compatibilité**: Fonctionne avec le système existant
5. **Maintenabilité**: Code organisé et bien structuré

## Extensions futures potentielles

### Service d'événements

```gdscript
class_name EventService
extends BaseService

signal event_triggered(event_id)

# Gestion d'événements aléatoires ou de quêtes
```

### Service d'achievements

```gdscript
class_name AchievementService
extends BaseService

signal achievement_unlocked(achievement_id)

# Suivi des accomplissements du joueur
```

### Service d'analyse

```gdscript
class_name AnalyticsService
extends BaseService

# Collecte et analyse des données de jeu pour l'équilibrage
```

## Conclusion

Cette architecture modulaire basée sur des services offre une solution robuste et extensible pour le jeu La Voie Romaine. Elle permet de:

1. Séparer clairement les responsabilités entre les différents systèmes
2. Faciliter la sauvegarde/chargement des données du jeu
3. Maintenir la compatibilité avec le système existant
4. Étendre facilement le jeu avec de nouvelles fonctionnalités
5. Simplifier la maintenance et le débogage

L'approche par services indépendants mais interconnectés est particulièrement bien adaptée pour un jeu incrémental qui va évoluer au fil du temps avec l'ajout de nouvelles fonctionnalités et mécaniques.
