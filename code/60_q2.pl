
% eval_expr(Expression, Value): Value is the integer value of Expression.
% Fails if any division inside Expression is invalid.

eval_expr(N, N) :-
    integer(N).

eval_expr(add(L, R), V) :-
    eval_expr(L, VL),
    eval_expr(R, VR),
    V is VL + VR.

eval_expr(sub(L, R), V) :-
    eval_expr(L, VL),
    eval_expr(R, VR),
    V is VL - VR.

eval_expr(mul(L, R), V) :-
    eval_expr(L, VL),
    eval_expr(R, VR),
    V is VL * VR.

eval_expr(div(L, R), V) :-
    eval_expr(L, VL),
    eval_expr(R, VR),
    exact_div(VL, VR, V).

% exact_div(A, B, Q): Q is A divided by B, if the division is exact.
exact_div(A, B, Q) :-
    B =\= 0,
    A mod B =:= 0,
    Q is A // B.


% format_expr(Expression, String):
% String is the canonical, space-free text of Expression.

format_expr(N, S) :-
    integer(N),
    format(string(S), "~d", [N]).

format_expr(E, S) :-
    binary_op(E, Sym, Prec, L, R),
    operand_string(L, left, Prec, LS),
    operand_string(R, right, Prec, RS),
    format(string(S), "~s~w~s", [LS, Sym, RS]).

% binary_op(Term, Symbol, Precedence, Left, Right).
binary_op(add(L, R), '+', 1, L, R).
binary_op(sub(L, R), '-', 1, L, R).
binary_op(mul(L, R), '*', 2, L, R).
binary_op(div(L, R), '/', 2, L, R).

% operand_string(Operand, Side, ParentPrec, String).
% Adds parentheses when required by precedence and associativity.

operand_string(X, _Side, _ParentPrec, S) :-
    integer(X),
    format_expr(X, S).

operand_string(X, Side, ParentPrec, S) :-
    binary_op(X, _, Prec, _, _),
    format_expr(X, Inner),
    (   needs_parens(Side, Prec, ParentPrec)
    ->  format(string(S), "(~s)", [Inner])
    ;   S = Inner
    ).

% needs_parens(Side, OperandPrec, ParentPrec).
needs_parens(left, Prec, ParentPrec) :-
    Prec < ParentPrec.

needs_parens(right, Prec, ParentPrec) :-
    Prec =< ParentPrec.

% generate_expr(+List, -Expr)
% Expr is a binary expression tree whose leaves are exactly the numbers of
% List, each used once and in their original order. A one-element list gives
% that number itself. Otherwise List splits into a non-empty Left part and a
% non-empty Right part, each part has an expression tree, and the two trees
% are joined by one of add, sub, mul or div. Backtracking over every split
% point and every operator yields every possible tree. An empty list has no
% tree, so the predicate fails.

generate_expr([N], N).
generate_expr(List, Expr) :-
    append(Left, Right, List),
    Left  = [_|_],
    Right = [_|_],
    generate_expr(Left, L),
    generate_expr(Right, R),
    member(Op, [add, sub, mul, div]),
    Expr =.. [Op, L, R].

% generate_equation_parts(+List, -LeftExpr, -RightExpr)
% LeftExpr and RightExpr are expression trees over a split of List into a
% non-empty prefix and a non-empty suffix. Together they use every number of
% List exactly once, in the original order: LeftExpr covers the prefix and
% RightExpr covers the suffix. Every split point and every pair of trees is
% produced on backtracking. A list with fewer than two elements has no such
% split, so the predicate fails.

generate_equation_parts(List, LeftExpr, RightExpr) :-
    append(Left, Right, List),
    Left  = [_|_],
    Right = [_|_],
    generate_expr(Left, LeftExpr),
    generate_expr(Right, RightExpr).

% generate_equation(+List, -Equation)
% Equation is one valid equation for List, as an SWI-Prolog string such as
% "4*2=5+3". It comes from a split of List into a non-empty prefix and suffix
% with an expression tree for each side, where both trees evaluate to the same
% integer (a division by zero or with a remainder anywhere inside a tree makes
% that tree have no value, so it is rejected). The two sides are written in
% canonical form and joined by exactly one "=". Only the first valid equation
% found is returned. If there is none, including for lists with fewer than two
% numbers, the predicate fails.

generate_equation(List, Equation) :-
    once(( generate_equation_parts(List, LeftExpr, RightExpr),
           eval_expr(LeftExpr, Value),
           eval_expr(RightExpr, Value),
           format_expr(LeftExpr, LeftStr),
           format_expr(RightExpr, RightStr),
           format(string(Equation), "~s=~s", [LeftStr, RightStr]))).

% all_equations(+List, -Equations)
% Equations is the sorted list, without duplicates, of every valid equation
% for List, each written as an SWI-Prolog string such as "4*2=5+3". An
% equation comes from a split of List into a non-empty prefix and suffix with
% an expression tree for each side, where both trees evaluate to the same
% integer (a division by zero or with a remainder anywhere inside a tree
% makes that tree have no value, so it is rejected). Each side is written in
% canonical form and the two sides are joined by exactly one "=". If no valid
% equation exists, Equations is [].

all_equations(List, Equations) :-
    findall(Equation,
            ( generate_equation_parts(List, LeftExpr, RightExpr),
              eval_expr(LeftExpr, Value),
              eval_expr(RightExpr, Value),
              format_expr(LeftExpr, LeftStr),
              format_expr(RightExpr, RightStr),
              format(string(Equation), "~s=~s", [LeftStr, RightStr]) ),
            Equations0),
    sort(Equations0, Equations).

% count_equations(+List, -N)
% N is the number of valid, unique equations for List, that is, the length of
% the list returned by all_equations/2. If there are none, N is 0.

count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).

