% methode_connexions/prop/arbre_indexe.pl

:- module(arbre_indexe_prop, [
    generer_arbre_indexe/2,

    afficher_arbre_indexe/1,

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
:- multifile regles_communes:etiqueter/7.

% ============================================================================
% Construction de l'arbre syntaxique indexé 
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
% Accesseurs ------------------------------------------------------------------
etiq_type_principal(etiq_formule(T, _, _, _, _, _), T).
etiq_type_secondaire1(etiq_formule(_, T, _, _, _, _), T).
etiq_type_secondaire2(etiq_formule(_, _, T, _, _, _), T).
etiq_formule(etiq_formule(_, _, _, F, _, _), F).
etiq_polarite(etiq_formule(_, _, _, _, P, _), P).
etiq_index(etiq_formule(_, _, _, _, _, I), I).

% ============================================================================
% CONSTRUCTION ARBRE
%   generer_arbre_indexe(+Formule, -Arbre)
%   Polarite initiale = 0 (pour l'instant comme TD avec tautologie)
%   Index initial = 0
% ============================================================================
generer_arbre_indexe(Formule, Arbre) :-
    regles_communes:etiqueter(Formule, 0, 0, _, none, none, Arbre).

% ============================================================================
% AFFICHAGE ARBRE 
%   afficher_arbre_indexe(+Arbre)
% ============================================================================
afficher_arbre_indexe(Arbre) :-
    afficher_arbre_indexe(Arbre, '', '').

afficher_arbre_indexe(feuille(Etiquette), Prefixe, _, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_polarite(Etiquette, Polarite),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [~w, ~w, _, ", [Index, Polarite]),
    ecrire_type(SousType),
    write(']'), nl.

% Cas noeud : appel depuis la racine (initiation du SousType à 'none')
afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite) :-
    afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite, none).

afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_type_principal(Etiquette, Type),
    etiq_polarite(Etiquette, Polarite),
    etiq_type_secondaire1(Etiquette, TypeSecondaire1),
    etiq_type_secondaire2(Etiquette, TypeSecondaire2),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [~w, ~w, ", [Index, Polarite]),
    ecrire_type(Type),
    write(', '),
    ecrire_type(SousType),
    write(']'), nl,
    afficher_liste_fils(ListeFils, PrefixeSuite, TypeSecondaire1, TypeSecondaire2).


% ============================================================================
%   afficher_liste_fils(+ListeFils, +PrefixeSuite, +TypeSec1, +TypeSec2)
% ============================================================================
afficher_liste_fils([], _, _, _).

% Le premier fils reçoit TypeSec1 (ex: alpha1), le second reçoit TypeSec2 (ex: alpha2).
afficher_liste_fils([Fils1, Fils2], PrefixeSuite, TypeSec1, TypeSec2) :-
    !,
    atom_concat(PrefixeSuite, '├── ', PrefixeFils1),
    atom_concat(PrefixeSuite, '│   ', SuiteFils1),
    afficher_arbre_indexe(Fils1, PrefixeFils1, SuiteFils1, TypeSec1),
    atom_concat(PrefixeSuite, '└── ', PrefixeFils2),
    atom_concat(PrefixeSuite, '    ', SuiteFils2),
    afficher_arbre_indexe(Fils2, PrefixeFils2, SuiteFils2, TypeSec2).

afficher_liste_fils([SeulFils], Suite, T1, _) :-
    !,
    atom_concat(Suite, '└── ', P1),
    atom_concat(Suite, '    ', S1),
    afficher_arbre_indexe(SeulFils, P1, S1, T1).

