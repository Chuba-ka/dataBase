-- 1. Нарушение UNIQUE (паспорт уже существует)
INSERT INTO clients (full_name, passport, phone, license_number, birth_date)
VALUES ('Тестов Тест', '4510 123456', '+79991112233', '99 ХХ 999999', '1990-01-01');

-- 2. Нарушение CHECK (возраст < 18)
INSERT INTO clients (full_name, passport, phone, license_number, birth_date)
VALUES ('Молодой Клиент', '9999 888777', '+79992223344', '99 ЮЮ 888777', '2010-05-05');

-- 3. Нарушение CHECK (дата окончания раньше начала)
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date)
VALUES (1, 3, 1, '2025-10-10', '2025-10-05');

-- 4. Нарушение FOREIGN KEY (несуществующий client_id)
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date)
VALUES (999, 1, 1, '2025-10-01', '2025-10-05');

-- 5. Нарушение составного ограничения EXCLUDE (пересечение дат аренды одной машины)
INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date)
VALUES (4, 2, 2, '2025-09-12', '2025-09-18');  -- машина 2 уже арендована с 10 по 15 сентября