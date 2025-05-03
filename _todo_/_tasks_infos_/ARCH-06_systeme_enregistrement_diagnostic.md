# ARCH-06: Système d'enregistrement et diagnostic

## Résumé
Un système de logs complet a été implémenté comme autoload indépendant, offrant des fonctionnalités avancées de diagnostic et d'enregistrement pour tous les modules du jeu.

## Implémentation
- Autoload `Logger` créé dans `/autoload/logger.gd`
- Intégration avec les services existants via la classe `BaseService`
- Fonctionnalités principales :
  - Différents niveaux de log (DEBUG, INFO, WARNING, ERROR)
  - Journalisation vers la console et fichiers avec rotation des logs
  - Système de catégorisation par groupes pour un filtrage flexible
  - Interface en jeu activable en mode développement (via la touche F11)

## Points techniques importants
- L'implémentation en tant qu'autoload indépendant permet de l'utiliser avant même l'initialisation des services
- Le système de groupes permet de filtrer les logs par service, fonctionnalité ou autre catégorie
- La rotation automatique des fichiers de logs empêche une croissance illimitée
- BaseService intègre automatiquement le nom du service comme groupe de log

## Exemples d'utilisation
```gdscript
# Log simple
Logger.info(["system"], "Application démarrée")

# Log avec plusieurs groupes
Logger.debug(["currency", "transaction"], "Transaction effectuée: +100 pièces")

# Log d'erreur
Logger.error(["save", "file"], "Impossible de sauvegarder le fichier")

# Depuis un service (ajoute automatiquement le nom du service au groupe)
my_service.log_message(["action"], "Action exécutée", "INFO")
```

## Corrections et améliorations

- **03/05/2025**: Amélioration du formatage des groupes de log en utilisant un séparateur de pipe (`|`) plutôt que la méthode précédente qui était moins lisible. Les groupes apparaissent maintenant au format `[system|filters]` au lieu de `[system]filters]`.

## Améliorations futures potentielles
- Système d'envoi des logs vers un service distant en cas d'erreur critique
- Configuration dynamique du niveau de log via un menu d'options
- Ajout d'un système de filtrage plus avancé basé sur des expressions régulières
