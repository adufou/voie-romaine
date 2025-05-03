# DICE-04: Implémentation du mécanisme de but commun

## Description
Modification du système de dés pour que tous les dés partagent un but commun, créant ainsi une mécanique de jeu coopérative où chaque dé contribue à la progression commune.

## Implémentation
1. Centralisation de la logique de jeu dans le RulesService
2. Suppression de la destruction des dés en cas d'échec
3. Essais illimités quand le dé retourne au but 6 après une séquence complète
4. Système centralisé de résultats dans le DicesService
5. Attribution d'un slot_id à chaque dé pour le suivi individuel

## Dépendances
- RulesService
- DicesService
- DiceSyntaxService
- ThrowResult

## Notes techniques
- Ce changement modifie fondamentalement la mécanique de jeu
- Tous les dés partagent maintenant le même but et contribuent à une progression commune
- Les récompenses sont gérées de manière centralisée par le RulesService
- Chaque dé peut toujours accéder à son résultat individuel via son slot_id
