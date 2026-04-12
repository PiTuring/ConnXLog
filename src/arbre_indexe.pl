:- op(750, fy, non). 
:- op(800, xfy, et).  
:- op(850, xfy, ou). 
:- op(900, xfy, impl). 


% ============================================================================
% Structure des noeuds :
%   noeud(TypePrincipal, Formule, Polarite, Index, 
%       fils(TypeSecondaire1, ArbreGauche), fils(TypeSecondaire2, ArbreDroit))
%   feuille(Formule, Polarite, Index)
%
% TypePrincipale    : alpha | beta
% TypeSecondaire    : alpha1 | alpha2 | beta1 | beta2
% Polarite          : 1 (vrai) | 0 (faux)
% Index             : entier, numérotation parcours en prondeur
% ============================================================================

% ============================================================================
% etiqueter(+Formule, +Polarite, +IndexIn, -IndexOut, -Arbre)
%
% IndexIn   : prochain index dispo en entrée
% IndexOut  : prochain index dispo après construction
% ============================================================================


% Règles ALPHA ---------------------------------------------------------------

% (A et B, 1) -> (A, 1, alpha1) | (B, 1, alpha2)
etiqueter(A et B, 1, IndexIn, IndexOut,
        noeud(alpha, A et B, 1, IndexIn,
            fils(alpha1, ArbreA),
            fils(alpha2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).

% (A ou B, 0) -> (A, 0, alpha1) | (B, 0, alpha2)
etiqueter(A ou B, 0, IndexIn, IndexOut,
        noeud(alpha, A ou B, 0, IndexIn,
            fils(alpha1, ArbreA),
            fils(alpha2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% (A impl B, 0) -> (A, 1, alpha1) | (B, 0, alpha2)
etiqueter(A impl B, 0, IndexIn, IndexOut,
        noeud(alpha, A impl B, 0, IndexIn,
            fils(alpha1, ArbreA),
            fils(alpha2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% IMPLICITE (non A, Polarite) -> (A, 1 - Polarite, alpha1)
etiqueter(non A, Polarite, IndexIn, IndexOut, Arbre) :-
    PolariteInverse is 1 - Polarite,
    etiqueter(A, PolariteInverse, IndexIn, IndexOut, Arbre).


% Règles BETA ---------------------------------------------------------------

% (A et B, 0) -> (A, 0, beta1) | (B, 0, beta2)
etiqueter(A et B, 0, IndexIn, IndexOut,
        noeud(beta, A et B, 0, IndexIn,
            fils(beta1, ArbreA),
            fils(beta2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 0, IndexMid, IndexOut, ArbreB).

% (A ou B, 1) -> (A, 1, beta1) | (B, 1, beta2)
etiqueter(A ou B, 1, IndexIn, IndexOut,
        noeud(beta, A ou B, 1, IndexIn,
            fils(beta1, ArbreA),
            fils(beta2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 1, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).

% (A impl B, 1) -> (A, 0, beta1) | (B, 1, beta2)
etiqueter(A impl B, 1, IndexIn, IndexOut,
        noeud(beta, A impl B, 1, IndexIn,
            fils(beta1, ArbreA),
            fils(beta2, ArbreB))) :-
    Index1 is IndexIn + 1,
    etiqueter(A, 0, Index1, IndexMid, ArbreA),
    etiqueter(B, 1, IndexMid, IndexOut, ArbreB).


% Si A est un atome, alors le résultat est une feuille.
etiqueter(A, Polarite, Index, IndexOut, feuille(A, Polarite, Index)) :-
    atom(A),
    IndexOut is Index + 1.

% ============================================================================
% CONSTRUCTION ARBRE
%   construire_arbre(+Formule, -Arbre)
%   Polarite initiale = 0 (pour l'instant comme TD avec tautologie)
%   Index initial = 0
% ============================================================================

construire_arbre(Formule, Arbre) :-
    etiqueter(Formule, 0, 0, _, Arbre).

% ============================================================================
% CONSTRUCTION ARBRE (pour debug)
%   afficher_arbre(+Arbre)
% ============================================================================

afficher_arbre(Arbre) :-
    afficher_arbre(Arbre, 0).

afficher_arbre(feuille(Formule, Polarite, Index), Profondeur) :-
    tab(Profondeur),
    format("feuille a~w : ~w [polarite=~w]~n", [Index, Formule, Polarite]).

afficher_arbre(noeud(Type, Formule, Polarite, Index,
                    fils(TypeSecondaire1, Gauche),
                    fils(TypeSecondaire2, Droite)), Profondeur) :-
    tab(Profondeur),
    format("noeud  a~w : ~w  [type=~w, polarite=~w]~n", [Index, Formule, Type, Polarite]),
    Profondeur1 is Profondeur + 4,
    tab(Profondeur1), format("[~w]~n", [TypeSecondaire1]),
    afficher_arbre(Gauche, Profondeur1),
    tab(Profondeur1), format("[~w]~n", [TypeSecondaire2]),
    afficher_arbre(Droite, Profondeur1).

% Exemple du cours :
?- construire_arbre((p impl q) impl ((q impl r) impl (p impl r)), Arbre),
   afficher_arbre(Arbre).