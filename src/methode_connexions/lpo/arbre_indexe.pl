% methode_connexions/lpo/arbre_indexe.pl

:- module(arbre_indexe_lpo, [
    generer_arbre_indexe/2,

    afficher_arbre_indexe/1,
    afficher_arbre_indexe/3,
    afficher_arbre_indexe/4,

    etiq_type_principal/2,
    etiq_type_secondaire1/2,
    etiq_type_secondaire2/2,
    etiq_formule/2,
    etiq_polarite/2,
    etiq_index/2
]).

:- include('../../core/utils').
:- use_module('../../core/arbre').
:- use_module('../../core/regles_communes'). 

% ============================================================================
% Construction de l'arbre syntaxique indexé en LPO
%
% Etiquette des noeuds :
%       etiq_formule(TypePrincipal, TypeSec1, TypeSec2, Formule, Polarite, Index)
%
% Etiquette des feuilles :
%       etiq_formule(atome, none, none, Formule, Polarite, Index)
%
%       TypePrincipal  : alpha | beta | gamma | delta | atome
%       TypeSecondaire : alpha1 | alpha2 | beta1 | beta2 | gamma1 | delta1 | none
%       Polarite       : 1 (vrai) | 0 (faux)
%       Index          : entier, numérotation en parcours préordre
% ============================================================================
% Accesseurs identiques ------------------------------------------------------
etiq_type_principal(etiq_formule(T, _, _, _, _, _), T).
etiq_type_secondaire1(etiq_formule(_, T, _, _, _, _), T).
etiq_type_secondaire2(etiq_formule(_, _, T, _, _, _), T).
etiq_formule(etiq_formule(_, _, _, F, _, _), F).
etiq_polarite(etiq_formule(_, _, _, _, P, _), P).
etiq_index(etiq_formule(_, _, _, _, _, I), I).

:- multifile regles_communes:etiqueter/5.
% Règles Gamma ---------------------------------------------------------------
% Règle (x pt A, 1) -> fils unique (A, 1, gamma1)
regles_communes:etiqueter(X pt A, 1, IndexIn, IndexOut,
    noeud(etiq_formule(gamma, gamma0, none, X pt A, 1, IndexIn), ArbreA, nil)) :-
    Index1 is IndexIn + 1,
    atom_concat(a, Index1, NomPosition),    % Créer le nom de la prochaine position    
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 1, Index1, IndexOut, ArbreA).

% Règle (x ie A, 0) -> fils unique (A, 0, gamma1)
regles_communes:etiqueter(X ie A, 0, IndexIn, IndexOut,
    noeud(etiq_formule(gamma, gamma0, none, X ie A, 0, IndexIn), ArbreA, nil)) :-
    Index1 is IndexIn + 1,
    atom_concat(a, Index1, NomPosition),    % Créer le nom de la prochaine position    
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 0, Index1, IndexOut, ArbreA).

% Règles Delta ---------------------------------------------------------------
% Règle (x pt A, O) -> fils unique (A, 0, delta1)
regles_communes:etiqueter(X pt A, 0, IndexIn, IndexOut,
    noeud(etiq_formule(delta, delta0, none, X pt A, 0, IndexIn), ArbreA, nil)) :-
    Index1 is IndexIn + 1,
    atom_concat(a, Index1, NomPosition),    % Créer le nom de la prochaine position    
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 0, Index1, IndexOut, ArbreA).

% Règle (x ie A, 1) -> fils unique (A, 1, delta1)
regles_communes:etiqueter(X ie A, 1, IndexIn, IndexOut,
    noeud(etiq_formule(delta, delta0, none, X ie A, 1, IndexIn), ArbreA, nil)) :-
    Index1 is IndexIn + 1,
    atom_concat(a, Index1, NomPosition),    % Créer le nom de la prochaine position       
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 1, Index1, IndexOut, ArbreA).

% ============================================================================
% CONSTRUCTION ARBRE
%   generer_arbre_indexe(+Formule, -Arbre)
%   Polarite initiale = 0 (pour l'instant comme TD avec tautologie)
%   Index initial = 0
% ============================================================================
generer_arbre_indexe(Formule, Arbre) :-
    regles_communes:etiqueter(Formule, 0, 0, _, Arbre).

% ============================================================================
% AFFICHAGE ARBRE 
%   afficher_arbre_indexe(+Arbre)
% ============================================================================
afficher_arbre_indexe(Arbre) :-
    afficher_arbre_indexe(Arbre, '', '').

% Cas nil : rien à afficher
afficher_arbre_indexe(nil, _, _, _) :- !.
afficher_arbre_indexe(nil, _, _)    :- !.

% Cas feuille : appel depuis la racine
afficher_arbre_indexe(feuille(Etiquette), Prefixe, _) :-
    afficher_arbre_indexe(feuille(Etiquette), Prefixe, _, none).

% Cas feuille : appel depuis noeud parent
afficher_arbre_indexe(feuille(Etiquette), Prefixe, _, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_polarite(Etiquette, Polarite),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [a~w, ~w, _, ", [Index, Polarite]),
    ecrire_type(SousType),
    write(']'), nl.

% Cas noeud : appel depuis la racine
afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite) :-
    afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite, none).

% Cas noeud binaire : alpha ou beta, deux fils
afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite, SousType) :-
    Droit \= nil,
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_type_principal(Etiquette, Type),
    etiq_polarite(Etiquette, Polarite),
    etiq_type_secondaire1(Etiquette, TypeSecondaire1),
    etiq_type_secondaire2(Etiquette, TypeSecondaire2),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [a~w, ~w, ", [Index, Polarite]),
    ecrire_type(Type),
    write(', '),
    ecrire_type(SousType),
    write(']'), nl,
    atom_concat(PrefixeSuite, '├── ', PrefixeGauche),
    atom_concat(PrefixeSuite, '│   ', PrefixeSuiteGauche),
    atom_concat(PrefixeSuite, '└── ', PrefixeDroit),
    atom_concat(PrefixeSuite, '    ', PrefixeSuiteDroit),
    afficher_arbre_indexe(Gauche, PrefixeGauche, PrefixeSuiteGauche, TypeSecondaire1),
    afficher_arbre_indexe(Droit,  PrefixeDroit, PrefixeSuiteDroit, TypeSecondaire2).

% Cas noeud unaire : gamma ou delta, fils droit absent
afficher_arbre_indexe(noeud(Etiquette, Gauche, nil), Prefixe, PrefixeSuite, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_type_principal(Etiquette, Type),
    etiq_polarite(Etiquette, Polarite),
    etiq_type_secondaire1(Etiquette, TypeSecondaire1),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [a~w, ~w, ", [Index, Polarite]),
    ecrire_type(Type),
    write(', '),
    ecrire_type(SousType),
    write(']'), nl,
    atom_concat(PrefixeSuite, '└── ', PrefixeGauche),
    atom_concat(PrefixeSuite, '    ', PrefixeSuiteGauche),
    afficher_arbre_indexe(Gauche, PrefixeGauche, PrefixeSuiteGauche, TypeSecondaire1).
    
