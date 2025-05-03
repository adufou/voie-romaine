# ARCH-02: Intégration des systèmes existants (DiceService)

## Tâche réalisée
- Création du fichier `dice_service.gd` dans le répertoire `services/dices/`
- Migration de la fonctionnalité depuis `scenes/dice.gd` vers l'architecture de services
- Implémentation suivant le modèle BaseService avec les méthodes initialize(), setup_dependencies() et start()
- Ajout des méthodes pour gérer les dés (add_dice, remove_dice)
- Implémentation de la sérialisation pour sauvegarde/chargement

## Points techniques
- Le service maintient une liste des dés actifs
- Le service a besoin d'une référence à la table de jeu (via init_table)
- Intégration avec les autres services via l'autoload Services

## État
Le DiceService est maintenant intégré à l'architecture des services, résolvant l'erreur de préchargement qui se produisait dans l'autoload Services.
