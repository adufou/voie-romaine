# REFACTOR-01: Suppression de la classe Cash obsolète

## Description
Cette tâche consistait à supprimer l'ancienne classe `Cash` (services/cash.gd) qui n'était plus nécessaire puisqu'elle a été remplacée par `CashService` qui hérite de `BaseService`.

## Changements effectués
- Suppression du fichier `services/cash.gd`
- Retrait de toutes les références à l'ancienne classe `Cash` dans `autoload/services.gd`
- Élimination du mécanisme de rétrocompatibilité qui synchronisait l'ancien objet `cash` avec le nouveau `cash_service`

## Impact
- Simplification de l'architecture
- Élimination du code redondant
- Réduction de la consommation mémoire (un objet en moins)
- Clarifie que `CashService` est maintenant la seule source de vérité pour la gestion de la monnaie dans le jeu

## Date de réalisation
3 mai 2025
