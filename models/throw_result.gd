extends Resource

class_name ThrowResult

## Indique si le lancer a atteint le but actuel
var success: bool = false

## Indique si une beugnette a été déclenchée (but+1 au dernier essai)
var beugnette: bool = false 

## Indique si une super beugnette a été déclenchée (6 au dernier essai sur but 1)
var super_beugnette: bool = false

## Le nouveau but après ce lancer
var new_goal: int = 6

## Le nombre d'essais restants après ce lancer
var new_attempts: int = 6

## La récompense obtenue (si succès)
var reward: int = 0

## Indique si le lancer a déclenché un effet critique
var critical: bool = false

## La valeur du dé qui a été lancé
var dice_value: int = 0

func _init(p_success: bool = false, p_new_goal: int = 6, p_new_attempts: int = 6) -> void:
	success = p_success
	new_goal = p_new_goal
	new_attempts = p_new_attempts

## Crée un objet ThrowResult à partir d'un dictionnaire
static func from_dictionary(dict: Dictionary) -> ThrowResult:
	var result = ThrowResult.new()
	
	if dict.has("success"):
		result.success = dict.success
	if dict.has("beugnette"):
		result.beugnette = dict.beugnette
	if dict.has("super_beugnette"):
		result.super_beugnette = dict.super_beugnette
	if dict.has("new_goal"):
		result.new_goal = dict.new_goal
	if dict.has("new_attempts"):
		result.new_attempts = dict.new_attempts
	if dict.has("reward"):
		result.reward = dict.reward
	if dict.has("critical"):
		result.critical = dict.critical
	if dict.has("dice_value"):
		result.dice_value = dict.dice_value
		
	return result

## Convertit l'objet en dictionnaire
func to_dictionary() -> Dictionary:
	return {
		"success": success,
		"beugnette": beugnette,
		"super_beugnette": super_beugnette,
		"new_goal": new_goal,
		"new_attempts": new_attempts,
		"reward": reward,
		"critical": critical,
		"dice_value": dice_value
	}

## Vérifie si le résultat indique une victoire finale (dernier but atteint)
func is_final_win() -> bool:
	return success and new_goal == 6 and success

## Vérifie si le résultat indique un échec final (plus d'essais sur but 6)
func is_final_lose() -> bool:
	return not success and new_attempts <= 0 and new_goal >= 6

## Affiche une représentation textuelle du résultat pour le débogage
func _to_string() -> String:
	var status = "Succès" if success else "Échec"
	if beugnette:
		status = "Beugnette"
	if super_beugnette:
		status = "Super Beugnette"
		
	return "%s - Dé: %d, Nouveau but: %d, Essais: %d, Récompense: %d" % [
		status, dice_value, new_goal, new_attempts, reward
	]
