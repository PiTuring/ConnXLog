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
    afihcer_arbre_chemins/1
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

% TODO