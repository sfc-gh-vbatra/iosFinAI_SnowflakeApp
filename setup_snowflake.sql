-- Setup script for FinAI Snowflake Cortex AI Demo
-- Run this to create the necessary database and tables

-- Create database and schema
CREATE DATABASE IF NOT EXISTS FINAI_DB;
USE DATABASE FINAI_DB;

CREATE SCHEMA IF NOT EXISTS CORTEX_AI;
USE SCHEMA CORTEX_AI;

-- Create sample transactions table
CREATE OR REPLACE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    amount DECIMAL(10,2),
    merchant VARCHAR(200),
    merchant_category VARCHAR(100),
    location VARCHAR(200),
    transaction_time TIMESTAMP,
    card_type VARCHAR(50),
    is_fraud BOOLEAN DEFAULT FALSE,
    risk_score INTEGER DEFAULT 0
);

-- Create sample customers table
CREATE OR REPLACE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    date_of_birth DATE,
    annual_income DECIMAL(12,2),
    credit_score INTEGER,
    employment_status VARCHAR(50),
    employment_years INTEGER,
    debt_to_income_ratio DECIMAL(5,2),
    previous_defaults INTEGER DEFAULT 0,
    credit_utilization DECIMAL(5,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create market news table for sentiment analysis
CREATE OR REPLACE TABLE market_news (
    news_id VARCHAR(50) PRIMARY KEY,
    headline VARCHAR(500),
    content TEXT,
    source VARCHAR(200),
    publish_date TIMESTAMP,
    sector VARCHAR(100),
    sentiment_score DECIMAL(3,2),
    impact_level VARCHAR(20)
);

-- Insert sample transaction data
INSERT INTO transactions VALUES
('TXN001', 'CUST001', 125.00, 'Starbucks Coffee', 'Food & Dining', 'New York, NY', '2024-01-15 09:30:00', 'Credit', FALSE, 15),
('TXN002', 'CUST001', 2500.00, 'Apple Store', 'Electronics', 'New York, NY', '2024-01-15 14:20:00', 'Credit', FALSE, 25),
('TXN003', 'CUST002', 5000.00, 'Cash Advance ATM', 'Cash Advance', 'Miami, FL', '2024-01-15 23:45:00', 'Credit', TRUE, 95),
('TXN004', 'CUST003', 50.00, 'Gas Station', 'Gas & Automotive', 'Los Angeles, CA', '2024-01-16 08:15:00', 'Debit', FALSE, 10),
('TXN005', 'CUST002', 15000.00, 'Luxury Cars Inc', 'Automotive', 'Las Vegas, NV', '2024-01-16 16:30:00', 'Credit', TRUE, 90);

-- Insert sample customer data
INSERT INTO customers VALUES
('CUST001', 'John', 'Smith', 'john.smith@email.com', '555-0123', '123 Main St', 'New York', 'NY', '10001', '1985-03-15', 75000.00, 720, 'Full-time', 5, 25.0, 0, 15.0, '2020-01-01 00:00:00'),
('CUST002', 'Sarah', 'Johnson', 'sarah.j@email.com', '555-0456', '456 Oak Ave', 'Miami', 'FL', '33101', '1990-07-22', 45000.00, 650, 'Full-time', 3, 40.0, 1, 35.0, '2021-03-15 00:00:00'),
('CUST003', 'Mike', 'Davis', 'mike.davis@email.com', '555-0789', '789 Pine St', 'Los Angeles', 'CA', '90210', '1988-11-08', 95000.00, 780, 'Full-time', 7, 20.0, 0, 10.0, '2019-06-01 00:00:00');

-- Insert sample market news
INSERT INTO market_news VALUES
('NEWS001', 'Tech Stocks Rally on Strong Earnings', 'Major technology companies reported better-than-expected earnings for Q4, driving significant gains across the NASDAQ index. Apple, Microsoft, and Google led the charge with double-digit percentage increases.', 'Financial Times', '2024-01-16 08:00:00', 'Technology', 0.85, 'High'),
('NEWS002', 'Federal Reserve Signals Interest Rate Cuts', 'The Federal Reserve indicated potential interest rate cuts in the coming months, citing cooling inflation and economic stability concerns.', 'Reuters', '2024-01-16 10:30:00', 'Banking', 0.60, 'Medium'),
('NEWS003', 'Banking Sector Faces Regulatory Challenges', 'New regulatory requirements are expected to impact banking operations and profitability in the upcoming quarter.', 'Wall Street Journal', '2024-01-16 12:15:00', 'Banking', -0.40, 'Medium');

-- Grant necessary permissions for Cortex AI functions
-- Note: Ensure your role has USAGE privilege on Cortex AI functions
GRANT USAGE ON DATABASE FINAI_DB TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA CORTEX_AI TO ROLE SYSADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA CORTEX_AI TO ROLE SYSADMIN;

-- Verify Cortex AI availability
SELECT 'Cortex AI Setup Complete' as status;
