extends BaseService

class_name DiceService

# Signaux spécifiques aux dés
signal dice_added(dice, slot)
signal dice_removed(dice)
signal dice_thrown()

# Références externes
var table: Node = null          # Référence à la table de jeu
var dice_scene: PackedScene = null # Scène de dé à instancier

# Données internes
const MAX_DICES = 32           # Nombre maximum de dés autorisés
var dices: Dictionary = {}     # Dictionnaire des dés actifs [slot_id: int] -> Dice

func _init():
	service_name = "dice_service"
	version = "0.0.1"

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		log_message(["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	log_message(["service", "init"], "Initialisation", "INFO")
	
	# Chargement de la scène de dé
	dice_scene = load("res://scenes/dice.tscn")
	if not dice_scene:
		log_message(["dice", "resources"], "Impossible de charger la scène de dé", "ERROR")
		return
	
	# Initialisation du dictionnaire de dés
	dices = {}
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary = {}) -> void:
	if not is_initialized:
		log_message(["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	log_message(["service", "dependencies"], "Configuration des dépendances", "INFO")
	
	# Récupération de la référence à la table depuis les dépendances
	if dependencies.has("table"):
		table = dependencies["table"]
		log_message(["dice", "table"], "Table de jeu configurée", "INFO")
	else:
		log_message(["dice", "table"], "Table de jeu non fournie dans les dépendances", "WARNING")

func start() -> void:
	if not is_initialized:
		log_message(["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		log_message(["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	if not table:
		log_message(["dice", "table"], "Table de jeu non configurée, impossible de démarrer le service", "ERROR")
		return
		
	log_message(["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service des dés
func first_available_dice_slot() -> int:
	for i in range(MAX_DICES):
		if not dices.has(i):
			return i
	return -1

func add_dice() -> int:
	if not is_started:
		log_message(["dice", "gameplay"], "Tentative d'ajouter un dé avant le démarrage complet du service", "WARNING")
		return -1
		
	if not table:
		log_message(["dice", "table"], "Table de jeu non configurée, impossible d'ajouter un dé", "ERROR")
		return -1
	
	var dice_slot = first_available_dice_slot()
	if dice_slot == -1:
		log_message(["dice", "gameplay"], "Aucun emplacement disponible pour un nouveau dé", "WARNING")
		return -1
		
	var dice = dice_scene.instantiate()
	table.add_child(dice)
	
	dice.position = get_dice_position(dice_slot)
	dices[dice_slot] = dice
	
	log_message(["dice", "gameplay"], "Dé ajouté à l'emplacement %d" % dice_slot, "DEBUG")
	dice_added.emit(dice, dice_slot)
	
	return dice_slot

func remove_dice(dice_to_remove) -> bool:
	if not is_started:
		log_message(["dice", "gameplay"], "Tentative de supprimer un dé avant le démarrage complet du service", "WARNING")
		return false
	
	var found = false
	for slot in dices.keys():
		if dices[slot] == dice_to_remove:
			dices.erase(slot)
			dice_to_remove.queue_free()
			found = true
			log_message(["dice", "gameplay"], "Dé supprimé de l'emplacement %d" % slot, "DEBUG")
			dice_removed.emit(dice_to_remove)
			break
	
	if not found:
		log_message(["dice", "gameplay"], "Tentative de supprimer un dé inexistant", "WARNING")
		
	return found

func remove_dice_at_slot(slot: int) -> bool:
	if not dices.has(slot):
		log_message(["dice", "gameplay"], "Aucun dé à l'emplacement %d" % slot, "WARNING")
		return false
		
	var dice = dices[slot]
	dices.erase(slot)
	dice.queue_free()
	
	log_message(["dice", "gameplay"], "Dé supprimé de l'emplacement %d" % slot, "DEBUG")
	dice_removed.emit(dice)
	return true

func get_dice_position(slot: int) -> Vector2:
	if slot < 0 or slot >= MAX_DICES:
		return Vector2.ZERO
	
	# Layout configuration
	const ROWS = 4
	const COLS = 8
	const MARGIN_PERCENT = 0.1  # Margin around the grid as percentage of table size
	
	# Calculate row and column from slot index
	var row = slot / COLS
	var col = slot % COLS
	
	# Calculate usable area after applying margins
	var table_size = Vector2(table.size)
	var margin = table_size * MARGIN_PERCENT
	var usable_area = table_size - (margin * 2)
	
	# Calculate cell size and spacing
	var cell_width = usable_area.x / COLS
	var cell_height = usable_area.y / ROWS
	
	# Calculate position within the grid
	var x = margin.x + (col * cell_width) + (cell_width * 0.5)
	var y = margin.y + (row * cell_height) + (cell_height * 0.5)
	
	return Vector2(x, y)

func throw_dices() -> void:
	if not is_started:
		log_message(["dice", "gameplay"], "Tentative de lancer les dés avant le démarrage complet du service", "WARNING")
		return
	
	var thrown_count = 0
	for slot in dices.keys():
		dices[slot].throw()
		thrown_count += 1
	
	log_message(["dice", "gameplay"], "Lancé de %d dés" % thrown_count, "DEBUG")
	dice_thrown.emit()

func get_dice_count() -> int:
	return dices.size()
	
func get_dices() -> Array:
	return dices.values()

func get_dice_values() -> Array:
	var values = []
	for dice in dices.values():
		values.append(dice.value)
	return values

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	if not with_persistence:
		# Supprimer tous les dés
		for dice in dices.values():
			dice.queue_free()
		dices.clear()
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	
	# Sauvegarder l'état de chaque dé
	var dice_data = {}
	for slot in dices.keys():
		var dice = dices[slot]
		dice_data[slot] = {
			"value": dice.value,
			"position": {
				"x": dice.position.x,
				"y": dice.position.y
			}
		}
	
	save_data["dice_count"] = dices.size()
	save_data["dices"] = dice_data
	
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
	
	# Nettoyer les dés existants
	for dice in dices.values():
		dice.queue_free()
	dices.clear()
	
	# Restaurer les dés sauvegardés
	if data.has("dices"):
		var dice_data = data["dices"]
		for slot_str in dice_data.keys():
			var slot = int(slot_str)
			var dice_info = dice_data[slot_str]
			
			var dice = dice_scene.instantiate()
			table.add_child(dice)
			
			# Restaurer la position si disponible, sinon utiliser la position calculée
			if dice_info.has("position"):
				dice.position = Vector2(
					dice_info["position"]["x"], 
					dice_info["position"]["y"]
				)
			else:
				dice.position = get_dice_position(slot)
			
			# Restaurer la valeur si disponible
			if dice_info.has("value"):
				dice.value = dice_info["value"]
			
			dices[slot] = dice
	
	return true
