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
:- op(700, fy, pt).
:- op(700, fy, ie).

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
ecrire_formule(pt A) :-
    write('∀'), ecrire_formule(A).
ecrire_formule(ie A) :-
    write('∃'), ecrire_formule(A).
ecrire_formule(A) :-
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

% En LPO

ecrire_type(gamma) :- write('γ').
ecrire_type(gamma1) :- write('γ1').
ecrire_type(delta) :- write('ẟ').
ecrire_type(delta1) :- write('ẟ1').

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