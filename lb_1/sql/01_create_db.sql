-- Создание пользователя и базы данных
-- Выполнять от суперпользователя postgres:
-- sudo -u postgres psql -f sql/01_create_db.sql

CREATE USER car_rental_user WITH PASSWORD '123';

CREATE DATABASE car_rental OWNER car_rental_user;

GRANT ALL PRIVILEGES ON DATABASE car_rental TO car_rental_user;

-- Подключаемся к новой базе и даём права на схему
\c car_rental

GRANT ALL ON SCHEMA public TO car_rental_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO car_rental_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO car_rental_user;