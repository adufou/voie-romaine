# ARCH-06: Implémentation d'un écran de chargement pour séquencer l'initialisation des services

## Description
Résolution d'un problème de séquencement dans l'initialisation des services qui causait des erreurs lors de l'ajout de dés dans la table de jeu.

## Problème identifié
Le service `DicesService` vérifie la valeur du flag `is_started` avant d'autoriser l'ajout de dés via la fonction `add_dice()`. Dans le code original, la méthode `_ready()` de la classe `Table` appelait `Services.dices_service.add_dice()` immédiatement après `init_table(self)`, sans attendre que `is_started` soit défini à `true` par le service autoload `Services`.

## Solution implémentée
Implémentation d'un écran de chargement qui garantit que les composants du jeu ne sont instanciés qu'après la complétion de l'initialisation des services:

1. Création d'un écran de chargement (`loading_screen.tscn` et `loading_screen.gd`)
2. Modification de la scène principale pour utiliser uniquement l'écran de chargement initialement
3. Mise à jour du script principal pour:
   - Instancier l'écran de chargement
   - Écouter le signal `loading_completed`
   - Initialiser les composants du jeu uniquement après ce signal

Cette architecture garantit que les instances de `Table` et de `HUD` ne sont créées qu'après l'initialisation complète des services, assurant ainsi que le flag `is_started` est déjà défini à `true` lorsque `add_dice()` est appelé.

## Fichiers modifiés
- `/scenes/loading_screen.gd` (créé)
- `/scenes/loading_screen.tscn` (créé)
- `/main.gd`
- `/main.tscn`

## Date de complétion
03/05/2025
