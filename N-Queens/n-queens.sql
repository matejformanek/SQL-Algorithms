WITH RECURSIVE queens(board, num_placed, curr_pos) AS
                   (SELECT STRING_AGG('.', ''), 0, 1
                    FROM GENERATE_SERIES(1, :n * :n)
                    UNION ALL
                    SELECT CASE
                               WHEN num.adding = 0 THEN queens.board
                               ELSE SUBSTR(board, 1, curr_pos - 1) || 'Q' ||
                                    SUBSTR(board, curr_pos + 1) END,
                           CASE WHEN num.adding = 0 THEN queens.num_placed ELSE queens.num_placed + 1 END,
                           queens.curr_pos + 1
                    FROM queens
                             JOIN (VALUES (0), (1)) AS num(adding)
                                  ON num.adding = 0 OR -- not adding no need to check rules
                                     NOT EXISTS(SELECT 1
                                                FROM GENERATE_SERIES(0, :n - 1) AS iter
                                                WHERE 'Q' = SUBSTR(board, (curr_pos - MOD((curr_pos - 1), :n)) + iter, 1) -- row
                                                   OR 'Q' = SUBSTR(board, MOD(curr_pos - 1, :n) + 1 + :n * iter, 1)       -- col
                                                   OR 'Q' = SUBSTR(board, CASE
                                                                              WHEN
                                                                                  iter + MOD(curr_pos - 1, :n) + 1 <=
                                                                                  :n AND
                                                                                  curr_pos -
                                                                                  iter * :n >= 1
                                                                                  THEN iter + curr_pos -
                                                                                       iter * :n
                                                                              ELSE curr_pos END, 1)                       -- right-top
                                                   OR 'Q' = SUBSTR(board, CASE
                                                                              WHEN
                                                                                  MOD(curr_pos - 1, :n) + 1 - iter >=
                                                                                  1 AND
                                                                                  curr_pos -
                                                                                  iter * :n >= 1
                                                                                  THEN curr_pos - iter -
                                                                                       iter * :n
                                                                              ELSE curr_pos END, 1) -- left-top
                                     )
                    WHERE queens.curr_pos <= :n * :n)
SELECT DISTINCT board
FROM queens
WHERE num_placed = :n;