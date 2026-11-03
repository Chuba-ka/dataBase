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
    daily_rate     NUMERIC(10,2) NOT NULL
);

CREATE TABLE clients (
    client_id          SERIAL PRIMARY KEY,
    full_name          VARCHAR(100) NOT NULL,
    passport           VARCHAR(20)  NOT NULL UNIQUE,
    phone              VARCHAR(20)  NOT NULL UNIQUE,
    email              VARCHAR(100),
    license_number     VARCHAR(20)  NOT NULL UNIQUE,
    birth_date         DATE         NOT NULL,
    registration_date  DATE         NOT NULL DEFAULT CURRENT_DATE
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
    status         VARCHAR(20)  NOT NULL DEFAULT 'available'
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
    status              VARCHAR(20)  NOT NULL DEFAULT 'active'
);
