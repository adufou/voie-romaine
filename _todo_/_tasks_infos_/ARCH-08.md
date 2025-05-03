# ARCH-08: Implémentation des dépendances explicites entre services

## Description
Cette tâche consistait à améliorer le système de dépendances entre services pour assurer que l'ordre de démarrage respecte les relations de dépendance.

## Problème identifié
L'ordre de démarrage des services ne tenait pas correctement compte des dépendances entre services car:
1. Les services ne déclaraient pas explicitement leurs dépendances dans leur tableau `service_dependencies`
2. L'arbre de dépendances était vide, ce qui produisait un ordre de démarrage arbitraire
3. Le parcours DFS dans `_calculate_startup_order` inversait l'ordre obtenu

## Solutions implémentées
1. Correction de la fonction `_build_dependency_tree_from_services` pour utiliser directement les `service_name` des services
2. Modification de la fonction `_calculate_startup_order` pour utiliser un vrai DFS postorder sans inversion
3. Mise à jour de tous les services pour déclarer explicitement leurs dépendances dans la méthode `_init()`
4. Standardisation de la signature de `setup_dependencies` avec `Dictionary[String, BaseService]`
5. Correction des appels à `super.setup_dependencies` dans tous les services
6. Suppression du `service_dependencies.clear()` dans `BaseService.setup_dependencies` pour préserver les dépendances déclarées dans `_init()`
7. Ajout d'une vérification pour éviter les doublons de dépendances

## Avantages
Cette implémentation assure que:
- Les dépendances sont toujours démarrées avant les services qui en dépendent
- Le système est plus robuste avec une meilleure gestion des erreurs
- L'ordre de démarrage reflète la structure réelle de dépendances
- Le code est plus maintenable et typé correctement

## Services mis à jour
- GameService
- UpgradesService
- RulesService
- StatisticsService
- CashService
- ScoreService
- DicesService
