INSERT INTO patient_feedback (patient_id, department, feedback_text, feedback_date)
VALUES
(101, 'Cardiology', 'The doctor was excellent but the waiting time was too long.', '2025-10-01'),
(102, 'Neurology', 'Staff were very polite. Clean and well managed.', '2025-10-03'),
(103, 'Orthopedics', 'I had to wait for an hour. Need better scheduling.', '2025-10-05'),
(104, 'Cardiology', 'The treatment was great and staff were supportive.', '2025-10-08'),
(105, 'Pediatrics', 'The pediatrician was very kind and explained everything well.', '2025-10-10');

INSERT INTO hospital_services (department, avg_wait_time_mins, doctor_name, satisfaction_score)
VALUES
('Cardiology', 45, 'Dr. Sharma', 4.5),
('Neurology', 30, 'Dr. Menon', 4.8),
('Orthopedics', 60, 'Dr. Gupta', 3.9),
('Pediatrics', 25, 'Dr. Reddy', 4.9);
