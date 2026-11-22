# P1 Analysis Report (Group 60)

## Solution Count Under Clues 1–8
- **Total search space (`count_solutions([], C)`):** $24 \times 24 \times 24 = 13,824$ valid bijective assignments.
- **Solutions satisfying Clues 1–8 (`count_solutions([1,2,3,4,5,6,7,8], C)`):** **3** distinct solutions.

## The 3 Distinct Solutions (Clues 1–8)

### Solution 1
- **Alex:** `[design, java, AI]`
- **Ben:** `[development, javascript, web]`
- **Carla:** `[research, c++, data]`
- **Dana:** `[testing, python, embedded]`

### Solution 2
- **Alex:** `[design, java, embedded]`
- **Ben:** `[development, javascript, web]`
- **Carla:** `[testing, python, AI]`
- **Dana:** `[research, c++, data]`

### Solution 3
- **Alex:** `[testing, python, embedded]`
- **Ben:** `[development, javascript, web]`
- **Carla:** `[design, java, AI]`
- **Dana:** `[research, c++, data]`

## Why the Original 8-Clue Puzzle Is Under-Constrained
1. **Ben is uniquely determined** (`[development, javascript, web]`), which leaves 3 departments (`design`, `research`, `testing`), 3 languages (`java`, `python`, `c++`), and 3 projects (`AI`, `data`, `embedded`) for Alex, Carla, and Dana.
2. **Clues 3, 5, and 8 lock three `(Department, Language)` pairs** (`(testing, python)`, `(design, java)`, and `(research, c++, data)`), leaving two degrees of freedom:
   - Who gets `(research, c++, data)`: either **Carla** (Solution 1) or **Dana** (Solutions 2 & 3).
   - How `(design, java)` and `(testing, python)` are split between **Alex** and **Carla** when Dana takes `research` (Solutions 2 vs. 3).
