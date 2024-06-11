# Sieve of Eratosthenes

Algorithm for finding all prime numbers that are smaller than given :n

## Implementaion

Because of how WITH works instead of changing not primes into false we SELECT the prime number and than all where we
don't know yet.

[File](sieve.sql)

```sql
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
```