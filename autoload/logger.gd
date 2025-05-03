extends Node

# Ce singleton est accessible via son nom "Logger" de n'importe où dans l'application

# Niveaux de log disponibles
enum LogLevel {
	DEBUG = 0,
	INFO = 1,
	WARNING = 2,
	ERROR = 3
}

# Configuration globale
var enabled: bool = true
var min_level: int = LogLevel.DEBUG
var log_to_file: bool = true
var log_to_console: bool = true
var max_log_file_size: int = 1024 * 1024 # 1Mo par défaut
var log_directory: String = "user://logs/"
var current_log_file: String = "game.log"
var filters: Dictionary = {} # Par catégorie/groupe
var buffer: Array[Dictionary] = [] # Pour l'affichage en jeu

# Constantes
const LOG_LEVEL_NAMES = {
	LogLevel.DEBUG: "DEBUG",
	LogLevel.INFO: "INFO",
	LogLevel.WARNING: "WARNING",
	LogLevel.ERROR: "ERROR"
}

# Signaux
signal new_log_entry(data)

func _ready() -> void:
	# Création du répertoire de logs si nécessaire
	_ensure_log_directory()
	
	# Rotation des logs au démarrage
	_rotate_log_files()
	
	# Log de démarrage
	info(["system"], "Système de logs initialisé")

# Méthodes publiques pour les différents niveaux de log

func debug(groups: Array[String], message: String) -> void:
	_log(groups, message, LogLevel.DEBUG)

func info(groups: Array[String], message: String) -> void:
	_log(groups, message, LogLevel.INFO)

func warning(groups: Array[String], message: String) -> void:
	_log(groups, message, LogLevel.WARNING)

func error(groups: Array[String], message: String) -> void:
	_log(groups, message, LogLevel.ERROR)

# Contrôle des filtres

func add_filter(group: String, min_level: int = LogLevel.DEBUG) -> void:
	filters[group] = min_level
	info(["system", "filters"], "Filtre ajouté: %s (niveau minimum: %s)" % [group, LOG_LEVEL_NAMES[min_level]])

func remove_filter(group: String) -> void:
	if filters.has(group):
		filters.erase(group)
		info(["system", "filters"], "Filtre supprimé: %s" % group)

func clear_filters() -> void:
	filters.clear()
	info(["system", "filters"], "Tous les filtres ont été effacés")

# Méthode centrale de journalisation
func _log(groups: Array[String], message: String, level: int) -> void:
	if not enabled or level < min_level:
		return
	
	# Vérification des filtres par groupe
	var should_log: bool = true
	if not filters.is_empty():
		should_log = false
		for group in groups:
			if filters.has(group) and level >= filters[group]:
				should_log = true
				break
	
	if not should_log:
		return
	
	# Construction du log entry
	var timestamp = Time.get_datetime_string_from_system()
	var level_name = LOG_LEVEL_NAMES[level]
	var groups_text = "[" + "|".join(groups) + "]"
	
	var log_entry = {
		"timestamp": timestamp,
		"level": level,
		"level_name": level_name,
		"groups": groups,
		"groups_text": groups_text,
		"message": message
	}
	
	# Ajouter au buffer pour l'affichage en jeu
	buffer.append(log_entry)
	if buffer.size() > 1000:  # Limite pour éviter une utilisation mémoire excessive
		buffer.pop_front()
	
	# Émission du signal pour l'interface
	new_log_entry.emit(log_entry)
	
	# Construction du texte formaté
	var formatted_text = "[%s] [%s] %s: %s" % [timestamp, level_name, groups_text, message]
	
	# Envoi à la console selon le niveau
	if log_to_console:
		match level:
			LogLevel.DEBUG:
				if OS.is_debug_build():
					print(formatted_text)
			LogLevel.INFO:
				print(formatted_text)
			LogLevel.WARNING:
				push_warning(formatted_text)
			LogLevel.ERROR:
				push_error(formatted_text)
	
	# Écriture dans le fichier
	if log_to_file:
		_write_to_log_file(formatted_text)

# Méthodes d'utilitaires internes

func _ensure_log_directory() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(log_directory):
		dir.make_dir(log_directory)

func _write_to_log_file(text: String) -> void:
	var file_path = log_directory + current_log_file
	
	# Vérifier si le fichier existe et sa taille
	if FileAccess.file_exists(file_path):
		var file_size = FileAccess.get_file_as_bytes(file_path).size()
		if file_size > max_log_file_size:
			_rotate_log_files()
	
	# Écrire le log
	var file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	if file:
		# Se positionner à la fin du fichier
		file.seek_end()
		file.store_line(text)
		file.close()

func _rotate_log_files() -> void:
	var dir = DirAccess.open(log_directory)
	if dir:
		# Renommer le fichier actuel avec un timestamp
		var old_path = log_directory + current_log_file
		if FileAccess.file_exists(old_path):
			var date_time = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
			var new_path = log_directory + "game_" + date_time + ".log"
			dir.rename(old_path, new_path)

# Récupération des logs pour l'affichage

func get_last_logs(count: int = 50, level_filter: int = LogLevel.DEBUG, groups_filter: Array[String] = []) -> Array[Dictionary]:
	var filtered_logs: Array[Dictionary] = []
	
	for log in buffer:
		# Filtrer par niveau
		if log.level < level_filter:
			continue
		
		# Filtrer par groupes si spécifié
		if not groups_filter.is_empty():
			var has_matching_group = false
			for group in log.groups:
				if groups_filter.has(group):
					has_matching_group = true
					break
			
			if not has_matching_group:
				continue
		
		filtered_logs.append(log)
		
		# Limiter le nombre de résultats
		if filtered_logs.size() >= count:
			break
	
	return filtered_logs
