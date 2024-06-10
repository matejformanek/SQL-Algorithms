# Sudoku solver (ORACLE)

Uses 1 recursive With to solve given sudoku.

    Replace $board with '86....3...2...1..7....74...27.9..1...8.....7...1..7.95...56....4..1...5...3....81'

Dot meaning an empty box written in pretty format.

```text
8 6 . | . . . | 3 . .
. 2 . | . . 1 | . . 7
. . . | . 7 4 | . . .
---------------------
2 7 . | 9 . . | 1 . .
. 8 . | . . . | . 7 .
. . 1 | . . 7 | . 9 5
---------------------
. . . | 5 6 . | . . .
4 . . | 1 . . | . 5 .
. . 3 | . . . | . 8 1

Result (Pretty print)
8 6 7 | 2 9 5 | 3 1 4
9 2 4 | 3 8 1 | 5 6 7
1 3 5 | 6 7 4 | 8 2 9
---------------------
2 7 6 | 9 5 3 | 1 4 8
5 8 9 | 4 1 6 | 2 7 3
3 4 1 | 8 2 7 | 6 9 5
---------------------
7 1 8 | 5 6 9 | 4 3 2
4 9 2 | 1 3 8 | 7 5 6
6 5 3 | 7 4 2 | 9 8 1
```

## Implementation

[File](sudoku_solver.sql)

1) Using JOIN ON NOT EXISTS

```sql
WITH x(board, curr) AS
         (SELECT $board,
                 instr($board, '.')
          FROM dual
          UNION ALL
          (SELECT CAST((SUBSTR(board, 1, curr - 1) || digit ||
                        SUBSTR(board, curr + 1, 81)) AS VARCHAR(81)),
                  instr(board, '.', 1, 2)
           FROM x
                    JOIN
                (SELECT column_value AS digit
                 FROM table(sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9')))
                ON NOT EXISTS
                       (SELECT 1
                        FROM (SELECT column_value AS iter
                              FROM table(sys.odcinumberlist(0, 1, 2, 3, 4, 5, 6, 7, 8)))
                        WHERE digit =
                              SUBSTR(board, MOD((curr - 1), 9) + 1 + 9 * iter, 1) -- col
                           OR digit =
                              SUBSTR(
                                      board,
                                      (curr - MOD((curr - 1), 9)) +
                                      iter,
                                      1)                                          -- row
                           OR digit =
                              SUBSTR(
                                      board,
                                      1 +
                                      MOD(curr - 1, 9) -
                                      MOD(curr - 1, 3) +
                                      MOD(iter, 3) -- box row
                                          +
                                      FLOOR((curr - 1) / 27) *
                                      27 +
                                      FLOOR(iter / 3) *
                                      9,
                                      1) -- box col
                       ) AND curr <> 0))
SELECT board
FROM x
WHERE curr = 0;
```

2) Connecting in WHERE

```sql
WITH x(board, curr) AS
         (SELECT $board,
                 instr($board, '.')
          FROM dual
          UNION ALL
          (SELECT CAST((SUBSTR(board, 1, curr - 1) || digit ||
                        SUBSTR(board, curr + 1, 81)) AS VARCHAR(81)),
                  instr(board, '.', 1, 2)
           FROM x,
                (SELECT column_value AS digit
                 FROM table(sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9')))
           WHERE curr <> 0
             AND NOT EXISTS
               (SELECT 1
                FROM (SELECT column_value AS iter
                      FROM table(sys.odcinumberlist(0, 1, 2, 3, 4, 5, 6, 7, 8)))
                WHERE digit =
                      SUBSTR(board, MOD((curr - 1), 9) + 1 + 9 * iter, 1) -- col
                   OR digit =
                      SUBSTR(board,
                             (curr - MOD((curr - 1), 9)) + iter, 1)       -- row
                   OR digit = SUBSTR(board, 1 + MOD(curr - 1, 9) - MOD(curr - 1, 3) + MOD(iter, 3) -- box row
                    + FLOOR((curr - 1) / 27) * 27 + FLOOR(iter / 3) * 9, 1) -- box col
               )))
SELECT board
FROM x
WHERE curr = 0;
```

## Sudoku package

[File](sudoku_package.sql)

Contains code above, sudoku solver in PL/SQL and pretty print function.

```sql
SELECT sudoku.pretty_print(
               sudoku.sudoku_solver_select('86....3...2...1..7....74...27.9..1...8.....7...1..7.95...56....4..1...5...3....81'))
           AS solved_sudoku
FROM dual;
```