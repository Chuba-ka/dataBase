# Сервис аренды автомобилей — Лабораторная работа №1

## Быстрый запуск

### 1. Создание пользователя и базы (один раз)

```bash
sudo -u postgres psql -f sql/01_create_db.sql
```

### 2. Создание таблиц

```bash
psql -U car_rental_user -d car_rental -h localhost -f sql/02_create_tables.sql
```

### 3. Заполнение тестовыми данными

```bash
psql -U car_rental_user -d car_rental -h localhost -f sql/03_insert_data.sql
```

### 4. Проверка ограничений целостности

```bash
psql -U car_rental_user -d car_rental -h localhost -f sql/04_test_constraints.sql
```

---

## Полезные команды

**Подключение к базе:**
```bash
psql -U car_rental_user -d car_rental -h localhost
```

**Количество записей во всех таблицах:**
```sql
SELECT 'offices' AS table_name, COUNT(*) FROM offices
UNION ALL SELECT 'car_categories', COUNT(*) FROM car_categories
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'cars', COUNT(*) FROM cars
UNION ALL SELECT 'rentals', COUNT(*) FROM rentals;
```

**Полный сброс базы (удаление всех таблиц):**
```bash
psql -U car_rental_user -d car_rental -h localhost -c "
DROP TABLE IF EXISTS rentals, cars, employees, clients, car_categories, offices CASCADE;
"
```

---

## Структура проекта

```
dataBase/
├── sql/
│   ├── 01_create_db.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_data.sql
│   └── 04_test_constraints.sql
└── README.md
```
