# Implémentation du GameDataService

## Résumé
Implementation d'un service `GameDataService` pour gérer les statistiques du jeu, tout en s'intégrant avec les services existants (CashService, ScoreService, et DiceService).

## Implémentation
- Création d'un nouveau service (`GameDataService`) qui hérite de `BaseService`
- Fonctionnalités principales:
  - Gestion des statistiques de jeu par catégories (jeu, dés, économie, accomplissements)
  - Suivi des meilleurs scores
  - Enregistrement du temps de jeu
  - Méthodes de suivi des événements de jeu (lancer de dés, objectifs atteints, etc.)
  - Intégration avec les services existants via dépendances
  - Sauvegarde/chargement des statistiques

## Architecture
Le service fonctionne en parallèle des services existants (`CashService`, `ScoreService` et `DiceService`) et se connecte à leurs signaux pour suivre les statistiques. Il n'y a pas de remplacement des anciennes classes car elles sont déjà utilisées via la nouvelle architecture BaseService.

### Structure de données
Les statistiques sont organisées par catégories:
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

## Intégration avec l'autoload Services
- Ajout du préchargement de la classe GameDataService
- Instantiation et configuration des dépendances
- Connexion aux signaux des services existants pour le suivi des statistiques
- Intégration dans le système de sauvegarde/chargement existant

## À faire dans le futur
- Ajouter des méthodes plus spécifiques pour les accomplissements
- Intégrer avec le futur système de règles pour suivre les statistiques de progression dans la Voie Romaine
- Ajouter d'autres catégories de statistiques selon les besoins (temps par partie, meilleur temps, etc.)
