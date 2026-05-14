% main.pl

:- module(main, [
    verifier/2,

    verif/1,        
    verif/2,

    trace_verif/1,  
    trace_verif/2
]).

:- include(core/utils).

% prop
:- use_module(methode_connexions/prop/arbre_indexe).
:- use_module(methode_connexions/prop/arbre_chemins).
:- use_module(methode_connexions/prop/recherche_connexions).

% lpo
:- use_module(methode_connexions/lpo/arbre_indexe, []).
:- use_module(methode_connexions/lpo/arbre_chemins, []).
:- use_module(methode_connexions/lpo/recherche_connexions, []).


% ============================================================================
% verifier(+Formule, +Logique)
%
% Logique : prop | lpo
% Applique la méthode des connexions dans la logique choisie.
% ============================================================================
% Logique propositionnelle ---------------------------------------------------
verifier(Formule, prop) :-
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

% Logique du premier ordre ----------------------------------------------
verifier(Formule, lpo) :-
      write('=== Formule : '),
      ecrire_formule(Formule),
      write(' ==='), 
      nl,

      % Etape 1 : Arbre des formules indexé
      echo_nl,
      echo("--- Arbre syntaxique indexé ---"),
      echo_nl,
      arbre_indexe_lpo:generer_arbre_indexe(Formule, ArbreIndexe),
      (
            echo_on -> arbre_indexe_lpo:afficher_arbre_indexe(ArbreIndexe)
            ;
            true
      ),

      % Etape 2 : Arbre des chemins
      echo_nl,
      echo("--- Arbre des chemins ---"),
      echo_nl,
      arbre_chemins_lpo:generer_arbre_chemins(ArbreIndexe, ArbreChemins),
      (
            echo_on -> arbre_chemins_lpo:afficher_arbre_chemins(ArbreChemins)
            ;
            true
      ),
      

      % Etape 3 : Recherche de connexions + Conclusion
      echo_nl,
      echo("--- Recherche de connexions ---"),
      echo_nl,
      (
            echo_on -> recherche_connexions_lpo:afficher_connexions(ArbreChemins)
            ;
            true
      ),
      echo_nl,

      write("--- Résultat ---"),
      nl,
      
      write('=== Fin ==='),
      nl.

% ============================================================================
% verif(+Formule, +Logique)
%
% Logique : prop | lpo (si vide, prop par défaut)
% Applique la méthode des connexions sans trace.
% ============================================================================
verif(Formule) :- verif(Formule, prop). % Prop par défaut
verif(Formule, Logique) :-
      clr_echo, % Désactive la trace par echo/1
      verifier(Formule, Logique).

% ============================================================================
% trace_verif(+Formule, +Logique)
%
% Logique : prop | lpo (si vide, prop par défaut)
% Applique la méthode des connexions sans trace.
% ============================================================================
trace_verif(Formule) :- verif(Formule, prop). % Prop par défaut
trace_verif(Formule, Logique) :-
      set_echo, % Active la trace par echo/1
      verifier(Formule, Logique).

% Tests avec trace de l'exemple du cours et du TD :
% prop
%?- trace_verif((p impl q) impl ((q impl r) impl (p impl r))). % ex du cours
%?- trace_verif(((a et b) impl c) impl ((a impl c) ou (b impl c))). % ex du TD
% lpo
?- trace_verif((y ie (p(y) et (x pt (p(x) impl q(x,y))))) impl (x ie (p(x) et q(x,x))), lpo). % ex1 du TD
%?- trace_verif((x ie (y pt (p(x,y)))) impl (x pt (y ie (p(y,x)))), lpo). % ex2 du TD
%?- trace_verif((x pt (y ie (p(y,x)))) impl (x ie (y pt (p(x,y)))), lpo). % ex3 du TD
%?- trace_verif(x ie (y pt (p(y) impl p(x))), lpo). % ex4 du TD