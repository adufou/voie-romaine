# ARCH-03: Configuration du système de sauvegarde/chargement

## Travail réalisé

1. **Création d'un gestionnaire de sauvegarde (`SaveManager`)**
   - Implémentation d'une classe utilitaire dans `utils/save_manager.gd`
   - Fonctionnalités de sauvegarde et chargement basées sur le système de fichiers de Godot
   - Mécanisme de sauvegarde de secours en cas de corruption des données

2. **Mise à jour du système de services**
   - Intégration du `SaveManager` dans le singleton `Services`
   - Implémentation complète des méthodes `save_game()` et `load_game()`
   - Ajout de la gestion des versions et de la compatibilité
   - Améliorations de la méthode `reset_game()` pour gérer les fichiers de sauvegarde

## Fonctionnalités

- **Sauvegarde des données** :
  - Format JSON pour la sérialisation des données
  - Structure hiérarchique avec version et horodatage
  - Organisation par service pour faciliter l'extension

- **Chargement des données** :
  - Vérification de la version de sauvegarde
  - Système de récupération en cas de corruption (fichier de sauvegarde de secours)
  - Émission de signaux pour notifier les composants UI

- **Réinitialisation** :
  - Support pour réinitialiser avec ou sans persistance des données
  - Nettoyage des fichiers de sauvegarde lors d'une réinitialisation complète

## Notes techniques

- Le système utilise le répertoire `user://saves/` qui correspond à l'emplacement spécifique à chaque plateforme pour les données utilisateur.
- Les services doivent implémenter les méthodes `get_save_data()` et `load_save_data()` pour être compatibles avec ce système.
- Le système est prêt à accueillir les futurs services qui seront développés.
