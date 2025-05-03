# DICE-03: Création d'une classe ThrowResult

## Description
Création d'une classe pour encapsuler le résultat d'un lancer de dé calculé par le RulesService, au lieu d'utiliser un dictionnaire.

## Implémentation
1. Créer une nouvelle classe ThrowResult dans services/rules/throw_result.gd
2. Définir les propriétés appropriées (success, beugnette, super_beugnette, new_goal, new_attempts, reward, critical)
3. Adapter le RulesService pour retourner cette classe au lieu d'un dictionnaire
4. Mettre à jour tous les appels à resolve_throw() pour utiliser cette nouvelle classe

## Dépendances
- RulesService
- Dice (scène)

## Notes techniques
- Cette refactorisation améliorera le typage et facilitera l'utilisation des résultats
- Permettra d'ajouter des méthodes utilitaires pour manipuler les résultats
- Facilitera l'extension future du système de résolution de lancers
