---
name: scheme-dev
description: Write, review, and test restricted Racket code for CS F301 Principles of Programming Languages Assignment 2 (S1 binary tree traversals and S2 nested-list insertion).
---

# Scheme Development Skill

## Language and Environment

- Racket 8.x, with `#lang racket/base` as the first line of every file.
- Follow the exact restrictions specified in the assignment.
- The submitted solution file must contain definitions only.
- Do not include top-level test calls or output statements.
- Assume the grader may append function calls to the submitted file.

## Running and Testing Files

- Run a solution with `racket <id>_q3.rkt` (S1) or `racket <id>_q4.rkt` (S2).
- To test, copy the solution to a temporary file, append the test calls to the copy, and run the copy. Never put test calls in the submitted file.
- Compare the exact printed text, including parentheses, spaces and the final newline.
- `racket <file>` with nothing appended must print nothing.

## Permitted Constructs

Use only the constructs permitted by the assignment:

- Definitions and functions: `define`, `lambda`
- Bindings: `let`, `let*`, `letrec`, named `let`
- Conditionals: `if`, `cond`, `else`
- Logical operations: `and`, `or`, `not`
- Sequencing: `begin`
- Quotation: `quote`, `'`
- List operations: `cons`, `car`, `cdr`, `list`, and compositions of `car`/`cdr` up to four levels (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, and so on)
- Predicates and lookup: `null?`, `pair?`, `eq?`, `assq`, `assoc`
- Arithmetic and comparisons: `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`
- Output: `display`, `newline`
- `read` only where the assignment permits it (S2 only, never S1).

Do not assume other Racket built-ins are allowed.

## Restrictions

Avoid forbidden constructs and library functions, including:

- Mutation: `set!`
- List helpers: `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`
- Other helpers: `list?`, `equal?`, `apply`
- Names that exist in Racket but are not on the permitted list, so they are forbidden: `add1`, `sub1`, `first`, `rest`, `empty?`, `void`, `displayln`, `printf`, `write`, `string-append`, `list*`, `foldl`, `foldr`, `andmap`, `ormap`, `assf`, `remove`, `sort`.
- Data structures: vectors and hashes
- Iteration constructs: `for`, `do`
- Unapproved I/O and formatting functions.

Implement required helper functions recursively using permitted constructs.

## Coding Conventions

- Use recursion to process lists and nested structures.
- Use `null?` to check for the empty list.
- Use `cons` to construct result lists.
- Preserve the original input when the specification requires decisions based on original values.
- Handle empty lists explicitly.
- Keep function definitions readable and consistently indented.
- Do not add unnecessary helper functions or change required function signatures.

## S1 Binary Tree Traversals

Tree shape: a tree is `()` or a three-element list `(value left right)`. Read the parts with `car`, `cadr` and `caddr`. A value is a number or a one-character symbol.

- Conventions: the height of `()` is 0, a node's height is 1 plus the larger subtree height (use `max`), a single node has height 1. A leaf is a node whose left and right are both `()`. The empty tree has 0 leaves, so `()` must give `(0 0)`.
- Order: always visit the left subtree before the right subtree.
- No `append`. Build traversal lists with an accumulator argument: the helper takes the tree and the list of values that must come after it, and returns the combined list using only `cons`. Work out by hand which of the three orders needs the node consed before, between or after the two recursive calls, then check it against the assignment's t1 example.
- Keep traversal, height and leaf-count as separate helpers, and keep printing in the three required functions (`print-inorder`, `print-all-traversals`, `print-height-and-leaves`).
- Printing: each line is `(display <list>)` followed by `(newline)`. Symbols print without a quote mark (`(b a c)`, not `(quote ...)`). `print-all-traversals` prints three lines in the order inorder, preorder, postorder. `print-height-and-leaves` prints one list `(height leaf-count)` built with `list`.
- Return values of the traversal helpers are lists, not printed text. Only the three `print-` functions print.
- Pass all state through arguments. Prefer tail recursion where it is natural, but correctness comes first.
- Expected outputs to test: t1 gives `(1 2 3 4 5 6 7)`, `(4 2 1 3 6 5 7)`, `(1 3 2 5 7 6 4)` and `(3 4)`. t2 `(1 () (2 () (3 () ())))` gives `(1 2 3)`, `(1 2 3)`, `(3 2 1)` and `(3 1)`. t3 `(a (b () ()) (c () ()))` gives `(b a c)`, `(a b c)`, `(b c a)` and `(2 2)`. The empty tree gives `()` on every traversal line and `(0 0)`.
- Edge cases to test: empty tree, single node, left-only chain, right-only chain, symbol values, a tree with both numbers and symbols, and a deep chain (for example 10,000 nodes) to check that nothing crashes.

## S2 Nested-List Insertion

For S2, pay particular attention to these requirements:

- Process nested lists recursively.
- Process nested elements before deciding whether to insert at the current list.
- Use the current list's original length for the insertion decision.
- Insert only when the supplied predicate accepts that length.
- Handle empty lists, including the empty top-level list.
- Define `insert-if-short` exactly once.
- Implement `insert-if-short` using `make-inserter`.
- `print-insert-result` must read the value, list, and threshold in that order.
- Print the result using `display` and `newline`.

## Testing

- Test every example from the assignment.
- Include boundary cases and empty-list cases.
- Test nested lists at multiple depths.
- Test the maximum input sizes and nesting depths specified in the assignment.
- Compare exact output, including list structure and parentheses.
- Check that loading the solution file produces no output.
- Check that no forbidden built-ins are used.
- For S1, check the final newline of every printed line and that the three lines of `print-all-traversals` come out in the right order.
- Keep test calls outside the submitted solution file.

## Self-Review Checklist

Before submitting, verify:

1. Every required function is defined.
2. Function names and parameter order match the assignment.
3. Only permitted constructs are used.
4. Empty and nested lists are handled correctly.
5. Original values are used wherever required.
6. No top-level test calls or output remain in the solution.
7. All provided examples pass.
8. Edge cases and stress tests pass.
9. The required prompt and test files are included.
10. Every helper used is defined in the file and uses only permitted built-ins (no `append`, `length`, `add1`, `first`, `rest` and so on).
11. For S1: the empty tree prints `()` and `(0 0)`, and every printing function ends with a newline.
12. The answer contains exactly the one definition that was asked for in this prompt.

## Common Mistakes

- Using a convenient built-in that the assignment prohibits.
- Checking a list's length after modifying its elements instead of using its original length.
- Forgetting to process nested empty lists.
- Handling only the top-level list.
- Adding test calls to the submitted source file.
- Defining a required function more than once.
- Assuming that code compiling successfully means it satisfies the assignment.
- Using `append` to join traversal lists, or `length`, `add1`, `first`, `rest` out of habit from full Racket.
- Mixing up the order of node and subtrees in preorder, inorder and postorder.
- Counting the empty tree as a leaf, or counting a node with one empty child as a leaf.
- Returning height and leaf count as two separate values or as a dotted pair instead of the list `(height leaf-count)`.
- Printing with `write`, `displayln` or `printf`, or forgetting `(newline)`, or printing a quoted form.
- Calling the function at the end of the file or printing from a helper.
- Writing more than the one function requested, or redefining a helper that already exists.
