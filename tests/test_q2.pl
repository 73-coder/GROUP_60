
% tests/test_q2.pl
% Automated tests for eval_expr/2 (P2, expression evaluation only).

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').


% Helpers
% -------

% expect_value(+Expr, +Expected)
% Succeeds only if eval_expr/2 produces exactly one expected solution.
expect_value(Expr, Expected) :-
    catch(findall(V, eval_expr(Expr, V), Vs), _, fail),
    Vs == [Expected].

% expect_fail(+Expr)
% Succeeds only if eval_expr/2 fails without raising an exception.
expect_fail(Expr) :-
    catch(\+ eval_expr(Expr, _), _, fail).


% Tests
% -----

% 1. A plain integer evaluates to itself.
test_integer :-
    expect_value(7, 7),
    expect_value(0, 0).

% 2. Addition, subtraction and multiplication.
test_basic_operations :-
    expect_value(add(2, 3), 5),
    expect_value(sub(9, 4), 5),
    expect_value(mul(6, 7), 42),
    expect_value(mul(5, 0), 0).

% 3. Nested expressions.
test_nested :-
    expect_value(mul(4, add(2, 5)), 28),
    expect_value(add(mul(4, 2), 5), 13),
    expect_value(sub(mul(4, 2), add(5, 3)), 0),
    expect_value(add(1, add(2, 3)), 6),
    expect_value(add(add(1, 2), 3), 6).

% 4. Negative intermediate values.
test_negative_intermediate :-
    expect_value(sub(3, 5), -2),
    expect_value(add(sub(3, 5), 10), 8),
    expect_value(mul(sub(3, 5), sub(1, 4)), 6),
    expect_value(sub(sub(1, 2), 3), -4).

% 5. Exact division.
test_exact_division :-
    expect_value(div(8, 4), 2),
    expect_value(div(0, 5), 0),
    expect_value(div(5, 1), 5),
    expect_value(div(mul(4, 2), add(1, 3)), 2).

% 6. Exact division with a negative numerator or divisor.
test_exact_division_negative :-
    expect_value(div(sub(3, 5), 2), -1),
    expect_value(div(sub(0, 6), 3), -2),
    expect_value(div(-6, 3), -2),
    expect_value(div(6, sub(0, 3)), -2).

% 7. Non-exact division must fail.
test_non_exact_division_fails :-
    expect_fail(div(7, 2)),
    expect_fail(div(1, 3)),
    expect_fail(div(sub(0, 7), 2)),
    expect_fail(div(sub(3, 5), 3)).

% 8. Division by zero must fail without an arithmetic error.
test_division_by_zero_fails :-
    expect_fail(div(4, 0)),
    expect_fail(div(0, 0)),
    expect_fail(div(4, sub(2, 2))).

% 9. An invalid nested division must make the whole expression fail.
test_nested_invalid_division_fails :-
    expect_fail(add(1, div(5, 2))),
    expect_fail(mul(3, div(1, 0))),
    expect_fail(sub(div(7, 2), div(4, 2))),
    expect_fail(div(div(7, 2), 1)),
    expect_fail(add(mul(2, 3), sub(4, div(9, 2)))).


% Test runner
% ----------

all_tests([
    test_integer,
    test_basic_operations,
    test_nested,
    test_negative_intermediate,
    test_exact_division,
    test_exact_division_negative,
    test_non_exact_division_fails,
    test_division_by_zero_fails,
    test_nested_invalid_division_fails
]).

% run_one(+Test): succeeds only if the test passes without an exception.
run_one(Test) :-
    catch(call(Test), _, fail).

% run_tests: runs all tests and reports any failures.
run_tests :-
    all_tests(Tests),
    findall(T, (member(T, Tests), \+ run_one(T)), Failed),
    (   Failed == []
    ->  writeln('ALL TESTS PASSED')
    ;   format("FAILED: ~w~n", [Failed]),
        fail
    ).
