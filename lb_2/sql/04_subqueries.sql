\set ON_ERROR_STOP on
\echo '3.1. Завершённые договоры дороже среднего завершённого договора своей категории'
SELECT r.rental_id, cat.name, c.plate_number, r.total_cost
FROM rentals r JOIN cars c ON c.car_id = r.car_id
JOIN car_categories cat ON cat.category_id = c.category_id
WHERE r.status = 'completed' AND r.total_cost > (
    SELECT avg(r2.total_cost) FROM rentals r2 JOIN cars c2 ON c2.car_id = r2.car_id
    WHERE r2.status = 'completed' AND c2.category_id = c.category_id
)
ORDER BY cat.name, r.total_cost DESC, r.rental_id;

\echo '3.2. EXISTS: клиенты, вернувшие хотя бы одну машину позже срока'
SELECT cl.client_id, cl.full_name, cl.phone FROM clients cl
WHERE EXISTS (SELECT 1 FROM rentals r WHERE r.client_id = cl.client_id
              AND r.status = 'completed' AND r.actual_return_date > r.end_date)
ORDER BY cl.client_id;

\echo '3.3. NOT EXISTS: клиенты, ни разу не завершившие аренду'
SELECT cl.client_id, cl.full_name, cl.email FROM clients cl
WHERE NOT EXISTS (SELECT 1 FROM rentals r WHERE r.client_id = cl.client_id AND r.status = 'completed')
ORDER BY cl.client_id;

\echo '3.4. Коррелированный подзапрос: индивидуальная сумма и дата последней завершённой аренды'
SELECT cl.client_id, cl.full_name,
       (SELECT coalesce(sum(r.total_cost), 0) FROM rentals r
        WHERE r.client_id = cl.client_id AND r.status = 'completed') AS completed_amount,
       (SELECT max(r.actual_return_date) FROM rentals r
        WHERE r.client_id = cl.client_id AND r.status = 'completed') AS last_return
FROM clients cl ORDER BY completed_amount DESC, cl.client_id;
