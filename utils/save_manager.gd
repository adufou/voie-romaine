extends Node
class_name SaveManager

# Constantes
const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "game_save.json"
const SAVE_FILE_PATH = SAVE_DIR + SAVE_FILE_NAME
const BACKUP_FILE_NAME = "game_save_backup.json" 
const BACKUP_FILE_PATH = SAVE_DIR + BACKUP_FILE_NAME

# Vérifie si le répertoire de sauvegarde existe, le crée si nécessaire
static func ensure_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)
		print("Répertoire de sauvegarde créé: %s" % SAVE_DIR)

# Sauvegarde les données dans un fichier
static func save_data(data: Dictionary) -> bool:
	ensure_save_directory()
	
	# Créer une sauvegarde du fichier existant si présent
	var file_check = FileAccess.file_exists(SAVE_FILE_PATH)
	if file_check:
		var current_save = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if current_save:
			var content = current_save.get_as_text()
			current_save.close()
			
			var backup = FileAccess.open(BACKUP_FILE_PATH, FileAccess.WRITE)
			if backup:
				backup.store_string(content)
				backup.close()
				print("Sauvegarde de secours créée")
	
	# Sauvegarder les nouvelles données
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Impossible de créer le fichier de sauvegarde: %s" % FileAccess.get_open_error())
		return false
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Données sauvegardées avec succès dans: %s" % SAVE_FILE_PATH)
	return true

# Charge les données depuis un fichier
static func load_data() -> Dictionary:
	ensure_save_directory()
	
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("Aucun fichier de sauvegarde trouvé.")
		return {}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Impossible d'ouvrir le fichier de sauvegarde: %s" % FileAccess.get_open_error())
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	if content.is_empty():
		push_warning("Fichier de sauvegarde vide")
		return {}
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("Erreur lors de l'analyse du JSON: %s à la ligne %s" % [json.get_error_message(), json.get_error_line()])
		
		# Essayer de charger la sauvegarde de secours
		return _try_load_backup()
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Format de données de sauvegarde invalide")
		return {}
	
	print("Données chargées avec succès depuis: %s" % SAVE_FILE_PATH)
	return data

# Essaie de charger la sauvegarde de secours en cas d'échec
static func _try_load_backup() -> Dictionary:
	if not FileAccess.file_exists(BACKUP_FILE_PATH):
		print("Aucun fichier de sauvegarde de secours trouvé.")
		return {}
	
	print("Tentative de restauration depuis la sauvegarde de secours...")
	var file = FileAccess.open(BACKUP_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Impossible d'ouvrir le fichier de sauvegarde de secours: %s" % FileAccess.get_open_error())
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("Erreur lors de l'analyse du JSON de secours: %s à la ligne %s" % [json.get_error_message(), json.get_error_line()])
		return {}
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Format de données de sauvegarde de secours invalide")
		return {}
	
	print("Données chargées avec succès depuis la sauvegarde de secours: %s" % BACKUP_FILE_PATH)
	return data

# Supprime toutes les données de sauvegarde (utilisé pour réinitialiser le jeu)
static func delete_save_data() -> bool:
	ensure_save_directory()
	
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("Aucun fichier de sauvegarde à supprimer.")
		return true
	
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		push_error("Impossible d'accéder au répertoire de sauvegarde: %s" % DirAccess.get_open_error())
		return false
	
	var err = dir.remove(SAVE_FILE_NAME)
	if err != OK:
		push_error("Erreur lors de la suppression du fichier de sauvegarde: %s" % err)
		return false
	
	print("Fichier de sauvegarde supprimé avec succès")
	return true
