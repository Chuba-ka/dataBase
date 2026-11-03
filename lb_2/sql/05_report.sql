\set ON_ERROR_STOP on
WITH
params AS (
    SELECT DATE '2026-01-01' AS date_from, DATE '2026-04-01' AS date_to
),
months AS (
    SELECT generate_series(date_from::timestamp, (date_to - INTERVAL '1 month')::timestamp,
                           INTERVAL '1 month')::date AS month FROM params
),
source_data AS (
    SELECT c.office_id, r.*, date_trunc('month', r.start_date)::date AS month
    FROM rentals r JOIN cars c ON c.car_id = r.car_id CROSS JOIN params p
    WHERE r.start_date >= p.date_from AND r.start_date < p.date_to
),
indicators AS (
    SELECT *, CASE WHEN status = 'completed' THEN total_cost ELSE 0 END AS completed_amount,
           CASE WHEN status = 'completed'
                THEN greatest(actual_return_date - end_date, 0) ELSE 0 END AS late_days
    FROM source_data
),
monthly AS (
    SELECT office_id, month, count(*) AS contracts,
           count(*) FILTER (WHERE status = 'completed') AS completed,
           count(*) FILTER (WHERE status = 'cancelled') AS cancelled,
           count(*) FILTER (WHERE status IN ('active', 'overdue')) AS open_contracts,
           count(DISTINCT client_id) AS clients,
           sum(completed_amount) AS completed_amount, sum(late_days) AS late_days,
           round(avg(total_cost) FILTER (WHERE status = 'completed'), 2) AS average_completed_cost
    FROM indicators GROUP BY office_id, month
),
office_months AS (
    SELECT o.office_id, o.city, m.month,
           coalesce(a.contracts, 0) AS contracts, coalesce(a.completed, 0) AS completed,
           coalesce(a.cancelled, 0) AS cancelled, coalesce(a.open_contracts, 0) AS open_contracts,
           coalesce(a.clients, 0) AS clients, coalesce(a.completed_amount, 0) AS completed_amount,
           coalesce(a.late_days, 0) AS late_days, a.average_completed_cost
    FROM offices o CROSS JOIN months m
    LEFT JOIN monthly a ON a.office_id = o.office_id AND a.month = m.month
),
comparison AS (
    SELECT *, lag(completed_amount) OVER (PARTITION BY office_id ORDER BY month) AS previous_amount
    FROM office_months
)
SELECT office_id, city, month, contracts, completed, cancelled, open_contracts, clients,
       completed_amount, average_completed_cost, late_days,
       round(100.0 * cancelled / nullif(contracts, 0), 2) AS cancelled_pct,
       completed_amount - previous_amount AS amount_change,
       round(100.0 * (completed_amount - previous_amount) / nullif(previous_amount, 0), 2) AS growth_pct
FROM comparison ORDER BY office_id, month;
