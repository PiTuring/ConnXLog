% arbre_chemins.pl

% ============================================================================
% Construction de l'arbre des chemins à parti de l'arbre indexé.
%
% Etiquette des noeuds :
%       etiq_chemin(NoeudTraite, Chemin)
%             NoeudTraite  : noeud de l'arbre indexé en cours de traitement
%             Chemin       : chemin courant
%
% Etiquette des feuilles :
%       etiq_chemin_final(ListeFeuilles)
%             ListeFeuilles  : liste des feuilles atomiques du chemin
% ============================================================================

:- module(arbre_chemins, [
    generer_arbre_chemins/2,
    afficher_arbre_chemins/1
]).

:- use_module(arbre).
:- use_module(arbre_indexe).

% ============================================================================
% generer_arbre_chemins(+ArbreIndexe, -ArbreChemins)
% ============================================================================

generer_arbre_chemins(ArbreIndexe, ArbreChemins) :-
      developper([ArbreIndexe], ArbreChemins).

% ============================================================================
% developper(+Ensemble, -ArbreChemins)
%
% Ensemble : liste de noeuds issus de l'arbre indexé
% ============================================================================

% Cas de base -> tous les éléments sont des feuilles
developper(Ensemble, feuille(etiq_chemin_final(Ensemble))) :-
      maplist(est_feuille, Ensemble), !.

% Récursion -> stratégie : on traite le premier noeud
developper(Ensemble, ArbreChemins) :-
      premier_noeud(Ensemble, Noeud, EnsembleSansNoeud),
      noeud_etiquette(Noeud, Etiquette),
      etiq_type_principal(Etiquette, TypePrincipal),
      noeud_gauche(Noeud, FilsGauche),
      noeud_droit(Noeud, FilsDroit),
      !,
      (
        TypePrincipal = alpha ->
            NouvelEnsemble = [FilsGauche, FilsDroit | EnsembleSansNoeud],
            developper(NouvelEnsemble, SousArbre),
            ArbreChemins = noeud(etiq_chemin(Noeud, Ensemble), SousArbre, nil)
        ; % beta
            developper([FilsGauche | EnsembleSansNoeud], SousArbreGauche),
            developper([FilsDroit | EnsembleSansNoeud], SousArbreDroit),
            ArbreChemins = noeud(etiq_chemin(Noeud, Ensemble), SousArbreGauche, SousArbreDroit)
      ).

% ============================================================================
% premier_noeud(+Ensemble, -Noeud, -EnsembleSansNoeud)
%
% Séléctionne le premier noeud non-feuille
% ============================================================================

premier_noeud([H | T], H, T) :-
      est_noeud(H), !.

premier_noeud([H | T], Noeud, [H | Reste]) :-
      est_feuille(H),
      premier_noeud(T, Noeud, Reste).

% ============================================================================
% afficher_arbre_chemins(+ArbreChemins)
% ============================================================================

afficher_arbre_chemins(Arbre) :-
      afficher_arbre_chemins(Arbre, 0).

afficher_arbre_chemins(feuille(etiq_chemin_final(Feuilles)), Profondeur) :-
      tab(Profondeur),
      format("chemin final : "),
      afficher_feuilles(Feuilles),
      nl.

afficher_arbre_chemins(noeud(etiq_chemin(Noeud, _), FilsGauche, FilsDroit), Profondeur) :-
      noeud_etiquette(Noeud, Etiquette),
      etiq_index(Etiquette, Index),
      etiq_type_principal(Etiquette, Type),
      tab(Profondeur),
      format("chemin a~w [~w]~n", [Index, Type]),
      Profondeur1 is Profondeur + 4,
      afficher_arbre_chemins(FilsGauche, Profondeur1),
      (
        FilsDroit \= nil -> afficher_arbre_chemins(FilsDroit, Profondeur1) 
        ; 
        true
      ).

afficher_feuilles([]).

afficher_feuilles([F | Reste]) :-
      feuille_etiquette(F, Etiquette),
      etiq_index(Etiquette, Index),
      etiq_formule(Etiquette, Formule),
      etiq_polarite(Etiquette, Polarite),
      format("a~w:~w(~w)  ", [Index, Formule, Polarite]),
      afficher_feuilles(Reste).