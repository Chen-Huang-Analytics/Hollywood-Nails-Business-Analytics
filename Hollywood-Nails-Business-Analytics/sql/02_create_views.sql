-- Analytical views

CREATE OR REPLACE VIEW vw_completed_appointments AS
SELECT
    a.appointment_id,
    a.customer_id,
    a.employee_id,
    a.appointment_datetime,
    a.booking_source,
    t.transaction_id,
    t.subtotal,
    t.discount,
    t.tax,
    t.tip,
    t.total,
    t.payment_method,
    t.estimated_service_cost,
    (t.subtotal - t.discount - t.estimated_service_cost) AS estimated_gross_profit
FROM appointments a
JOIN transactions t
    ON a.appointment_id = t.appointment_id
WHERE a.status = 'Completed';

CREATE OR REPLACE VIEW vw_service_sales AS
SELECT
    a.appointment_id,
    a.customer_id,
    a.employee_id,
    a.appointment_datetime,
    s.service_id,
    s.service_name,
    s.category,
    aps.quantity,
    aps.unit_price,
    (aps.quantity * aps.unit_price) AS service_revenue,
    (aps.quantity * s.estimated_supply_cost) AS estimated_service_cost
FROM appointment_services aps
JOIN appointments a
    ON aps.appointment_id = a.appointment_id
JOIN services s
    ON aps.service_id = s.service_id
WHERE a.status = 'Completed';

CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.join_date,
    c.referral_source,
    COUNT(v.appointment_id) AS completed_visits,
    COALESCE(SUM(v.total), 0) AS lifetime_value,
    COALESCE(AVG(v.total), 0) AS average_ticket,
    MIN(v.appointment_datetime) AS first_visit,
    MAX(v.appointment_datetime) AS last_visit
FROM customers c
LEFT JOIN vw_completed_appointments v
    ON c.customer_id = v.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.join_date, c.referral_source;
