extends BaseService

class_name DiceSyntaxService

var _dice_syntax = preload("res://addons/dice_syntax/dice_syntax.gd")
var _dice_regex = RegEx.new()

func _init():
	service_name = "dice_syntax_service"
	version = "0.0.1"

func initialize() -> void:
	if is_initialized:
		Logger.log_message("dice_syntax_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("dice_syntax_service", ["service", "init"], "Initialisation", "INFO")
	
	# Initialisation du regex pour dice_syntax
	_dice_regex.compile('[0-9]*d[0-9]+[dksfro/!<=>0-9lh]*')
	
	is_initialized = true
	initialized.emit()

func start() -> void:
	if not is_initialized:
		Logger.log_message("dice_syntax_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("dice_syntax_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("dice_syntax_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthode simple pour obtenir une valeur de dé
func roll_die(faces) -> int:
	var result = _dice_syntax.roll("d" + str(faces), RandomNumberGenerator.new(), _dice_regex)
	if result.error:
		Logger.log_message("dice_syntax_service", ["dice", "roll"], "Erreur lors du lancer de dé: " + str(result.msg), "ERROR")
		return 1  # Valeur par défaut en cas d'erreur
	return result.result
