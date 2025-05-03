# ARCH-05: Intégration des systèmes existants (Cash, Score, Dices)

## Résumé

Cette tâche consistait à intégrer les systèmes existants (Cash, Score, Dices) dans la nouvelle architecture de services basée sur `BaseService`.

## Changements effectués

### 1. Création des nouveaux services

Trois nouveaux services ont été créés, héritant tous de `BaseService`:

- **CashService**: Gère la monnaie du jeu
  - Fonctions: `add_cash`, `use_cash`, `has_enough`, `get_cash`, `set_cash`
  - Signal: `cash_changed`

- **ScoreService**: Gère le score du joueur
  - Fonctions: `pass_goal`, `add_score`, `get_score`, `set_score`
  - Signal: `score_changed`

- **DiceService**: Gère les dés du jeu
  - Fonctions: `add_dice`, `remove_dice`, `throw_dices`, etc.
  - Signaux: `dice_added`, `dice_removed`, `dice_thrown`

### 2. Mise à jour du système d'Autoload Services

Le singleton `Services` a été mis à jour pour:
- Instancier les nouveaux services
- Initialiser les nouveaux services
- Configurer les dépendances entre services
- Démarrer les services
- Connecter les signaux entre les nouveaux et anciens services
- Gérer les sauvegardes/chargements des nouveaux services

### 3. Rétrocompatibilité

La rétrocompatibilité avec les anciens services a été maintenue:
- Les signaux des nouveaux services sont connectés aux anciens services pour maintenir la synchronisation
- Les données sont sauvegardées à la fois dans l'ancien et le nouveau format
- Les données peuvent être chargées depuis l'ancien format si le nouveau n'est pas disponible

## Résultats

- Les systèmes existants sont désormais accessibles via le singleton Services comme les nouveaux services
- La compatibilité bidirectionnelle est assurée entre anciens et nouveaux systèmes
- Les signaux sont connectés pour maintenir la synchronisation entre les services
- Le système de sauvegarde/chargement prend en charge les nouveaux services

## Structure du code

```gdscript
# Dans Services.gd
# Préchargement des nouvelles classes
const CashServiceClass = preload("res://services/cash/cash_service.gd")
const ScoreServiceClass = preload("res://services/score/score_service.gd")
const DiceServiceClass = preload("res://services/dices/dice_service.gd")

# Références
var cash_service: CashService
var score_service: ScoreService
var dice_service: DiceService

# Handlers pour la rétrocompatibilité
func _on_cash_service_changed(new_cash: int) -> void:
    cash._cash = new_cash
    cash.emit_signal("cash_changed", new_cash)
```
