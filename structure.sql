CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  registration_date TIMESTAMP DEFAULT NOW() NOT NULL
);
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  booking_date TIMESTAMP NOT NULL,
  booking_status VARCHAR(20) NOT NULL,
);
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  customer_name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
);
CREATE TABLE inventory (
  item_id SERIAL PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  description TEXT,
  quantity INTEGER NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
);
CREATE TABLE inquiries (
  inquiry_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  inquiry_date TIMESTAMP NOT NULL,
  message TEXT NOT NULL,
);