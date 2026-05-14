% methode_connexions/lpo/arbre_indexe.pl

:- module(arbre_indexe_lpo, [
    generer_arbre_indexe/3,

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

:- multifile regles_communes:etiqueter/7.

% ============================================================================
%   generer_fils_gamma(Compteur, Formule, Variable, Polarite, IndexIn, IndexOut, MultipliciteInitiale, ListeFils)
% ============================================================================
% Cas de base : on a fini de générer les M copies
generer_fils_gamma(0, _, _, _, _, 0, _, []) :- !.
% Cas récursif : on génère une copie, puis on décrémente
generer_fils_gamma(K, A, X, Pol, IndexStart, MaxOut, M, [ArbreFils | ResteFils]) :-
    K > 0,
    NumCopie is M - K + 1, % Pour numéroter de 1 à M
    construire_nom(IndexStart, NumCopie, NomPosition),
    VariableGamma = var(NomPosition, _),
    substituer(A, X, VariableGamma, ASubst),
    regles_communes:etiqueter(ASubst, Pol, IndexStart, OutLocal, M, NumCopie, ArbreFils),
    K1 is K - 1,
    generer_fils_gamma(K1, A, X, Pol, IndexStart, OutReste, M, ResteFils),
    MaxOut is max(OutLocal, OutReste).

% Règles Gamma ---------------------------------------------------------------
% Règle (x pt A, 1) -> fils unique (A, 1, gamma1)
regles_communes:etiqueter(X pt A, 1, IndexIn, IndexOut, M, Suffix,
    noeud(etiq_formule(gamma, gamma0, none, X pt A, 1, NomComplet), ListeFils)) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    IndexSuivant is IndexIn + 1,
    generer_fils_gamma(M, A, X, 1, IndexSuivant, IndexOut, M, ListeFils).

% Règle (x ie A, 0) -> fils unique (A, 0, gamma1)
regles_communes:etiqueter(X ie A, 0, IndexIn, IndexOut, M, Suffix,
    noeud(etiq_formule(gamma, gamma0, none, X ie A, 0, NomComplet), ListeFils)) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    IndexSuivant is IndexIn + 1,
    generer_fils_gamma(M, A, X, 0, IndexSuivant, IndexOut, M, ListeFils).

% Règles Delta ---------------------------------------------------------------
% Règle (x pt A, O) -> fils unique (A, 0, delta1)
regles_communes:etiqueter(X pt A, 0, IndexIn, IndexOut, M, Suffix,
    noeud(etiq_formule(delta, delta0, none, X pt A, 0, NomComplet), [ArbreA])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    construire_nom(Index1, Suffix, NomPosition),    % Créer le nom de la prochaine position    
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 0, Index1, IndexOut, M, Suffix, ArbreA).

% Règle (x ie A, 1) -> fils unique (A, 1, delta1)
regles_communes:etiqueter(X ie A, 1, IndexIn, IndexOut, M, Suffix,
    noeud(etiq_formule(delta, delta0, none, X ie A, 1, NomComplet), [ArbreA])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    construire_nom(Index1, Suffix, NomPosition),    % Créer le nom de la prochaine position       
    substituer(A, X, NomPosition, ASubst),  % [X -> NomPosition] dans A
    regles_communes:etiqueter(ASubst, 1, Index1, IndexOut, M, Suffix, ArbreA).

% ============================================================================
% CONSTRUCTION ARBRE
%   generer_arbre_indexe(+Formule, +Multiplicite, -Arbre)
%   Polarite initiale = 0 (pour l'instant comme TD avec tautologie)
%   Index initial = 0
% ============================================================================
generer_arbre_indexe(Formule, Multiplicite, Arbre) :-
    regles_communes:etiqueter(Formule, 0, 0, _, Multiplicite, none, Arbre).

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
    nettoyer_formule(Formule, FormulePropre),
    ecrire_formule(FormulePropre),
    format("  [~w, ~w, _, ", [Index, Polarite]),
    ecrire_type(SousType),
    write(']'), nl.

% Cas noeud : appel depuis la racine (initiation du SousType à 'none')
afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite) :-
    afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite, none).

% Cas noeud n-aire 
afficher_arbre_indexe(noeud(Etiquette, ListeFils), Prefixe, PrefixeSuite, SousType) :-
    etiq_index(Etiquette, Index),
    etiq_formule(Etiquette, Formule),
    etiq_type_principal(Etiquette, Type),
    etiq_polarite(Etiquette, Polarite),
    etiq_type_secondaire1(Etiquette, TypeSec1),
    etiq_type_secondaire2(Etiquette, TypeSec2),
    write(Prefixe),
    nettoyer_formule(Formule, FormulePropre),
    ecrire_formule(FormulePropre),
    format("  [~w, ~w, ", [Index, Polarite]),
    ecrire_type(Type),
    write(', '),
    ecrire_type(SousType),
    write(']'), nl,
    afficher_liste_fils(ListeFils, PrefixeSuite, TypeSec1, TypeSec2).

% ============================================================================
%   afficher_liste_fils(+ListeFils, +PrefixeSuite, +TypeSec1, +TypeSec2)
% ============================================================================
afficher_liste_fils([], _, _, _).

% Cas 1 : Exactement 2 fils (Règles Alpha et Beta)
% Le premier fils reçoit TypeSec1 (ex: alpha1), le second reçoit TypeSec2 (ex: alpha2).
afficher_liste_fils([Fils1, Fils2], PrefixeSuite, TypeSec1, TypeSec2) :-
    !,
    atom_concat(PrefixeSuite, '├── ', PrefixeFils1),
    atom_concat(PrefixeSuite, '│   ', SuiteFils1),
    afficher_arbre_indexe(Fils1, PrefixeFils1, SuiteFils1, TypeSec1),
    atom_concat(PrefixeSuite, '└── ', PrefixeFils2),
    atom_concat(PrefixeSuite, '    ', SuiteFils2),
    afficher_arbre_indexe(Fils2, PrefixeFils2, SuiteFils2, TypeSec2).

% Cas 2 : Un seul fils (Règle Delta, ou dernier fils d'un Gamma)
% Utilise TypeSec1 (qui correspond à delta0 ou gamma0).
afficher_liste_fils([DernierFils], PrefixeSuite, TypeSec1, _) :-
    !,
    atom_concat(PrefixeSuite, '└── ', PrefixeFils),
    atom_concat(PrefixeSuite, '    ', SuiteFils),
    afficher_arbre_indexe(DernierFils, PrefixeFils, SuiteFils, TypeSec1).

% Cas 3 : Multiples fils (Règles Gamma à multiplicité > 1)
% Tous les fils Gamma reçoivent TypeSec1 (gamma0).
afficher_liste_fils([Fils | Reste], PrefixeSuite, TypeSec1, TypeSec2) :-
    Reste \= [],
    atom_concat(PrefixeSuite, '├── ', PrefixeFils),
    atom_concat(PrefixeSuite, '│   ', SuiteFils),
    afficher_arbre_indexe(Fils, PrefixeFils, SuiteFils, TypeSec1),
    afficher_liste_fils(Reste, PrefixeSuite, TypeSec1, TypeSec2).