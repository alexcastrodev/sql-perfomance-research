INSERT INTO users (username, email, password_hash, registration_date) VALUES
  ('john_doe', 'john.doe@example.com', 'hashed_password_1', '2023-07-30 12:34:56'),
  ('jane_smith', 'jane.smith@example.com', 'hashed_password_2', '2023-07-29 10:20:30'),
  ('bob_johnson', 'bob.johnson@example.com', 'hashed_password_3', '2023-07-28 15:45:55');

INSERT INTO bookings (user_id, booking_date, booking_status) VALUES
  (1, '2023-08-15 10:00:00', 'confirmed'),
  (2, '2023-08-20 14:30:00', 'pending'),
  (3, '2023-08-25 09:45:00', 'canceled');

INSERT INTO customers (user_id, customer_name, address, phone_number) VALUES
  (1, 'John Doe', '123 Main St, Cityville', '555-1234'),
  (2, 'Jane Smith', '456 Park Ave, Townsville', '555-5678'),
  (3, 'Bob Johnson', '789 Oak Rd, Villagetown', '555-9876');

INSERT INTO inventory (item_name, description, quantity, price) VALUES
  ('Widget', 'A small widget', 100, 9.99),
  ('Gadget', 'A cool gadget', 50, 19.99),
  ('Thingamajig', 'A mysterious thingamajig', 20, 29.99);

INSERT INTO inquiries (user_id, inquiry_date, message) VALUES
  (1, '2023-07-31 08:45:00', 'Hello, I have a question about your products.'),
  (2, '2023-07-31 10:15:00', 'Is there a discount for bulk orders?');