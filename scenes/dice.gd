extends Node2D

class_name Dice

@export var pop_up_message_scene: PackedScene # Make it a service if used in several places 

var value: int
var slot_id: int = -1  # ID du slot attribué par le DicesService

# Variables d'affichage synchronisées avec le RulesService
var goal: int = 6:
	set(new_value):
		%Goal.text = str(new_value)
		goal = new_value
		
var tries: int = -1: # -1 => Infinite
	set(new_value):
		var tries_text = "∞"
		if (new_value > 0):
			tries_text = str(new_value)
		
		%Tries.text = tries_text
		tries = new_value

func _ready() -> void:
	# Connexion aux signaux du RulesService
	Services.rules_service.goal_achieved.connect(_on_goal_achieved)
	Services.rules_service.beugnette_triggered.connect(_on_beugnette_triggered)
	Services.rules_service.super_beugnette_triggered.connect(_on_super_beugnette_triggered)
	
	reset()

func set_slot_id(id: int) -> void:
	slot_id = id

func throw():
	%AnimatedSprite2D.play("throw")
	%ThrowRollTimer.start()

func set_value():
	%AnimatedSprite2D.animation = "white"
	%AnimatedSprite2D.pause()
	
	# Utiliser DiceSyntaxService pour le lancer de dé
	value = Services.dice_syntax_service.roll_die(6)
	%AnimatedSprite2D.frame = value - 1
	
	# Déléguer la résolution du lancer au RulesService
	var result: ThrowResult = Services.rules_service.resolve_throw(value)
	
	# Enregistrer le résultat dans le DicesService
	if slot_id >= 0:
		Services.dices_service.register_dice_result(slot_id, result)
	
	process_throw_result(result)

func _on_timer_timeout() -> void:
	set_value()

# Traite le résultat du lancer calculé par le RulesService
func process_throw_result(result: ThrowResult) -> void:
	# Mise à jour de l'interface uniquement
	goal = result.new_goal
	tries = result.new_attempts
	
	# Affichage des récompenses obtenues
	if result.success and result.reward > 0:
		pop_up_message("$" + str(result.reward))
	
	# Affichage des événements spéciaux
	if result.beugnette:
		pop_up_message("Beugnette !")
	if result.super_beugnette:
		pop_up_message("Super beugnette...")
	if result.is_final_win():
		pop_up_message("SÉQUENCE COMPLÈTE!")

func reset():
	# Pas besoin de réinitialiser le RulesService car il est partagé entre tous les dés
	# Services.rules_service.reset_game_state()
	
	# Synchronisation avec l'état du RulesService
	var game_state = Services.rules_service.get_game_state()
	goal = game_state.current_goal
	tries = game_state.remaining_attempts
	
	throw()

func lose():
	pop_up_message("LOSE")
	# Ne plus supprimer le dé à l'échec
	# Services.dices_service.remove_dice(self)
	# queue_free()

# Gestion des événements du RulesService (plus besoin d'actions spécifiques)
func _on_goal_achieved(goal_number: int, reward: int) -> void:
	# Rien à faire ici, affichage géré dans process_throw_result
	pass

func _on_beugnette_triggered(goal_number: int) -> void:
	# Rien à faire ici, affichage géré dans process_throw_result
	pass

func _on_super_beugnette_triggered() -> void:
	# Rien à faire ici, affichage géré dans process_throw_result
	pass

func pop_up_message(message: String):
	var pop_up_message: PopUpMessage = pop_up_message_scene.instantiate()
	pop_up_message.init_message(message)
	pop_up_message.position = position
	
	add_sibling(pop_up_message)

func _on_throw_info_timer_timeout() -> void:
	%ThrowInfo.text = ""
