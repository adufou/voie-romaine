# DICE-01: Intégration de l'addon dice_syntax

## Description
Intégration de l'addon dice_syntax pour la gestion des lancers de dés via un nouveau service dédié.

## Implémentation
1. Créer un nouveau service DiceSyntaxService qui encapsule les fonctionnalités de l'addon
2. Implémenter la méthode roll_die pour remplacer randi_range
3. Modifier la classe Dice pour utiliser le service au lieu de la génération aléatoire native

## Dépendances
- DicesService
- addons/dice_syntax/dice_syntax.gd

## Notes techniques
- L'addon dice_syntax permet de gérer des expressions de dés complexes
- Pour l'instant, seule la fonctionnalité de base (d6) est implémentée
- À l'avenir, pourra être étendu pour supporter des dés spéciaux
