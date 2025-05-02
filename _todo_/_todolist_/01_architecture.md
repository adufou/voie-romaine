# Tâches d'architecture - La Voie Romaine

Ces tâches sont triées dans un ordre qui garantit de ne pas être bloqué par des dépendances.

## ARCH-01: Analyse de la structure existante

**Priorité :** Haute  
**Dépend de :** Aucune  
**Estimation :** 2 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_services.md`

### Description
Analyser la structure existante du projet, notamment le système de dés (`Dices`), de monnaie (`Cash`) et de score (`Score`) pour comprendre comment ils sont implémentés et comment les intégrer dans la nouvelle architecture.

### Critères de validation
- [ ] Documentation des classes existantes et de leur fonctionnement
- [ ] Identification des points d'intégration avec la nouvelle architecture
- [ ] Liste des modifications nécessaires pour assurer la compatibilité

### Notes techniques
Examiner particulièrement la classe `Dices` qui gère le positionnement des dés sur la table.

---

## ARCH-02: Implémentation de BaseService

**Priorité :** Haute  
**Dépend de :** ARCH-01  
**Estimation :** 3 heures  
**Sources :** `implementation_base_service.md`, `implementation_services.md`

### Description
Créer la classe de base `BaseService` qui sera héritée par tous les services du jeu, avec le système d'initialisation en trois phases et la gestion de sauvegarde/chargement.

### Critères de validation
- [ ] Méthodes `initialize()`, `setup_dependencies()` et `start()` implémentées
- [ ] Système de signaux pour la communication entre services
- [ ] Méthodes `get_save_data()` et `load_save_data()` pour la persistance
- [ ] Tests de fonctionnement avec un service simple

### Notes techniques
```gdscript
# /services/base_service.gd
extends Node
class_name BaseService

# Signaux communs que tous les services peuvent émettre
signal initialized
signal started
signal reset(with_persistence)

# Version du service pour la gestion de compatibilité des sauvegardes
var version: String = "0.0.1"
```

---

## ARCH-03: Création du Singleton Services

**Priorité :** Haute  
**Dépend de :** ARCH-02  
**Estimation :** 4 heures  
**Sources :** `implementation_services.md`, `implementation_game_manager.md`

### Description
Créer le service principal `Services` en tant qu'Autoload qui contiendra et initialisera tous les autres services, assurant ainsi l'ordre d'initialisation contrôlé.

### Critères de validation
- [ ] Structure de base du singleton Services avec les méthodes d'initialisation
- [ ] Mécanisme de création et d'ajout des services
- [ ] Processus d'initialisation en trois phases pour tous les services
- [ ] Configuration de l'Autoload dans le projet Godot

### Notes techniques
```gdscript
# /autoload/services.gd
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
```

---

## ARCH-04: Système de sauvegarde/chargement de base

**Priorité :** Haute  
**Dépend de :** ARCH-03  
**Estimation :** 5 heures  
**Sources :** `implementation_game_manager.md`, `implementation_data_service.md`

### Description
Implémenter le système de base pour sauvegarder et charger les données de jeu via les méthodes `get_save_data()` et `load_save_data()` de chaque service.

### Critères de validation
- [ ] Méthodes de sauvegarde et chargement au niveau du service principal
- [ ] Gestion des erreurs de chargement et compatibilité des versions
- [ ] Tests avec des données simples pour valider la persistance
- [ ] Sauvegarde automatique à des intervalles définis

### Notes techniques
Utiliser `JSON.stringify()` pour sérialiser les données et `JSON.parse()` pour les désérialiser. S'assurer que la structure de sauvegarde inclut des métadonnées comme la version du jeu.

---

## ARCH-05: Intégration des systèmes existants

**Priorité :** Haute  
**Dépend de :** ARCH-03, ARCH-04  
**Estimation :** 6 heures  
**Sources :** `implementation_services.md`, `implementation_game_manager.md`

### Description
Intégrer les systèmes existants (Cash, Score, Dices) dans la nouvelle architecture de services, assurant une transition fluide et une compatibilité complète.

### Critères de validation
- [ ] Systèmes existants accessibles via le singleton Services
- [ ] Compatibilité bidirectionnelle entre anciens et nouveaux systèmes
- [ ] Signaux connectés entre les services pour maintenir la synchronisation
- [ ] Tests d'intégration complets

### Notes techniques
```gdscript
# Dans Services._connect_signals()
game_data.gold_changed.connect(_on_gold_changed)
game_data.score_changed.connect(_on_score_changed)

# Handlers pour assurer la compatibilité
func _on_gold_changed(new_gold: int) -> void:
    cash.set_amount(new_gold)
    
func _on_score_changed(new_score: int) -> void:
    score.set_amount(new_score)
```

---

## ARCH-06: Système d'enregistrement et diagnostic

**Priorité :** Moyenne  
**Dépend de :** ARCH-03  
**Estimation :** 3 heures  
**Sources :** `implementation_game_manager.md`

### Description
Mettre en place un système de logs et de diagnostic pour faciliter le débogage pendant le développement et suivre les erreurs en production.

### Critères de validation
- [ ] Différents niveaux de log (DEBUG, INFO, WARNING, ERROR)
- [ ] Logs vers la console et/ou fichier
- [ ] Système de catégories pour filtrer les logs
- [ ] Interface pour consulter les logs en jeu (développement uniquement)

### Notes techniques
Créer une classe utilitaire `Logger` accessible via le singleton Services pour centraliser la gestion des logs.
