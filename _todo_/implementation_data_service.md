# Service de Données de Jeu pour La Voie Romaine

Ce document décrit l'implémentation du service de données de jeu pour La Voie Romaine, qui gère toutes les ressources et statistiques du joueur.

## Service de Données de Jeu

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
