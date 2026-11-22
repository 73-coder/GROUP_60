---
name: prolog-dev
description: Write, review, and test SWI-Prolog 9.x code under strict constraints (predicate definitions only, no side-effecting database or global-variable builtins, restricted libraries). Make sure to use this skill whenever the user asks for Prolog code, predicates, facts, rules, logic-programming exercises, DCGs, or SWI-Prolog solutions, or mentions .pl files, swipl, backtracking, unification, or Prolog assignments, even if they do not explicitly say "SWI-Prolog".
---

# Prolog Development (SWI-Prolog 9.x)

Use this skill to produce correct, clean, deterministic-where-required Prolog that can be loaded and queried non-interactively.

## 1. Language & Constraints

- Target **SWI-Prolog 9.x** only.
- A solution file contains **only predicate definitions** (facts and rules). Nothing else.
- **Forbidden** in solution files:
  - `:- initialization(...)` directives of any kind
  - `halt/0` (or `halt/1`)
  - `assert/1`, `asserta/1`, `assertz/1`, `retract/1`, `retractall/1`
  - `b_setval/2`, `nb_setval/2`
  - Top-level queries or goals such as `:- main.` or `?- foo(X).`
- **Allowed libraries** (via `:- use_module(library(...))`): `lists`, `apply`, `yall`, `aggregate`. No other library may be imported or relied upon.
  - Do not call predicates from non-allowed libraries (e.g. `assoc`, `pairs`, `dcg/basics`, `strings`, `clpfd`, `readutil`) even if SWI autoloads them.
  - Only built-ins and the four libraries above are in scope.
- If the specification requires a particular predicate name, arity, argument order, or atom/string representation, follow it exactly.

## 2. Coding Conventions

- Use **snake_case** for all predicate and atom names (`path_length/3`, `is_ancestor/2`). Variables use standard Prolog `CamelCase` (`Rest`, `Acc`, `_Unused`).
- Keep comments **concise**.
- Place a **declarative reading comment directly above every predicate**, describing what is true when the predicate holds (not how it executes). Example:

```prolog
% sum_list_acc(List, Total): Total is the sum of the numbers in List.
sum_list_acc(List, Total) :-
    sum_acc(List, 0, Total).

% sum_acc(List, Acc, Total): Total is Acc plus the sum of the numbers in List.
sum_acc([], Total, Total).
sum_acc([X|Xs], Acc0, Total) :-
    Acc is Acc0 + X,
    sum_acc(Xs, Acc, Total).
```

- Every helper predicate gets its own declarative comment too.
- Group clauses of the same predicate together (avoid discontiguous clauses).
- Prefer pure, relational definitions; use cuts or if-then-else only when needed to guarantee required determinism, and keep their use local and obvious.
- Prefer first-argument indexing-friendly clause heads (e.g. `[]` / `[H|T]`).

## 3. Execution & Testing

Run a file non-interactively with:

```bash
swipl -q -f <file> -g "<goal>" -t halt
```

- `-q` quiet, `-f <file>` loads the file, `-g "<goal>"` runs the test goal, `-t halt` exits afterwards.
- Test goals belong **on the command line, never in the file**.
- To check for failure or errors, wrap goals so results are visible via exit status, e.g. `-g "(foo(1,X), X == 2 -> true ; halt(1))"`. Keep this in the command, not the solution file.
- **Never print anything** (`write/1`, `print/1`, `format/2`, `nl/0`, etc.) inside solution predicates unless the predicate specification explicitly requires output.
- Test at least: a typical case, an empty/boundary case, a failing case, and (where relevant) enumeration of all solutions via `findall/3` to confirm backtracking behavior.
- Check determinism with a goal like `-g "call_cleanup(foo(X), Det=true), (Det == true -> true ; halt(2))"` or by confirming `findall/3` returns exactly the expected number of solutions.

## 4. Mandatory Self-Review Checklist

Before outputting any code, verify **every** item:

1. **No singleton variables.** Load the file and confirm no singleton warnings. Rename intentionally unused variables to `_` or `_Name`.
2. **Exact atom/string types.** Confirm each value is the type the spec requires: atoms (`alex`, `'Alex'`), strings (`"alex"`), numbers, or code/char lists. Do not mix them, and quote atoms that need quoting.
3. **Deterministic vs. backtracking behavior.** Decide for each predicate whether it should be deterministic (exactly one solution, no leftover choicepoint) or nondeterministic (all solutions on backtracking), and confirm the code matches the spec.
4. **Allowed libraries only.** Imports are limited to `lists`, `apply`, `yall`, `aggregate`; no other library predicates are used.
5. **Forbidden constructs absent.** No `initialization`, `halt`, `assert*`, `retract*`, `b_setval`, `nb_setval`, or top-level queries.
6. **No unintended output.** No printing unless the spec requires it.
7. **Names, arities, and argument order** match the specification exactly.
8. **Every predicate has a declarative comment** directly above it.
9. **Edge cases handled:** empty list, single element, duplicates, no solution (should fail, not error).
10. **The file loads cleanly** with `swipl -q -f <file> -g true -t halt` and produces no warnings.

## 5. Known AI Failure Modes in Prolog

Watch for and actively avoid these common mistakes:

- **`=` instead of `is` / `=:=` for arithmetic.**
  - Wrong: `X = Y + 1` (this only unifies with the term `Y+1`).
  - Right: `X is Y + 1`; for numeric comparison use `=:=`, `=\=`, `<`, `>`, `=<`, `>=`.
- **Forgetting quotes on capitalized or symbolic atoms.**
  - `Alex` is a variable; write `'Alex'`. Likewise `'AI'`, `'c++'`, `'hello world'`, `'New York'`, and atoms with symbols or leading uppercase letters.
  - Check that every atom in a fact or test goal is quoted when it needs to be.
- **Leaving stray choicepoints.**
  - Overlapping clauses (e.g. `foo([], ...)` and a catch-all `foo(_, ...)`) leave choicepoints and yield duplicate or spurious solutions.
  - Make clauses mutually exclusive via distinct head patterns, guards, or `->` / `;`, and confirm with `findall/3` or `call_cleanup/2` tests.
- **Adding top-level queries or `initialization` directives.**
  - Do not write `:- initialization(main).`, `:- main.`, `?- ...`, or any directive that runs code on load. Put test goals on the `swipl -g` command line instead.
- **Using forbidden state builtins** (`assert`, `retract`, `nb_setval`, `b_setval`) to "remember" results. Use accumulators, `findall/3`, `aggregate_all/3`, or recursion instead.
- **Printing results from predicates** instead of binding arguments. Return values through arguments, not through output.
- **Confusing atoms and strings** (`"abc"` vs `abc`), especially with `atom_length/2`, `atom_concat/3`, `atom_string/2`, and `string_concat/3`.
- **Importing disallowed libraries** or silently relying on autoloaded predicates outside the four allowed libraries.
- **Non-termination from left recursion** or missing base cases; always provide a base case and place recursive calls after progress-making goals.
- **Misusing `\=` and `\+`** where unification-free or sound negation is needed; ensure variables are bound before negation-as-failure.
