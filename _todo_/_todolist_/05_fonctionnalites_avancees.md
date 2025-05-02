# Tâches des Fonctionnalités Avancées - La Voie Romaine

Ces tâches concernent l'implémentation des fonctionnalités avancées du jeu, triées dans un ordre qui garantit de ne pas être bloqué par des dépendances.

## ADV-01: Système de types de dés spéciaux

**Priorité :** Haute  
**Dépend de :** GAME-05, SERV-05  
**Estimation :** 6 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_gameplay_services.md`

### Description
Implémenter les différents types de dés spéciaux qui offrent des avantages uniques ou des effets spéciaux, tels que le dé doré, le dé chanceux, et le dé antique.

### Critères de validation
- [ ] Définition des caractéristiques pour chaque type de dé
- [ ] Système d'achat et de déverrouillage des dés spéciaux
- [ ] Intégration avec le système de lancers et de résolution
- [ ] Effets visuels et sonores pour chaque type de dé
- [ ] Gestion des statistiques pour les dés spéciaux

### Notes techniques
```gdscript
# Exemple de définition de type de dé
var dice_types = {
    "golden_dice": {
        "bonus_gold": 0.5,
        "penalty_chance": 0.1
    },
    "lucky_dice": {
        "bonus_chance": 0.2,
        "penalty_gold": 0.25
    },
    "antique_dice": {
        "special_effects": ["extra_attempts", "temporary_bonus"]
    }
}
```

---

## ADV-02: Mini-jeu "Voie Express"

**Priorité :** Moyenne  
**Dépend de :** GAME-04, SERV-04  
**Estimation :** 5 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_gameplay_services.md`

### Description
Développer le mini-jeu "Voie Express" qui offre une version simplifiée de la Voie Romaine jouable en parallèle du jeu principal, avec des multiplicateurs temporaires.

### Critères de validation
- [ ] Interface dédiée pour le mini-jeu
- [ ] Mécanique de jeu simplifiée avec un seul dé
- [ ] Système de multiplicateurs temporaires
- [ ] Intégration avec le gameplay principal pour les bonus
- [ ] Indicateurs visuels et sonores pour les multiplicateurs

### Notes techniques
```gdscript
# Exemple de gestion du mini-jeu
func start_express_game() -> void:
    var express_dice = Dice.new()
    express_dice.set_type("express")
    
    # Logique de jeu simplifiée
    while express_dice.current_goal > 0:
        var result = express_dice.throw()
        if result.success:
            apply_express_multiplier()
        
    # Fin du mini-jeu
    end_express_game()
```

---

## ADV-03: Système de challenges

**Priorité :** Moyenne  
**Dépend de :** GAME-06, SERV-02  
**Estimation :** 4 heures  
**Sources :** `_specs_/game_design_incremental.md`

### Description
Implémenter le système de challenges qui modifient les règles du jeu pour offrir des défis uniques, avec des récompenses spéciales.

### Critères de validation
- [ ] Définition des règles pour chaque challenge
- [ ] Interface pour sélectionner et suivre les challenges
- [ ] Récompenses uniques pour la complétion des challenges
- [ ] Intégration avec le système de règles existant
- [ ] Indicateurs de progression et de succès

### Notes techniques
```gdscript
# Exemple de configuration de challenge
var challenges = {
    "super_beugnette_challenge": {
        "description": "Super Beugnette active pour tous les buts",
        "reward": "unique_relic"
    },
    "no_beugnette_challenge": {
        "description": "Beugnette désactivée",
        "reward": "bonus_gold"
    }
}
```

---

## ADV-04: Système de sauvegarde hors-ligne

**Priorité :** Basse  
**Dépend de :** SERV-04  
**Estimation :** 3 heures  
**Sources :** `implementation_game_manager.md`

### Description
Mettre en place un système de sauvegarde qui permet de calculer les gains même lorsque le joueur n'est pas actif, en utilisant des sauvegardes régulières.

### Critères de validation
- [ ] Calcul des gains hors-ligne basé sur le temps écoulé
- [ ] Sauvegarde automatique à intervalles réguliers
- [ ] Chargement des données hors-ligne au démarrage
- [ ] Interface pour afficher les gains hors-ligne
- [ ] Optimisation pour éviter les abus

### Notes techniques
```gdscript
# Exemple de calcul de gains hors-ligne
func calculate_offline_gains(elapsed_time: int) -> int:
    var gold_per_second = Services.game_data.gold_per_second
    return gold_per_second * elapsed_time
```

---

## ADV-05: Optimisation pour mobile

**Priorité :** Basse  
**Dépend de :** UIUX-04  
**Estimation :** 4 heures  
**Sources :** `implementation_gameplay_services.md`

### Description
Optimiser le jeu pour les plateformes mobiles, en ajustant les contrôles, l'interface, et les performances pour garantir une expérience fluide.

### Critères de validation
- [ ] Ajustement des contrôles pour le tactile
- [ ] Interface adaptée aux écrans mobiles
- [ ] Optimisation des performances graphiques
- [ ] Tests sur différentes résolutions et appareils
- [ ] Réduction de la consommation de batterie

### Notes techniques
```gdscript
# Exemple d'ajustement pour mobile
func adjust_controls_for_mobile() -> void:
    # Activer les contrôles tactiles
    enable_touch_controls()
    
    # Ajuster les éléments de l'interface
    resize_ui_elements_for_mobile()
```
