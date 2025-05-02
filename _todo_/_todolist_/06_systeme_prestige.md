# Tâches du Système de Prestige - La Voie Romaine

Ces tâches concernent l'implémentation du système de prestige, triées dans un ordre qui garantit de ne pas être bloqué par des dépendances.

## PRESTIGE-01: Calcul et attribution des Reliques

**Priorité :** Haute  
**Dépend de :** SERV-01, GAME-03  
**Estimation :** 4 heures  
**Sources :** `_specs_/game_design_incremental.md`

### Description
Implémenter le système de calcul et d'attribution des reliques, qui sont gagnées en sacrifiant la progression actuelle pour obtenir des bonus permanents.

### Critères de validation
- [ ] Formule de calcul des reliques basée sur l'or total
- [ ] Interface pour initier le prestige et confirmer l'attribution
- [ ] Mise à jour des statistiques de prestige
- [ ] Application des bonus permanents des reliques
- [ ] Feedback visuel et sonore lors du prestige

### Notes techniques
```gdscript
# Exemple de calcul de reliques
func calculate_relics_gain() -> int:
    var total_gold = Services.game_data.total_gold_earned
    return int(log(total_gold / 1000))
```

---

## PRESTIGE-02: Arbre de talents

**Priorité :** Moyenne  
**Dépend de :** PRESTIGE-01  
**Estimation :** 5 heures  
**Sources :** `_specs_/game_design_incremental.md`, `implementation_game_manager.md`

### Description
Créer un arbre de talents qui permet aux joueurs de dépenser des points de talent gagnés lors des prestiges pour débloquer des capacités spéciales.

### Critères de validation
- [ ] Structure de l'arbre de talents avec branches distinctes
- [ ] Interface pour visualiser et naviguer dans l'arbre
- [ ] Système pour dépenser des points de talent
- [ ] Effets des talents appliqués au gameplay
- [ ] Indicateurs de progression dans l'arbre

### Notes techniques
```gdscript
# Exemple de structure d'arbre de talents
var talent_tree = {
    "fortune_branch": {
        "talents": [
            {"name": "Gold Boost", "effect": "increase_gold", "cost": 1},
            {"name": "Critical Mastery", "effect": "increase_crit_chance", "cost": 2}
        ]
    },
    "chance_branch": {
        "talents": [
            {"name": "Lucky Throws", "effect": "increase_throw_chance", "cost": 1},
            {"name": "Beugnette Mastery", "effect": "enhance_beugnette", "cost": 2}
        ]
    }
}
```

---

## PRESTIGE-03: Reliques spéciales et leurs effets

**Priorité :** Moyenne  
**Dépend de :** PRESTIGE-01  
**Estimation :** 3 heures  
**Sources :** `_specs_/game_design_incremental.md`

### Description
Développer des reliques spéciales qui offrent des effets uniques, déblocables après avoir atteint certains objectifs de prestige.

### Critères de validation
- [ ] Définition des effets uniques pour chaque relique spéciale
- [ ] Système de déblocage basé sur les objectifs atteints
- [ ] Application des effets spéciaux au gameplay
- [ ] Interface pour visualiser les reliques spéciales
- [ ] Indicateurs de progression vers le déblocage

### Notes techniques
```gdscript
# Exemple de reliques spéciales
var special_relics = {
    "harvest_relic": {
        "effect": "intermediate_gold_gains",
        "unlock_condition": "reach_100_relics"
    },
    "celerity_relic": {
        "effect": "increase_throw_speed",
        "unlock_condition": "complete_50_challenges"
    }
}
```

---

## PRESTIGE-04: Réinitialisation et bonus

**Priorité :** Basse  
**Dépend de :** PRESTIGE-01  
**Estimation :** 4 heures  
**Sources :** `implementation_game_manager.md`

### Description
Mettre en œuvre le système de réinitialisation qui conserve certaines progressions tout en appliquant des bonus de prestige au nouveau cycle de jeu.

### Critères de validation
- [ ] Système de réinitialisation avec conservation des reliques et talents
- [ ] Application des bonus de prestige au démarrage
- [ ] Interface pour confirmer et visualiser la réinitialisation
- [ ] Feedback visuel et sonore lors de la réinitialisation
- [ ] Tests de cohérence et de stabilité après réinitialisation

### Notes techniques
```gdscript
# Exemple de réinitialisation
func reset_game_with_prestige() -> void:
    # Conserver les reliques et talents
    var relics = Services.game_data.relics
    var talents = Services.game_data.talents_purchased
    
    # Réinitialiser les autres données
    Services.game_data.reset(true)
    
    # Appliquer les bonus de prestige
    apply_prestige_bonuses(relics, talents)
```

---

## PRESTIGE-05: Interface et feedback pour le prestige

**Priorité :** Basse  
**Dépend de :** PRESTIGE-01, PRESTIGE-02  
**Estimation :** 3 heures  
**Sources :** `_specs_/game_design_incremental.md`

### Description
Créer une interface dédiée pour le système de prestige, permettant aux joueurs de visualiser leurs progrès, les reliques, et les talents disponibles.

### Critères de validation
- [ ] Interface claire pour visualiser les reliques et talents
- [ ] Indicateurs de progression vers le prochain prestige
- [ ] Feedback visuel et sonore lors des actions de prestige
- [ ] Optimisation pour une navigation fluide
- [ ] Cohérence avec le style graphique du jeu

### Notes techniques
```gdscript
# Exemple de mise à jour de l'interface de prestige
func update_prestige_interface() -> void:
    var relics = Services.game_data.relics
    var talents = Services.game_data.talents_purchased
    
    # Mettre à jour l'affichage
    set_relics_display(relics)
    set_talents_display(talents)
```
