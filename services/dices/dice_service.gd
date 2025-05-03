extends BaseService

class_name DiceService

signal dice_added(dice)
signal dice_removed(dice)

# Scene references
const DiceScene = preload("res://scenes/dice.tscn")

# References
var _table = null
var _dices = []

func _init():
	service_name = "dice_service"
	version = "0.0.1"

# BaseService implementation
func initialize() -> void:
	if is_initialized:
		Logger.log_message("dice_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("dice_service", ["service", "init"], "Initialisation", "INFO")
	
	# Initialize dices array
	_dices = []
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(_dependencies: Dictionary = {}) -> void:
	if not is_initialized:
		Logger.log_message("dice_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("dice_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	# Dependencies will be set via init_table when the table is available

func start() -> void:
	if not is_initialized:
		Logger.log_message("dice_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("dice_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("dice_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Service-specific methods
func init_table(table) -> void:
	_table = table
	Logger.log_message("dice_service", ["table"], "Table de jeu initialisée", "INFO")

func add_dice() -> Dice:
	if not _table:
		Logger.log_message("dice_service", ["dices"], "Tentative d'ajouter un dé sans table initialisée", "ERROR")
		return null
	
	var dice = DiceScene.instantiate()
	_table.add_child(dice)
	_dices.append(dice)
	
	Logger.log_message("dice_service", ["dices"], "Nouveau dé ajouté", "INFO")
	dice_added.emit(dice)
	
	return dice

func remove_dice(dice: Dice) -> void:
	if dice in _dices:
		_dices.erase(dice)
		Logger.log_message("dice_service", ["dices"], "Dé supprimé", "INFO")
		dice_removed.emit(dice)
	else:
		Logger.log_message("dice_service", ["dices"], "Tentative de supprimer un dé inexistant", "WARNING")

func get_dices() -> Array:
	return _dices

func get_dice_count() -> int:
	return _dices.size()

# Sauvegarde et chargement
func serialize() -> Dictionary:
	return {
		"dice_count": get_dice_count(),
	}

func deserialize(data: Dictionary) -> bool:
	if not is_initialized:
		Logger.log_message("dice_service", ["service", "deserialize"], "Tentative de désérialiser avant initialisation", "ERROR")
		return false
	
	# Clear existing dices
	for dice in _dices.duplicate():
		remove_dice(dice)
	
	# Add dices based on saved count
	if data.has("dice_count"):
		var count = data["dice_count"]
		for i in range(count):
			add_dice()
	
	Logger.log_message("dice_service", ["service", "deserialize"], "Désérialisation effectuée", "INFO")
	return true
