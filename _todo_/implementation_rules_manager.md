# Implémentation du système Rules Manager pour La Voie Romaine

Ce document décrit l'implémentation d'un système modulaire de règles pour le jeu La Voie Romaine, permettant de facilement configurer différents modes de jeu, challenges et mini-jeux.

## Objectifs

- Extérioriser les règles du jeu actuellement codées dans `scenes/dice.gd`
- Créer un système modulaire et extensible de règles
- Permettre la création facile de variantes de jeu (challenges, mini-jeux)
- Maintenir la compatibilité avec le fonctionnement actuel

## Structure des fichiers à créer

### 1. Service principal - Rules Manager

**Fichier:** `/services/rules_manager.gd`

```gdscript
extends Node

class_name RulesManager

signal rules_changed

# Collection de règles actives
var active_rules: Array = []

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
func resolve_throw(dice: Dice, value: int) -> ThrowResult:
    # Créer un résultat initial basé sur l'état actuel du dé
    var result = ThrowResult.new(dice.goal, dice.tries)
    
    # Appliquer chaque règle, qui met à jour le résultat
    for rule in active_rules:
        if rule.is_applicable(dice, value, result):
            rule.apply(dice, value, result)
    
    return result

# Chargement des règles par défaut au démarrage
func _ready() -> void:
    # Ajouter les règles standard par défaut
    add_rule(StandardGoalRule.new())
    add_rule(BeugnetteRule.new())
    add_rule(SuperBeugnetteRule.new())
    
# Fonctions pour appliquer des presets de règles prédéfinis
func apply_standard_rules() -> void:
    set_rules([
        StandardGoalRule.new(),
        BeugnetteRule.new(),
        SuperBeugnetteRule.new()
    ])

func apply_challenge_no_beugnette() -> void:
    set_rules([
        StandardGoalRule.new(),
        SuperBeugnetteRule.new()
        # Notez l'absence de BeugnetteRule
    ])

func apply_challenge_generalized_super_beugnette() -> void:
    set_rules([
        StandardGoalRule.new(),
        BeugnetteRule.new(),
        GeneralizedSuperBeugnetteRule.new()
    ])
```

### 2. Classe de base pour les règles

**Fichier:** `/services/rules/dice_rule.gd`

```gdscript
extends Resource

class_name DiceRule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return false  # À surcharger dans les classes enfants

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    # À surcharger dans les classes enfants
    result.rule_applied(get_rule_name())

func get_rule_name() -> String:
    return "BaseRule"
```

### 3. Règles standards

**Fichier:** `/services/rules/standard_goal_rule.gd`

```gdscript
extends DiceRule

class_name StandardGoalRule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return value == dice.goal

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    # Règle standard - même valeur que goal
    result.new_goal = dice.goal - 1 if dice.goal > 1 else 6
    result.new_tries = result.new_goal
    result.add_gold(7 - dice.goal)
    result.add_message("Goal!")
```

**Fichier:** `/services/rules/beugnette_rule.gd`

```gdscript
extends DiceRule

class_name BeugnetteRule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return dice.tries == 1 and value == dice.goal + 1

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    result.new_tries = dice.goal
    result.add_message("Beugnette!")
```

**Fichier:** `/services/rules/super_beugnette_rule.gd`

```gdscript
extends DiceRule

class_name SuperBeugnetteRule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return dice.goal == 1 and value == 6

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    result.new_goal = 6
    result.new_tries = -1
    result.add_message("Super beugnette...")
```

### 4. Règles pour challenges (exemples)

**Fichier:** `/services/rules/generalized_super_beugnette_rule.gd`

```gdscript
extends DiceRule

class_name GeneralizedSuperBeugnetteRule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return value == 6  # Peut se produire à n'importe quel goal

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    result.new_goal = 6
    result.new_tries = -1
    result.add_message("Super beugnette généralisée!")
```

### 5. Classe ThrowResult

**Fichier:** `/services/rules/throw_result.gd`

```gdscript
class_name ThrowResult
extends RefCounted

var new_goal: int  # Le nouveau goal après application des règles
var new_tries: int  # Le nouveau nombre d'essais après application des règles
var gold_reward: int = 0  # Récompense en or
var messages: Array[String] = []  # Messages à afficher
var special_effects: Dictionary = {}  # Effets spéciaux (animations, sons, etc.)
var rules_applied: Array[String] = []  # Liste des règles appliquées pour le debug

# Initialise le résultat avec les valeurs actuelles du dé
func _init(initial_goal: int, initial_tries: int) -> void:
    new_goal = initial_goal
    new_tries = initial_tries

# Ajoute un message à afficher
func add_message(message: String) -> void:
    messages.append(message)

# Ajoute de l'or à la récompense
func add_gold(amount: int) -> void:
    gold_reward += amount

# Marque qu'une règle a été appliquée
func rule_applied(rule_name: String) -> void:
    rules_applied.append(rule_name)
```

## Modifications à apporter au code existant

### 1. Créer le dossier pour les règles

```
mkdir -p /Users/antoinedufou/voie-romaine/services/rules
```

### 2. Mettre à jour le système de services

Ajouter RulesManager dans votre système de services existant. Si vous utilisez un autoload ou un singleton :

1. Créer une instance de `RulesManager` dans le script d'autoload
2. Exposer cette instance via une propriété `rules_manager`

### 3. Modifier la classe Dice

**Fichier:** `/scenes/dice.gd`

Remplacer la fonction `throw_resolve()` actuelle:

```gdscript
func throw_resolve() -> void:
    var result = Services.rules_manager.resolve_throw(self, value)
    
    # Appliquer les résultats
    if result.new_goal != goal:
        goal = result.new_goal
    
    if result.new_tries != tries:
        tries = result.new_tries
    
    if result.gold_reward > 0:
        add_gold_reward(result.gold_reward)
    
    # Afficher les messages
    for message in result.messages:
        pop_up_message(message)
    
    # Vérifier les conditions spéciales
    if goal == 1 and value == goal:
        win()
```

Supprimer ou commenter les fonctions suivantes qui sont désormais gérées par le système de règles:
- Les parties du code qui vérifient la "beugnette"
- Les parties du code qui vérifient la "super beugnette"

## Exemples d'utilisation des règles pour des challenges

### Challenge "Sans filet" (désactivation de la beugnette)

```gdscript
# Dans un script qui initialise le challenge
Services.rules_manager.apply_challenge_no_beugnette()

# Pour revenir aux règles normales
Services.rules_manager.apply_standard_rules()
```

### Challenge "Super Beugnette généralisée"

```gdscript
# Dans un script qui initialise le challenge
Services.rules_manager.apply_challenge_generalized_super_beugnette()
```

## Extensions possibles

### Mini-jeu "Voie Express"

**Fichier:** `/services/rules/express_multiplier_rule.gd`

```gdscript
class_name ExpressMultiplierRule
extends Rule

func is_applicable(dice: Dice, value: int, result: ThrowResult) -> bool:
    return value == result.new_goal

func apply(dice: Dice, value: int, result: ThrowResult) -> void:
    # Ajouter un effet spécial
    result.special_effects["express_multiplier"] = {
        "value": 1.1,
        "duration": 30
    }
    # Ajouter un message
    result.add_message("Voie Express activée ! Multiplicateur x1.1")
    # Marquer que la règle a été appliquée
    result.rule_applied(get_rule_name())

func get_rule_name() -> String:
    return "ExpressMultiplier"
```

## Avantages du nouveau système

1. **Modularité** : Ajoutez/retirez des règles à volonté
2. **Flexibilité** : Créez des configurations de règles pour différents modes
3. **Découplage** : La logique de règles est séparée du comportement du dé
4. **Extension facile** : Ajoutez de nouvelles règles sans modifier le code existant
5. **Testabilité** : Les règles peuvent être testées individuellement
