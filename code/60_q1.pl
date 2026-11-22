:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).

% valid_assignment(Solution): Solution lists Alex, Ben, Carla and Dana in this
% order, each with a distinct department, a distinct favorite language and a
% distinct project, every value coming from its domain.
valid_assignment([p('Alex', D1, L1, P1),
                  p('Ben', D2, L2, P2),
                  p('Carla', D3, L3, P3),
                  p('Dana', D4, L4, P4)]) :-
    permutation([research, development, design, testing], [D1, D2, D3, D4]),
    permutation([python, java, 'c++', javascript], [L1, L2, L3, L4]),
    permutation(['AI', web, embedded, data], [P1, P2, P3, P4]).

% clue(N, Solution): clue N holds in the fully instantiated Solution.

% Clue 1: the friend with the 'AI' project is not in research and is not Dana.
clue(1, Solution) :-
    memberchk(p(Name, Dept, _, 'AI'), Solution),
    Dept \== research,
    Name \== 'Dana'.
% Clue 2: Alex is not in development and does not prefer 'c++'.
clue(2, Solution) :-
    memberchk(p('Alex', Dept, Lang, _), Solution),
    Dept \== development,
    Lang \== 'c++'.
% Clue 3: the friend in testing likes python.
clue(3, Solution) :-
    memberchk(p(_, testing, Lang, _), Solution),
    Lang == python.
% Clue 4: Ben prefers web projects and is not in testing.
clue(4, Solution) :-
    memberchk(p('Ben', Dept, _, Proj), Solution),
    Proj == web,
    Dept \== testing.
% Clue 5: the friend whose favorite language is java works in design.
clue(5, Solution) :-
    memberchk(p(_, Dept, java, _), Solution),
    Dept == design.
% Clue 6: Carla's project is not embedded and her department is not development.
clue(6, Solution) :-
    memberchk(p('Carla', Dept, _, Proj), Solution),
    Proj \== embedded,
    Dept \== development.
% Clue 7: Dana does not like java and works in research or testing.
clue(7, Solution) :-
    memberchk(p('Dana', Dept, Lang, _), Solution),
    Lang \== java,
    memberchk(Dept, [research, testing]).
% Clue 8: the friend with the data project works in research and not with javascript.
clue(8, Solution) :-
    memberchk(p(_, Dept, Lang, data), Solution),
    Dept == research,
    Lang \== javascript.

% main: prints one solution satisfying valid_assignment/1 and clues 1 to 8,
% as two lines per friend (name, then [department, language, project]).
main :-
    once(( valid_assignment(Solution),
           forall(member(N, [1, 2, 3, 4, 5, 6, 7, 8]), clue(N, Solution)) )),
    maplist(print_friend, Solution).

% print_friend(Friend): Friend is printed as its name on one line and
% [Dept, Lang, Proj] as unquoted text on the next line.
print_friend(p(Name, Dept, Lang, Proj)) :-
    format("~w~n[~w, ~w, ~w]~n", [Name, Dept, Lang, Proj]).

% count_solutions(ClueNumbers, Count): Count is the number of distinct
% solutions that are valid assignments and satisfy every clue in ClueNumbers.
count_solutions(ClueNumbers, Count) :-
    aggregate_all(count,
                  ( valid_assignment(Solution),
                    forall(member(N, ClueNumbers), clue(N, Solution)) ),
                  Count).
