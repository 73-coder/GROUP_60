
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
