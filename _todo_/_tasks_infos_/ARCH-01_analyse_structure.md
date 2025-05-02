# Analyse de la structure existante - La Voie Romaine

## Introduction

Ce document présente une analyse de la structure existante du projet La Voie Romaine, en se concentrant sur les systèmes de dés (Dices), de monnaie (Cash) et de score (Score). L'objectif est de comprendre l'implémentation actuelle afin de planifier l'intégration de ces systèmes dans la nouvelle architecture basée sur les services.

## Structure actuelle

### Vue d'ensemble

Le projet est actuellement organisé avec trois services principaux qui fonctionnent indépendamment:
- **Dices**: Gestion des dés sur la table de jeu
- **Cash**: Gestion de la monnaie/or du jeu
- **Score**: Gestion du score du jeu

Ces services ne sont pas encore intégrés dans une architecture centralisée mais sont référencés via un singleton "Services" mentionné dans le fichier `table.gd`.

### Analyse des classes existantes

#### Classe Dices (`services/dices/dices.gd`)

**Responsabilités**:
- Gestion des dés sur une table de jeu
- Positionnement des dés dans une grille 4x8 (maximum 32 dés)
- Ajout et suppression de dés
- Lancement de tous les dés

**Propriétés clés**:
- `MAX_DICES = 32`: Nombre maximum de dés pouvant être placés
- `table`: Référence à l'instance de Table sur laquelle les dés sont placés
- `dices`: Dictionnaire stockant les références aux dés par leur slot

**Méthodes principales**:
- `init_table()`: Initialise la référence à la table
- `add_dice()`: Ajoute un dé au premier slot disponible
- `remove_dice()`: Supprime un dé spécifique
- `get_dice_position()`: Calcule la position d'un dé selon son slot
- `throw_dices()`: Lance tous les dés sur la table

**Interactions**:
- Dépend de la classe Table pour le positionnement
- Instancie des objets Dice (packed_scene) pour chaque dé ajouté

#### Classe Cash (`services/cash.gd`)

**Responsabilités**:
- Gestion de la monnaie du joueur (or)
- Notification des changements de monnaie

**Propriétés clés**:
- `_cash`: Valeur entière représentant la monnaie du joueur

**Méthodes principales**:
- `add_cash()`: Ajoute une quantité spécifiée à la monnaie actuelle
- `use_cash()`: Réduit la monnaie par une quantité spécifiée

**Signaux**:
- `cash_changed`: Émis lorsque la valeur de la monnaie change

#### Classe Score (`services/score.gd`)

**Responsabilités**:
- Gestion du score du joueur
- Calcul du score basé sur les buts atteints dans le jeu

**Propriétés clés**:
- `_score`: Valeur entière représentant le score du joueur

**Méthodes principales**:
- `pass_goal()`: Ajoute des points au score lorsqu'un but est atteint (7 - goal)

**Signaux**:
- `score_changed`: Émis lorsque la valeur du score change

#### Classe Table (`scenes/table.gd`)

**Responsabilités**:
- Agit comme conteneur visuel pour les dés
- Initialise la connexion avec le service Dices

**Comportement**:
- Dans `_ready()`, initialise la table dans le service Dices et ajoute un dé initial

## Points d'intégration avec la nouvelle architecture

### 1. Système de Services centralisé

Le service principal (Autoload) devra gérer l'accès à tous les services, y compris les existants.

**Points d'intégration**:
- Inclure les références aux services existants (Cash, Score, Dices)
- Garantir l'initialisation correcte de ces services dans le processus en trois phases

### 2. Communication entre anciens et nouveaux services

**Points d'intégration**:
- Cash <-> GameDataService: Synchroniser les valeurs d'or
- Score <-> GameDataService: Synchroniser les valeurs de score
- Dices <-> RulesService: Les règles du jeu doivent pouvoir interagir avec les dés

### 3. Sauvegarde et chargement

**Points d'intégration**:
- Ajouter la capacité de sauvegarde/chargement aux services existants
- Intégrer les données des services existants dans le système de sauvegarde global

## Modifications nécessaires

### 1. Modifications pour Cash

- Étendre les fonctionnalités pour s'intégrer avec GameDataService
- Ajouter des méthodes de sauvegarde/chargement
- Potentiellement refactoriser pour hériter de BaseService

### 2. Modifications pour Score

- Étendre les fonctionnalités pour s'intégrer avec GameDataService
- Ajouter des méthodes de sauvegarde/chargement
- Potentiellement refactoriser pour hériter de BaseService

### 3. Modifications pour Dices

- Améliorer l'intégration avec le système de règles
- Ajouter des méthodes de sauvegarde/chargement
- Potentiellement refactoriser pour s'adapter à l'architecture de services

## Conclusion

La structure existante est relativement simple mais fonctionnelle, avec des responsabilités clairement séparées entre les services. Les points d'intégration avec la nouvelle architecture sont identifiables et réalisables, nécessitant principalement des modifications pour assurer la compatibilité et la communication entre les systèmes existants et nouveaux.

L'implémentation de BaseService et du singleton Services devra prendre en compte les spécificités des services existants pour garantir une transition fluide vers la nouvelle architecture.
