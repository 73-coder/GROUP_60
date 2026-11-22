
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
