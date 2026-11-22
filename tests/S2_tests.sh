#!/usr/bin/env bash
# S2 tests for PPL Assignment 2.
# Usage: bash tests/S2_tests.sh [path-to-q4-file]

set -u

SRC="${1:-code/id_q4.rkt}"

if [ ! -f "$SRC" ]; then
    echo "ERROR: Solution file not found: $SRC"
    exit 1
fi

if [ ! -f "/c/Program Files/Racket/Racket.exe" ]; then
    echo "ERROR: Racket executable not found."
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp "$SRC" "$TMP/test.rkt"
printf '\n(print-insert-result)\n' >> "$TMP/test.rkt"

pass=0
fail=0

check() {
    name="$1"
    input="$2"
    expected="$3"

    if got="$(printf '%s' "$input" | "/c/Program Files/Racket/Racket.exe" "$TMP/test.rkt" 2>"$TMP/error")"; then
        if [ "$got" = "$expected" ]; then
            pass=$((pass + 1))
            echo "PASS  $name"
        else
            fail=$((fail + 1))
            echo "FAIL  $name"
            echo "  Expected: $expected"
            echo "  Got:      $got"
        fi
    else
        fail=$((fail + 1))
        echo "FAIL  $name (Racket error)"
        cat "$TMP/error"
    fi
}

# Assignment PDF examples
check "PDF example 1" \
'42 ((1 2) (3 4 5) (6) ()) 3' \
'((42 1 2) (3 4 5) (42 6) (42))'

check "PDF example 2" \
'0 (((1) 2) (3) ((4 5 6) ())) 3' \
'((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))'

check "PDF example 3" '7 () 3' '(7)'
check "PDF example 4" '7 () 0' '()'

# Edge cases
check "n=0" \
'x ((1) () (2 3)) 0' \
'((1) () (2 3))'

check "n=1" \
'x ((1) () (2 3)) 1' \
'((1) (x) (2 3))'

check "length equal to n" \
'x (1 2 3) 3' \
'(1 2 3)'

check "length n-1" \
'x (1 2) 3' \
'(x 1 2)'

check "original length" \
'z (a (b)) 2' \
'(a (z b))'

check "nested symbols" \
'a (b (c)) 2' \
'(b (a c))'

check "nested empty lists" \
'q (() (())) 2' \
'((q) (q (q)))'

check "large n" \
'9 ((1) (2 (3))) 100' \
'(9 (9 1) (9 2 (9 3)))'

# Stress test: nesting depth 100
deep="(1 2)"
expected="(9 1 2)"

for ((i=0; i<100; i++)); do
    deep="($deep)"
    expected="(9 $expected)"
done

check "nesting depth 100" "9 $deep 3" "$expected"

# Stress test: list containing 10,000 elements
wide=""
for ((i=0; i<10000; i++)); do
    wide="${wide}1 "
done
wide="${wide% }"

check "10,000 elements" \
"9 ($wide) 20000" \
"(9 $wide)"

# Static check: forbidden built-ins
bad="$(grep -nE \
'\((length|append|map|filter|reverse|member|memq|list-ref|list-tail|list\?|set!|for|do|vector|hash|equal\?|apply|write)[ )]' \
"$SRC" | grep -v '^[[:space:]]*[0-9]*:[[:space:]]*;' || true)"

if [ -z "$bad" ]; then
    pass=$((pass + 1))
    echo "PASS  no forbidden built-ins detected"
else
    fail=$((fail + 1))
    echo "FAIL  possible forbidden built-ins:"
    echo "$bad"
fi

# Static check: no output when loading the solution
if out="$("/c/Program Files/Racket/Racket.exe" "$SRC" </dev/null 2>"$TMP/load_error")" && [ -z "$out" ]; then
    pass=$((pass + 1))
    echo "PASS  silent on load"
else
    fail=$((fail + 1))
    echo "FAIL  solution produces output or errors on load"
    cat "$TMP/load_error"
    [ -n "$out" ] && echo "$out"
fi

# Static check: exactly one insert-if-short definition
count="$(grep -Ec '^[[:space:]]*\(define[[:space:]]+\(insert-if-short([[:space:]]|\))' "$SRC" || true)"

if [ "$count" = "1" ]; then
    pass=$((pass + 1))
    echo "PASS  exactly one insert-if-short definition"
else
    fail=$((fail + 1))
    echo "FAIL  found $count insert-if-short definitions"
fi

echo "-----------------------------"
echo "Passed: $pass"
echo "Failed: $fail"

[ "$fail" -eq 0 ]
