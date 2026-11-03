\set ON_ERROR_STOP on

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE offices (
    office_id      SERIAL PRIMARY KEY,
    city           VARCHAR(50)  NOT NULL,
    address        VARCHAR(150) NOT NULL,
    phone          VARCHAR(20)  NOT NULL UNIQUE,
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE car_categories (
    category_id    SERIAL PRIMARY KEY,
    name           VARCHAR(50)  NOT NULL UNIQUE,
    description    TEXT,
    daily_rate     NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_daily_rate CHECK (daily_rate > 0)
);

CREATE TABLE clients (
    client_id          SERIAL PRIMARY KEY,
    full_name          VARCHAR(100) NOT NULL,
    passport           VARCHAR(20)  NOT NULL UNIQUE,
    phone              VARCHAR(20)  NOT NULL UNIQUE,
    email              VARCHAR(100),
    license_number     VARCHAR(20)  NOT NULL UNIQUE,
    birth_date         DATE         NOT NULL,
    registration_date  DATE         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_client_age CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years')
);

CREATE TABLE employees (
    employee_id    SERIAL PRIMARY KEY,
    office_id      INTEGER      NOT NULL REFERENCES offices(office_id) ON DELETE RESTRICT,
    full_name      VARCHAR(100) NOT NULL,
    position       VARCHAR(50)  NOT NULL,
    phone          VARCHAR(20)  NOT NULL UNIQUE,
    hire_date      DATE         NOT NULL DEFAULT CURRENT_DATE,
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE cars (
    car_id         SERIAL PRIMARY KEY,
    category_id    INTEGER      NOT NULL REFERENCES car_categories(category_id) ON DELETE RESTRICT,
    office_id      INTEGER      NOT NULL REFERENCES offices(office_id) ON DELETE RESTRICT,
    brand          VARCHAR(50)  NOT NULL,
    model          VARCHAR(50)  NOT NULL,
    plate_number   VARCHAR(15)  NOT NULL UNIQUE,
    vin            VARCHAR(17)  NOT NULL UNIQUE,
    year           INTEGER      NOT NULL,
    color          VARCHAR(30)  NOT NULL,
    mileage        INTEGER      NOT NULL DEFAULT 0,
    status         VARCHAR(20)  NOT NULL DEFAULT 'available',
    CONSTRAINT chk_car_year CHECK (year BETWEEN 2000 AND 2100),
    CONSTRAINT chk_car_vin CHECK (length(vin) = 17),
    CONSTRAINT chk_car_mileage CHECK (mileage >= 0),
    CONSTRAINT chk_car_status CHECK (status IN ('available', 'maintenance', 'retired'))
);

CREATE TABLE rentals (
    rental_id           SERIAL PRIMARY KEY,
    client_id           INTEGER      NOT NULL REFERENCES clients(client_id) ON DELETE RESTRICT,
    car_id              INTEGER      NOT NULL REFERENCES cars(car_id) ON DELETE RESTRICT,
    employee_id         INTEGER      NOT NULL REFERENCES employees(employee_id) ON DELETE RESTRICT,
    start_date          DATE         NOT NULL,
    end_date            DATE         NOT NULL,
    actual_return_date  DATE,
    total_cost          NUMERIC(12,2) NOT NULL,
    status              VARCHAR(20)  NOT NULL DEFAULT 'active',
    CONSTRAINT chk_rental_dates CHECK (end_date > start_date),
    CONSTRAINT chk_rental_cost CHECK (total_cost >= 0),
    CONSTRAINT chk_return_date CHECK (actual_return_date IS NULL OR actual_return_date >= start_date),
    CONSTRAINT chk_rental_return_status CHECK (
        (status = 'completed' AND actual_return_date IS NOT NULL)
        OR (status <> 'completed' AND actual_return_date IS NULL)
    ),
    CONSTRAINT chk_rental_status CHECK (status IN ('active', 'completed', 'cancelled', 'overdue')),
    CONSTRAINT unique_car_period EXCLUDE USING gist (
        car_id WITH =,
        daterange(start_date, COALESCE(actual_return_date, end_date), '[)') WITH &&
    ) WHERE (status <> 'cancelled')
);
COMMIT;
