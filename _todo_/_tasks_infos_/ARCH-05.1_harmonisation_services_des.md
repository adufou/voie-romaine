# ARCH-05.1: Harmonisation des noms de services de dés (DiceService/DicesService)

## Description du problème
Le projet contient actuellement deux implémentations de service de dés :
1. `DiceService` (singulier) dans dice_service.gd
2. `DicesService` (pluriel) dans dices_service.gd

Les deux services déclarent le même `service_name` comme "dice_service" dans leur méthode `_init()`, mais les noms de classes sont différents. Cela crée une confusion et des problèmes de typage lorsque d'autres services tentent d'accéder au service "dice_service".

## Actions réalisées
1. Mise à jour de la variable dans StatisticsService de `dice_service: DiceService` à `dices_service: DicesService`
2. Renommage de toutes les références à `dice_service` en `dices_service` dans StatisticsService
3. Renommage de toutes les références à `dice_service` en `dices_service` dans le singleton Services (services.gd)

## Actions additionnelles (03/05/2025)
1. Correction des références dans `scenes/table.gd` : changement de `Services.dice_service` à `Services.dices_service`
2. Correction des références dans `scenes/hud.gd` : changement de `Services.dice_service` à `Services.dices_service`
3. Correction de la clé de dépendance dans `autoload/services.gd` : changement de `"dice_service"` à `"dices_service"`

## Modifications en attente
Pour une harmonisation complète, il reste encore plusieurs points à traiter :
1. Les services GameService et GameDataService utilisent toujours le type DiceService
2. Les fichiers de service (dice_service.gd et dices_service.gd) utilisent le même service_name

## Solution à long terme
Pour une véritable harmonisation, une décision doit être prise :
- Soit standardiser sur la version singulier (DiceService) et migrer toutes les références
- Soit standardiser sur la version pluriel (DicesService) et migrer toutes les références

La version plurielle semble être l'implémentation principale utilisée par le système, donc elle devrait probablement être conservée comme standard.
