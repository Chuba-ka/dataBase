\set ON_ERROR_STOP on
BEGIN;
DO $$
BEGIN
    IF (SELECT count(*) FROM car_categories
        WHERE name IN ('Эконом', 'Комфорт', 'Бизнес', 'SUV')) <> 4 THEN
        RAISE EXCEPTION 'Нужны все четыре категории из sql/data.sql ЛР1';
    END IF;
    IF (SELECT count(*) FROM offices
        WHERE phone IN ('+74951234567', '+78123456789', '+78431234567')) <> 3 THEN
        RAISE EXCEPTION 'Нужны все три офиса из sql/data.sql ЛР1';
    END IF;
    IF EXISTS (SELECT 1 FROM offices o
               WHERE o.phone IN ('+74951234567', '+78123456789', '+78431234567')
                 AND NOT EXISTS (SELECT 1 FROM employees e
                                 WHERE e.office_id = o.office_id AND e.is_active)) THEN
        RAISE EXCEPTION 'В каждом исходном офисе нужен действующий сотрудник';
    END IF;
END $$;
INSERT INTO clients (full_name, passport, phone, email, license_number, birth_date, registration_date)
SELECT 'Клиент ЛР2 №' || n, 'LAB2-P-' || n, '+7999000' || lpad(n::text, 4, '0'),
       CASE WHEN n % 3 = 0 THEN NULL ELSE 'client' || n || '@example.org' END,
       'LAB2-L-' || n, DATE '1990-01-01' + n, DATE '2025-12-01'
FROM generate_series(1, 20) AS g(n)
ON CONFLICT (passport) DO NOTHING;

INSERT INTO cars (category_id, office_id, brand, model, plate_number, vin, year, color, mileage, status)
SELECT cat.category_id, o.office_id, 'Lada', 'Vesta ЛР2 ' || n,
       'ЛР2-' || n, 'LAB2' || lpad(n::text, 13, '0'), 2025, 'белый',
       CASE WHEN n = 10 THEN 0 ELSE n * 3000 END,
       CASE WHEN n = 9 THEN 'maintenance' ELSE 'available' END
FROM generate_series(1, 10) AS g(n)
JOIN car_categories cat ON cat.name = (ARRAY['Эконом','Комфорт','Бизнес','SUV'])[1 + (n - 1) % 4]
JOIN offices o ON o.phone = (ARRAY['+74951234567','+78123456789','+78431234567'])[1 + (n - 1) % 3]
ON CONFLICT (vin) DO NOTHING;

INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date,
                     actual_return_date, total_cost, status)
SELECT cl.client_id, c.car_id, e.employee_id, d.start_date, d.start_date + 4,
       CASE WHEN s.status = 'completed' THEN d.start_date +
            CASE WHEN n % 3 = 0 THEN 5 WHEN n % 3 = 1 THEN 3 ELSE 4 END END,
       CASE WHEN n = 1 AND m = 0 AND k = 0 THEN 0 ELSE cat.daily_rate * 4 END,
       s.status
FROM generate_series(1, 8) AS g(n)
CROSS JOIN generate_series(0, 2) AS months(m)
CROSS JOIN generate_series(0, 2) AS slots(k)
JOIN cars c ON c.vin = 'LAB2' || lpad(n::text, 13, '0')
JOIN car_categories cat ON cat.category_id = c.category_id
JOIN clients cl ON cl.passport = 'LAB2-P-' || (1 + (n + m + k - 1) % 16)
JOIN LATERAL (SELECT employee_id FROM employees
              WHERE office_id = c.office_id AND is_active ORDER BY employee_id LIMIT 1) e ON TRUE
CROSS JOIN LATERAL (SELECT (DATE '2026-01-01' + make_interval(months => m)
                            + k * INTERVAL '9 days')::date AS start_date) d
CROSS JOIN LATERAL (SELECT CASE WHEN k = 2 THEN 'cancelled'
                       WHEN m = 2 AND k = 1 AND n % 2 = 0 THEN 'overdue'
                       WHEN m = 2 AND k = 1 THEN 'active'
                       ELSE 'completed' END AS status) s
WHERE NOT EXISTS (SELECT 1 FROM rentals r
                  WHERE r.car_id = c.car_id AND r.start_date = d.start_date);
COMMIT;
