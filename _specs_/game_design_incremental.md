# La Voie Romaine - Design Document (Version Incrémentale)

## Concept général
Un jeu incrémental basé sur le jeu traditionnel de la Voie Romaine où le joueur commence avec un simple dé et développe progressivement un "temple de dés" générant des richesses. Le joueur lance des dés selon les règles de la Voie Romaine (6, 5, 4, 3, 2, 1) et utilise les gains pour développer son système.

## 1. Mécaniques fondamentales

### Système de dés
- **Règles de base**: Commencer par obtenir 6, puis 5 essais pour faire 5, 4 essais pour faire 4, etc.
- **Beugnette**: Quand on rate le dernier essai mais qu'on fait (goal+1), on récupère tous ses essais
- **Super Beugnette**: Quand on rate le 1 et qu'on fait 6, on retourne au début (but = 6)

### Système d'économie et de score

#### Or (ressource à court terme)
- **Gain initial**: Or gagné uniquement en atteignant le but 1 (complétion d'une séquence entière)
- **Progression**: Déblocage de gains intermédiaires à chaque but via les reliques de prestige
- **Fonction**: Ressource dépensable pour acheter des améliorations dans la run actuelle
- **Indicateurs**: Or/seconde, or total, or non dépensé

#### Score (ressource à long terme)
- **Gain de base**: (7-goal) points pour chaque but atteint (plus le but est bas, plus la récompense est élevée)
- **Progression**: Amélioration de la formule de score via l'arbre de talents après prestige
- **Fonction**: Détermine les points de prestige gagnés lors d'une réinitialisation
- **Indicateurs**: Score total, meilleur score, multiplicateur de score

### Système de chance
- **Mécanique de base**: Dans le jeu standard, chaque face du dé a 16,67% (1/6) de chance d'apparaître
- **Modificateurs de chance**: Certaines améliorations peuvent augmenter la probabilité d'obtenir la valeur souhaitée
  - Exemple: Avec +20% de chance, la probabilité d'obtenir le goal passe de 16,67% à 20%
- **Critiques**: Chance supplémentaire qu'un lancer réussi donne une récompense multipliée
  - Un critique standard donne x2 or pour ce lancer
  - Les critiques rares peuvent donner x3 ou x5

### Système de Fièvre (interaction active)
- **Jauge de Fièvre**: Se remplit lorsque le joueur tapote/clique sur l'écran
- **Multiplicateur progressif**: Plus la jauge est remplie, plus le multiplicateur appliqué est important
  - Exemple: 25% = x1.25, 50% = x1.5, 75% = x2, 100% = x3
- **Application**: Affecte à la fois le score et l'or générés par tous les dés
- **Décroissance**: La jauge se vide progressivement si le joueur cesse d'interagir
- **Combinaisons**: Certains types de dés ou améliorations peuvent modifier l'effet de la fièvre
  - **Dé de Fièvre**: Spécialisé dans les bonus liés à la jauge de fièvre
  - **Talents**: Décroissance plus lente, remplissage plus rapide, effets spéciaux à pleine jauge

## 2. Progression du joueur

### Améliorations achetables
| Amélioration | Effet | Coût initial | Croissance |
|--------------|-------|--------------|------------|
| Vitesse de lancer | +10% vitesse/niveau | 50 or | x1.5 |
| Chance critique | +1% chance/niveau | 100 or | x2 |
| Multiplicateur d'or | +10% or/niveau | 75 or | x1.8 |
| Lanceurs auto | +1 lancer auto/5s | 500 or | x3 |
| Emplacement de dé | +1 dé sur table | 1000 or | x4 |

### Types de dés déblocables
| Type | Caractéristiques | Débloqué par |
|------|------------------|--------------|
| Dé standard | Probabilités standard (1/6 pour chaque face) | Début |
| Dé doré | +50% or par lancer réussi, mais -10% de chance d'obtenir le goal | 5000 or |
| Dé chanceux | +20% de chance d'obtenir le goal, mais -25% d'or par lancer | 5000 or |
| Dé risqué | 40% de chance de doubler l'or gagné, 20% de chance de tout perdre | 10000 or |
| Dé antique | Peut activer des effets spéciaux rares (extra-essais, bonus temporaires) | 1 Relique |

### Arbre de talents (post-prestige)
- **Branche Fortune**: Augmente gains d'or et chances de critique
- **Branche Chance**: Améliore chances de réussite et effets de Beugnette
- **Branche Automatisation**: Optimise lancers auto et gestion multi-dés
- **Branche Express**: Améliore les effets et la durée des multiplicateurs du mini-jeu

## 3. Système de prestige

### Reliques
- Obtenus en sacrifiant progression actuelle (prestige)
- Formule: Log(or_total/1000)
- Chaque relique: +5% multiplicateur permanent à tous les gains
- Reliques spéciales déblocables :
  - **Relique de récolte**: Débloque des gains d'or intermédiaires à chaque but atteint
  - **Relique de célérité**: Accélère la vitesse de lancer de base
  - **Relique de fortune**: Augmente les gains de score

### Sagesse ancienne
- Points de talent obtenus au prestige
- Utilisés pour débloquer des capacités dans l'arbre de talents
- Formule: √(nombre_de_reliques)

### Réinitialisation
- Conserve: Reliques, Talents, Accomplissements
- Perd: Or, Améliorations, Dés actifs
- Bonus au démarrage selon prestige précédent

## 4. Contenu étendu

### Système de Mini-Jeu: "Voie Express"

#### Concept
- Version simplifiée de la Voie Romaine jouable à tout moment en parallèle du jeu principal
- Accessible via un bouton dédié dans l'interface ou un dé spécial visible dans un coin de l'écran
- Offre des multiplicateurs temporaires qui boostent les gains du jeu principal

#### Mécaniques
- **Un seul dé**: Utilise un dé unique avec règles de base de la Voie Romaine (6→5→4→3→2→1)
- **Essais standards**: Conserve le système d'essais du jeu principal (6 essais pour faire 6, etc.)
- **Règles de base**: Les règles de Beugnette et Super Beugnette s'appliquent normalement

#### Système de récompense
- **Multiplicateur progressif**:
  - Chaque but atteint: +multiplicateur x1.1 pendant 30 secondes
  - Chaque but supplémentaire: +10 secondes de durée au multiplicateur actif
  - Complétion d'une séquence complète: augmente le multiplicateur de base de +0.1
- **Indicateurs visuels**:
  - Aura lumineuse autour des dés du jeu principal quand le multiplicateur est actif
  - Timer visuel montrant le temps restant du multiplicateur
  - Compteur indiquant la puissance du multiplicateur actuel

#### Évolution & Améliorations
| Amélioration | Effet | Débloqué par |
|--------------|-------|--------------|
| Bonus de chaîne | Compléter plusieurs séquences consécutives sans échec augmente le multiplicateur de +0.05 par chaîne | 15000 or |
| Persistance | Le multiplicateur perd sa puissance progressivement (-0.1 toutes les 20 secondes) au lieu de disparaître d'un coup | Talent de prestige |
| Double récompense | 20% de chance qu'un but atteint compte double pour la progression du multiplicateur | 8 Reliques |
| Synchronisation | Les dés principaux ont 5% de chance de générer un lancé automatique dans le mini-jeu | Talent de prestige |
| Écho temporel | La première séquence complétée après un prestige utilise le dernier multiplicateur obtenu avant le prestige | 12 Reliques |
| Dé mémoriel | Mémorise le prochain lancer nécessaire, +25% de chance de l'obtenir | 20000 or |
| Effet de cascade | Les lancers critiques dans le jeu principal ajoutent du temps au multiplicateur | Talent de prestige |


### Système de challenges
- **Déblocage**: Après avoir atteint un certain cap de progression (score/prestige à définir)
- **Durée**: Run complète sous des règles spéciales
- **Récompenses**: Gemmes, Points prestige bonus, Dés spéciaux, Reliques uniques

#### Exemples de challenges
- **Super Beugnette généralisée**: La super beugnette peut se déclencher pour tous les buts, pas seulement pour le but 1
- **Sans filet**: La beugnette est désactivée complètement
- **Chance infime**: La probabilité d'obtenir le but est réduite significativement
- **Pressure**: Le nombre d'essais par but est réduit de 1 (4 essais pour 5, 3 pour 4, etc.)
- **Mode Hardcore**: Combinaison de plusieurs modificateurs difficiles

### Accomplissements
| Catégorie | Exemples |
|-----------|----------|
| Progression | "Obtenir 1M d'or total" |
| Collection | "Posséder tous les types de dés" |
| Maîtrise | "Réussir 100 lancers parfaits" |
| Prestige | "Atteindre 50 Reliques" |
| Mini-Jeu | "Maintenir un multiplicateur x2.0 pendant 5 minutes" |

## 5. Interface utilisateur

### Écrans principaux
- **Table de jeu**: Affichage des dés actifs (grille 4×8)
- **Améliorations**: Liste d'achats disponibles
- **Mini-Jeu Voie Express**: Interface dédiée pour le mini-jeu avec son dé unique
- **Prestige**: Menu de réinitialisation et arbre de talents
- **Statistiques**: Données de progression et records

### Éléments d'UI
- **Compteur d'or**: Affichage en haut de l'écran
- **Indicateur de lancers/sec**: Vitesse actuelle du système
- **Indicateur de multiplicateur**: Valeur et durée du bonus du mini-jeu
- **Notifications**: Alertes pour événements et accomplissements

## 6. Progression technique & Balance

### Étapes de progression
1. **Débutant**: 0-1000 or - Lancers manuels, premières améliorations
2. **Développement**: 1000-25k or - Premiers lanceurs auto, multi-dés
3. **Expansion**: 25k-500k or - Table complète, tous types de dés
4. **Maîtrise**: 500k-10M or - Optimisation pour premier prestige
5. **Prestige**: 10M+ or - Cycles de prestige, déblocage de contenu avancé

### Courbe de difficulté
- Premier prestige atteint en ~2-3h de jeu
- Progression arithmétique initiale → progression géométrique
- Points d'équilibre réguliers pour maintenir l'intérêt

## 7. Aspects techniques (Godot)

### Structure des scènes
- **Main**: Contrôleur principal et UI
- **DiceManager**: Gestion de tous les dés (utiliser la classe Dices existante)
- **UpgradeSystem**: Logique d'achat et d'application des améliorations
- **PrestigeManager**: Logique de réinitialisation et bonus permanents
- **ExpressGame**: Gestion du mini-jeu et de ses multiplicateurs

### Extensions potentielles
- Système de sauvegarde/chargement automatique
- Support hors-ligne (calcul des gains pendant l'absence)
- Système d'export de sauvegarde/import

## 8. Calendrier de développement

### Étapes de développement proposées
1. **Base**: Système de dés existant + UI basique + premières améliorations
2. **Progression**: Système complet d'améliorations + multi-dés
3. **Diversification**: Types de dés différents + événements + mini-jeu Voie Express
4. **Méta**: Système de prestige complet + arbre de talents
5. **Finition**: Accomplissements + équilibrage + polissage

## 9. Style graphique

### Palette de couleurs
- **Fond principal**: Noir (#000000)
- **Éléments d'accentuation**: Couleurs vives pour différencier les concepts clés:
  - Vert vif (#00FF00) pour les gains et progressions positives
  - Bleu électrique (#00FFFF) pour les systèmes de chance
  - Jaune (#FFFF00) pour l'or et les ressources
  - Rouge (#FF0000) pour le prestige et les éléments premium
  - Violet (#FF00FF) pour les effets spéciaux/critiques

### Direction artistique
- **Minimaliste et épuré**: Interface utilisateur faite "à la main", très simple
- **Pixel art léger**: Utilisation limitée de pixel art pour ne pas que ce soit trop lisse
  - Contours des dés et des boutons légèrement pixelisés
  - Animations simples avec transitions franches
- **Contraste**: Éléments importants mis en valeur sur fond noir
- **Cohérence visuelle**: Système visuel unifié avec codes couleurs constants

### Typographie
- **Police principale**: Non pixel art, douce, facile à lire, moderne
  - Option: Montserrat ou Open Sans pour l'interface générale
  - Variante légèrement plus stylisée pour les titres
- **Taille et lisibilité**: Texte suffisamment grand et contrasté
- **Hiérarchie visuelle**: Variation de poids et taille pour indiquer l'importance

### Effets visuels
- **Shader de vignettage**: Léger assombrissement des bords pour focaliser l'attention
- **Shader de scintillement**: Effet subtil de brillance sur les éléments interactifs
- **Effets de particules**: Simples et peu gourmands pour les moments clés (gains importants, prestige)
- **Animations**: Transitions fluides mais discrètes entre les états de jeu

### Game Juice
- **Principes de base**: Maximiser la sensation de satisfaction sans compromettre la simplicité visuelle
- **Réactivité tactile**: 
  - Micro-animations de feedback sur chaque interaction (boutons qui s'enfoncent, éléments qui vibrent)
  - Effets sonores courts et satisfaisants pour chaque action
- **Événements satisfaisants**:
  - Animations "squash and stretch" sur les dés lors des lancers
  - Éclatement de particules lors des réussites et critiques
  - Effets de zoom/pulse sur les chiffres qui augmentent
  - Effets d'ondes concentriques lors des milestones
- **Retours sensoriels**:
  - Vibrations subtiles (haptic feedback) sur appareil mobile
  - Échelles de sons pour les paliers de réussite (accords de plus en plus satisfaisants)
  - Animation de "cascade" visuelle lors des séquences de réussite continues
- **Progression visuelle**:
  - Effets d'éclat de plus en plus impressionnants à mesure que le joueur progresse
  - Transformations visuelles des dés selon leur niveau d'amélioration

### Responsive design
- **Adaptation aux formats**: Interface adaptable pour différentes tailles d'écran
- **Zones tactiles**: Éléments interactifs suffisamment grands pour les appareils tactiles
- **Optimisation**: Simplification des éléments visuels sur petits écrans sans perte de fonctionnalité
