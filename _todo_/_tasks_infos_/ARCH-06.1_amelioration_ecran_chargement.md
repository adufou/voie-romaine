# ARCH-06.1: Amélioration de l'écran de chargement pour attendre le démarrage complet des services

## Description
Amélioration de l'écran de chargement pour garantir que tous les services sont non seulement initialisés mais également complètement démarrés avant de quitter l'écran de chargement, en utilisant un arbre de dépendances pour optimiser le processus.

## Problème identifié
Malgré l'implémentation de l'écran de chargement (ARCH-06), un problème persistait : la fonction `add_dice()` du service de dés était toujours appelée avant que le service ne soit complètement démarré (flag `is_started` à `false`). Le code de l'écran de chargement ne vérifiait que l'initialisation des services, pas leur démarrage complet.

## Solution implémentée

### 1. Construction d'un arbre de dépendances des services
Ajout d'un système d'arbre de dépendances dans la classe `Services` qui :
   - Identifie les relations de dépendance entre les différents services
   - Calcule un ordre optimal de démarrage des services basé sur ces dépendances
   - Utilise un algorithme de tri topologique pour générer cet ordre

### 2. Amélioration de l'écran de chargement
Modification de l'écran de chargement pour utiliser cet arbre de dépendances :
   - Attente des services selon l'ordre calculé par l'arbre de dépendances
   - Affichage du statut de chargement de chaque service
   - Mise à jour progressive de la barre de progression
   - Implémentation d'un fallback si l'arbre de dépendances n'est pas disponible

Cette approche garantit non seulement que tous les services sont complètement démarrés avant que l'écran de chargement ne disparaisse, mais aussi que le processus de démarrage est optimisé en tenant compte des dépendances entre services.

## Fichiers modifiés
- `/scenes/loading_screen.gd`
- `/autoload/services.gd`

## Date de complétion
03/05/2025
