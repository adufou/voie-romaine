# ARCH-08: Implémentation des dépendances explicites entre services

## Problème initial
Le chargement du jeu était bloqué car `dices_service` ne démarrait pas correctement, causant un blocage de l'écran de chargement. Le problème venait du fait que `dices_service` requérait une référence à une "table" pour démarrer, mais cette dépendance n'était pas explicitement déclarée ni gérée par le système de services.

## Solution implémentée

### 1. Création d'un service dédié pour la table
- Création d'un nouveau service `table_service` responsable de la création et gestion de la table de jeu
- Implémentation d'un mécanisme de secours pour créer une table par défaut si aucune scène n'est fournie
- Ajout de signaux pour notifier les autres services quand la table est disponible

### 2. Déclaration explicite des dépendances
- Modification du `dices_service` pour déclarer explicitement sa dépendance sur `table_service` via `service_dependencies`
- Intégration du `table_service` dans le système d'ordonnancement des services

### 3. Amélioration de la robustesse
- Le `table_service` crée toujours une table valide, même sans ressource fournie
- La méthode `get_table()` garantit qu'une table est toujours disponible en créant une table par défaut si nécessaire
- Le signal `table_created` permet aux services dépendants d'être notifiés quand la table est prête

## Changements architecturaux
Cette implémentation renforce l'architecture orientée services du projet en :
- Appliquant le principe de responsabilité unique (chaque service a une responsabilité claire)
- Établissant des dépendances explicites entre services
- Assurant un démarrage ordonné en fonction des dépendances
- Améliorant la robustesse du système face aux cas exceptionnels

## Impacts sur le développement futur
- Les nouveaux services pourront déclarer facilement leurs dépendances avec `service_dependencies.append()`
- L'ordre de démarrage est maintenant calculé automatiquement en fonction des dépendances
- Des services génériques comme `table_service` peuvent être utilisés par plusieurs autres services

## Date de complétion
03/05/2025
