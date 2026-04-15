% main.pl

:- module(main, [verifier/1]).

:- include(core/utils).
:- use_module(methode_connexions/arbre_indexe).
:- use_module(methode_connexions/arbre_chemins).

% ============================================================================
% verifier(+Formule)
% ============================================================================

verifier(Formule) :-
      % en-tete
      write('=== Formule : '),
      ecrire_formule(Formule),
      write(' ==='), 
      nl,

      % Etape 1 : Arbre des formules indexé
      generer_arbre_indexe(Formule, ArbreIndexe),
      echo_nl,
      echo("--- Arbre syntaxique indexé ---"),
      echo_nl,
      (
            echo_on -> afficher_arbre_indexe(ArbreIndexe)
            ;
            true
      ),

      % Etape 2 : Arbre des chemins
      echo_nl,
      echo("--- Arbre des chemins ---"),
      echo_nl,
      generer_arbre_chemins(ArbreIndexe, ArbreChemins),
      (
            echo_on -> afficher_arbre_chemins(ArbreChemins)
            ;
            true
      ),

      % Etape 3 : Conclure
      write('Fin.').

verif(Formule) :-
      clr_echo, % Désactive la trace par echo/1
      verifier(Formule).

trace_verif(Formule) :-
      set_echo, % Active la trace par echo/1
      verifier(Formule).

% Exemple du cours :
?- trace_verif((p impl q) impl ((q impl r) impl (p impl r))).