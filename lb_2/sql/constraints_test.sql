\set ON_ERROR_STOP off

\echo Тест 1: UNIQUE: повторный паспорт
BEGIN;
INSERT INTO clients (full_name, passport, phone, license_number, birth_date) VALUES ('Тестов Тест', '4510 123456', '+79991112233', '99 ХХ 999999', '1990-01-01');
ROLLBACK;

\echo Тест 2: CHECK: клиент младше 18 лет
BEGIN;
INSERT INTO clients (full_name, passport, phone, license_number, birth_date) VALUES ('Молодой Клиент', '9999 888777', '+79992223344', '99 ЮЮ 888777', CURRENT_DATE - INTERVAL '17 years');
ROLLBACK;

\echo Тест 3: CHECK: окончание раньше начала
BEGIN;
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date, total_cost) VALUES (1, 3, 1, '2025-10-10', '2025-10-05', 1000);
ROLLBACK;

\echo Тест 4: FOREIGN KEY: несуществующий клиент
BEGIN;
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date, total_cost) VALUES (999, 1, 1, '2025-10-01', '2025-10-05', 10000);
ROLLBACK;

\echo Тест 5: EXCLUDE: пересечение аренд автомобиля 2
BEGIN;
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date, total_cost) VALUES (4, 2, 2, '2025-09-12', '2025-09-18', 27000);
ROLLBACK;

\echo Тест 6: CHECK: отрицательная стоимость
BEGIN;
UPDATE rentals SET total_cost = -100 WHERE rental_id = 1;
ROLLBACK;

\echo Тест 7: CHECK: возврат раньше начала
BEGIN;
UPDATE rentals SET actual_return_date = '2025-08-31' WHERE rental_id = 1;
ROLLBACK;

\echo Тест 8: CHECK: завершение без даты возврата
BEGIN;
UPDATE rentals SET actual_return_date = NULL WHERE rental_id = 1;
ROLLBACK;

\echo Тест 9: NOT NULL: отсутствует марка
BEGIN;
UPDATE cars SET brand = NULL WHERE car_id = 1;
ROLLBACK;
