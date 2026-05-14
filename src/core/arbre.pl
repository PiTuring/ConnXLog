% core/arbre.pl

:- module(arbre, [
  est_feuille/1,
  est_noeud/1,
  
  noeud_etiquette/2,
  noeud_fils/2,
  feuille_etiquette/2
]).

% ============================================================================
% Structure d'arbre partagée entre l'arbre syntaxique 
% et l'arbre des chemins
%
% Un arbre est soit :
%     noeud(Etiquette, ListeFils)
%     feuille(Etiquette)
%
% ============================================================================

% Prédicats est_xxx ----------------------------------------------------------
est_feuille(feuille(_)).
est_noeud(noeud(_, _)).

% Accesseurs ------------------------------------------------------------------
noeud_etiquette(noeud(E, _), E).
noeud_fils(noeud(_, Fils), Fils).
feuille_etiquette(feuille(E), E).
