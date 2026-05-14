% methode_connexions/lpo/recherche_connexions.pl

:- module(recherche_connexions_lpo, [
	verifier_connexions/2,
	afficher_connexions/1
]).
:- include('../../core/utils').
:- use_module('../../core/arbre').
:- use_module(arbre_indexe).
:- use_module(arbre_chemins).

% ============================================================================
% Recherche dans chaque chemin final d'un arbre généré par `arbre_chemins`
% d'une connexion.
% ============================================================================

% ============================================================================
% verifier_connexions(+ArbreChemins, -Resultat)
%
% Resultat : valide si tous les chemins finaux contiennent une connexion.
%			 invalide sinon.
% ============================================================================
verifier_connexions(ArbreChemins, valide) :-
	tous_chemins_connectes(ArbreChemins), !.
verifier_connexions(_, invalide).

% ============================================================================
% tous_chemins_connectes(+ArbreChemins)
%
% Vari si tous les chemins finaux de l'arbre contiennent une connexion.
% ============================================================================
% Lorsqu'on est sur un chemin final, on vérifie si il existe une connexion
tous_chemins_connectes(feuille(etiq_chemin_final(Feuilles))) :-
	chemin_connecte(Feuilles).
% Sinon on vérifie dans les fils
tous_chemins_connectes(noeud(_, FilsGauche, nil)) :-
	tous_chemins_connectes(FilsGauche).
tous_chemins_connectes(noeud(_, FilsGauche, FilsDroit)) :-
	FilsDroit \= nil,
	tous_chemins_connectes(FilsGauche),
	tous_chemins_connectes(FilsDroit).

% ============================================================================
% chemin_connecte(+Feuilles)
%
% Vrai si la liste de feuilles contient une connexion.
% ============================================================================
chemin_connecte(Feuilles) :-
	connexion(Feuilles, _, _), !.

% ============================================================================
% connexion(+Feuilles, -Feuille1, -Feuille2)
%
% Trouve une paire de feuilles de même prédicat et de polarité opposée.
% ============================================================================
connexion(Feuilles, F1, F2) :-
	% On prend une feuille du chemin
	select(F1, Feuilles, Reste),

	% Extraction de polarite et symbole
	feuille_etiquette(F1, Etiquette1),
	etiq_formule(Etiquette1, Litteral1),
	etiq_polarite(Etiquette1, Polarite1),

	% Polarite de l'autre element doit etre inverse
	Polarite2 is 1 - Polarite1,

	% On prend une autre feuille
	member(F2, Reste),

	% On vérifie parité opposée
	feuille_etiquette(F2, Etiquette2),
	etiq_formule(Etiquette2, Litteral2),
	etiq_polarite(Etiquette2, Polarite2),

	unifier_lpo(Litteral1, Litteral2).

% ============================================================================
% afficher_connexions(+ArbreChemins)
%
% Affiche pour chaque chemin final la connexion trouvée ou son abscence.
% ============================================================================
afficher_connexions(ArbreChemins) :- 
	afficher_connexions(ArbreChemins, 1, _).
afficher_connexions(feuille(etiq_chemin_final(Feuilles)), N, N1) :-
	N1 is N + 1,
    format("  Chemin ~w : ", [N]),
    (       connexion(Feuilles, F1, F2) ->  feuille_etiquette(F1, Etiquette1),
                  feuille_etiquette(F2, Etiquette2),
                  etiq_index(Etiquette1, Index1),
                  etiq_index(Etiquette2, Index2),
                  etiq_formule(Etiquette1, Symbole),
									nettoyer_formule(Symbole, SymbolePropre),
                  format("connexion (a~w, a~w) sur '~w'.~n", [Index1, Index2, SymbolePropre])
            ;   
                  format("aucune connexion.~n")
    ).
afficher_connexions(noeud(_, FilsGauche, nil), N, N1) :-
	afficher_connexions(FilsGauche, N, N1).
afficher_connexions(noeud(_, FilsGauche, FilsDroit), N, N2) :-
	FilsDroit \= nil,
	afficher_connexions(FilsGauche, N, N1),
	afficher_connexions(FilsDroit, N1, N2).

% ============================================================================
% unifier_lpo(+T1, +T2)
%
% Unification intelligente qui gère les structures var(Position, Variable)
% ============================================================================
% Cas 1 : Deux variables Gamma
unifier_lpo(var(_, V1), var(_, V2)) :- !, unify_with_occurs_check(V1, V2).

% Cas 2 : Une variable Gamma et un autre terme (Delta ou atome)
unifier_lpo(var(_, V), Terme) :- !, unify_with_occurs_check(V, Terme).
unifier_lpo(Terme, var(_, V)) :- !, unify_with_occurs_check(V, Terme).

% Cas 3 : Deux prédicats/fonctions (on décompose et on unifie les arguments)
unifier_lpo(T1, T2) :-
    compound(T1), compound(T2), !,
    T1 =.. [Nom | Args1],
    T2 =.. [Nom | Args2],
    maplist(unifier_lpo, Args1, Args2).

% Cas 4 : Atomes ou constantes identiques (Delta)
unifier_lpo(T1, T2) :-
    T1 == T2.