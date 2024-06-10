WITH x(board, curr) AS
         (SELECT $board,
                 INSTR($board, '.')
          FROM dual
          UNION ALL
          (SELECT CAST((SUBSTR(board, 1, curr - 1) || digit ||
                        SUBSTR(board, curr + 1, 81)) AS VARCHAR(81)),
                  INSTR(board, '.', 1, 2)
           FROM x,
                (SELECT column_value AS digit
                 FROM TABLE (sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9')))
           WHERE curr <> 0
             AND NOT EXISTS
               (SELECT 1
                FROM (SELECT column_value AS iter
                      FROM TABLE (sys.odcinumberlist(0, 1, 2, 3, 4, 5, 6, 7, 8)))
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

-- Using JOIN ON NOT EXISTS
WITH x(board, curr) AS
         (SELECT $board,
                 INSTR($board, '.')
          FROM dual
          UNION ALL
          (SELECT CAST((SUBSTR(board, 1, curr - 1) || digit ||
                        SUBSTR(board, curr + 1, 81)) AS VARCHAR(81)),
                  INSTR(board, '.', 1, 2)
           FROM x
                    JOIN
                (SELECT column_value AS digit
                 FROM TABLE (sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9'))) ON NOT EXISTS
                    (SELECT 1
                     FROM (SELECT column_value AS iter
                           FROM TABLE (sys.odcinumberlist(0, 1, 2, 3, 4, 5, 6, 7, 8)))
                     WHERE digit =
                           SUBSTR(board, MOD((curr - 1), 9) + 1 + 9 * iter, 1) -- col
                        OR digit =
                           SUBSTR(board,
                                  (curr - MOD((curr - 1), 9)) + iter, 1)       -- row
                        OR digit = SUBSTR(board, 1 + MOD(curr - 1, 9) - MOD(curr - 1, 3) + MOD(iter, 3) -- box row
                         + FLOOR((curr - 1) / 27) * 27 + FLOOR(iter / 3) * 9, 1) -- box col
                    ) AND curr <> 0 ))
SELECT board
FROM x
WHERE curr = 0;