\set ON_ERROR_STOP on

BEGIN;

INSERT INTO offices (city, address, phone) VALUES
('Москва', 'ул. Тверская, 12', '+74951234567'),
('Санкт-Петербург', 'Невский пр., 28', '+78123456789'),
('Казань', 'ул. Баумана, 5', '+78431234567');

INSERT INTO car_categories (name, description, daily_rate) VALUES
('Эконом', 'Небольшие городские автомобили', 2500.00),
('Комфорт', 'Седаны среднего класса', 4500.00),
('Бизнес', 'Представительский класс', 8000.00),
('SUV', 'Кроссоверы и внедорожники', 6000.00);

INSERT INTO clients (full_name, passport, phone, email, license_number, birth_date) VALUES
('Иванов Иван Иванович', '4510 123456', '+79001234567', 'ivanov@mail.ru', '77 АА 123456', '1990-05-15'),
('Петрова Анна Сергеевна', '4511 654321', '+79007654321', 'petrova@gmail.com', '78 ВВ 654321', '1985-11-20'),
('Сидоров Алексей', '4509 987654', '+79161234567', NULL, '77 СС 987654', '1995-03-10'),
('Козлова Мария', '4512 111222', '+79261234567', 'kozlova@yandex.ru', '50 ММ 111222', '1992-07-25'),
('Морозов Дмитрий', '4513 333444', '+79361234567', 'morozov@mail.ru', '77 ДД 333444', '1988-01-30');

INSERT INTO employees (office_id, full_name, position, phone) VALUES
(1, 'Смирнов Андрей', 'Менеджер', '+79031112233'),
(1, 'Кузнецова Елена', 'Оператор', '+79032223344'),
(2, 'Васильев Павел', 'Менеджер', '+79043334455'),
(3, 'Новикова Ольга', 'Оператор', '+79054445566');

INSERT INTO cars (category_id, office_id, brand, model, plate_number, vin, year, color, mileage, status) VALUES
(1, 1, 'Kia', 'Rio', 'А123ВС77', 'Z94C241BBLR123456', 2021, 'белый', 45000, 'available'),
(2, 1, 'Toyota', 'Camry', 'В456ОР77', 'JTDBR32E700123456', 2022, 'чёрный', 32000, 'available'),
(3, 1, 'Mercedes-Benz', 'E-Class', 'С789ТУ77', 'WDD2130421A123456', 2023, 'серый', 15000, 'available'),
(4, 2, 'Hyundai', 'Tucson', 'Е321КХ178', 'TMAJ3812AJ0123456', 2021, 'синий', 58000, 'available'),
(1, 2, 'Volkswagen', 'Polo', 'К654МН178', 'XW8ZZZ61ZLG123456', 2020, 'красный', 72000, 'available'),
(2, 3, 'Skoda', 'Octavia', 'М987ОР16', 'TMBBG61Z1L2123456', 2022, 'серебристый', 28000, 'available');

INSERT INTO rentals (client_id, car_id, employee_id, start_date, end_date, actual_return_date, total_cost, status) VALUES
(1, 1, 1, '2025-09-01', '2025-09-05', '2025-09-05', 10000.00, 'completed'),
(2, 2, 1, '2025-09-10', '2025-09-15', '2025-09-15', 22500.00, 'completed'),
(3, 4, 3, '2025-09-12', '2025-09-20', '2025-09-20', 48000.00, 'completed'),
(4, 2, 2, '2025-09-12', '2025-09-18', NULL, 27000.00, 'cancelled');

COMMIT;
