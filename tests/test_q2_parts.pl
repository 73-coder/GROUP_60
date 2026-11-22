% tests/test_q2_parts.pl
% Automated tests for generate_equation_parts/3 (P2, splitting into two
% non-empty sides with an expression tree for each).
%
% Run from the repository root with:
%   swipl -q -f tests/test_q2_parts.pl -g run_tests -t halt
%
% Requires generate_equation_parts/3 and generate_expr/2 in code/60_q2.pl.
% run_tests prints "ALL TESTS PASSED" only if every test succeeds.
% Otherwise it prints the names of the failing tests and fails.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').

% --------
% Helpers


% all_pairs(+List, -Pairs)
% Pairs is every solution of generate_equation_parts/3 for List, as L-R terms,
% in generation order. An exception makes this helper fail, so an error is
% reported as a failed test rather than being mistaken for a pass.
all_pairs(List, Pairs) :-
    catch(findall(L-R, generate_equation_parts(List, L, R), Pairs), _, fail).

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

% pair_uses_list(+Pair, +List)
% The left and right trees together hold exactly List, in order.
pair_uses_list(L-R, List) :-
    tree_leaves(L, LL),
    tree_leaves(R, RL),
    append(LL, RL, All),
    All == List.

% pair_sides_nonempty(+Pair)
% Both sides are valid expression trees with at least one number.
pair_sides_nonempty(L-R) :-
    tree_leaves(L, LL), LL = [_|_],
    tree_leaves(R, RL), RL = [_|_].

% left_size_count(+Pairs, +Size, -Count)
% Count is how many pairs have a left tree with exactly Size numbers.
left_size_count(Pairs, Size, Count) :-
    findall(x,
            ( member(L-_, Pairs), tree_leaves(L, Ls), length(Ls, Size) ),
            Xs),
    length(Xs, Count).

% split_represented(+Pairs, +Prefix)
% Some pair has a left tree whose numbers are exactly Prefix.
split_represented(Pairs, Prefix) :-
    member(L-_, Pairs),
    tree_leaves(L, Ls),
    Ls == Prefix,
    !.

% no_duplicates(+List)
% Succeeds if List has no repeated element (compared with ==).
no_duplicates(List) :-
    sort(List, Sorted),
    length(List, N),
    length(Sorted, N).

% -----
% Tests


% 1. Empty and single-element lists produce no results.
test_too_short :-
    all_pairs([], P0),
    P0 == [],
    all_pairs([5], P1),
    P1 == [],
    catch(\+ generate_equation_parts([], _, _), _, fail),
    catch(\+ generate_equation_parts([5], _, _), _, fail).

% 2. [1,2] produces exactly one pair: 1-2.
test_two_numbers :-
    all_pairs([1, 2], Pairs),
    Pairs == [1-2].

% 3. [1,2,3] produces exactly 8 pairs (4 for each of the 2 split points).
test_three_numbers_count :-
    all_pairs([1, 2, 3], Pairs),
    length(Pairs, 8).

% 4. [1,2,3,4] produces exactly 80 pairs (32 + 16 + 32 over the 3 split points).
test_four_numbers_count :-
    all_pairs([1, 2, 3, 4], Pairs),
    length(Pairs, 80).

% 5. Every pair uses all input numbers exactly once, in the original order.
test_numbers_in_order :-
    all_pairs([1, 2, 3], P3),
    forall(member(P, P3), pair_uses_list(P, [1, 2, 3])),
    all_pairs([1, 2, 3, 4], P4),
    forall(member(P, P4), pair_uses_list(P, [1, 2, 3, 4])),
    all_pairs([4, 2, 5, 3], PE),             % the assignment's example list
    forall(member(P, PE), pair_uses_list(P, [4, 2, 5, 3])),
    all_pairs([2, 2, 2], PR),                % repeated numbers keep their order
    forall(member(P, PR), pair_uses_list(P, [2, 2, 2])).

% 6. Both sides are non-empty expression trees.
test_sides_nonempty :-
    all_pairs([1, 2], P2),
    forall(member(P, P2), pair_sides_nonempty(P)),
    all_pairs([1, 2, 3, 4], P4),
    forall(member(P, P4), pair_sides_nonempty(P)).

% 7. Every possible split point is represented.
test_every_split_represented :-
    all_pairs([1, 2, 3, 4], Pairs),
    split_represented(Pairs, [1]),
    split_represented(Pairs, [1, 2]),
    split_represented(Pairs, [1, 2, 3]),
    % each split also has the expected number of pairs
    left_size_count(Pairs, 1, 32),           % 1 * T(3) = 1 * 32
    left_size_count(Pairs, 2, 16),           % T(2) * T(2) = 4 * 4
    left_size_count(Pairs, 3, 32),           % T(3) * 1 = 32 * 1
    left_size_count(Pairs, 4, 0).            % no split puts all numbers on the left

% 8. There are no duplicate pairs.
test_no_duplicate_pairs :-
    all_pairs([1, 2, 3], P3),
    no_duplicates(P3),
    all_pairs([1, 2, 3, 4], P4),
    no_duplicates(P4),
    all_pairs([2, 2, 2, 2], PR),             % repeated numbers still give distinct trees
    no_duplicates(PR),
    length(PR, 80).

% -------
% Runner


all_tests([
    test_too_short,
    test_two_numbers,
    test_three_numbers_count,
    test_four_numbers_count,
    test_numbers_in_order,
    test_sides_nonempty,
    test_every_split_represented,
    test_no_duplicate_pairs
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