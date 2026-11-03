\set ON_ERROR_STOP on
\echo '2.1.1. Подробный журнал договоров: клиент, машина, категория, офис и сотрудник'
SELECT r.rental_id, cl.full_name AS client, c.plate_number, c.brand, c.model,
       cat.name AS category, o.city, e.full_name AS employee,
       r.start_date, r.end_date, r.actual_return_date, r.status, r.total_cost
FROM rentals r
JOIN clients cl ON cl.client_id = r.client_id
JOIN cars c ON c.car_id = r.car_id
JOIN car_categories cat ON cat.category_id = c.category_id
JOIN offices o ON o.office_id = c.office_id
JOIN employees e ON e.employee_id = r.employee_id
ORDER BY r.start_date, r.rental_id;

\echo '2.1.2. Автомобили без единого договора, включая отменённые'
SELECT c.plate_number, c.brand, c.model, c.status, cat.name AS category, o.city
FROM cars c
JOIN car_categories cat ON cat.category_id = c.category_id
JOIN offices o ON o.office_id = c.office_id
LEFT JOIN rentals r ON r.car_id = c.car_id
WHERE r.rental_id IS NULL
ORDER BY o.city, c.plate_number;

\echo '2.1.3. Незакрытые договоры со сроком возврата до 01.04.2026 в действующих офисах'
SELECT r.rental_id, cl.full_name, cl.phone, c.plate_number, o.city, r.end_date
FROM rentals r
JOIN clients cl ON cl.client_id = r.client_id
JOIN cars c ON c.car_id = r.car_id
JOIN offices o ON o.office_id = c.office_id
WHERE r.status IN ('active', 'overdue') AND r.actual_return_date IS NULL AND o.is_active
  AND r.end_date < DATE '2026-04-01'
ORDER BY r.end_date, r.rental_id;

\echo '2.2.1. Количество договоров каждого состояния по офисам'
SELECT o.city, o.office_id, r.status, count(*) AS rental_count,
       count(DISTINCT r.client_id) AS client_count
FROM rentals r JOIN cars c ON c.car_id = r.car_id
JOIN offices o ON o.office_id = c.office_id
GROUP BY o.office_id, o.city, r.status ORDER BY o.office_id, r.status;

\echo '2.2.2. Категории с суммой завершённых договоров от 100000 рублей'
SELECT cat.name, count(*) AS completed_count, sum(r.total_cost) AS completed_amount,
       round(avg(r.total_cost), 2) AS average_cost,
       min(r.total_cost) AS minimum_cost, max(r.total_cost) AS maximum_cost
FROM rentals r JOIN cars c ON c.car_id = r.car_id
JOIN car_categories cat ON cat.category_id = c.category_id
WHERE r.status = 'completed'
GROUP BY cat.category_id, cat.name HAVING sum(r.total_cost) >= 100000
ORDER BY completed_amount DESC;

\echo '2.2.3. Сравнение месяцев по числу договоров, отменам и сумме завершённых'
SELECT date_trunc('month', start_date)::date AS month,
       count(*) AS contracts, count(*) FILTER (WHERE status = 'cancelled') AS cancelled,
       round(100.0 * count(*) FILTER (WHERE status = 'cancelled') / count(*), 2) AS cancelled_pct,
       coalesce(sum(total_cost) FILTER (WHERE status = 'completed'), 0) AS completed_amount
FROM rentals GROUP BY date_trunc('month', start_date) ORDER BY month;
