% tests/test_q2_count.pl
% Automated tests for count_equations/2 (P2, number of valid unique equations).
%
% Run from the repository root with:
%   swipl -q -f tests/test_q2_count.pl -g run_tests -t halt
%
% Requires count_equations/2 and all_equations/2 in code/60_q2.pl.
% run_tests prints "ALL TESTS PASSED" only if every test succeeds.
% Otherwise it prints the names of the failing tests and fails.

:- use_module(library(lists)).
:- consult('../code/60_q2.pl').

% ---------------------------------------------------------------
% Helpers
% ---------------------------------------------------------------

% count_of(+List, -N)
% N is the single solution of count_equations/2 for List. It fails if there
% is no solution, more than one solution, or an exception, so an error is
% reported as a failed test rather than being mistaken for a pass.
count_of(List, N) :-
    catch(findall(C, count_equations(List, C), Cs), _, fail),
    Cs = [N].

% expect_count(+List, +Expected)
% count_equations/2 gives exactly Expected for List (compared with ==, so
% the count must be an integer, not a float or an unbound variable).
expect_count(List, Expected) :-
    count_of(List, N),
    integer(N),
    N == Expected.

% Hand-verified counts: List-Count. Each was worked out by listing the splits,
% the values of both sides, and rejecting invalid divisions.
%   [1,1]    1=1                                          -> 1
%   [0,0]    0=0                                          -> 1
%   [2,2]    2=2                                          -> 1
%   [1,2]    no equal sides                               -> 0
%   [1,2,3]  1+2=3                                        -> 1
%   [3,3,9]  3*3=9                                        -> 1
%   [2,2,4]  2+2=4, 2*2=4                                 -> 2
%   [6,3,2]  6=3*2, 6/3=2                                 -> 2
%   [10,5,2] 10=5*2, 10/5=2                               -> 2
%   [1,1,1]  1=1*1, 1=1/1, 1*1=1, 1/1=1                   -> 4
%   [0,0,0]  0=0+0, 0=0-0, 0=0*0, 0+0=0, 0-0=0, 0*0=0     -> 6
known_counts([
    [1,1]-1,
    [0,0]-1,
    [2,2]-1,
    [1,2]-0,
    [1,2,3]-1,
    [3,3,9]-1,
    [2,2,4]-2,
    [6,3,2]-2,
    [10,5,2]-2,
    [1,1,1]-4,
    [0,0,0]-6
]).

% Lists used for the consistency check with all_equations/2.
tst_samples([[4,2,5,3], [2,4,8], [2,3,4], [1,2,3], [6,3,2], [10,5,2],
             [3,3,9], [1,1,1], [2,2,2,2], [1,1], [0,0], [5], []]).

% ---------------------------------------------------------------
% Tests
% ---------------------------------------------------------------

% 1. [4,2,5,3] has exactly 7 equations.
test_four_numbers :-
    catch(count_equations([4, 2, 5, 3], 7), _, fail),
    expect_count([4, 2, 5, 3], 7).

% 2. [2,4,8] has exactly 1 equation.
test_two_four_eight :-
    catch(count_equations([2, 4, 8], 1), _, fail),
    expect_count([2, 4, 8], 1).

% 3. [2,3,4] has no equations, so the count is 0.
test_no_equations :-
    catch(count_equations([2, 3, 4], 0), _, fail),
    expect_count([2, 3, 4], 0).

% 4. Empty and single-element lists have count 0.
test_short_lists :-
    expect_count([], 0),
    expect_count([5], 0),
    expect_count([0], 0).

% 5. Additional inputs with known counts.
test_known_counts :-
    known_counts(Pairs),
    forall(member(List-Expected, Pairs),
           expect_count(List, Expected)).

% 6. The count equals the length of the list from all_equations/2.
test_matches_all_equations :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( catch(all_equations(L, Es), _, fail),
             length(Es, Len),
             expect_count(L, Len) )).

% 7. The count is a non-negative integer, and the call is deterministic
%    (exactly one solution).
test_count_is_integer :-
    tst_samples(Lists),
    forall(member(L, Lists),
           ( count_of(L, N), integer(N), N >= 0 )).

% ---------------------------------------------------------------
% Runner
% ---------------------------------------------------------------

all_tests([
    test_four_numbers,
    test_two_four_eight,
    test_no_equations,
    test_short_lists,
    test_known_counts,
    test_matches_all_equations,
    test_count_is_integer
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