% methode_connexions/lpo/recherche_connexions.pl

:- module(recherche_connexions_lpo, [
    verifier_connexions/3,
    afficher_connexions/1,
    creer_graphe_dependance/3,
    afficher_graphe/1,
	detecter_cycle/1
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
% verifier_connexions(+ArbreIndexe, +ArbreChemins, -Resultat)
%
% Cherche une combinaison de connexions pour tous les chemins finaux
% telle qu'il n'y ait aucun cycle de dépendance.
% ============================================================================
verifier_connexions(ArbreIndexe, ArbreChemins, Resultat) :-
    % On cherche une combinaison (Prolog backtrackera ici si la suite échoue)
    parcourir_chemins(ArbreChemins, ListeSubst),
    % On construit le graphe pour cette combinaison précise
    creer_graphe_dependance(ArbreIndexe, ListeSubst, Graphe),
    % On vérifie qu'il n'ya pas de cycle
    \+ detecter_cycle(Graphe),
    !,  % On cut si on a déjà trouvé une valide
    Resultat = valide.

% Si toutes les combinaisons échouent (soit pas de connexion, soit que des cycles)
verifier_connexions(_, _, invalide).


% Parcourt l'arbre des chemins et accumule les substitutions
parcourir_chemins(feuille(etiq_chemin_final(Feuilles)), Subst) :-
    connexion(Feuilles, _, _, Subst).

parcourir_chemins(noeud(_, ListFils), SubstTotale) :-
    maplist(parcourir_chemins, ListFils, ListesSubst),
    append(ListesSubst, SubstTotale).


% ============================================================================
% connexion(+Feuilles, -Feuille1, -Feuille2, -Subst)
%
% Trouve une paire de feuilles de même prédicat et de polarité opposée. Renvoie aussi la substitution
% ============================================================================
connexion(Feuilles, F1, F2, Subst) :-
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

	% On récupère les substitutions
	unifier_lpo(Litteral1, Litteral2, Subst).

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
    (   connexion(Feuilles, F1, F2, Subst) ->  
            feuille_etiquette(F1, Etiquette1),
            feuille_etiquette(F2, Etiquette2),
            etiq_index(Etiquette1, Index1),
            etiq_index(Etiquette2, Index2),
            
            % On récupère les deux formules pour l'affichage
            etiq_formule(Etiquette1, Symbole1),
            etiq_formule(Etiquette2, Symbole2),
            
            nettoyer_formule(Symbole1, SymbolePropre1),
            nettoyer_formule(Symbole2, SymbolePropre2),
            
            % On affiche avec les bonnes variables
            format("connexion (~w, ~w) entre '~w' et '~w'.~n", [Index1, Index2, SymbolePropre1, SymbolePropre2]),
            format("             Substitutions : ~w~n", [Subst])
        ;   
            format("aucune connexion.~n")
    ).

afficher_connexions(noeud(_, ListeFils), N, N1) :-
    afficher_liste_connexions(ListeFils, N, N1).

afficher_liste_connexions([], N, N).
afficher_liste_connexions([F|R], NIn, NOut) :-
    afficher_connexions(F, NIn, NMid),
    afficher_liste_connexions(R, NMid, NOut).

% ============================================================================
% unifier_lpo(+T1, +T2, -Subst)
%
% Unification intelligente qui gère les structures var(Position, Variable) et renvoie la liste des substitutions
% pour la substitution, on utilise une structure de la forme subst(ancien, nouveau)
% ============================================================================
% Cas 1 : Deux variables Gamma
unifier_lpo(var(Pos1, V1), var(Pos2, V2), [subst(Pos1, var(Pos2, V2))]) :- !, unify_with_occurs_check(V1, V2).

% Cas 2 : Une variable Gamma et un autre terme (Delta ou atome)
unifier_lpo(var(Pos1, V), Terme, [subst(Pos1, Terme)]) :- !, unify_with_occurs_check(V, Terme).
unifier_lpo(Terme, var(Pos2, V), [subst(Pos2, Terme)]) :- !, unify_with_occurs_check(V, Terme).

% Cas 3 : Deux prédicats/fonctions (on décompose et on unifie les arguments)
unifier_lpo(T1, T2, SubstGlobales) :-
    compound(T1), compound(T2), !,
    T1 =.. [Nom | Args1],
    T2 =.. [Nom | Args2],
    unifier_listes_args(Args1, Args2, SubstGlobales).

% --- Fonction utilitaire pour le cas 3 ---
% Parcourt les arguments, unifie un par un, et assemble (aplatit) les listes de substitutions
unifier_listes_args([], [], []).
unifier_listes_args([Arg1 | Reste1], [Arg2 | Reste2], SubstTotales) :-
    unifier_lpo(Arg1, Arg2, SubstArg),           % Unifie le premier argument
    unifier_listes_args(Reste1, Reste2, SubstReste), % Appel récursif sur le reste
    append(SubstArg, SubstReste, SubstTotales).  % Concatène les 2 listes

% Cas 4 : Atomes ou constantes identiques (Delta)
unifier_lpo(T1, T2, []) :-
    T1 == T2.

% ============================================================================
% creer_graphe_dependance(+ArbreIndexe, +ListeSubst, -Graphe)
% ============================================================================
creer_graphe_dependance(ArbreIndexe, ListeSubst, Graphe) :-
    % Extraire les liens directs de l'arbre (Structure de l'arbre)
    extraire_liens_structure(ArbreIndexe, LiensStructure),

    % Extraire les liens d'unification (Substitutions)
    extraire_liens_substitution(ListeSubst, LiensSubst),

    % Fusionner et supprimer les doublons
    append(LiensStructure, LiensSubst, GrapheBrut),
    sort(GrapheBrut, Graphe).

% ============================================================================
% LIENS DE STRUCTURE : Parent -> Enfant
% ============================================================================

% Cas d'une feuille ou d'un noeud vide : pas de liens vers le bas
extraire_liens_structure(nil, []).
extraire_liens_structure(feuille(_), []).

% Cas d'un noeud : on lie l'index actuel à l'index des fils
extraire_liens_structure(noeud(Etiquette, ListeFils), Liens) :-
    arbre_indexe_lpo:etiq_index(Etiquette, IndexParent),
    maplist(extraire_arete_vers_fils(IndexParent), ListeFils, AretesFils),
    maplist(extraire_liens_structure, ListeFils, LiensFils),
    flatten([AretesFils, LiensFils], Liens).

% Prédicat utilitaire pour créer l'arête vers un fils s'il existe
extraire_arete_vers_fils(P, Fils, arete(struct, P, I)) :-
    (est_noeud(Fils) -> noeud_etiquette(Fils, Et) ; feuille_etiquette(Fils, Et)),
    arbre_indexe_lpo:etiq_index(Et, I).

% ============================================================================
% LIENS DE SUBSTITUTION : IndiceDansTerme -> IndexVariable
% ============================================================================

extraire_liens_substitution([], []).
extraire_liens_substitution([subst(V, Terme) | Reste], LiensTotal) :-
    trouver_indices_dans_terme(Terme, Indices),
    % Ici V est l'index de la variable (ex: a1_1)
    generer_aretes_unif(Indices, V, LiensIci),
    extraire_liens_substitution(Reste, LiensReste),
    append(LiensIci, LiensReste, LiensTotal).

generer_aretes_unif([], _, []).
generer_aretes_unif([I|Is], V, [arete(unif, I, V) | Reste]) :-
    generer_aretes_unif(Is, V, Reste).

% Trouver les indices (atomes commençant par 'a') dans un terme
trouver_indices_dans_terme(T, []) :- var(T), !.
trouver_indices_dans_terme(A, [A]) :- 
    atom(A), atom_concat(a, _, A), !.
trouver_indices_dans_terme(Terme, Indices) :-
    compound(Terme), !,
    Terme =.. [_ | Args],
    maplist(trouver_indices_dans_terme, Args, Listes),
    flatten(Listes, Indices).
trouver_indices_dans_terme(_, []).

% ============================================================================
% afficher_graphe(+Graphe)
%
% Affiche proprement les arêtes du graphe de dépendance.
% ============================================================================
afficher_graphe(Graphe) :-
    write("--- Graphe de dépendance ---"), nl,
    (   Graphe = [] -> write("  (Graphe vide)")
    ;   forall(member(arete(Type, Source, Cible), Graphe), 
               (  Type == struct -> format("  ~w ---> ~w (structure)~n", [Source, Cible])
               ;  format("  ~w ===> ~w (unification)~n", [Source, Cible])
               ))
    ),
    nl.


% ============================================================================
% detecter_cycle(+Graphe)
% vrai s'il existe un cycle dans le graphe.
% ============================================================================
detecter_cycle(Graphe) :-
    member(arete(_, X, _), Graphe),    % On choisit un point de départ
    visiter(X, Graphe, [X]).     % On lance la visite en gardant l'historique

% Si le prochain nœud Y est déjà dans le chemin parcouru : cycle !
visiter(X, Graphe, Chemin) :-
    member(arete(_, X, Y), Graphe),
    member(Y, Chemin), !.

% Sinon, on continue l'exploration
visiter(X, Graphe, Chemin) :-
    member(arete(_, X, Y), Graphe),
    visiter(Y, Graphe, [Y|Chemin]).