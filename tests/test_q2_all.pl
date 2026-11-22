
% tests/test_q2_all.pl
% Automated tests for all_equations/2.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').

% all_eqs(+List, -Equations)
all_eqs(List, Equations) :-
    catch(all_equations(List, Equations), _, fail).

% tst_value(+Term, -Value)
tst_value(N, N) :-
    integer(N).
tst_value(A + B, V) :-
    tst_value(A, X), tst_value(B, Y), V is X + Y.
tst_value(A - B, V) :-
    tst_value(A, X), tst_value(B, Y), V is X - Y.
tst_value(A * B, V) :-
    tst_value(A, X), tst_value(B, Y), V is X * Y.
tst_value(A / B, V) :-
    tst_value(A, X), tst_value(B, Y),
    Y =\= 0, X mod Y =:= 0, V is X // Y.

% tst_numbers(+Term, -Numbers)
tst_numbers(N, [N]) :-
    integer(N).
tst_numbers(T, Ns) :-
    compound(T),
    T =.. [Op, A, B],
    memberchk(Op, ['+', '-', '*', '/', '=']),
    tst_numbers(A, NA),
    tst_numbers(B, NB),
    append(NA, NB, Ns).

% tst_parse(+Equation, -Left, -Right)
tst_parse(Equation, Left, Right) :-
    catch(term_string(T, Equation), _, fail),
    T = (Left = Right).

% tst_is_plain_string(+X)
tst_is_plain_string(X) :-
    string(X),
    \+ atom(X),
    \+ is_list(X).

% tst_one_equals_no_spaces(+Equation)
tst_one_equals_no_spaces(Equation) :-
    split_string(Equation, "=", "", Parts),
    length(Parts, 2),
    \+ sub_string(Equation, _, _, _, " ").

% tst_same_value(+Equation)
tst_same_value(Equation) :-
    tst_parse(Equation, Left, Right),
    tst_value(Left, V1),
    tst_value(Right, V2),
    V1 == V2.

% tst_uses_numbers(+Equation, +List)
tst_uses_numbers(Equation, List) :-
    tst_parse(Equation, Left, Right),
    tst_numbers(Left = Right, Ns),
    Ns == List.

% tst_valid(+List, +Equation)
tst_valid(List, Equation) :-
    tst_is_plain_string(Equation),
    tst_one_equals_no_spaces(Equation),
    tst_same_value(Equation),
    tst_uses_numbers(Equation, List).

% tst_all_valid(+List, +Equations)
tst_all_valid(List, Equations) :-
    forall(member(E, Equations), tst_valid(List, E)).

% tst_no_duplicates(+List)
tst_no_duplicates(List) :-
    sort(List, Sorted),
    length(List, N),
    length(Sorted, N).

% tst_is_sorted(+List)
tst_is_sorted(List) :-
    msort(List, Sorted),
    List == Sorted.

% tst_samples(-Lists)
tst_samples([[4,2,5,3], [2,4,8], [2,3,4], [1,2,3], [6,3,2],
             [10,5,2], [3,3,9], [1,1,1], [2,2,2,2],
             [1,1], [0,0], [5], []]).

% Test 1: Four numbers give exactly seven equations.
test_four_numbers :-
    all_eqs([4, 2, 5, 3], Es),
    Es == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
           "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].

% Test 2: [2,4,8] gives one equation.
test_two_four_eight :-
    catch(all_equations([2, 4, 8], ["2*4=8"]), _, fail),
    all_eqs([2, 4, 8], Es),
    Es == ["2*4=8"].

% Test 3: Inputs with no valid equations return [].
test_no_equations :-
    all_eqs([2, 3, 4], Es),
    Es == [].

% Test 4: Empty and single-element lists return [].
test_short_lists :-
    all_eqs([], E0), E0 == [],
    all_eqs([5], E1), E1 == [],
    all_eqs([0], E2), E2 == [].

% Test 5: Results contain no duplicates.
test_no_duplicates :-
    tst_samples(Lists),
    forall(member(L, Lists),
           (all_eqs(L, Es), tst_no_duplicates(Es))).

% Test 6: Results are sorted.
test_sorted :-
    tst_samples(Lists),
    forall(member(L, Lists),
           (all_eqs(L, Es), tst_is_sorted(Es))).

% Test 7: Every returned equation is valid.
test_every_equation_valid :-
    tst_samples(Lists),
    forall(member(L, Lists),
           (all_eqs(L, Es), tst_all_valid(L, Es))).

% Test 8: Known solvable inputs return non-empty results.
test_nonempty_when_solvable :-
    forall(member(L, [[4,2,5,3], [2,4,8], [6,3,2], [10,5,2],
                      [3,3,9], [1,1,1], [2,2,2,2], [1,1], [0,0]]),
           (all_eqs(L, Es), Es \== [])).

% Test runner.
all_tests([
    test_four_numbers,
    test_two_four_eight,
    test_no_equations,
    test_short_lists,
    test_no_duplicates,
    test_sorted,
    test_every_equation_valid,
    test_nonempty_when_solvable
]).

run_one(Test) :-
    catch(call(Test), _, fail).

run_tests :-
    all_tests(Tests),
    findall(T, (member(T, Tests), \+ run_one(T)), Failed),
    (   Failed == []
    ->  writeln('ALL TESTS PASSED')
    ;   format("FAILED: ~w~n", [Failed]),
        fail
    ).
