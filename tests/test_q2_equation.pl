% tests/test_q2_equation.pl
% Automated tests for generate_equation/2 (P2, one valid equation as a string).
%
% Run from the repository root with:
%   swipl -q -f tests/test_q2_equation.pl -g run_tests -t halt
%
% Requires generate_equation/2 and its helpers in code/60_q2.pl.
% run_tests prints "ALL TESTS PASSED" only if every test succeeds.
% Otherwise it prints the names of the failing tests and fails.
%
% Note: to check an equation independently of the solution code, the tests
% parse the returned string with term_string/2 and evaluate it with their own
% exact evaluator. This is done in the TESTS only; the solution must not do it.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').


% Helpers
% ----------

% tst_value(+Term, -Value)
% Exact integer evaluation of a parsed side (+ - * /). Division must be
% exact and the divisor non-zero, so a wrong equation cannot slip through
% via floating-point results.
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
% The integers of a parsed equation read left to right. It fails if the term
% contains anything other than integers and the operators + - * / =.
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
% Parse "L=R" into its two sides (tests only).
tst_parse(Equation, Left, Right) :-
    catch(term_string(T, Equation), _, fail),
    T = (Left = Right).

% tst_is_plain_string(+X)
% X is an SWI-Prolog string, not an atom, not a list.
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
% Both sides evaluate to the same integer.
tst_same_value(Equation) :-
    tst_parse(Equation, Left, Right),
    tst_value(Left, V1),
    tst_value(Right, V2),
    V1 == V2.

% tst_uses_numbers(+Equation, +List)
% All input numbers appear exactly once, in the original order.
tst_uses_numbers(Equation, List) :-
    tst_parse(Equation, Left, Right),
    tst_numbers(Left = Right, Ns),
    Ns == List.

% tst_valid(+List, +Equation): all the checks above together.
tst_valid(List, Equation) :-
    tst_is_plain_string(Equation),
    tst_one_equals_no_spaces(Equation),
    tst_same_value(Equation),
    tst_uses_numbers(Equation, List).

% tst_one_result(+List, -Equation)
% generate_equation/2 gives exactly one solution for List (no error).
tst_one_result(List, Equation) :-
    catch(findall(E, generate_equation(List, E), Es), _, fail),
    Es = [Equation].

% Lists that all have at least one valid equation.
tst_samples([[4,2,5,3], [2,4,8], [1,1], [0,0], [1,2,3], [6,3,2], [10,5,2], [3,3,9]]).

% Tests
% ----------

% 1. [4,2,5,3] produces exactly one valid equation, one of the seven known ones.
test_four_numbers :-
    tst_one_result([4, 2, 5, 3], E),
    tst_valid([4, 2, 5, 3], E),
    memberchk(E, ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).

% 2. [2,4,8] produces "2*4=8".
test_two_four_eight :-
    tst_one_result([2, 4, 8], E),
    E == "2*4=8".

% 3. [2,3,4], [] and [5] fail cleanly (no result, no error).
test_failures :-
    catch(\+ generate_equation([2, 3, 4], _), _, fail),
    catch(\+ generate_equation([], _), _, fail),
    catch(\+ generate_equation([5], _), _, fail),
    catch(findall(E, generate_equation([2, 3, 4], E), []), _, fail),
    catch(findall(E, generate_equation([], E), []), _, fail),
    catch(findall(E, generate_equation([5], E), []), _, fail).

% 4. The result is an SWI-Prolog string, not an atom or a list.
test_result_is_string :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( tst_one_result(L, E), tst_is_plain_string(E) )),
    generate_equation([2, 4, 8], E1),
    E1 \== '2*4=8',
    E1 == "2*4=8".

% 5. Exactly one "=" and no spaces.
test_one_equals_no_spaces :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( tst_one_result(L, E), tst_one_equals_no_spaces(E) )).

% 6. Both sides evaluate to the same integer.
test_both_sides_equal :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( tst_one_result(L, E), tst_same_value(E) )).

% 7. All input numbers are used exactly once, in the original order.
test_numbers_in_order :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( tst_one_result(L, E), tst_uses_numbers(E, L) )).

% 8. Repeated calls can keep returning valid equations.
test_repeated_calls :-
    forall(between(1, 5, _),
           ( generate_equation([4, 2, 5, 3], E1), tst_valid([4, 2, 5, 3], E1) )),
    forall(between(1, 5, _),
           ( generate_equation([6, 3, 2], E2), tst_valid([6, 3, 2], E2) )),
    generate_equation([1, 2, 3], A),
    generate_equation([4, 2, 5, 3], B),
    generate_equation([1, 2, 3], C),
    tst_valid([1, 2, 3], A),
    tst_valid([4, 2, 5, 3], B),
    tst_valid([1, 2, 3], C).

% Runner
% ------

all_tests([
    test_four_numbers,
    test_two_four_eight,
    test_failures,
    test_result_is_string,
    test_one_equals_no_spaces,
    test_both_sides_equal,
    test_numbers_in_order,
    test_repeated_calls
]).

% run_one(+Test): a test passes only if it succeeds without raising an error.
run_one(Test) :-
    catch(call(Test), _, fail).

run_tests :-
    all_tests(Tests),
    findall(T, ( member(T, Tests), \+ run_one(T) ), Failed),
    (   Failed == []
    ->  writeln('ALL TESTS PASSED')
    ;   format("FAILED: ~w~n", [Failed]),
        fail
    ).