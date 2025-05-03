extends Node
class_name BaseService

# Signaux communs que tous les services peuvent émettre
## Émis quand le service a terminé sa phase d'initialisation de base
signal initialized
## Émis quand le service a terminé sa phase de démarrage complet
signal started
## Émis quand le service est réinitialisé, with_persistence indique si les données persistantes doivent être conservées
signal reset(with_persistence)
## Émis quand les données du service ont été sauvegardées
signal save_completed
## Émis quand les données du service ont été chargées, success indique si le chargement a réussi
signal load_completed(success)

# Métadonnées du service
## Version du service pour la gestion de compatibilité des sauvegardes
var version: String = "0.0.1"
## Nom unique du service pour l'identification dans les logs et sauvegardes
var service_name: String = "base_service"
## Indique si le service a été correctement initialisé
var is_initialized: bool = false
## Indique si le service a complété sa phase de démarrage
var is_started: bool = false

#########################################################
# Initialisation en trois phases pour éviter les problèmes de dépendances
#########################################################

## Phase 1: Configuration de base du service sans dépendance sur d'autres services
func initialize() -> void:
	if is_initialized:
		push_warning("Service %s a déjà été initialisé" % service_name)
		return
	
	print("Initialisation du service: %s" % service_name)
	
	# Configuration de base à implémenter dans les sous-classes
	# IMPORTANT: Ne pas accéder aux autres services dans cette phase
	
	is_initialized = true
	initialized.emit()

## Phase 2: Configuration des liens de dépendance avec d'autres services
func setup_dependencies(dependencies: Dictionary = {}) -> void:
	if not is_initialized:
		push_error("Tentative de configurer les dépendances du service %s avant son initialisation" % service_name)
		return
	
	print("Configuration des dépendances du service: %s" % service_name)
	
	# À implémenter dans les sous-classes pour configurer les références à d'autres services
	# Les dépendances sont passées en paramètre par le service principal

## Phase 3: Démarrage des fonctionnalités nécessitant d'autres services
func start() -> void:
	if not is_initialized:
		push_error("Tentative de démarrer le service %s avant son initialisation" % service_name)
		return
		
	if is_started:
		push_warning("Service %s a déjà été démarré" % service_name)
		return
	
	print("Démarrage du service: %s" % service_name)
	
	# À implémenter dans les sous-classes pour démarrer les fonctionnalités
	# qui requièrent d'autres services
	
	is_started = true
	started.emit()

#########################################################
# Gestion des données et persistance
#########################################################

## Réinitialise l'état du service
func perform_reset(with_persistence: bool = false) -> void:
	print("Réinitialisation du service: %s (persistance: %s)" % [service_name, with_persistence])
	
	# Par défaut, réinitialise l'état à implémenter dans les sous-classes
	# Si with_persistence est true, préserver les données persistantes
	
	is_started = false
	reset.emit(with_persistence)

## Méthode pour récupérer les données à sauvegarder
func get_save_data() -> Dictionary:
	# Les sous-classes devraient étendre ce dictionnaire avec leurs propres données
	# en appelant d'abord super.get_save_data() puis en ajoutant leurs données
	var save_data = {
		"version": version,
		"service_name": service_name
	}
	
	print("Données sauvegardées pour le service: %s" % service_name)
	save_completed.emit()
	
	return save_data

## Méthode pour restaurer les données sauvegardées
func load_save_data(data: Dictionary) -> bool:
	if not data:
		push_error("Tentative de charger des données null pour le service %s" % service_name)
		load_completed.emit(false)
		return false
		
	if not data.has("version") or not data.has("service_name"):
		push_error("Données de sauvegarde invalides pour le service %s" % service_name)
		load_completed.emit(false)
		return false
	
	# Vérification du service_name pour s'assurer que les données sont pour le bon service
	if data["service_name"] != service_name:
		push_error("Données de sauvegarde pour le mauvais service: %s (attendu: %s)" % [data["service_name"], service_name])
		load_completed.emit(false)
		return false
	
	# Chargement de base à étendre dans les sous-classes
	version = data["version"]
	
	print("Données chargées pour le service: %s (version: %s)" % [service_name, version])
	load_completed.emit(true)
	
	return true

#########################################################
# Utilitaires
#########################################################

## Log avec niveau - utilitaire pour le débogage avec groupement
## @param groups: Tableau de groupes de log (ex: ["currency", "transaction"])
## @param message: Message à journaliser
## @param criticality: Niveau de criticité (DEBUG, INFO, WARNING, ERROR), défaut à DEBUG
func log_message(groups: Array[String], message: String, criticality: String = "DEBUG") -> void:
	# Ajouter automatiquement le nom du service comme premier groupe
	var service_groups: Array[String] = [service_name]
	service_groups.append_array(groups)
	
	# Utiliser l'autoload Logger directement
	match criticality:
		"DEBUG":
			Logger.debug(service_groups, message)
		"INFO":
			Logger.info(service_groups, message)
		"WARNING":
			Logger.warning(service_groups, message)
		"ERROR":
			Logger.error(service_groups, message)
		_:
			Logger.debug(service_groups, message)
