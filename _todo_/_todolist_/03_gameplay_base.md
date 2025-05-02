# Tâches du Gameplay de Base - La Voie Romaine

Ces tâches concernent l'implémentation des mécaniques fondamentales du jeu, triées dans un ordre qui garantit de ne pas être bloqué par des dépendances.

## GAME-01: Système de buts et d'essais

**Priorité :** Haute  
**Dépend de :** SERV-02, SERV-04  
**Estimation :** 4 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_rules_manager.md`

### Description
Implémenter le système de buts progressifs (6→5→4→3→2→1) avec le nombre approprié d'essais pour chaque but (6 essais pour faire 6, 5 pour faire 5, etc.) et la logique de progression entre les buts.

### Critères de validation
- [ ] Structure de données pour le suivi des buts actuels
- [ ] Gestion du nombre d'essais restants par but
- [ ] Transition correcte d'un but au suivant après réussite
- [ ] Réinitialisation après complétion d'une séquence complète
- [ ] Signaux émis pour les événements de progression

### Notes techniques
```gdscript
# À implémenter dans le GameService ou un nouveau GoalManager
var current_goal: int = 6
var remaining_attempts: int = 6
var completed_goals: Array = []

func set_next_goal() -> void:
    if current_goal > 1:
        current_goal -= 1
        remaining_attempts = current_goal
        completed_goals.append(current_goal + 1)
    else:
        # Séquence complète, récompense et réinitialisation
        complete_sequence()
        
func complete_sequence() -> void:
    # Récompenses pour avoir complété 6→1
    var gold_reward = calculate_sequence_reward()
    Services.game_data.add_gold(gold_reward)
    
    # Réinitialiser
    current_goal = 6
    remaining_attempts = 6
    completed_goals.clear()
```

---

## GAME-02: Lancer de dés et résolution

**Priorité :** Haute  
**Dépend de :** GAME-01, SERV-02  
**Estimation :** 5 heures  
**Sources :** `implementation_rules_manager.md`, `implementation_gameplay_services.md`

### Description
Implémenter le système de lancer de dés avec la logique de résolution qui détermine si un lancer est réussi, déclenche une Beugnette/Super Beugnette, ou échoue, et gère les conséquences correspondantes.

### Critères de validation
- [ ] Système de génération de valeurs aléatoires pour les dés
- [ ] Intégration avec le RulesService pour la résolution des lancers
- [ ] Détection et traitement des Beugnettes
- [ ] Détection et traitement des Super Beugnettes
- [ ] Distribution des récompenses en fonction des résultats

### Notes techniques
```gdscript
# Dans un DiceManager ou GameService
func throw_dice() -> void:
    # Générer une valeur de dé (1-6)
    var dice_value = randi() % 6 + 1
    
    # Résoudre le lancer avec les règles
    var result = Services.rules.resolve_throw(dice_value, current_goal, remaining_attempts)
    
    # Appliquer le résultat
    if result.success:
        # Réussite - passer au but suivant
        set_next_goal()
        # Attribuer des points de score (7 - goal)
        Services.game_data.add_score(7 - current_goal)
    elif result.beugnette:
        # Beugnette - récupérer les essais
        remaining_attempts = Services.rules.rules_config.goal_attempts[current_goal]
        Services.game_data.total_beugnettes += 1
    elif result.super_beugnette:
        # Super Beugnette - retour au début
        current_goal = 6
        remaining_attempts = 6
        Services.game_data.total_super_beugnettes += 1
    else:
        # Échec simple - diminuer les essais restants
        remaining_attempts -= 1
        
    # Si plus d'essais, passer au but suivant ou échouer la séquence
    if remaining_attempts <= 0:
        reset_current_sequence()
        
    # Incrémenter les statistiques
    Services.game_data.total_throws += 1
```

---

## GAME-03: Système d'économie de base

**Priorité :** Haute  
**Dépend de :** GAME-02, SERV-01, SERV-03  
**Estimation :** 4 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_game_manager.md`

### Description
Implémenter le système économique de base avec gain d'or à la complétion d'une séquence, système de score basé sur les buts atteints, et achat d'améliorations.

### Critères de validation
- [ ] Calcul des gains d'or pour les séquences complètes
- [ ] Système de score (7-goal points par but atteint)
- [ ] Interface de dépense de l'or pour les améliorations
- [ ] Mise à jour du GameDataService avec les nouvelles valeurs
- [ ] Affichage des indicateurs économiques dans l'UI

### Notes techniques
```gdscript
# Calcul des récompenses
func calculate_sequence_reward() -> int:
    # Récompense de base pour une séquence complète
    var base_reward = 100
    
    # Appliquer les multiplicateurs des améliorations
    var gold_multiplier = 1.0 + Services.upgrades.get_upgrade_effect("gold_multiplier")
    
    # Appliquer l'effet de la fièvre si actif
    var fever_multiplier = Services.fever.get_current_multiplier()
    
    return int(base_reward * gold_multiplier * fever_multiplier)
```

---

## GAME-04: Système de temps et vitesse

**Priorité :** Moyenne  
**Dépend de :** GAME-02, SERV-03  
**Estimation :** 3 heures  
**Sources :** `implementation_gameplay_services.md`, `_specs_/game_design_incremental.md`

### Description
Implémenter le système qui gère la vitesse de lancer des dés, influencée par les améliorations achetées, et la progression du temps dans le jeu.

### Critères de validation
- [ ] Calcul de la vitesse de lancer en fonction des améliorations
- [ ] Système de temporisation entre les lancers
- [ ] Gestion du temps de jeu et statistiques temporelles
- [ ] Integration avec le système de gains par seconde
- [ ] Optimisation pour différentes fréquences d'images

### Notes techniques
```gdscript
# Dans GameService ou un nouveau TimeManager
var base_throw_interval: float = 1.0  # 1 seconde entre les lancers par défaut
var throw_timer: float = 0.0

func _process(delta: float) -> void:
    # Mettre à jour le timer de lancer
    throw_timer += delta
    
    # Calculer l'intervalle actuel entre les lancers
    var speed_multiplier = 1.0 + Services.upgrades.get_upgrade_effect("throw_speed")
    var current_throw_interval = base_throw_interval / speed_multiplier
    
    # Vérifier si c'est le moment de lancer
    if throw_timer >= current_throw_interval:
        throw_timer = 0.0  # Réinitialiser le timer
        throw_dice()  # Lancer le dé
        
    # Mettre à jour les autres systèmes temporels
    update_resources_per_second(delta)
```

---

## GAME-05: Lanceurs automatiques

**Priorité :** Moyenne  
**Dépend de :** GAME-04, SERV-03  
**Estimation :** 4 heures  
**Sources :** `implementation_gameplay_services.md`, `_specs_/game_design_incremental.md`

### Description
Implémenter le système de lanceurs automatiques qui permettent au joueur de générer des lancers de dés sans interaction directe, avec gestion de plusieurs lanceurs simultanés.

### Critères de validation
- [ ] Système d'achat et de gestion des lanceurs automatiques
- [ ] Gestion des lancers multiples simultanés
- [ ] Priorisation des dés à lancer en automatique
- [ ] Affichage visuel des lanceurs en action
- [ ] Statistiques sur les lancers automatiques

### Notes techniques
```gdscript
# Dans AutoThrowManager ou GameService
var auto_throwers: int = 0
var auto_throw_interval: float = 5.0  # 5 secondes entre les lancers auto
var auto_throw_timers: Array = []

func initialize() -> void:
    # Configurer les timers initiaux
    auto_throw_timers.resize(max_auto_throwers)
    for i in range(max_auto_throwers):
        auto_throw_timers[i] = 0.0
    super.initialize()

func _process(delta: float) -> void:
    # Mettre à jour uniquement le nombre de lanceurs actifs
    for i in range(auto_throwers):
        auto_throw_timers[i] += delta
        
        if auto_throw_timers[i] >= auto_throw_interval:
            auto_throw_timers[i] = 0.0
            auto_throw_dice(i)  # Lancer automatique
            
func add_auto_thrower() -> bool:
    if auto_throwers >= max_auto_throwers:
        return false
        
    auto_throwers += 1
    return true
    
func auto_throw_dice(thrower_id: int) -> void:
    # Similaire à throw_dice() mais pour les lancers automatiques
    # Peut avoir des modificateurs spécifiques
    var dice_value = randi() % 6 + 1
    # Résolution du lancer...
```

---

## GAME-06: Critiques et chance

**Priorité :** Basse  
**Dépend de :** GAME-02, SERV-03  
**Estimation :** 3 heures  
**Sources :** `_specs_/game_design_incremental.md`

### Description
Implémenter le système de lancers critiques et de chance qui peuvent augmenter la probabilité d'obtenir le résultat souhaité ou multiplier les récompenses obtenues lors d'un lancer réussi.

### Critères de validation
- [ ] Système de modificateurs de chance pour favoriser certaines valeurs
- [ ] Détection et traitement des lancers critiques
- [ ] Différents niveaux de critiques (x2, x3, x5)
- [ ] Intégration avec les améliorations achetables
- [ ] Effets visuels pour les critiques et succès "chanceux"

### Notes techniques
```gdscript
# Dans DiceManager ou GameplayService
func calculate_dice_probabilities() -> Dictionary:
    # Probabilités par défaut
    var probabilities = {
        1: 1.0/6.0,
        2: 1.0/6.0,
        3: 1.0/6.0,
        4: 1.0/6.0,
        5: 1.0/6.0,
        6: 1.0/6.0
    }
    
    # Modificateur de chance pour le goal actuel
    var chance_bonus = Services.upgrades.get_upgrade_effect("goal_chance")
    if chance_bonus > 0:
        var goal_prob = probabilities[current_goal]
        var boost = min(chance_bonus, 0.5)  # Plafond à 50% de boost
        
        # Augmenter la probabilité du goal
        probabilities[current_goal] = goal_prob + boost
        
        # Distribuer la réduction sur les autres faces
        var reduction_per_face = boost / 5.0
        for face in probabilities.keys():
            if face != current_goal:
                probabilities[face] -= reduction_per_face
                
    return probabilities
    
func is_critical_hit() -> Dictionary:
    var crit_chance = 0.05 + Services.upgrades.get_upgrade_effect("critical_chance")
    var roll = randf()
    
    if roll < crit_chance * 0.2:
        # Super critique (x5)
        return {"is_crit": true, "multiplier": 5.0}
    elif roll < crit_chance * 0.5:
        # Critique rare (x3)
        return {"is_crit": true, "multiplier": 3.0}
    elif roll < crit_chance:
        # Critique standard (x2)
        return {"is_crit": true, "multiplier": 2.0}
    else:
        # Pas de critique
        return {"is_crit": false, "multiplier": 1.0}
```
