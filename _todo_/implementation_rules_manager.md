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
func resolve_throw(dice: Dice, value: int) -> Dictionary:
    var result = {
        "new_goal": dice.goal,
        "new_tries": dice.tries,
        "gold_reward": 0,
        "messages": [],
        "special_events": []
    }
    
    for rule in active_rules:
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

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    pass # À implémenter dans les classes dérivées
```

### 3. Règles standards

**Fichier:** `/services/rules/standard_goal_rule.gd`

```gdscript
extends DiceRule

class_name StandardGoalRule

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    if value == dice.goal:
        # Règle standard - même valeur que goal
        result.new_goal = dice.goal - 1 if dice.goal > 1 else 6
        result.new_tries = result.new_goal
        result.gold_reward += (7 - dice.goal)
        result.messages.append("Goal!")
```

**Fichier:** `/services/rules/beugnette_rule.gd`

```gdscript
extends DiceRule

class_name BeugnetteRule

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    if dice.tries == 1 and value == dice.goal + 1:
        result.new_tries = dice.goal
        result.messages.append("Beugnette!")
```

**Fichier:** `/services/rules/super_beugnette_rule.gd`

```gdscript
extends DiceRule

class_name SuperBeugnetteRule

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    if dice.goal == 1 and value == 6:
        result.new_goal = 6
        result.new_tries = -1
        result.messages.append("Super beugnette...")
```

### 4. Règles pour challenges (exemples)

**Fichier:** `/services/rules/generalized_super_beugnette_rule.gd`

```gdscript
extends DiceRule

class_name GeneralizedSuperBeugnetteRule

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    if value == 6:  # Peut se produire à n'importe quel goal
        result.new_goal = 6
        result.new_tries = -1
        result.messages.append("Super beugnette généralisée!")
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
extends DiceRule

class_name ExpressMultiplierRule

func apply(dice: Dice, value: int, result: Dictionary) -> void:
    if value == dice.goal:
        result.special_events.append({
            "type": "express_multiplier",
            "value": 1.1,
            "duration": 30
        })
```

## Avantages du nouveau système

1. **Modularité** : Ajoutez/retirez des règles à volonté
2. **Flexibilité** : Créez des configurations de règles pour différents modes
3. **Découplage** : La logique de règles est séparée du comportement du dé
4. **Extension facile** : Ajoutez de nouvelles règles sans modifier le code existant
5. **Testabilité** : Les règles peuvent être testées individuellement
