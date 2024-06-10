CREATE OR REPLACE PACKAGE sudoku
    AUTHID DEFINER
AS
    board_size CONSTANT INTEGER := 81;

    invalid_board EXCEPTION;
    PRAGMA EXCEPTION_INIT ( invalid_board, -25000);

-- Solves sudoku using recursion and for loops
    FUNCTION sudoku_solver_func(board IN VARCHAR, curr_pos IN INTEGER DEFAULT 1) RETURN VARCHAR;
-- Solves sudoku using WITH
    FUNCTION sudoku_solver_select(board IN VARCHAR) RETURN VARCHAR;
-- Formats the output
    FUNCTION pretty_print(board IN VARCHAR) RETURN VARCHAR;
-- Support function for sudoku_solver_func. Checks if u can add digit to board on current position.
    FUNCTION board_is_valid(board IN VARCHAR, digit IN VARCHAR, curr_pos IN INTEGER DEFAULT 1) RETURN BOOLEAN;
END;

CREATE OR REPLACE PACKAGE BODY
    sudoku
AS
    FUNCTION sudoku_solver_func(board IN VARCHAR, curr_pos IN INTEGER DEFAULT 1)
        RETURN VARCHAR
    AS
        tmp_board VARCHAR(81);
    BEGIN
        -- Check correct board length
        IF LENGTH(board) <> board_size THEN
            RAISE invalid_board;
        END IF;

-- End the recursion
        IF curr_pos = 82 THEN
            RETURN board;
        END IF;

-- If the position is already filled continue
        IF SUBSTR(board, curr_pos, 1) <> '.' THEN
            RETURN sudoku_solver_func(board, curr_pos + 1);
        END IF;

-- Try to add each possible digit
        FOR digit IN 1..9
            LOOP
                IF board_is_valid(board, TO_CHAR(digit), curr_pos) THEN
                    SELECT CAST((SUBSTR(board, 1, curr_pos - 1) || digit ||
                                 SUBSTR(board, curr_pos + 1, 81)) AS VARCHAR(81))
                    INTO tmp_board
                    FROM dual;

--                     If the digit is valid try to recur.
                    tmp_board := sudoku_solver_func(tmp_board, curr_pos + 1);
                    IF tmp_board <> 'X' THEN
                        RETURN tmp_board;
                    END IF;
                END IF;
            END LOOP;

        RETURN 'X';
    END;

    FUNCTION sudoku_solver_select(board IN VARCHAR)
        RETURN VARCHAR
    AS
        res VARCHAR(81);
    BEGIN
        -- Check correct board length
        IF LENGTH(board) <> board_size THEN
            RAISE invalid_board;
        END IF;

        WITH x(board, curr) AS
                 (SELECT sudoku_solver_select.board,
                         INSTR(sudoku_solver_select.board, '.')
                  FROM dual
                  UNION ALL
                  (SELECT CAST((SUBSTR(board, 1, curr - 1) || digit ||
                                SUBSTR(board, curr + 1, 81)) AS VARCHAR(81)),
                          INSTR(board, '.', 1, 2) -- next position to change.
                   FROM x
                            JOIN
                        (SELECT column_value AS digit
                         FROM TABLE (sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9'))) ON
                            NOT EXISTS -- Try to join the board with each possible digit if not exists blocking digit in board.
                                (SELECT 1
                                 FROM (SELECT column_value AS iter -- Iterates from 0-8
                                       FROM TABLE (sys.odcinumberlist(0, 1, 2, 3, 4, 5, 6, 7, 8)))
                                 WHERE digit =
                                       SUBSTR(board, MOD((curr - 1), 9) + 1 + 9 * iter, 1) -- col
                                    OR digit =
                                       SUBSTR(board,
                                              (curr - MOD((curr - 1), 9)) + iter, 1)       -- row
                                    OR digit =
                                       SUBSTR(board, 1 + MOD(curr - 1, 9) - MOD(curr - 1, 3) + MOD(iter, 3) -- box row
                                           + FLOOR((curr - 1) / 27) * 27 + FLOOR(iter / 3) * 9, 1) -- box col
                                ) AND curr <> 0)) -- cur = 0 -> no more '.' in board.
        SELECT board
        INTO res
        FROM x
        WHERE curr = 0;

        RETURN res;
    END;

    FUNCTION pretty_print(board IN VARCHAR)
        RETURN VARCHAR
    AS
        digit INTEGER := 1;
        res   VARCHAR(1024);
    BEGIN
        FOR j IN 0..8
            LOOP
                IF MOD(j, 3) = 0 AND j <> 0 THEN
                    res := res || '---------------------
';
                END IF;
                FOR i IN 0..8
                    LOOP
                        IF MOD(i, 3) = 0 AND i <> 0 THEN
                            res := res || '| ';
                        END IF;
                        res := res || SUBSTR(board, digit, 1) || ' ';
                        digit := digit + 1;
                    END LOOP;
                res := res || '
';
            END LOOP;


        RETURN res;
    END;

    FUNCTION board_is_valid(board IN VARCHAR, digit IN VARCHAR, curr_pos IN INTEGER DEFAULT 1)
        RETURN BOOLEAN
    AS
        col     INTEGER := MOD(curr_pos - 1, 9) + 1;
        row_var INTEGER := curr_pos - MOD(curr_pos - 1, 9);
        boarder INTEGER := -1 * MOD(FLOOR((curr_pos - 1) / 9), 3);
    BEGIN
        LOOP
            EXIT WHEN col >= 82;

            IF col <> curr_pos AND SUBSTR(board, col, 1) = digit THEN
                RETURN FALSE;
            END IF;

            col := col + 9;
        END LOOP;

        LOOP
            EXIT WHEN row_var >= curr_pos + 9 - MOD(curr_pos - 1, 9);

            IF row_var <> curr_pos AND SUBSTR(board, row_var, 1) = digit THEN
                RETURN FALSE;
            END IF;

            row_var := row_var + 1;
        END LOOP;

        col := boarder;

        LOOP
            EXIT WHEN col >= boarder + 3;

            row_var := col * 9 + curr_pos - MOD(curr_pos - 1, 3);
            LOOP
                EXIT WHEN row_var >= col * 9 + curr_pos + 3 - MOD(curr_pos - 1, 3);

                IF row_var <> curr_pos AND SUBSTR(board, row_var, 1) = digit THEN
                    RETURN FALSE;
                END IF;

                row_var := row_var + 1;
            END LOOP;

            col := col + 1;
        END LOOP;

        RETURN TRUE;
    END;
END;