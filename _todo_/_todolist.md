# La Voie Romaine - Plan de Développement

## Concept du jeu
Jeu incrémental basé sur la Voie Romaine (lancer de dé pour obtenir 6→5→4→3→2→1 avec règles de Beugnette). Progression par améliorations, types de dés et système de prestige.

## Architecture (Priorité 1)
- [x] Analyse de la structure existante
- [x] Implémenter BaseService et système d'Autoload Services
- [x] Configurer la sauvegarde/chargement - Terminé le 03/05/2025
- [x] Intégrer les systèmes existants (Cash, Score, Dices) - Terminé le 03/05/2025
- [x] Système d'enregistrement et diagnostic (Logger) - Terminé le 03/05/2025

## Services Core (Priorité 1)
- [ ] GameDataService (or, score, statistiques)
- [ ] RulesService (règles de jeu, résolution des lancers)
- [ ] UpgradeService (améliorations achetables)
- [ ] GameService (coordination globale)

## Gameplay de Base (Priorité 2)
- [ ] Système de dés Voie Romaine (6→5→4→3→2→1)
- [ ] Beugnette et Super Beugnette
- [ ] Économie (or & score) et améliorations

## Interface & UX (Priorité 2)
- [ ] Table de jeu avec positionnement des dés
- [ ] UI des magasins et stats
- [ ] Animations et feedback visuel

## Fonctionnalités Avancées (Priorité 3)
- [ ] Types de dés spéciaux
- [ ] Lanceurs automatiques
- [ ] Système de Fièvre (interaction active)
- [ ] Mini-jeu "Voie Express"

## Meta-Progression (Priorité 4)
- [ ] Système de prestige (Reliques)
- [ ] Arbre de talents
- [ ] Challenges avec règles modifiées
- [ ] Accomplissements

## Finition (Priorité 5)
- [ ] Équilibrage de l'économie
- [ ] Tests et optimisation
- [ ] Builds multi-plateformes
- [ ] Documentation