# Tâches des Services Core - La Voie Romaine

Ces tâches concernent l'implémentation des services principaux du jeu, triées dans un ordre qui garantit de ne pas être bloqué par des dépendances.

## SERV-01: Implémentation du StatisticsService

**Priorité :** Haute  
**Dépend de :** ARCH-02, ARCH-03  
**Estimation :** 4 heures  
**Sources :** `implementation_data_service.md`, `implementation_game_manager.md`

### Description
Implémenter un service spécialisé pour la gestion des statistiques de jeu. Ce service suivra les événements du jeu et maintiendra un historique des statistiques importantes, tout en respectant le principe de responsabilité unique.

### Critères de validation
- [ ] Organisation des statistiques en catégories (jeu, dices, économie, accomplissements)
- [ ] Système d'enregistrement et de suivi des statistiques de jeu
- [ ] Intégration avec les services existants (CashService, ScoreService, DiceService)
- [ ] Méthodes dédiées pour suivre les événements de jeu
- [ ] Implémentation des méthodes de sauvegarde/chargement
- [ ] Suivi du temps de jeu

### Notes techniques
```gdscript
# /services/statistics/statistics_service.gd
extends BaseService
class_name StatisticsService

# Signal émis quand une statistique est mise à jour
signal statistic_changed(category, name, value)

# Dépendances de services
var cash_service: CashService = null
var score_service: ScoreService = null
var dice_service: DiceService = null

# Statistiques par catégories
var _statistics: Dictionary = {
    "game": {
        "total_games_played": 0,
        "total_time_played": 0.0,
        "best_score": 0
    },
    "dice": {
        "total_throws": 0,
        "successful_throws": 0,
        "beugnettes": 0
    },
    "economy": {
        "total_gold_earned": 0,
        "total_gold_spent": 0
    }
}
```

---

## SERV-02: Implémentation du RulesService

**Priorité :** Haute  
**Dépend de :** ARCH-02, ARCH-03  
**Estimation :** 5 heures  
**Sources :** `implementation_rules_manager.md`, `_specs_/game_design_incremental.md`

### Description
Implémenter le service qui gère les règles du jeu, notamment le système de buts (6→5→4→3→2→1), les règles de Beugnette et Super Beugnette, et la résolution des lancers de dés.

### Critères de validation
- [ ] Configuration des règles de base (nombre d'essais par but)
- [ ] Implémentation de la logique des Beugnettes et Super Beugnettes
- [ ] Système pour résoudre les lancers et déterminer les réussites/échecs
- [ ] Calcul des récompenses en fonction du but atteint
- [ ] Flexibilité pour modifier les règles (challenges)

### Notes techniques
```gdscript
# /services/rules_service.gd
extends BaseService
class_name RulesService

# Structure des règles
var rules_config = {
    "goal_attempts": {6: 6, 5: 5, 4: 4, 3: 3, 2: 2, 1: 1},
    "beugnette_enabled": true,
    "super_beugnette_enabled": true,
    "super_beugnette_goals": [1]  # Par défaut uniquement pour le but 1
}

func resolve_throw(dice_value: int, current_goal: int, remaining_attempts: int) -> Dictionary:
    # Logique de résolution d'un lancer
    var result = {
        "success": dice_value == current_goal,
        "beugnette": false,
        "super_beugnette": false,
        "new_goal": current_goal,
        "new_attempts": remaining_attempts - 1,
        "reward": 0
    }
    
    # Vérifier conditions de Beugnette
    if rules_config.beugnette_enabled and dice_value == current_goal + 1 and result.new_attempts <= 0:
        result.beugnette = true
        result.new_attempts = rules_config.goal_attempts[current_goal]
    
    # Vérifier conditions de Super Beugnette
    if rules_config.super_beugnette_enabled and current_goal in rules_config.super_beugnette_goals:
        if dice_value == 6 and current_goal == 1 and result.new_attempts <= 0:
            result.super_beugnette = true
            result.new_goal = 6
            result.new_attempts = rules_config.goal_attempts[6]
    
    # Calculer récompense si succès
    if result.success:
        result.reward = calculate_reward(current_goal)
        
    return result
```

---

## SERV-03: Implémentation du UpgradeService

**Priorité :** Haute  
**Dépend de :** SERV-01, ARCH-03  
**Estimation :** 6 heures  
**Sources :** `implementation_game_manager.md`, `_specs_/game_design_incremental.md`

### Description
Implémenter le service de gestion des améliorations achetables, qui permettra au joueur de dépenser son or pour améliorer différents aspects du jeu.

### Critères de validation
- [ ] Définition des différents types d'améliorations (vitesse, critique, etc.)
- [ ] Système de coûts avec progression géométrique
- [ ] Méthodes pour acheter des améliorations et vérifier le coût
- [ ] Application des effets des améliorations au gameplay
- [ ] Interface pour lire les données des améliorations (pour l'UI)

### Notes techniques
```gdscript
# /services/upgrade_service.gd
extends BaseService
class_name UpgradeService

# Service de données de jeu, injecté via setup_dependencies
var game_data: GameDataService

# Définitions des améliorations
var upgrade_definitions = {
    "throw_speed": {
        "name": "Vitesse de lancer",
        "description": "Augmente la vitesse de lancer de dés",
        "base_cost": 50,
        "cost_multiplier": 1.5,
        "effect_per_level": 0.1,  # +10% par niveau
        "max_level": 100
    },
    "critical_chance": {
        "name": "Chance critique",
        "description": "Augmente la chance d'obtenir un critique",
        "base_cost": 100,
        "cost_multiplier": 2.0,
        "effect_per_level": 0.01,  # +1% par niveau
        "max_level": 100
    },
    # Autres améliorations...
}

# Niveaux actuels des améliorations
var upgrades = {}

func initialize() -> void:
    # Initialiser tous les upgrades à 0
    for upgrade_id in upgrade_definitions.keys():
        upgrades[upgrade_id] = 0
    super.initialize()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
    if dependencies.has("game_data"):
        game_data = dependencies.game_data
    super.setup_dependencies(dependencies)

func get_upgrade_cost(upgrade_id: String) -> int:
    if not upgrade_id in upgrade_definitions:
        return 0
        
    var def = upgrade_definitions[upgrade_id]
    var level = upgrades[upgrade_id]
    
    # Vérifier si niveau maximum atteint
    if level >= def.max_level:
        return -1
        
    return int(def.base_cost * pow(def.cost_multiplier, level))
    
func purchase_upgrade(upgrade_id: String) -> bool:
    if not upgrade_id in upgrade_definitions:
        return false
        
    var cost = get_upgrade_cost(upgrade_id)
    if cost <= 0 or not game_data.spend_gold(cost):
        return false
        
    upgrades[upgrade_id] += 1
    return true
    
func get_upgrade_effect(upgrade_id: String) -> float:
    if not upgrade_id in upgrade_definitions:
        return 0.0
        
    var def = upgrade_definitions[upgrade_id]
    var level = upgrades[upgrade_id]
    
    return def.effect_per_level * level
```

---

## SERV-04: Implémentation du GameService

**Priorité :** Haute  
**Dépend de :** SERV-01, SERV-02, SERV-03  
**Estimation :** 8 heures  
**Sources :** `implementation_game_service.md`, `implementation_gameplay_services.md`

### Description
Implémenter le service principal qui coordonne le gameplay, reliant les autres services et gérant la boucle de jeu globale, le prestige, et les sauvegardes.

### Critères de validation
- [ ] Coordination du système de lancer de dés avec les règles
- [ ] Gestion des récompenses et de la progression
- [ ] Système de prestige avec réinitialisation contrôlée
- [ ] Sauvegarde et chargement des données du jeu
- [ ] Gestion du temps hors-ligne

### Notes techniques
```gdscript
# /services/game_service.gd
extends BaseService
class_name GameService

# Services dépendants
var data_service: GameDataService
var rules_service: RulesService
var upgrade_service: UpgradeService

# État du jeu actuel
var active: bool = false
var last_save_time: int = 0
var save_interval: int = 60  # Sauvegarde toutes les 60 secondes

func setup_dependencies(dependencies: Dictionary = {}) -> void:
    if dependencies.has("data_service"):
        data_service = dependencies.data_service
    if dependencies.has("rules_service"):
        rules_service = dependencies.rules_service
    if dependencies.has("upgrade_service"):
        upgrade_service = dependencies.upgrade_service
    super.setup_dependencies(dependencies)

func start() -> void:
    active = true
    super.start()
    
func _process(delta: float) -> void:
    if not active:
        return
        
    # Sauvegarde automatique
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_save_time >= save_interval:
        save_game()
        last_save_time = current_time

func save_game() -> bool:
    var save_data = {
        "game_data": data_service.get_save_data(),
        "rules": rules_service.get_save_data(),
        "upgrades": upgrade_service.get_save_data(),
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Logique de sauvegarde...
    return true
    
func load_game() -> bool:
    # Logique de chargement...
    return true
    
func prestige() -> bool:
    # Calculer les reliques à gagner
    var relics_to_gain = calculate_relics_gain()
    if relics_to_gain <= 0:
        return false
        
    # Ajouter les reliques
    data_service.add_relics(relics_to_gain)
    
    # Réinitialiser avec persistance
    reset(true)
    return true
    
func reset(with_persistence: bool = false) -> void:
    # Réinitialiser tous les services dans l'ordre
    upgrade_service.reset(with_persistence)
    rules_service.reset(with_persistence)
    data_service.reset(with_persistence)
    
    # Émettre le signal de réinitialisation
    super.reset(with_persistence)
```

---

## SERV-05: Intégration des systèmes de dés

**Priorité :** Moyenne  
**Dépend de :** SERV-02, SERV-04  
**Estimation :** 4 heures  
**Sources :** `implementation_gameplay_services.md`, `_specs_/game_design_incremental.md`

### Description
Intégrer la gestion des dés (types, placement, lancers) avec les services de règles et de jeu pour permettre la diversification des dés et leurs comportements spéciaux.

### Critères de validation
- [ ] Système de typologie des dés (standard, doré, chanceux, etc.)
- [ ] Intégration avec le placement des dés sur la table
- [ ] Comportements spéciaux par type de dé
- [ ] Gestion des lancers multiples
- [ ] Système d'achat/déverrouillage de nouveaux dés

### Notes techniques
Les dés doivent fonctionner avec la classe `Dices` existante, qui gère déjà le positionnement des dés sur la table. Il faudra étendre ce système pour prendre en compte les différents types de dés et leurs effets spéciaux.

---

## SERV-06: Système de Fièvre

**Priorité :** Moyenne  
**Dépend de :** SERV-01, SERV-04  
**Estimation :** 5 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_gameplay_services.md`

### Description
Implémenter le système de Fièvre qui permet au joueur d'interagir activement en tapotant l'écran pour remplir une jauge qui offre des multiplicateurs temporaires.

### Critères de validation
- [ ] Jauge de Fièvre avec remplissage par interaction
- [ ] Système de décroissance lorsque l'interaction cesse
- [ ] Multiplicateurs progressifs selon le niveau de remplissage
- [ ] Application des effets aux gains d'or et de score
- [ ] Effets visuels indiquant l'état de la jauge

### Notes techniques
```gdscript
# /services/fever_service.gd
extends BaseService
class_name FeverService

signal fever_changed(value)

# Services dépendants
var game_data: GameDataService

# Paramètres de la fièvre
var fever_value: float = 0.0
var max_fever: float = 100.0
var decay_rate: float = 5.0  # Unités par seconde
var increase_per_tap: float = 2.0

# Niveaux de multiplicateur
var fever_multipliers = {
    0.25: 1.25,  # 25% = x1.25
    0.5: 1.5,    # 50% = x1.5
    0.75: 2.0,   # 75% = x2
    1.0: 3.0     # 100% = x3
}

func _process(delta: float) -> void:
    # Appliquer la décroissance
    if fever_value > 0:
        fever_value = max(0, fever_value - decay_rate * delta)
        fever_changed.emit(fever_value / max_fever)

func handle_tap() -> void:
    # Augmenter la fièvre lors d'un tap
    fever_value = min(max_fever, fever_value + increase_per_tap)
    fever_changed.emit(fever_value / max_fever)
    
func get_current_multiplier() -> float:
    # Trouver le multiplicateur correspondant au niveau actuel
    var ratio = fever_value / max_fever
    var multiplier = 1.0
    
    for threshold in fever_multipliers.keys():
        if ratio >= threshold:
            multiplier = fever_multipliers[threshold]
            
    return multiplier
```
