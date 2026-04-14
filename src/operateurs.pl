% operateurs.pl

% ============================================================
% Déclaration des opérateurs logiques propositionnels
% ============================================================

:- op(750, fy,  non).
:- op(800, xfy, et).
:- op(850, xfy, ou).
:- op(900, xfy, impl).

% ============================================================================
% TRADUCTION DES CONNECTEURS
%   ecrire_formule(+Formule)
% ============================================================================

ecrire_formule(A impl B) :-
    write('('), ecrire_formule(A), write(' → '), ecrire_formule(B), write(')').
ecrire_formule(A et B) :-
    write('('), ecrire_formule(A), write(' ∧ '), ecrire_formule(B), write(')').
ecrire_formule(A ou B) :-
    write('('), ecrire_formule(A), write(' ∨ '), ecrire_formule(B), write(')').
ecrire_formule(non A) :-
    write('¬'), ecrire_formule(A).
ecrire_formule(A) :-
    atom(A), write(A).

% ============================================================================
% TRADUCTION DES TYPES
%   ecrire_type(+Formule)
% ============================================================================

ecrire_type(alpha)  :- write('α').
ecrire_type(beta)   :- write('β').
ecrire_type(alpha1) :- write('α1').
ecrire_type(alpha2) :- write('α2').
ecrire_type(beta1)  :- write('β1').
ecrire_type(beta2)  :- write('β2').
ecrire_type(none)   :- write('_').