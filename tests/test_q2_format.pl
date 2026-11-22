
% tests/test_q2_format.pl
% Automated tests for format_expr/2.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').


% Helpers
% -------

% expect_string(Expr, Expected):
% Checks that formatting produces exactly one correct string.
expect_string(Expr, Expected) :-
    catch(findall(S, format_expr(Expr, S), Ss), _, fail),
    Ss = [Result],
    string(Result),
    Result == Expected.

% expect_no_parens(Expr):
% Checks that the formatted expression contains no parentheses.
expect_no_parens(Expr) :-
    catch(format_expr(Expr, S), _, fail),
    string(S),
    \+ sub_string(S, _, _, _, "("),
    \+ sub_string(S, _, _, _, ")").


% Tests
% -----

% 1. Plain integers.
test_integer :-
    expect_string(7, "7"),
    expect_string(0, "0"),
    expect_string(10, "10"),
    expect_string(123, "123").

% 2. Each of the four operators.
test_each_operator :-
    expect_string(add(4, 5), "4+5"),
    expect_string(sub(9, 4), "9-4"),
    expect_string(mul(6, 7), "6*7"),
    expect_string(div(8, 4), "8/4").

% 3. Operator precedence.
test_precedence :-
    expect_string(add(1, mul(2, 3)), "1+2*3"),
    expect_string(add(mul(2, 3), 1), "2*3+1"),
    expect_string(sub(1, div(6, 3)), "1-6/3"),
    expect_string(sub(div(6, 3), 1), "6/3-1"),
    expect_string(mul(2, add(3, 4)), "2*(3+4)").

% 4. Left associativity.
test_left_associativity :-
    expect_string(add(add(1, 2), 3), "1+2+3"),
    expect_string(sub(sub(1, 2), 3), "1-2-3"),
    expect_string(mul(mul(2, 3), 4), "2*3*4"),
    expect_string(div(div(8, 4), 2), "8/4/2"),
    expect_string(mul(div(8, 4), 2), "8/4*2"),
    expect_string(div(mul(8, 4), 2), "8*4/2").

% 5. Right operands with equal precedence.
test_right_equal_precedence :-
    expect_string(add(1, add(2, 3)), "1+(2+3)"),
    expect_string(sub(1, sub(2, 3)), "1-(2-3)"),
    expect_string(sub(1, add(2, 3)), "1-(2+3)"),
    expect_string(add(1, sub(2, 3)), "1+(2-3)"),
    expect_string(mul(2, mul(3, 4)), "2*(3*4)"),
    expect_string(div(8, div(4, 2)), "8/(4/2)"),
    expect_string(div(8, mul(4, 2)), "8/(4*2)"),
    expect_string(mul(8, div(4, 2)), "8*(4/2)").

% 6. Left operands with lower precedence.
test_left_lower_precedence :-
    expect_string(mul(add(4, 2), 3), "(4+2)*3"),
    expect_string(mul(sub(4, 2), 3), "(4-2)*3"),
    expect_string(div(add(8, 4), 2), "(8+4)/2"),
    expect_string(div(sub(8, 4), 2), "(8-4)/2"),
    expect_string(mul(add(1, 2), add(3, 4)), "(1+2)*(3+4)").

% 7. Nested expressions.
test_nested :-
    expect_string(mul(4, add(2, 5)), "4*(2+5)"),
    expect_string(sub(mul(4, 2), add(5, 3)), "4*2-(5+3)"),
    expect_string(add(mul(2, 3), mul(4, 5)), "2*3+4*5"),
    expect_string(sub(add(1, mul(2, 3)), div(8, 4)), "1+2*3-8/4"),
    expect_string(div(mul(add(1, 2), 3), sub(4, 1)), "(1+2)*3/(4-1)").

% 8. No unnecessary parentheses.
test_no_unnecessary_parens :-
    expect_no_parens(5),
    expect_no_parens(add(mul(2, 3), 4)),
    expect_no_parens(add(4, mul(2, 3))),
    expect_no_parens(sub(mul(4, 2), div(6, 3))),
    expect_no_parens(add(add(1, 2), 3)),
    expect_no_parens(mul(div(8, 4), 2)).

% 9. The result must be a string, not an atom or list.
test_result_is_string :-
    format_expr(7, S1),
    string(S1),
    format_expr(add(4, 5), S2),
    string(S2),
    \+ atom(S2),
    \+ is_list(S2),
    S2 == "4+5".

% Test runner
% -----------
all_tests([
    test_integer,
    test_each_operator,
    test_precedence,
    test_left_associativity,
    test_right_equal_precedence,
    test_left_lower_precedence,
    test_nested,
    test_no_unnecessary_parens,
    test_result_is_string
]).

% run_one(Test): succeeds only if the test passes without an exception.
run_one(Test) :-
    catch(call(Test), _, fail).

% run_tests: runs all tests and reports failures.
run_tests :-
    all_tests(Tests),
    findall(T, (member(T, Tests), \+ run_one(T)), Failed),
    (   Failed == []
    ->  writeln('ALL TESTS PASSED')
    ;   format("FAILED: ~w~n", [Failed]),
        fail
    ).
