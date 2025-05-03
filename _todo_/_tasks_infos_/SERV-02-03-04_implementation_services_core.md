# Implémentation des Services Core

## Résumé
Implémentation des principaux services de jeu:
- RulesService (règles du jeu et résolution des lancers)
- UpgradeService (système d'améliorations achetables)
- GameService (coordination globale du jeu)

## RulesService (SERV-02)
Service qui gère les règles du jeu, notamment le système de buts (6→5→4→3→2→1), les Beugnettes et la résolution des lancers.

### Fonctionnalités
- Configuration personnalisable des règles du jeu
- Système de buts avec essais limités (6→5→4→3→2→1)
- Mécanismes de Beugnette et Super Beugnette
- Calcul des récompenses et bonus critiques
- Signaux pour notifier les autres systèmes des événements

### Points clés
- Organisation des règles dans un dictionnaire de configuration
- Résolution des lancers selon les règles actuelles
- Sauvegarde et chargement de l'état des règles

## UpgradeService (SERV-03)
Service qui gère les améliorations achetables pour augmenter les capacités du joueur.

### Fonctionnalités
- Définition des améliorations (vitesse, chance critique, etc.)
- Système de coûts avec progression géométrique
- Vérification et achat d'améliorations
- Interface pour obtenir les données d'amélioration pour l'UI
- Déverrouillage de fonctionnalités spéciales (lancer auto, multi-dés)

### Points clés
- Dépendance au service de monnaie pour les achats
- Stockage des niveaux d'amélioration
- Calcul dynamique des effets et des coûts
- Mise à jour des statistiques lors des achats

## GameService (SERV-04)
Service de coordination qui orchestre l'ensemble du jeu.

### Fonctionnalités
- Gestion des états de jeu (menu, en jeu, pause, game over)
- Coordination entre les services (dés, règles, améliorations)
- Lancement manuel et automatique des dés
- Gestion des événements de jeu (réussite, échec, etc.)
- Suivi des statistiques de jeu

### Points clés
- Dépendances avec tous les autres services
- Système d'état pour gérer le flux du jeu
- Gestion du lancer automatique via _process
- Réaction aux améliorations achetées

## Architecture
Les trois services sont construits selon le modèle BaseService:
- Cycle de vie en trois phases (initialize, setup_dependencies, start)
- Système de sauvegarde/chargement
- Signaux pour la communication

## Intégration
Les services sont intégrés à l'autoload Services pour être accessibles globalement, avec:
- Préchargement des classes de service
- Instanciation dans _create_services()
- Configuration des dépendances entre services
- Sauvegarde et chargement de l'état

## Avenir
Ces services constituent le cœur du système de jeu incrémental, prêts à être utilisés par l'interface utilisateur. Les prochaines étapes incluront l'implémentation de l'UI pour interagir avec ces services.
