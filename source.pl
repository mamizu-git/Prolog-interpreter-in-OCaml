%source

male(kobo).
male(koji).
male(iwao).
female(sanae).
female(mine).
female(miho).

parent(kobo, koji).
parent(kobo, sanae).
parent(sanae, iwao).
parent(sanae, mine).
parent(miho, koji).
parent(miho, sanae).

father(X,Y) :- parent(X,Y), male(Y).
mother(X,Y) :- parent(X,Y), female(Y).

grandparent(X,Z) :- parent(X,Y), parent(Y,Z).

ancestor(X,Y) :- parent(X,Z), ancestor(Z,Y).
ancestor(X,Y) :- parent(X,Y).

nat(z).
nat(s(X)) :- nat(X).
nat_list([]).
nat_list([N|X]) :- nat(N), nat_list(X).

add(z, Y, Y).
add(s(X), Y, s(Z)) :- add(X, Y, Z).

mult(z, _, z).
mult(s(X), Y, Z) :- mult(X, Y, W), add(W, Y, Z).

append([], Y, Y).
append([A|X], Y, [A|Z]) :- append(X, Y, Z).

next_sub([X,Y], X, Y).
next([A|_], X, Y) :- next_sub(A, X, Y).
next([_|E], X, Y) :- next(E, X, Y).

path(E, [A,B]) :- next(E, A, B).
path(E, [A,B|X]) :- next(E, A, B), path(E, [B|X]). 

remove([A|X], A, X).
remove([B|X], A, [B|Y]) :- remove(X, A, Y). 

permutation([],[]).
permutation(X, [A|Z]) :- remove(X, A, Y), permutation(Y, Z). 

hamilton(V, E) :- permutation(V, W), path(E, W). 

eq(a, b).
eq(c, b).
eq(X, Z) :- eq(X, Y), eq(Y, Z).
eq(X, Y) :- eq(Y, X).

test :- q(X, X).
q(X, f(X)).

ok.