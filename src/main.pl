% main.pl

:- module(main, [verifier/1]).
:- include(operateurs).
:- use_module(arbre_indexe).
:- use_module(arbre_chemins).

% ============================================================================
% verifier(+Formule)
% ============================================================================

verifier(Formule) :-
      write('=== Formule : '),
      ecrire_formule(Formule),
      write(' ==='), nl,
      generer_arbre_indexe(Formule, ArbreIndexe),
      format("--- Arbre syntaxique indexé ---~n"),
      afficher_arbre_indexe(ArbreIndexe),
      format("~n--- Arbre des chemins ---~n"),
      generer_arbre_chemins(ArbreIndexe, ArbreChemins),
      afficher_arbre_chemins(ArbreChemins).

% Exemple du cours :
?- verifier((p impl q) impl ((q impl r) impl (p impl r))).