% main.pl

:- module(main, [verifier/1]).

:- include(core/utils).
:- use_module(methode_connexions/arbre_indexe).
:- use_module(methode_connexions/arbre_chemins).
:- use_module(methode_connexions/recherche_connexions).

% ============================================================================
% verifier(+Formule)
%
% Applique la méthode des connexions à la formule donnée.
% ============================================================================
verifier(Formule) :-
      write('=== Formule : '),
      ecrire_formule(Formule),
      write(' ==='), 
      nl,

      % Etape 1 : Arbre des formules indexé
      echo_nl,
      echo("--- Arbre syntaxique indexé ---"),
      echo_nl,
      generer_arbre_indexe(Formule, ArbreIndexe),
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

      % Etape 3 : Recherche de connexions + Conclusion
      echo_nl,
      echo("--- Recherche de connexions ---"),
      echo_nl,
      (
            echo_on -> afficher_connexions(ArbreChemins)
            ;
            true
      ),
      echo_nl,

      write("--- Résultat ---"),
      nl,
      verifier_connexions(ArbreChemins, Resultat),
      (
            Resultat = valide -> write("La formule est valide.")
            ;
            write("La formule n'est pas valide.")

      ),
      nl,
      write('=== Fin ==='),
      nl.

% ============================================================================
% verif(+Formule)
%
% Applique la méthode des connexions sans trace.
% ============================================================================
verif(Formule) :-
      clr_echo, % Désactive la trace par echo/1
      verifier(Formule).

% ============================================================================
% verif(+Formule)
%
% Applique la méthode des connexions avecs trace.
% ============================================================================
trace_verif(Formule) :-
      set_echo, % Active la trace par echo/1
      verifier(Formule).

% Exemple du cours :
?- verif((p impl q) impl ((q impl r) impl (p impl r))).