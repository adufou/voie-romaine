extends BaseService

class_name UpgradesService

# Signaux
signal upgrade_purchased(upgrade_type: UpgradeConstants.UpgradeType, new_level: int)
signal upgrade_effect_changed(upgrade_type: UpgradeConstants.UpgradeType, new_effect: float)

# Dépendances de services
var cash_service: CashService = null
var statistics_service: StatisticsService = null

# Définitions des améliorations
var upgrade_definitions: Dictionary[UpgradeConstants.UpgradeType, Dictionary] = {
	UpgradeConstants.UpgradeType.THROW_SPEED: {
		"name": "Vitesse de lancer",
		"description": "Augmente la vitesse de lancer de dés",
		"base_cost": 50,
		"base_effect": 1.0,
		"cost_multiplier": 1.5,
		"effect_per_level": 0.1,  # +10% par niveau
		"max_level": 100
	},
	UpgradeConstants.UpgradeType.CRITICAL_CHANCE: {
		"name": "Chance critique",
		"description": "Augmente la chance d'obtenir un critique",
		"base_cost": 100,
		"base_effect": 0,
		"cost_multiplier": 2.0,
		"effect_per_level": 0.01,  # +1% par niveau
		"max_level": 100
	},
	UpgradeConstants.UpgradeType.REWARD_MULTIPLIER: {
		"name": "Multiplicateur de gains",
		"description": "Augmente les récompenses obtenues",
		"base_cost": 200,
		"base_effect": 1.0,
		"cost_multiplier": 2.5,
		"effect_per_level": 0.05,  # +5% par niveau
		"max_level": 100
	},
	UpgradeConstants.UpgradeType.AUTO_THROW: {
		"name": "Lancer automatique",
		"description": "Débloque le lancer automatique de dés",
		"base_cost": 500,
		"base_effect": 0,
		"cost_multiplier": 2.0,
		"effect_per_level": 0.0,  # Effet booléen (débloqué ou non)
		"max_level": 1
	},
	UpgradeConstants.UpgradeType.MULTI_DICE: {
		"name": "Dés multiples",
		"description": "Permet d'utiliser plusieurs dés simultanément",
		"base_cost": 1000,
		"base_effect": 1,
		"cost_multiplier": 5.0,
		"effect_per_level": 1.0,  # +1 dé par niveau
		"max_level": 10
	},
	UpgradeConstants.UpgradeType.NUMBER_OF_FACES: {
		"name": "Nombre de faces",
		"description": "Augmente le nombre de faces des dés",
		"base_cost": 25,
		"base_effect": 1,
		"cost_multiplier": 5.0,
		"effect_per_level": 1.0,  # +1 face par niveau
		"max_level": 100
	}
}

# Niveaux actuels des améliorations
var upgrades = {}

func _init():
	service_name = "upgrades_service"
	version = "0.0.1"
	
	# Déclarer explicitement les dépendances
	service_dependencies.append("cash_service")
	service_dependencies.append("rules_service")

# Surcharge des méthodes de BaseService
func initialize() -> void:
	if is_initialized:
		Logger.log_message("upgrades_service", ["service", "init"], "Service déjà initialisé", "WARNING")
		return
	
	Logger.log_message("upgrades_service", ["service", "init"], "Initialisation", "INFO")
	
	# Initialiser tous les upgrades à 0
	for upgrade_type in upgrade_definitions.keys():
		upgrades[upgrade_type] = 0
	
	is_initialized = true
	initialized.emit()

func setup_dependencies(dependencies: Dictionary[String, BaseService] = {}) -> void:
	if not is_initialized:
		Logger.log_message("upgrades_service", ["service", "dependencies"], "Tentative de configurer les dépendances avant initialisation", "ERROR")
		return
	
	Logger.log_message("upgrades_service", ["service", "dependencies"], "Configuration des dépendances", "INFO")
	
	# Récupérer les références aux services requis
	if dependencies.has("cash_service"):
		cash_service = dependencies["cash_service"]
	else:
		Logger.log_message("upgrades_service", ["service", "dependencies"], "Cash service non fourni dans les dépendances", "WARNING")
	
	if dependencies.has("statistics_service"):
		statistics_service = dependencies["statistics_service"]
	else:
		Logger.log_message("upgrades_service", ["service", "dependencies"], "Statistics service non fourni dans les dépendances", "WARNING")

func start() -> void:
	if not is_initialized:
		Logger.log_message("upgrades_service", ["service", "start"], "Tentative de démarrer le service avant initialisation", "ERROR")
		return
		
	if is_started:
		Logger.log_message("upgrades_service", ["service", "start"], "Service déjà démarré", "WARNING")
		return
	
	Logger.log_message("upgrades_service", ["service", "start"], "Démarrage", "INFO")
	
	is_started = true
	started.emit()

# Méthodes spécifiques au service Upgrade

## Calcule le coût d'une amélioration pour le niveau suivant
func get_upgrade_cost(upgrade_type: UpgradeConstants.UpgradeType) -> int:
	if not upgrade_type in upgrade_definitions:
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Amélioration inexistante: %s" % upgrade_type, "WARNING")
		return 0
		
	var def = upgrade_definitions[upgrade_type]
	var level = upgrades[upgrade_type]
	
	# Vérifier si niveau maximum atteint
	if level >= def["max_level"]:
		return -1
		
	return int(def["base_cost"] * pow(def["cost_multiplier"], level))

## Tente d'acheter une amélioration
func purchase_upgrade(upgrade_type: UpgradeConstants.UpgradeType) -> bool:
	Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Tentative d'acheter une amélioration: %s" % upgrade_type, "INFO")

	if not is_started:
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Tentative d'acheter une amélioration avant le démarrage complet du service", "WARNING")
		return false
	
	if not upgrade_type in upgrade_definitions:
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Amélioration inexistante: %s" % upgrade_type, "WARNING")
		return false
		
	var cost = get_upgrade_cost(upgrade_type)
	if cost < 0:
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Niveau maximum atteint pour %s" % upgrade_type, "INFO")
		return false
		
	if not cash_service:
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Cash service non configuré, impossible d'acheter une amélioration", "ERROR")
		return false
		
	if not cash_service.use_cash(cost):
		Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Cash insuffisant: %d requis" % cost, "INFO")
		return false
		
	upgrades[upgrade_type] += 1
	
	Logger.log_message("upgrades_service", ["upgrade", "purchase"], "Amélioration %s achetée (niveau %d) pour %d or" % 
		[upgrade_type, upgrades[upgrade_type], cost], "INFO")
	
	upgrade_purchased.emit(upgrade_type, upgrades[upgrade_type])
	upgrade_effect_changed.emit(upgrade_type, get_upgrade_effect(upgrade_type))
	
	# Enregistrer l'achat dans les statistiques si disponible
	if statistics_service:
		statistics_service.record_upgrade_purchased()
		statistics_service.record_gold_spent(cost)
	
	return true

## Obtient l'effet actuel d'une amélioration
func get_upgrade_effect(upgrade_type: UpgradeConstants.UpgradeType) -> float:
	if not upgrade_type in upgrade_definitions:
		Logger.log_message("upgrades_service", ["upgrade", "info"], "Amélioration inexistante: %s" % upgrade_type, "WARNING")
		return 0.0
		
	var def = upgrade_definitions[upgrade_type]
	var level = upgrades[upgrade_type]
	var base_effect = def["base_effect"]
	
	return base_effect + def["effect_per_level"] * level

## Vérifie si une amélioration est au niveau maximum
func is_upgrade_maxed(upgrade_type: UpgradeConstants.UpgradeType) -> bool:
	if not upgrade_type in upgrade_definitions:
		return false
		
	return upgrades[upgrade_type] >= upgrade_definitions[upgrade_type]["max_level"]

## Obtient le niveau actuel d'une amélioration
func get_upgrade_level(upgrade_type: UpgradeConstants.UpgradeType) -> int:
	if not upgrade_type in upgrade_definitions:
		return 0
		
	return upgrades[upgrade_type]

## Vérifie si une amélioration booléenne est débloquée
func is_upgrade_unlocked(upgrade_type: UpgradeConstants.UpgradeType) -> bool:
	if not upgrade_type in upgrade_definitions:
		return false
		
	return upgrades[upgrade_type] > 0

## Obtient toutes les données des améliorations pour l'UI
func get_all_upgrades_data() -> Dictionary:
	var result = {}
	
	for upgrade_type in upgrade_definitions.keys():
		var def = upgrade_definitions[upgrade_type]
		var level = upgrades[upgrade_type]
		var next_cost = get_upgrade_cost(upgrade_type)
		
		result[upgrade_type] = {
			"id": upgrade_type,
			"name": def["name"],
			"description": def["description"],
			"level": level,
			"max_level": def["max_level"],
			"current_effect": get_upgrade_effect(upgrade_type),
			"effect_per_level": def["effect_per_level"],
			"next_cost": next_cost,
			"is_maxed": level >= def["max_level"]
		}
	
	return result

# Gestion des données et persistance
func perform_reset(with_persistence: bool = false) -> void:
	if not with_persistence:
		# Réinitialiser toutes les améliorations à 0
		for upgrade_type in upgrades.keys():
			upgrades[upgrade_type] = 0
	
	super.perform_reset(with_persistence)

func get_save_data() -> Dictionary:
	var save_data = super.get_save_data()
	save_data["upgrades"] = upgrades.duplicate()
	save_data["upgrade_definitions"] = upgrade_definitions.duplicate()
	return save_data

func load_save_data(data: Dictionary) -> bool:
	var success = super.load_save_data(data)
	if not success:
		return false
		
	if data.has("upgrades") and data["upgrades"] is Dictionary:
		# Conserver uniquement les améliorations qui existent toujours
		for upgrade_type in data["upgrades"].keys():
			if upgrade_definitions.has(upgrade_type):
				upgrades[upgrade_type] = data["upgrades"][upgrade_type]
	
	# Vérifier si de nouvelles améliorations ont été ajoutées
	for upgrade_type in upgrade_definitions.keys():
		if not upgrades.has(upgrade_type):
			upgrades[upgrade_type] = 0
	
	return true
