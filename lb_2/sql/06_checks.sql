\set ON_ERROR_STOP on
DO $$
DECLARE n integer;
BEGIN
    SELECT (SELECT count(*) FROM offices) + (SELECT count(*) FROM car_categories)
         + (SELECT count(*) FROM clients) + (SELECT count(*) FROM employees)
         + (SELECT count(*) FROM cars) + (SELECT count(*) FROM rentals) INTO n;
    IF n < 100 THEN RAISE EXCEPTION 'Всего строк: %, требуется >= 100', n; END IF;
    IF (SELECT count(*) FROM rentals) < 30 THEN RAISE EXCEPTION 'Недостаточно аренд'; END IF;
    IF (SELECT count(DISTINCT status) FROM rentals) < 3 THEN RAISE EXCEPTION 'Недостаточно состояний'; END IF;
    IF (SELECT count(DISTINCT date_trunc('month', start_date)) FROM rentals) < 3
       THEN RAISE EXCEPTION 'Недостаточно месяцев'; END IF;
    IF NOT EXISTS (SELECT 1 FROM rentals GROUP BY client_id HAVING count(*) > 1)
       THEN RAISE EXCEPTION 'Нет повторных аренд'; END IF;
    IF NOT EXISTS (SELECT 1 FROM clients c WHERE NOT EXISTS
                  (SELECT 1 FROM rentals r WHERE r.client_id = c.client_id))
       THEN RAISE EXCEPTION 'Нет клиентов без аренд'; END IF;
    IF NOT EXISTS (SELECT 1 FROM cars c WHERE NOT EXISTS
                  (SELECT 1 FROM rentals r WHERE r.car_id = c.car_id))
       THEN RAISE EXCEPTION 'Нет машин без аренд'; END IF;
    IF NOT EXISTS (SELECT 1 FROM rentals WHERE total_cost = 0)
       OR NOT EXISTS (SELECT 1 FROM cars WHERE mileage = 0)
       OR NOT EXISTS (SELECT 1 FROM clients WHERE email IS NULL)
       THEN RAISE EXCEPTION 'Нет пограничных значений'; END IF;
    IF EXISTS (SELECT 1 FROM clients WHERE passport = 'LAB2-DEMO')
       THEN RAISE EXCEPTION 'Демонстрационные данные не удалены'; END IF;
    RAISE NOTICE 'Требования к набору данных выполнены, всего строк: %', n;
END $$;

CREATE TEMP TABLE dml_snapshot AS
SELECT 'clients' AS entity, to_jsonb(c) AS row_data FROM clients c
UNION ALL SELECT 'rentals', to_jsonb(r) FROM rentals r;
\ir 02_dml.sql
DO $$
BEGIN
    IF EXISTS (
        WITH after_dml AS (
            SELECT 'clients' AS entity, to_jsonb(c) AS row_data FROM clients c
            UNION ALL SELECT 'rentals', to_jsonb(r) FROM rentals r
        )
        (SELECT * FROM dml_snapshot EXCEPT ALL SELECT * FROM after_dml)
        UNION ALL
        (SELECT * FROM after_dml EXCEPT ALL SELECT * FROM dml_snapshot)
    ) THEN RAISE EXCEPTION 'ROLLBACK не восстановил исходные строки'; END IF;
    RAISE NOTICE 'ROLLBACK проверен: строки клиентов и аренд полностью совпадают';
END $$;
DROP TABLE dml_snapshot;

CREATE TEMP VIEW all_lab_rows AS
SELECT 'offices' AS entity, to_jsonb(t) AS row_data FROM offices t
UNION ALL SELECT 'car_categories', to_jsonb(t) FROM car_categories t
UNION ALL SELECT 'clients', to_jsonb(t) FROM clients t
UNION ALL SELECT 'employees', to_jsonb(t) FROM employees t
UNION ALL SELECT 'cars', to_jsonb(t) FROM cars t
UNION ALL SELECT 'rentals', to_jsonb(t) FROM rentals t;
CREATE TEMP TABLE seed_snapshot AS SELECT * FROM all_lab_rows;
\ir 01_seed.sql
DO $$
BEGIN
    IF EXISTS (
        (SELECT * FROM seed_snapshot EXCEPT ALL SELECT * FROM all_lab_rows)
        UNION ALL
        (SELECT * FROM all_lab_rows EXCEPT ALL SELECT * FROM seed_snapshot)
    ) THEN RAISE EXCEPTION 'Повторная загрузка изменила строки'; END IF;
    RAISE NOTICE 'Повторная загрузка проверена: строки всех шести таблиц совпадают';
END $$;
DROP TABLE seed_snapshot;
DROP VIEW all_lab_rows;
