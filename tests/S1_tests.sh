#!/usr/bin/env bash
# S1 tests for PPL Assignment 2 (binary tree traversals).
# Usage: bash tests/S1_tests.sh [path-to-q3-file]

set -u

SRC="${1:-code/60_q3.rkt}"

if [ ! -f "$SRC" ]; then
    echo "ERROR: Solution file not found: $SRC"
    exit 1
fi

if ! command -v racket >/dev/null 2>&1; then
    echo "ERROR: Racket is not installed or not on PATH."
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
nl=$'\n'

# check NAME CALL EXPECTED
# Copies the solution, appends CALL, runs it, and compares the exact output
# (including the final newline) with EXPECTED followed by one newline.
check() {
    name="$1"
    call="$2"
    expected="$3"

    cp "$SRC" "$TMP/test.rkt"
    printf '\n%s\n' "$call" >> "$TMP/test.rkt"
    printf '%s\n' "$expected" > "$TMP/expected"

    if racket "$TMP/test.rkt" > "$TMP/got" 2> "$TMP/error"; then
        if cmp -s "$TMP/got" "$TMP/expected"; then
            pass=$((pass + 1))
            echo "PASS  $name"
        else
            fail=$((fail + 1))
            echo "FAIL  $name"
            echo "  Expected: $(head -c 300 "$TMP/expected")"
            echo "  Got:      $(head -c 300 "$TMP/got")"
        fi
    else
        fail=$((fail + 1))
        echo "FAIL  $name (Racket error)"
        head -n 5 "$TMP/error"
    fi
}

# check_tree NAME TREE INORDER PREORDER POSTORDER HEIGHT-AND-LEAVES
# TREE is a quoted Racket tree, for example "'(1 () ())".
check_tree() {
    name="$1"
    tree="$2"
    in_out="$3"
    pre_out="$4"
    post_out="$5"
    hl_out="$6"

    check "$name: print-inorder" "(print-inorder $tree)" "$in_out"
    check "$name: print-all-traversals" "(print-all-traversals $tree)" \
        "$in_out$nl$pre_out$nl$post_out"
    check "$name: print-height-and-leaves" "(print-height-and-leaves $tree)" "$hl_out"
}

# ---- Assignment PDF examples ----
check_tree "t1" \
    "'(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ())))" \
    "(1 2 3 4 5 6 7)" "(4 2 1 3 6 5 7)" "(1 3 2 5 7 6 4)" "(3 4)"

check_tree "t2" \
    "'(1 () (2 () (3 () ())))" \
    "(1 2 3)" "(1 2 3)" "(3 2 1)" "(3 1)"

check_tree "t3" \
    "'(a (b () ()) (c () ()))" \
    "(b a c)" "(a b c)" "(b c a)" "(2 2)"

check_tree "empty tree" \
    "'()" \
    "()" "()" "()" "(0 0)"

# ---- Edge cases ----
check_tree "single node" \
    "'(5 () ())" \
    "(5)" "(5)" "(5)" "(1 1)"

check_tree "left-only chain" \
    "'(3 (2 (1 () ()) ()) ())" \
    "(1 2 3)" "(3 2 1)" "(1 2 3)" "(3 1)"

check_tree "numbers and symbols mixed" \
    "'(m (3 (a () ()) ()) (9 () (z () ())))" \
    "(a 3 m 9 z)" "(m 3 a 9 z)" "(a 3 z 9 m)" "(3 2)"

check_tree "unbalanced, three leaves" \
    "'(8 (4 (2 () ()) (6 () ())) (12 () ()))" \
    "(2 4 6 8 12)" "(8 4 2 6 12)" "(2 6 4 12 8)" "(3 3)"

# ---- Stress tests: chains of 10,000 nodes ----
ones=""
right_prefix=""
right_suffix=""
left_prefix=""
left_suffix=""
for ((i=0; i<10000; i++)); do
    ones="${ones}1 "
    right_prefix="${right_prefix}(1 () "
    right_suffix="${right_suffix})"
    left_prefix="${left_prefix}(1 "
    left_suffix="${left_suffix} ())"
done
ones="${ones% }"

right_chain="'${right_prefix}()${right_suffix}"
left_chain="'${left_prefix}()${left_suffix}"
big_list="($ones)"

check_tree "right chain of 10,000 nodes" "$right_chain" \
    "$big_list" "$big_list" "$big_list" "(10000 1)"

check_tree "left chain of 10,000 nodes" "$left_chain" \
    "$big_list" "$big_list" "$big_list" "(10000 1)"

# ---- Static checks ----
# Strip comments, then look for forbidden built-ins.
bad="$(sed 's/;.*//' "$SRC" | grep -nE \
'\((length|append|map|filter|reverse|member|memq|list-ref|list-tail|list\?|set!|for|do|vector|hash|equal\?|apply|write|displayln|printf|add1|sub1|first|rest|empty\?|string-append|foldl|foldr|sort|read|void)[ )]' \
|| true)"

if [ -z "$bad" ]; then
    pass=$((pass + 1))
    echo "PASS  no forbidden built-ins detected"
else
    fail=$((fail + 1))
    echo "FAIL  possible forbidden built-ins:"
    echo "$bad"
fi

# Static check: first line is #lang racket/base.
first_line="$(head -n 1 "$SRC" | tr -d '\r')"
if [ "$first_line" = "#lang racket/base" ]; then
    pass=$((pass + 1))
    echo "PASS  file starts with #lang racket/base"
else
    fail=$((fail + 1))
    echo "FAIL  first line is: $first_line"
fi

# Static check: no output when loading the solution.
if out="$(racket "$SRC" </dev/null 2>"$TMP/load_error")" && [ -z "$out" ]; then
    pass=$((pass + 1))
    echo "PASS  silent on load"
else
    fail=$((fail + 1))
    echo "FAIL  solution produces output or errors on load"
    head -n 5 "$TMP/load_error"
    [ -n "$out" ] && echo "$out"
fi

# Static check: each required function is defined exactly once.
for fn in print-inorder print-all-traversals print-height-and-leaves; do
    count="$(grep -Ec "^[[:space:]]*\(define[[:space:]]+\($fn([[:space:]]|\))" "$SRC" || true)"
    if [ "$count" = "1" ]; then
        pass=$((pass + 1))
        echo "PASS  exactly one definition of $fn"
    else
        fail=$((fail + 1))
        echo "FAIL  found $count definitions of $fn"
    fi
done

echo "-----------------------------"
echo "Passed: $pass"
echo "Failed: $fail"

[ "$fail" -eq 0 ]
