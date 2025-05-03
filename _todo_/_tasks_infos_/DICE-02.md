# DICE-02: Refactorisation pour utiliser RulesService

## Description
Refactorisation de la classe Dice pour utiliser le RulesService et supprimer la logique de la voie romaine dupliquée.

## Implémentation
1. Modifier la classe Dice pour utiliser RulesService.resolve_throw() au lieu de sa propre logique
2. Se connecter aux signaux émis par RulesService pour réagir aux événements (beugnette, super beugnette)
3. Supprimer le code redondant de résolution de lancer
4. Adapter le système de récompenses pour utiliser les calculs du RulesService

## Dépendances
- DiceSyntaxService
- RulesService
- CashService
- ScoreService

## Notes techniques
- La classe Dice ne devrait plus contenir aucune logique de jeu concernant les règles de la voie romaine
- Toutes les règles doivent être gérées par le RulesService
- La classe Dice ne se charge plus que de l'affichage, de l'animation et des interactions
