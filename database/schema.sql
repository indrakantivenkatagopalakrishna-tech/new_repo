-- PostgreSQL Database Schema for Temple/Pooja Booking System
-- Database: Neon PostgreSQL

-- Enable UUID extension if needed (optional)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table (Customers)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for user email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 2. Slots Table (Available pooja timings)
CREATE TABLE IF NOT EXISTS slots (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_bookings INTEGER DEFAULT 1,
    current_bookings INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_date_slot UNIQUE (date, start_time, end_time)
);

-- Index for querying slots by date
CREATE INDEX IF NOT EXISTS idx_slots_date ON slots(date);

-- 3. Bookings Table (Customer booking records)
CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    slot_id INTEGER REFERENCES slots(id) ON DELETE RESTRICT,
    booking_date DATE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    pooja_name VARCHAR(255) NOT NULL,
    gotra VARCHAR(100),
    rashi VARCHAR(100),
    status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, cancelled
    payment_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for searching bookings
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(booking_date);
CREATE INDEX IF NOT EXISTS idx_bookings_phone ON bookings(customer_phone);

-- 4. Payments Table (Razorpay transactions)
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES bookings(id) ON DELETE CASCADE,
    transaction_id VARCHAR(255),
    razorpay_order_id VARCHAR(255) UNIQUE NOT NULL,
    razorpay_payment_id VARCHAR(255),
    razorpay_signature VARCHAR(255),
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, captured, failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for orders lookup
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(razorpay_order_id);

-- 5. Admin Users Table (Admin portal / app authentication)
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed initial admin user
-- Default Credentials: Username: admin, Password: AdminPass123!
-- password_hash is pre-generated using bcrypt (salt rounds = 10)
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('admin', '$2a$10$w8TbeH1DkEsw/tVq7P4GfOszM.1ZJz6b45yTus2Zlhg89Hq6bL7Xq', 'admin')
ON CONFLICT (username) DO NOTHING;

-- 6. Monthly Revenue View
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT 
    TO_CHAR(created_at, 'YYYY-MM') AS month,
    SUM(amount) AS total_revenue,
    COUNT(id) AS total_transactions
FROM payments
WHERE status = 'captured'
GROUP BY TO_CHAR(created_at, 'YYYY-MM');

