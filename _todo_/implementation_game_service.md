# Service Principal de Jeu pour La Voie Romaine

Ce document décrit l'implémentation du service principal de gestion de jeu pour La Voie Romaine, qui coordonne les autres services et gère les sauvegardes.

## Service de Gestion de Jeu

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
    
    if result.score_reward > 0:
        Services.game_data.add_score(result.score_reward)
    
    # Mettre à jour les statistiques
    Services.game_data.total_throws += 1
    
    if result.is_goal_reached:
        Services.game_data.total_goals_reached += 1
        
    if result.is_beugnette:
        Services.game_data.total_beugnettes += 1
        
    if result.is_super_beugnette:
        Services.game_data.total_super_beugnettes += 1
```
