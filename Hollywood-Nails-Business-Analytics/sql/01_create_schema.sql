-- Hollywood Nails Business Analytics Portfolio
-- PostgreSQL schema
-- Synthetic portfolio project prepared for Chen Chung Huang

DROP TABLE IF EXISTS inventory_usage CASCADE;
DROP TABLE IF EXISTS inventory_counts CASCADE;
DROP TABLE IF EXISTS purchase_order_items CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS appointment_services CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120),
    phone VARCHAR(30),
    join_date DATE NOT NULL,
    referral_source VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    position VARCHAR(80),
    hire_date DATE,
    status VARCHAR(20)
);

CREATE TABLE services (
    service_id INTEGER PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(10,2) NOT NULL,
    duration_minutes INTEGER,
    estimated_supply_cost NUMERIC(10,2)
);

CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    appointment_datetime TIMESTAMP NOT NULL,
    status VARCHAR(20),
    booking_source VARCHAR(30)
);

CREATE TABLE appointment_services (
    appointment_service_id INTEGER PRIMARY KEY,
    appointment_id INTEGER REFERENCES appointments(appointment_id),
    service_id INTEGER REFERENCES services(service_id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    appointment_id INTEGER UNIQUE REFERENCES appointments(appointment_id),
    subtotal NUMERIC(10,2),
    discount NUMERIC(10,2),
    tax NUMERIC(10,2),
    tip NUMERIC(10,2),
    total NUMERIC(10,2),
    payment_method VARCHAR(30),
    estimated_service_cost NUMERIC(10,2)
);

CREATE TABLE vendors (
    vendor_id INTEGER PRIMARY KEY,
    vendor_name VARCHAR(120) NOT NULL,
    category VARCHAR(80),
    location VARCHAR(100)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(50),
    unit_cost NUMERIC(10,2),
    starting_stock NUMERIC(12,2),
    reorder_level NUMERIC(12,2),
    vendor_id INTEGER REFERENCES vendors(vendor_id)
);

CREATE TABLE purchase_orders (
    purchase_order_id INTEGER PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(vendor_id),
    order_date DATE NOT NULL,
    status VARCHAR(30)
);

CREATE TABLE purchase_order_items (
    purchase_order_item_id INTEGER PRIMARY KEY,
    purchase_order_id INTEGER REFERENCES purchase_orders(purchase_order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity NUMERIC(12,2),
    unit_cost NUMERIC(10,2),
    line_total NUMERIC(12,2)
);

CREATE TABLE inventory_counts (
    inventory_count_id INTEGER PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    count_date DATE NOT NULL,
    expected_quantity NUMERIC(12,2),
    actual_quantity NUMERIC(12,2),
    variance NUMERIC(12,2)
);

CREATE TABLE inventory_usage (
    inventory_usage_id INTEGER PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    month VARCHAR(7),
    estimated_quantity_used NUMERIC(12,2),
    method VARCHAR(150)
);

CREATE INDEX idx_appointments_customer ON appointments(customer_id);
CREATE INDEX idx_appointments_employee ON appointments(employee_id);
CREATE INDEX idx_appointments_datetime ON appointments(appointment_datetime);
CREATE INDEX idx_transactions_appointment ON transactions(appointment_id);
CREATE INDEX idx_appointment_services_appointment ON appointment_services(appointment_id);
CREATE INDEX idx_appointment_services_service ON appointment_services(service_id);
CREATE INDEX idx_purchase_orders_date ON purchase_orders(order_date);
CREATE INDEX idx_inventory_counts_date ON inventory_counts(count_date);
