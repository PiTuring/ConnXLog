% core/regles_communes.pl


:- module(regles_communes, [etiqueter/7]).

:- include(utils).
:- use_module(arbre).

% ============================================================================
% Règles communes alpha/beta partagées entre la logique propositionnelle
% et la logique du premier ordre.
%
% etiqueter(+Formule, +Polarite, +IndexIn, -IndexOut, +Multiplicite, ,+Suffixe, -Arbre)
%
% IndexIn   : prochain index dispo en entrée
% IndexOut  : prochain index dispo après construction
%
% Déclaré multifile pour permettre aux modules spécifiques (lpo) 
% d'ajouter règles γ et δ sans modifier ce fichier.
% ============================================================================
:- multifile etiqueter/7.
% Règles ALPHA ---------------------------------------------------------------
% (A et B, 1) -> (A, 1, alpha1) | (B, 1, alpha2)
etiqueter(A et B, 1, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(alpha, alpha1, alpha2, A et B, 1, NomComplet),
            [ArbreA, ArbreB])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, M, Suffix, ArbreB).

% (A ou B, 0) -> (A, 0, alpha1) | (B, 0, alpha2)
etiqueter(A ou B, 0, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(alpha, alpha1, alpha2, A ou B, 0, NomComplet),
            [ArbreA, ArbreB])) :-
    Index1 is IndexIn + 1,
    construire_nom(IndexIn, Suffix, NomComplet),
    etiqueter(A, 0, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, M, Suffix, ArbreB).

% (A impl B, 0) -> (A, 1, alpha1) | (B, 0, alpha2)
etiqueter(A impl B, 0, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(alpha, alpha1, alpha2, A impl B, 0, NomComplet),
            [ArbreA, ArbreB])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, M, Suffix, ArbreB).

% IMPLICITE (non A, Polarite) -> (A, 1 - Polarite, alpha1)
etiqueter(non A, Polarite, IndexIn, IndexOut, M, Suffix, Arbre) :-
    PolariteInverse is 1 - Polarite,
    etiqueter(A, PolariteInverse, IndexIn, IndexOut, M, Suffix, Arbre).

% Règles BETA ----------------------------------------------------------------
% (A et B, 0) -> (A, 0, beta1) | (B, 0, beta2)
etiqueter(A et B, 0, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(beta, beta1, beta2, A et B, 0, NomComplet),
            [ArbreA, ArbreB])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, M, Suffix, ArbreB).

% (A ou B, 1) -> (A, 1, beta1) | (B, 1, beta2)
etiqueter(A ou B, 1, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(beta, beta1, beta2, A ou B, 1, NomComplet),
            [ArbreA, ArbreB])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, M, Suffix, ArbreB).

% (A impl B, 1) -> (A, 0, beta1) | (B, 1, beta2)
etiqueter(A impl B, 1, IndexIn, IndexOut, M, Suffix,
        noeud(etiq_formule(beta, beta1, beta2, A impl B, 1, NomComplet),
            [ArbreA, ArbreB])) :-
    construire_nom(IndexIn, Suffix, NomComplet),
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, M, Suffix, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, M, Suffix, ArbreB).

% Feuilles ------------------------------------------------------------
% Si A est un atome, alors le résultat est une feuille.
etiqueter(A, Polarite, Index, IndexOut, _, Suffix, feuille(etiq_formule(atome, none, none, A, Polarite, NomComplet))) :-
    est_litteral(A),
    construire_nom(Index, Suffix, NomComplet),
    IndexOut is Index + 1.