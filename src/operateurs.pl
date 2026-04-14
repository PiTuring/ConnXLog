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