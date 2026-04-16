% core/arbre.pl

:- module(arbre, [
  est_feuille/1,
  est_noeud/1,
  est_noeud_unaire/1,
  est_noeud_binaire/1,
  noeud_etiquette/2,
  noeud_gauche/2,
  noeud_droit/2,
  feuille_etiquette/2
]).

% ============================================================================
% Structure d'arbre binaire partagée entre l'arbre syntaxique 
% et l'arbre des chemins
%
% Un arbre est soit :
%     noeud(Etiquette, FilsGauche, FilsDroit)
%     feuille(Etiquette)
%
% On définie la convention suivante : FilsDroit = nil dans le cas 
%                                     d'un noeud à  1 seul enfant
%                                     (alpha dans l'arbre des chemins).
% ============================================================================

% Prédicats est_xxx ----------------------------------------------------------
est_feuille(feuille(_)).
est_noeud(noeud(_, _, _)).
est_noeud_unaire(noeud(_, _, nil)). % On vérifie si FilsDroit est nil
est_noeud_binaire(noeud(_, G, D)) :- G \= nil, D \= nil. % On vérifie que les deux fils ne soient pas nil

% Accesseurs ------------------------------------------------------------------
noeud_etiquette(noeud(E, _, _), E).
noeud_gauche(noeud(_, G, _), G).
noeud_droit(noeud(_, _, D), D).
feuille_etiquette(feuille(E), E).
