# Services de Gameplay pour La Voie Romaine

Ce document décrit l'implémentation des services de règles et d'améliorations pour La Voie Romaine.

## Service de Règles du Jeu

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

## Service de Gestion des Upgrades

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
