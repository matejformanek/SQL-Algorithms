WITH RECURSIVE sieve(num, prime, divider) AS
                   (SELECT num, FALSE, 2
                    FROM GENERATE_SERIES(2, :n) AS num -- :n Being the top block
                    UNION ALL
                    SELECT sieve.num,
                           CASE WHEN divider = sieve.num THEN TRUE ELSE FALSE END AS prime,
                           divider + 1
                    FROM sieve
                    WHERE (sieve.num >= divider AND MOD(sieve.num, divider) <> 0)
                       OR sieve.num = divider)
SELECT num, prime
FROM sieve
WHERE prime = TRUE
ORDER BY num;