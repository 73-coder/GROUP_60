:- use_module(library(lists)).
:- consult('../code/60_q1.pl').

% expected_solution(Solution): Solution is the unique answer to the puzzle
% under clues 1 to 9.
expected_solution([p('Alex', design, java, embedded),
                   p('Ben', development, javascript, web),
                   p('Carla', testing, python, 'AI'),
                   p('Dana', research, 'c++', data)]).

% invalid_assignment(Solution): Solution is a valid bijective assignment that
% violates each of the clues 1 to 9.
invalid_assignment([p('Alex', research, 'c++', web),
                    p('Ben', testing, javascript, data),
                    p('Carla', design, python, embedded),
                    p('Dana', development, java, 'AI')]).

% clue_numbers(Numbers): Numbers lists the clue numbers 1 to 9.
clue_numbers(Numbers) :-
    numlist(1, 9, Numbers).

% test_counts: the solution counts for no clues, clues 1-8 and clues 1-9 are
% 13824, 3 and 1.
test_counts :-
    numlist(1, 8, Clues1To8),
    clue_numbers(Clues1To9),
    count_solutions([], 13824),
    count_solutions(Clues1To8, 3),
    count_solutions(Clues1To9, 1).

% test_unique_solution: the only valid assignment satisfying clues 1 to 9 is
% the expected solution.
test_unique_solution :-
    expected_solution(Expected),
    clue_numbers(Clues),
    findall(Solution,
            ( valid_assignment(Solution),
              forall(member(N, Clues), clue(N, Solution)) ),
            Solutions),
    Solutions == [Expected].

% test_clues_accept: every clue from 1 to 9 holds on the expected solution,
% which is itself a valid assignment.
test_clues_accept :-
    expected_solution(Solution),
    clue_numbers(Clues),
    once(valid_assignment(Solution)),
    forall(member(N, Clues), clue(N, Solution)).

% test_clues_reject: the invalid assignment is a valid bijection and every
% clue from 1 to 9 fails on it.
test_clues_reject :-
    invalid_assignment(Solution),
    clue_numbers(Clues),
    once(valid_assignment(Solution)),
    forall(member(N, Clues), \+ clue(N, Solution)).

% run_tests: all tests pass and ALL TESTS PASSED is printed; it fails without
% output if any test fails.
run_tests :-
    test_counts,
    test_unique_solution,
    test_clues_accept,
    test_clues_reject,
    format("ALL TESTS PASSED~n").
