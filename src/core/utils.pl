% core/utils.pl

% ============================================================================
% Contients tous les prédicats utiles à la gestion de 
% l'affichage ou à la déclaration des éléments globaux 
% du programme :
%   - Connecteurs
%   - Types des règles appliquées
%   - Gestion de la trace active ou non
% ============================================================================

% Connecteurs ----------------------------------------------------------------

% ============================================================================
% Déclaration des opérateurs logiques propositionnels
% ============================================================================
:- op(750, fy,  non).
:- op(800, xfy, et).
:- op(850, xfy, ou).
:- op(900, xfy, impl).

% ============================================================================
% Déclaration des opérateurs en logique des prédicats
% ============================================================================
:- op(950, xfy, pt).  
:- op(950, xfy, ie).

% ============================================================================
% substituer(+Terme, +Ancien, +Nouveau, -Resultat)
%
% Remplace toutes les occurrences de Ancien par Nouveau dans Terme.
% ============================================================================
substituer(Terme, _, _, Terme) :- var(Terme), !.
substituer(Ancien, Ancien, Nouveau, Nouveau) :- !.
substituer(Terme, _, _, Terme) :- atomic(Terme), !.
substituer(Terme, Ancien, Nouveau, Resultat) :-
    compound(Terme),
    Terme =.. [F | Args],
    maplist([Arg, ArgSubst]>>(substituer(Arg, Ancien, Nouveau, ArgSubst)), Args, ArgsSubst),
    Resultat =.. [F | ArgsSubst].

% --- Helper pour construire le nom de position ---
% Si Suffixe = none -> "a1"
% Si Suffixe = 1    -> "a1_1"
construire_nom(Index, none, Nom) :- !, atom_concat(a, Index, Nom).
construire_nom(Index, Suffix, Nom) :- 
    atomic_list_concat([a, Index, '_', Suffix], Nom).

% ── Littéraux (feuilles) ─────────────────────────────────────────────────────
% Un littéral est :
%   - un atome propositionnel : p, q, r
%   - un prédicat appliqué    : p(x), q(a,b), p(f(y))
connecteur(et).   
connecteur(ou).   
connecteur(impl).
connecteur(non).  
connecteur(pt).   
connecteur(ie).

est_litteral(A) :-
    atom(A), !.
est_litteral(A) :-
    compound(A),
    functor(A, Foncteur, _),
    \+ connecteur(Foncteur).

% Affichage --------------------------------------------------

% ============================================================================
% ecrire_formule(+Formule)
%
% Affiche une formule de la logique propositionnelle avec les symboles
% courant dans la littérature.
% ============================================================================
ecrire_formule(A impl B) :-
    write('('), ecrire_formule(A), write(' → '), ecrire_formule(B), write(')').
ecrire_formule(A et B) :-
    write('('), ecrire_formule(A), write(' ∧ '), ecrire_formule(B), write(')').
ecrire_formule(A ou B) :-
    write('('), ecrire_formule(A), write(' ∨ '), ecrire_formule(B), write(')').
ecrire_formule(non A) :-
    write('¬'), ecrire_formule(A).
% sur-couche LPO :
ecrire_formule(X pt A) :-
    write('∀'), write(X), write('.'), ecrire_formule(A).
ecrire_formule(X ie A) :-
    write('∃'), write(X), write('.'), ecrire_formule(A).
ecrire_formule(A) :-
    est_litteral(A), !,
    write(A).

% ============================================================================
% ecrire_type(+Type)
%
% Affiche le type d'une formule dans la méthode des connexions 
% par sa lettre dans l'alphabet latin.
% ============================================================================
ecrire_type(alpha)  :- write('α').
ecrire_type(beta)   :- write('β').
ecrire_type(alpha1) :- write('α1').
ecrire_type(alpha2) :- write('α2').
ecrire_type(beta1)  :- write('β1').
ecrire_type(beta2)  :- write('β2').
ecrire_type(none)   :- write('_').
% sur-couche LPO :
ecrire_type(gamma) :- write('γ').
ecrire_type(gamma0) :- write('γ0').
ecrire_type(delta) :- write('ẟ').
ecrire_type(delta0) :- write('ẟ0').

% ============================================================================
% nettoyer_formule(+Litteral, -LitteralNettoye)
%
%Transforme récursivement les structures var(Pos, _) en Pos pour l'affichage
% ============================================================================
nettoyer_formule(var(Pos, _), Pos) :- !. % Cas d'une variable Gamma
nettoyer_formule(Formule, FormuleNettoyee) :-
      compound(Formule), !, % Si c'est un prédicat (ex: p(X, Y))
      Formule =.. [Nom | Args],
      maplist(nettoyer_formule, Args, ArgsNettoyes),
      FormuleNettoyee =.. [Nom | ArgsNettoyes].
nettoyer_formule(Formule, Formule) :- !. % Cas des atomes ou constantes (Delta)

% ============================================================================
% Prédicats d'affichage ancien TP
% ============================================================================
% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.
echo(T) :- echo_on, !, write(T).
echo(_).

% echo_nl: si le flag echo_on est positionné, echo_nl affiche un saut de ligne
%          sinon, echo_nl réussit simplement en ne faisant rien. 
echo_nl :- echo_on, !, nl.
echo_nl.