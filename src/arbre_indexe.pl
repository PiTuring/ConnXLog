% arbre_indexe.pl

% ============================================================================
% Construction de l'arbre syntaxique indexé 
%
% Etiquette des noeuds :
%       etiq_formule(TypePrincipal, TypeSec1, TypeSec2, Formule, Polarite, Index)
%
% Etiquette des feuilles :
%       etiq_formule(atome, none, none, Formule, Polarite, Index)
%
%       TypePrincipal  : alpha | beta | atome
%       TypeSecondaire : alpha1 | alpha2 | beta1 | beta2 | none
%       Polarite       : 1 (vrai) | 0 (faux)
%       Index          : entier, numérotation en parcours préordre
% ============================================================================

:- module(arbre_indexe, [
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

:- include(operateurs).
:- use_module(arbre).

% Accesseurs ------------------------------------------------------------------

etiq_type_principal(etiq_formule(T, _, _, _, _, _), T).
etiq_type_secondaire1(etiq_formule(_, T, _, _, _, _), T).
etiq_type_secondaire2(etiq_formule(_, _, T, _, _, _), T).
etiq_formule(etiq_formule(_, _, _, F, _, _), F).
etiq_polarite(etiq_formule(_, _, _, _, P, _), P).
etiq_index(etiq_formule(_, _, _, _, _, I), I).

% ============================================================================
% etiqueter(+Formule, +Polarite, +IndexIn, -IndexOut, -Arbre)
%
% IndexIn   : prochain index dispo en entrée
% IndexOut  : prochain index dispo après construction
% ============================================================================


% Règles ALPHA ---------------------------------------------------------------

% (A et B, 1) -> (A, 1, alpha1) | (B, 1, alpha2)
etiqueter(A et B, 1, IndexIn, IndexOut,
        noeud(etiq_formule(alpha, alpha1, alpha2, A et B, 1, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).

% (A ou B, 0) -> (A, 0, alpha1) | (B, 0, alpha2)
etiqueter(A ou B, 0, IndexIn, IndexOut,
        noeud(etiq_formule(alpha, alpha1, alpha2, A ou B, 0, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% (A impl B, 0) -> (A, 1, alpha1) | (B, 0, alpha2)
etiqueter(A impl B, 0, IndexIn, IndexOut,
        noeud(etiq_formule(alpha, alpha1, alpha2, A impl B, 0, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% IMPLICITE (non A, Polarite) -> (A, 1 - Polarite, alpha1)
etiqueter(non A, Polarite, IndexIn, IndexOut, Arbre) :-
    PolariteInverse is 1 - Polarite,
    etiqueter(A, PolariteInverse, IndexIn, IndexOut, Arbre).


% Règles BETA ----------------------------------------------------------------

% (A et B, 0) -> (A, 0, beta1) | (B, 0, beta2)
etiqueter(A et B, 0, IndexIn, IndexOut,
        noeud(etiq_formule(beta, beta1, beta2, A et B, 0, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% (A ou B, 1) -> (A, 1, beta1) | (B, 1, beta2)
etiqueter(A ou B, 1, IndexIn, IndexOut,
        noeud(etiq_formule(beta, beta1, beta2, A ou B, 1, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).

% (A impl B, 1) -> (A, 0, beta1) | (B, 1, beta2)
etiqueter(A impl B, 1, IndexIn, IndexOut,
        noeud(etiq_formule(beta, beta1, beta2, A impl B, 1, IndexIn),
              ArbreA, ArbreB)) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).

% Atomes (feuilles) ------------------------------------------------------------

% Si A est un atome, alors le résultat est une feuille.
etiqueter(A, Polarite, Index, IndexOut, feuille(etiq_formule(atome, none, none, A, Polarite, Index))) :-
    atom(A),
    IndexOut is Index + 1.

% ============================================================================
% CONSTRUCTION ARBRE
%   generer_arbre_indexe(+Formule, -Arbre)
%   Polarite initiale = 0 (pour l'instant comme TD avec tautologie)
%   Index initial = 0
% ============================================================================

generer_arbre_indexe(Formule, Arbre) :-
    etiqueter(Formule, 0, 0, _, Arbre).

% ============================================================================
% AFFICHAGE ARBRE (pour debug)
%   afficher_arbre_indexe(+Arbre)
% ============================================================================

afficher_arbre_indexe(Arbre) :-
    afficher_arbre_indexe(Arbre, '', '').

afficher_arbre_indexe(feuille(Etiquette), Prefixe, _) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_polarite(Etiquette, Polarite),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [a~w, ~w, _, ", [Index, Polarite]),
    ecrire_type('_'),
    write(']'), nl.

afficher_arbre_indexe(feuille(Etiquette), Prefixe, _, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_polarite(Etiquette, Polarite),
    write(Prefixe),
    ecrire_formule(Formule),
    format("  [a~w, ~w, _, ", [Index, Polarite]),
    ecrire_type(SousType),
    write(']'), nl.

afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite) :-
    afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite, none).

afficher_arbre_indexe(noeud(Etiquette, Gauche, Droit), Prefixe, PrefixeSuite, SousType) :-
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