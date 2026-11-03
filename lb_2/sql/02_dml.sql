\set ON_ERROR_STOP on
BEGIN;
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM cars c JOIN employees e ON e.office_id = c.office_id
        WHERE c.vin = 'LAB2' || lpad('1', 13, '0') AND e.is_active
    ) OR NOT EXISTS (
        SELECT 1 FROM rentals r JOIN cars c ON c.car_id = r.car_id
        WHERE c.vin = 'LAB2' || lpad('1', 13, '0')
          AND r.start_date = DATE '2026-03-10' AND r.status = 'active'
    ) OR (SELECT count(*) FROM rentals WHERE status = 'active'
          AND start_date >= DATE '2026-03-01' AND start_date < DATE '2026-04-01') < 3 THEN
        RAISE EXCEPTION 'Нет нужных учебных аренд/сотрудника: сначала выполните 01_seed.sql на базе ЛР1';
    END IF;
END $$;
\echo '1. INSERT: новый клиент и связанная аренда'
WITH new_client AS (
    INSERT INTO clients (full_name, passport, phone, license_number, birth_date)
    VALUES ('Демонстрационный клиент', 'LAB2-DEMO', '+79999999999', 'LAB2-DEMO', '1991-04-10')
    RETURNING client_id
)
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date, total_cost, status)
SELECT nc.client_id, c.car_id, e.employee_id, DATE '2030-01-01', DATE '2030-01-03', 5000, 'active'
FROM new_client nc
JOIN cars c ON c.vin = 'LAB2' || lpad('1', 13, '0')
JOIN LATERAL (SELECT employee_id FROM employees WHERE office_id = c.office_id AND is_active
              ORDER BY employee_id LIMIT 1) e ON TRUE
RETURNING *;

\echo '2. UPDATE: завершить существовавшую до демонстрации аренду'
UPDATE rentals r SET status = 'completed', actual_return_date = DATE '2026-03-14'
FROM cars c
WHERE c.car_id = r.car_id AND c.vin = 'LAB2' || lpad('1', 13, '0')
  AND r.start_date = DATE '2026-03-10' AND r.status = 'active'
RETURNING r.*;

\echo '3. Массовый UPDATE: скидка 10% на отменённые договоры не применяется; только активные'
UPDATE rentals SET total_cost = round(total_cost * 0.9, 2)
WHERE status = 'active' AND start_date >= DATE '2026-03-01'
  AND start_date < DATE '2026-04-01'
RETURNING rental_id, status, total_cost;

\echo '4. DELETE: сначала зависимая аренда, затем клиент (ON DELETE RESTRICT)'
DELETE FROM rentals WHERE client_id = (SELECT client_id FROM clients WHERE passport = 'LAB2-DEMO')
RETURNING rental_id;
DELETE FROM clients WHERE passport = 'LAB2-DEMO' RETURNING client_id;

\echo '5. ROLLBACK: отмена скидок и всех остальных изменений транзакции'
ROLLBACK;
SELECT count(*) AS demo_clients_after_rollback FROM clients WHERE passport = 'LAB2-DEMO';
