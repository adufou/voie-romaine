# Implémentation du StatisticsService

## Résumé
Implémentation d'un service spécialisé pour la gestion des statistiques de jeu, en suivant le principe de responsabilité unique. Ce service s'intègre avec les services existants (CashService, ScoreService, et DiceService).

## Approach
Au lieu d'un GameDataService générique qui gère à la fois l'or, le score et les statistiques, nous implémentons un service dédié uniquement aux statistiques. Cette approche permet:
- Une meilleure séparation des responsabilités
- Une architecture plus modulaire et maintenable
- La conservation des services existants (CashService et ScoreService) comme sources de vérité pour leurs domaines respectifs

## Implémentation
- Création d'un service spécialisé `StatisticsService` qui hérite de `BaseService`
- Fonctionnalités:
  - Suivi des statistiques de jeu par catégories (jeu, dés, économie, accomplissements)
  - Enregistrement des records (meilleurs scores, temps de jeu, etc.)
  - Suivi du temps de jeu
  - Méthodes dédiées pour suivre différents événements de jeu
  - Intégration avec les services existants via signaux

## Architecture
Le StatisticsService recevra des notifications des services existants via des signaux et des méthodes dédiées:
- CashService reste la source de vérité pour l'or/cash
- ScoreService reste la source de vérité pour le score
- StatisticsService est la source de vérité pour toutes les statistiques de jeu

### Structure de données
Les statistiques seront organisées par catégories:
```gdscript
var _statistics: Dictionary = {
    "game": {
        "total_games_played": 0,
        "total_time_played": 0.0,
        "best_score": 0,
    },
    "dice": {
        "total_throws": 0,
        "successful_throws": 0,
        "beugnettes": 0,
        "super_beugnettes": 0,
        "perfect_games": 0,
    },
    "achievements": {
        "goals_reached": 0,
        "voie_romaine_completed": 0,
    },
    "economy": {
        "total_gold_earned": 0,
        "total_gold_spent": 0,
        "upgrades_purchased": 0,
    }
}
```

## Intégration
Le StatisticsService sera intégré à l'autoload Services:
- Préchargé et instancié comme les autres services spécialisés
- Configuré avec les dépendances vers CashService, ScoreService et DiceService
- Démarré après l'initialisation des autres services
- Intégré au système de sauvegarde/chargement

## À faire dans le futur
- Implémentation d'un AchievementsService dédié pour gérer les accomplissements
- Interfaces pour visualiser les statistiques dans l'UI
- Système d'exportation des statistiques pour analyse
