-- Create a new database
CREATE OR REPLACE DATABASE healthcare_db;

-- Create a schema
CREATE OR REPLACE SCHEMA cortex_demo;

-- Use the schema
USE SCHEMA healthcare_db.cortex_demo;

-- Create a table for patient feedback
CREATE OR REPLACE TABLE patient_feedback (
    feedback_id INT AUTOINCREMENT,
    patient_id INT,
    department STRING,
    feedback_text STRING,
    feedback_date DATE
);

-- Create a table for hospital services
CREATE OR REPLACE TABLE hospital_services (
    department STRING,
    avg_wait_time_mins INT,
    doctor_name STRING,
    satisfaction_score FLOAT
);
