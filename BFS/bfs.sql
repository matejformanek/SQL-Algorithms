WITH trips (dest, path, total_cost) AS
         ((SELECT dest,
                  "start" || ',' || dest,
                  cost
           FROM flights
           WHERE "start" = $start)
          UNION ALL
          (SELECT f.dest,
                  t.path || ',' || f.dest,
                  t.total_cost + f.cost
           FROM trips t,
                flights f
           WHERE t.dest = f."start"
             AND INSTR(t.path, f.dest) = 0
             AND f."start" <> $end))
SELECT path, total_cost
FROM trips
WHERE dest = $end
ORDER BY total_cost;