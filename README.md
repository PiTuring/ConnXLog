```
   _____                 __   ___                 
  / ____|                \ \ / / |                
 | |     ___  _ __  _ __  \ V /| |     ___   __ _ 
 | |    / _ \| '_ \| '_ \  > < | |    / _ \ / _` |
 | |___| (_) | | | | | | |/ . \| |___| (_) | (_| |
  \_____\___/|_| |_|_| |_/_/ \_\______\___/ \__, |
                                             __/ |
                                            |___/                         
```


  **Université** : Université de Lorraine (Nancy) — Département Informatique<br/>
  **Module** : M1 S8 — Preuves & Déductions Automatisées<br/>
  **Auteurs** : PiTuring & Metheor31Game<br/>
  **Encadrant** : Didier Galmiche<br/>
  **Année universitaire** : 2025-2026<br/>
  **Licence** : MIT — voir `LICENSE`

---

## 📌 Présentation

Ce dépôt contient une implémentation pédagogique en **Prolog** de la **méthode des connexions**. Développé initialement par Wolfgang Bibel, ce calcul de démonstration automatique permet de vérifier la validité d'une formule en cherchant des connexions (paires de littéraux complémentaires) couvrant tous les chemins possibles de la formule sous forme de matrice.

L'objectif de ce projet est de proposer :
- Un moteur capable de traiter la **logique propositionnelle** et la **logique du premier ordre (LPO)**.
- Une gestion de la **multiplicité itérative** pour assurer la complétude en LPO.
- Une visualisation claire via des arbres syntaxiques indexés et des arbres de chemins.

---

## 🔧 Prérequis

- **SWI-Prolog** (version 8.x ou supérieur recommandée).
- Un terminal compatible UTF-8 (pour l'affichage des symboles logiques $\alpha, \beta, \forall, \exists, \rightarrow$, ...).

---

## ⚙️ Installation

1. Clonez le dépôt :
  ```bash
  git clone https://github.com/PiTuring/ConnXLog.git
  cd ConnXLog
  ```

2. Installez SWI-Prolog si nécessaire :
- **macOS** : ```brew install swi-prolog```
- **Ubuntu/Debian** : ```sudo apt install swi-prolog```
- **Windows** : télécharger SWI-Prolog depuis le site officiel https://www.swi-prolog.org/ et installer le binaire.

---

## 🚀 Démarrage rapide

1. Lancez SWI-Prolog à la racine :
  ```bash
  swipl src/main.pl
  ```

2. Exemples de commandes :
  ```prolog
  % Vérifier une formule propositionnelle (Tautologie de l'implication)
  ?- verif((p impl q) impl ((q impl r) impl (p impl r))).

  % Vérifier une formule LPO avec trace complète (Exemple du buveur)
  ?- trace_verif(x ie (y pt (p(y) impl p(x))), lpo).
  ```

---

## 🧭 Guide d'utilisation 

### Prédicats principaux
- `verif(Formule, Logique)` : Lance la vérification (Logique = `prop` ou `lpo`). Par défaut, `Logique` est `prop`.
- `trace_verif(Formule, Logique)` : Identique à `verif`, mais active l'affichage détaillé de l'arbre indexé, de l'arbre des chemins et des connexions trouvées.
- `verifier(Formule, lpo)` : En LPO, ce prédicat implémente un approfondissement itératif de la **multiplicité** (de 1 à 10) pour tenter de fermer les chemins.

### Syntaxe des formules
| Logique | Syntaxe Prolog | Symbole |
| :--- | :--- | :--- |
| Négation | `non A` | ¬ |
| Conjonction | `A et B` | ∧ |
| Disjonction | `A ou B` | ∨ |
| Implication | `A impl B` | → |
| Universel | `x pt A` | ∀x. |
| Existentiel | `x ie A` | ∃x. |


---

## 🗂️ Structure du projet

```text
src/
 ├── core/
 │    ├── arbre.pl            # Structure n-aire (noeud/feuille)
 │    ├── regles_communes.pl  # Règles alpha/beta et unification
 │    └── utils.pl            # Opérateurs, affichage et substitutions
 ├── methode_connexions/
 │    ├── prop/               # Modules spécifiques à la logique prop
 │    │    ├── arbre_indexe.pl
 │    │    ├── arbre_chemins.pl
 │    │    └── recherche_connexions.pl
 │    └── lpo/                # Modules spécifiques à la LPO
 │         ├── arbre_indexe.pl
 │         ├── arbre_chemins.pl
 │         └── recherche_connexions.pl
 └── main.pl                  # Point d'entrée et boucle de multiplicité
```

---

## 🔬 Exemples & Cas d'usage

### Logique du Premier Ordre (LPO)
Le système détecte automatiquement les variables à quantifier et applique les substitutions nécessaires via l'unification :
```prolog
?- trace_verif((x pt p(x)) impl (x ie p(x)), lpo).
% Résultat : Valide (M=1)
```

### Détection de Cycle / Échec
En cas de dépendance circulaire (instanciation impossible), le système conclut à la non-validité après avoir atteint la limite de multiplicité :
```prolog
?- verif((x pt (y ie p(x,y))) impl (y ie (x pt p(x,y))), lpo).
% Résultat : Non valide (Cycle détecté)
```

---

## ✍️ Contribuer

Contributions bienvenues :

1) Ouvrez un ticket décrivant l'amélioration souhaitée.
2) Créez une branche dédiée, puis envoyez une Pull Request avec des explications et tests si nécessaire.

Avant une PR :
- Documentez la fonctionnalité
- Ajoutez des exemples et tests (si vous ajoutez des prédicats)

---

## 📖 Références

- W. Bibel, *"An approach to a systematic theorem proving procedure in first-order logic"*, **Computing**, vol. 12, pp. 43–55, 1974
- W. Bibel, *Automated Theorem Proving*, Vieweg+Teubner Verlag, 1982 (2e éd. 1987)
- L. A. Wallen, *Automated Proof Search in Non-Classical Logics: Efficient Matrix Proof Methods for Modal and Intuitionistic Logics*, MIT Press, 1990
- Cours M1 Preuves & déductions automatisées — Didier Galmiche, Université de Lorraine

---

## 📝 Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour le texte complet de la licence.

---

## Auteurs

PiTuring & Metheor31Game — Implementation pédagogique et didactique — M1 S8, Master Informatique, Université de Lorraine.

---
