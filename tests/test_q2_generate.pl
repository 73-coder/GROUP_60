% tests/test_q2_generate.pl
% Automated tests for generate_expr/2 (P2, expression-tree generation only).
%
% Run from the repository root with:
%   swipl -q -f tests/test_q2_generate.pl -g run_tests -t halt
%
% Requires generate_expr/2 to be present in code/60_q2.pl.
% run_tests prints "ALL TESTS PASSED" only if every test succeeds.
% Otherwise it prints the names of the failing tests and fails.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').


% Helpers
% -------

% gen_all(+List, -Trees)
% Trees is every solution of generate_expr/2 for List, in generation order.
% An exception inside generate_expr/2 makes this helper fail, so an error is
% reported as a failed test rather than being mistaken for a pass.
gen_all(List, Trees) :-
    catch(findall(E, generate_expr(List, E), Trees), _, fail).

% tree_leaves(+Tree, -Leaves)
% Leaves are the numbers of Tree read from left to right. It fails if the
% tree contains anything other than integers and add/sub/mul/div nodes.
tree_leaves(N, [N]) :-
    integer(N).
tree_leaves(Tree, Leaves) :-
    compound(Tree),
    Tree =.. [Op, L, R],
    memberchk(Op, [add, sub, mul, div]),
    tree_leaves(L, LL),
    tree_leaves(R, RL),
    append(LL, RL, Leaves).

% all_leaves_equal(+Trees, +Expected)
% Every tree in Trees has exactly Expected as its left-to-right leaves.
all_leaves_equal(Trees, Expected) :-
    forall(member(T, Trees),
           ( tree_leaves(T, Ls), Ls == Expected )).

% no_duplicates(+List)
% Succeeds if List has no repeated element (compared with ==).
no_duplicates(List) :-
    sort(List, Sorted),
    length(List, N),
    length(Sorted, N).

% top_operators(+Trees, -Ops)
% Ops is the sorted set of operators found at the root of the trees.
top_operators(Trees, Ops) :-
    findall(Op, ( member(T, Trees), compound(T), T =.. [Op, _, _] ), Ops0),
    sort(Ops0, Ops).

% Tests
% -----

% 1. A single number gives that number, and only that.
test_single_number :-
    catch(generate_expr([5], 5), _, fail),
    gen_all([5], Trees),
    Trees == [5],
    gen_all([0], Zero),
    Zero == [0].

% 2. An empty list produces no results (it fails, with no error).
test_empty_list :-
    gen_all([], Trees),
    Trees == [],
    catch(\+ generate_expr([], _), _, fail).

% 3. [1,2] gives exactly 4 trees, one for each operator.
test_two_numbers :-
    gen_all([1, 2], Trees),
    length(Trees, 4),
    msort(Trees, Sorted),
    msort([add(1, 2), sub(1, 2), mul(1, 2), div(1, 2)], Expected),
    Sorted == Expected.

% 4. [1,2,3] gives exactly 32 trees (2 shapes * 4 * 4 operator choices).
test_three_numbers_count :-
    gen_all([1, 2, 3], Trees),
    length(Trees, 32).

% 4b. Both parenthesizations of [1,2,3] are present.
test_three_numbers_shapes :-
    gen_all([1, 2, 3], Trees),
    memberchk(add(add(1, 2), 3), Trees),
    memberchk(add(1, add(2, 3)), Trees),
    memberchk(mul(add(1, 2), 3), Trees),
    memberchk(div(1, sub(2, 3)), Trees).

% 5. Every tree uses all input numbers exactly once and in the original order.
test_leaves_in_order :-
    gen_all([1, 2], T2),
    all_leaves_equal(T2, [1, 2]),
    gen_all([1, 2, 3], T3),
    all_leaves_equal(T3, [1, 2, 3]),
    gen_all([4, 2, 5, 3], T4),
    all_leaves_equal(T4, [4, 2, 5, 3]),
    gen_all([2, 2, 2], TR),                 % repeated numbers keep their order too
    all_leaves_equal(TR, [2, 2, 2]).

% 5b. A larger list: Catalan(3) * 4^3 = 5 * 64 = 320 trees.
test_four_numbers_count :-
    gen_all([4, 2, 5, 3], Trees),
    length(Trees, 320).

% 6. All four operators are generated.
test_all_operators_generated :-
    gen_all([1, 2], T2),
    top_operators(T2, Ops2),
    Ops2 == [add, div, mul, sub],
    gen_all([1, 2, 3], T3),
    top_operators(T3, Ops3),
    Ops3 == [add, div, mul, sub].

% 7. There are no duplicate expression trees.
test_no_duplicate_trees :-
    gen_all([1, 2], T2),
    no_duplicates(T2),
    gen_all([1, 2, 3], T3),
    no_duplicates(T3),
    gen_all([4, 2, 5, 3], T4),
    no_duplicates(T4),
    gen_all([2, 2, 2], TR),
    no_duplicates(TR),
    length(TR, 32).

% Runner
% -------

all_tests([
    test_single_number,
    test_empty_list,
    test_two_numbers,
    test_three_numbers_count,
    test_three_numbers_shapes,
    test_leaves_in_order,
    test_four_numbers_count,
    test_all_operators_generated,
    test_no_duplicate_trees
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