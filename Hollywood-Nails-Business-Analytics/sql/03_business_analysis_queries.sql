-- ============================================================
-- Hollywood Nails Business Analytics Queries
-- ============================================================

-- 1. Monthly revenue, completed visits, and average ticket
SELECT
    DATE_TRUNC('month', appointment_datetime)::date AS month,
    COUNT(*) AS completed_visits,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(total), 2) AS average_ticket
FROM vw_completed_appointments
GROUP BY 1
ORDER BY 1;

-- 2. Month-over-month revenue growth
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', appointment_datetime)::date AS month,
        SUM(total) AS revenue
    FROM vw_completed_appointments
    GROUP BY 1
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    ) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 3. Top services by revenue
SELECT
    service_name,
    category,
    COUNT(DISTINCT appointment_id) AS appointments,
    ROUND(SUM(service_revenue), 2) AS revenue,
    ROUND(SUM(estimated_service_cost), 2) AS estimated_cost,
    ROUND(SUM(service_revenue - estimated_service_cost), 2) AS estimated_gross_profit
FROM vw_service_sales
GROUP BY service_name, category
ORDER BY revenue DESC;

-- 4. Customer retention and repeat rate
WITH customer_visits AS (
    SELECT
        customer_id,
        COUNT(*) AS visit_count
    FROM vw_completed_appointments
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers_with_visits,
    COUNT(*) FILTER (WHERE visit_count >= 2) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE visit_count >= 2) / COUNT(*),
        2
    ) AS repeat_customer_rate_pct
FROM customer_visits;

-- 5. Top 20 customers by lifetime value
SELECT
    customer_id,
    first_name,
    last_name,
    completed_visits,
    ROUND(lifetime_value, 2) AS lifetime_value,
    ROUND(average_ticket, 2) AS average_ticket,
    last_visit
FROM vw_customer_summary
WHERE completed_visits > 0
ORDER BY lifetime_value DESC
LIMIT 20;

-- 6. Inactive customer re-engagement list
SELECT
    customer_id,
    first_name,
    last_name,
    completed_visits,
    ROUND(lifetime_value, 2) AS lifetime_value,
    last_visit,
    CURRENT_DATE - last_visit::date AS days_since_last_visit
FROM vw_customer_summary
WHERE last_visit IS NOT NULL
  AND CURRENT_DATE - last_visit::date >= 90
ORDER BY lifetime_value DESC;

-- 7. Peak weekday analysis
SELECT
    TO_CHAR(appointment_datetime, 'Day') AS weekday,
    EXTRACT(ISODOW FROM appointment_datetime) AS weekday_number,
    COUNT(*) AS completed_visits,
    ROUND(SUM(total), 2) AS revenue,
    ROUND(AVG(total), 2) AS average_ticket
FROM vw_completed_appointments
GROUP BY 1,2
ORDER BY 2;

-- 8. Peak hour analysis
SELECT
    EXTRACT(HOUR FROM appointment_datetime) AS hour_of_day,
    COUNT(*) AS completed_visits,
    ROUND(SUM(total), 2) AS revenue
FROM vw_completed_appointments
GROUP BY 1
ORDER BY 1;

-- 9. Cancellation and no-show rate
SELECT
    status,
    COUNT(*) AS appointment_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS appointment_share_pct
FROM appointments
GROUP BY status
ORDER BY appointment_count DESC;

-- 10. Booking source performance
SELECT
    a.booking_source,
    COUNT(*) AS total_appointments,
    COUNT(*) FILTER (WHERE a.status = 'Completed') AS completed_appointments,
    COUNT(*) FILTER (WHERE a.status IN ('Cancelled', 'No-show')) AS lost_appointments,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.status = 'Completed') / COUNT(*),
        2
    ) AS completion_rate_pct
FROM appointments a
GROUP BY a.booking_source
ORDER BY completed_appointments DESC;

-- 11. Employee productivity
SELECT
    e.employee_name,
    COUNT(v.appointment_id) AS completed_appointments,
    ROUND(SUM(v.total), 2) AS revenue,
    ROUND(AVG(v.total), 2) AS average_ticket,
    ROUND(SUM(v.tip), 2) AS tips
FROM employees e
LEFT JOIN vw_completed_appointments v
    ON e.employee_id = v.employee_id
GROUP BY e.employee_id, e.employee_name
ORDER BY revenue DESC NULLS LAST;

-- 12. Payment method mix
SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total), 2) AS revenue,
    ROUND(100.0 * SUM(total) / SUM(SUM(total)) OVER (), 2) AS revenue_share_pct
FROM vw_completed_appointments
GROUP BY payment_method
ORDER BY revenue DESC;

-- 13. Monthly purchasing spend
SELECT
    DATE_TRUNC('month', po.order_date)::date AS month,
    COUNT(DISTINCT po.purchase_order_id) AS purchase_orders,
    ROUND(SUM(poi.line_total), 2) AS purchasing_spend
FROM purchase_orders po
JOIN purchase_order_items poi
    ON po.purchase_order_id = poi.purchase_order_id
GROUP BY 1
ORDER BY 1;

-- 14. Supplier spend
SELECT
    v.vendor_name,
    COUNT(DISTINCT po.purchase_order_id) AS purchase_orders,
    ROUND(SUM(poi.line_total), 2) AS total_spend
FROM vendors v
JOIN purchase_orders po
    ON v.vendor_id = po.vendor_id
JOIN purchase_order_items poi
    ON po.purchase_order_id = poi.purchase_order_id
GROUP BY v.vendor_name
ORDER BY total_spend DESC;

-- 15. Inventory variance by product
SELECT
    p.product_name,
    COUNT(ic.inventory_count_id) AS inventory_counts,
    ROUND(AVG(ic.variance), 2) AS average_variance,
    ROUND(SUM(ABS(ic.variance)), 2) AS total_absolute_variance
FROM products p
JOIN inventory_counts ic
    ON p.product_id = ic.product_id
GROUP BY p.product_name
ORDER BY total_absolute_variance DESC;

-- 16. Products below reorder level in latest inventory count
WITH latest_counts AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        count_date,
        actual_quantity
    FROM inventory_counts
    ORDER BY product_id, count_date DESC
)
SELECT
    p.product_name,
    lc.count_date,
    lc.actual_quantity,
    p.reorder_level,
    (p.reorder_level - lc.actual_quantity) AS reorder_shortage
FROM products p
JOIN latest_counts lc
    ON p.product_id = lc.product_id
WHERE lc.actual_quantity < p.reorder_level
ORDER BY reorder_shortage DESC;

-- 17. Referral source customer value
SELECT
    referral_source,
    COUNT(*) FILTER (WHERE completed_visits > 0) AS customers,
    ROUND(SUM(lifetime_value), 2) AS lifetime_revenue,
    ROUND(AVG(lifetime_value) FILTER (WHERE completed_visits > 0), 2) AS avg_customer_value
FROM vw_customer_summary
GROUP BY referral_source
ORDER BY lifetime_revenue DESC;

-- 18. Estimated gross profit by month
SELECT
    DATE_TRUNC('month', appointment_datetime)::date AS month,
    ROUND(SUM(subtotal - discount), 2) AS net_service_revenue,
    ROUND(SUM(estimated_service_cost), 2) AS estimated_service_cost,
    ROUND(SUM(estimated_gross_profit), 2) AS estimated_gross_profit,
    ROUND(
        100.0 * SUM(estimated_gross_profit) / NULLIF(SUM(subtotal - discount),0),
        2
    ) AS estimated_gross_margin_pct
FROM vw_completed_appointments
GROUP BY 1
ORDER BY 1;
