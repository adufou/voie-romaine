extends Control

class_name LoadingScreen

signal loading_completed

var services_ready = false
var resources_loaded = false

func _ready() -> void:
	# Connect to services ready signal
	if not Services.is_initialized:
		Services.services_ready.connect(_on_services_ready)
	else:
		# Even if Services is initialized, we need to check if all services are started
		_check_services_started()
	
	# Set initial status
	%StatusLabel.text = "Initializing services..."
	%ProgressBar.value = 0
	
	# You could add a timer to simulate resource loading
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_resources_loaded)
	timer.one_shot = true
	timer.start(0.5)  # Adjust based on your needs

func _on_services_ready() -> void:
	Services.services_ready.disconnect(_on_services_ready)
	_check_services_started()

func _check_services_started() -> void:
	# Vérifier que les services sont non seulement initialisés mais complètement démarrés
	# Utiliser l'ordre de démarrage calculé par l'arbre de dépendances
	if Services.service_startup_order.size() > 0:
		# Suivre l'ordre de démarrage calculé pour attendre les services dans le bon ordre
		var progress_step = 30.0 / Services.service_startup_order.size()
		var current_progress = 10.0
		
		for service_name in Services.service_startup_order:
			var service = null
			
			# Récupérer la référence au service
			if service_name == "cash_service" and Services.cash_service:
				service = Services.cash_service
			elif service_name == "score_service" and Services.score_service:
				service = Services.score_service
			elif service_name == "dices_service" and Services.dices_service:
				service = Services.dices_service
			elif service_name == "statistics_service" and Services.statistics_service:
				service = Services.statistics_service
			elif service_name == "rules_service" and Services.rules_service:
				service = Services.rules_service
			elif service_name == "upgrades_service" and Services.upgrades_service:
				service = Services.upgrades_service
			elif service_name == "game_service" and Services.game_service:
				service = Services.game_service
			
			# Debug log pour chaque service
			if service:
				Logger.log_message("loading_screen", ["debug"], "Vérification du service %s, is_started=%s" % [service_name, service.is_started], "DEBUG")
			else:
				Logger.log_message("loading_screen", ["debug"], "Service %s n'existe pas" % service_name, "WARNING")

			# Si le service existe et n'est pas démarré, attendre son démarrage
			if service and not service.is_started:
				%StatusLabel.text = "Démarrage de %s..." % service_name
				Logger.log_message("loading_screen", ["service", "loading"], "En attente du démarrage de %s" % service_name, "INFO")
				
				# Définir un timeout pour éviter de bloquer indéfiniment
				var start_time = Time.get_ticks_msec()
				var timeout_duration = 5000 # 5 secondes en millisecondes
				
				# Attente avec vérification du timeout
				while not service.is_started:
					# Vérifier le timeout
					if Time.get_ticks_msec() - start_time > timeout_duration:
						Logger.log_message("loading_screen", ["debug"], "TIMEOUT: Service %s n'a pas démarré après 5 secondes" % service_name, "WARNING")
						break
					
					# Attendre un petit moment avant de vérifier à nouveau
					await get_tree().create_timer(0.1).timeout
				
				if service.is_started:
					Logger.log_message("loading_screen", ["debug"], "Service %s a démarré" % service_name, "DEBUG")
					Logger.log_message("loading_screen", ["system", "loading"], "%s démarré avec succès" % service_name, "INFO")
				else:
					# Force continue even if service did not start
					Logger.log_message("loading_screen", ["system", "loading"], "Service %s n'a pas démarré après le timeout, continuation forcée" % service_name, "WARNING")
			else:
				Logger.log_message("loading_screen", ["system", "loading"], "Service %s non trouvé, ignoré" % service_name, "WARNING")
			
			# Mettre à jour la barre de progression
			current_progress += progress_step
			%ProgressBar.value = current_progress
	else:
		# Fallback si l'arbre de dépendances n'est pas disponible
		# Attendre les services dans un ordre fixe
		if Services.dices_service and not Services.dices_service.is_started:
			%StatusLabel.text = "Démarrage du service de dés..."
			await Services.dices_service.started
		
		if Services.cash_service and not Services.cash_service.is_started:
			%StatusLabel.text = "Démarrage du service de monnaie..."
			await Services.cash_service.started
		
		if Services.score_service and not Services.score_service.is_started:
			%StatusLabel.text = "Démarrage du service de score..."
			await Services.score_service.started
		
		if Services.statistics_service and not Services.statistics_service.is_started:
			%StatusLabel.text = "Démarrage du service de statistiques..."
			await Services.statistics_service.started
	
	%StatusLabel.text = "Services started..."
	%ProgressBar.value = 50
	services_ready = true
	_check_loading_complete()

func _on_resources_loaded() -> void:
	Logger.log_message("loading_screen", ["system", "loading"], "Ressources chargées", "INFO")
	resources_loaded = true
	%ProgressBar.value = 100
	%StatusLabel.text = "Ready!"
	_check_loading_complete()

func _check_loading_complete() -> void:
	Logger.log_message("loading_screen", ["system", "loading"], "Vérification de la fin du chargement: services_ready=%s, resources_loaded=%s" % [services_ready, resources_loaded], "INFO")
	if services_ready and resources_loaded:
		# Use a small delay to ensure everything is truly ready
		Logger.log_message("loading_screen", ["system", "loading"], "Toutes les conditions remplies, émission du signal dans 0.2s...", "INFO")
		await get_tree().create_timer(0.2).timeout
		Logger.log_message("loading_screen", ["system", "loading"], "Émission du signal loading_completed", "INFO")
		loading_completed.emit()
