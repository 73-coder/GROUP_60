---
name: scheme-dev
description: Write, review, and test restricted Racket code for CS F301 Principles of Programming Languages assignments.
---

# Scheme Development Skill

## Language and Environment

- Use `#lang racket/base`.
- Follow the exact restrictions specified in the assignment.
- The submitted solution file must contain definitions only.
- Do not include top-level test calls or output statements.
- Assume the grader may append function calls to the submitted file.

## Permitted Constructs

Use only the constructs permitted by the assignment:

- Definitions and functions: `define`, `lambda`
- Bindings: `let`, `let*`, `letrec`, named `let`
- Conditionals: `if`, `cond`, `else`
- Logical operations: `and`, `or`, `not`
- Sequencing: `begin`
- Quotation: `quote`, `'`
- List operations: `cons`, `car`, `cdr`, `list`
- Predicates and lookup: `null?`, `pair?`, `eq?`, `assq`, `assoc`
- Arithmetic and comparisons: `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`
- Output: `display`, `newline`
- `read` when explicitly permitted by the assignment.

Do not assume other Racket built-ins are allowed.

## Restrictions

Avoid forbidden constructs and library functions, including:

- Mutation: `set!`
- List helpers: `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`
- Other helpers: `list?`, `equal?`, `apply`
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

## Common Mistakes

- Using a convenient built-in that the assignment prohibits.
- Checking a list's length after modifying its elements instead of using its original length.
- Forgetting to process nested empty lists.
- Handling only the top-level list.
- Adding test calls to the submitted source file.
- Defining a required function more than once.
- Assuming that code compiling successfully means it satisfies the assignment.
