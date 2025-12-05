-- ============================
-- V1__init.sql - UPDATED
-- Mini-Ecommerce with Advanced Payment & Shipping
-- ============================

-- USERS
CREATE TABLE users
(
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255)              NOT NULL,
    role       VARCHAR(20)               NOT NULL,
    email      VARCHAR(255)              NOT NULL UNIQUE,
    password   VARCHAR(255)              NOT NULL,
    created_at DATETIME                           DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME                           DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME                           DEFAULT NULL
);


-- CATEGORIES
CREATE TABLE categories
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at  DATETIME DEFAULT NULL
);

-- PRODUCTS
CREATE TABLE products
(
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255)   NOT NULL,
    description    TEXT,
    price          DECIMAL(12, 2) DEFAULT 0 NOT NULL,
    stock_quantity INT            DEFAULT 0 NOT NULL,
    category_id    BIGINT NOT NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at     DATETIME DEFAULT NULL,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories (id)
);

-- ORDERS (UPDATED with COMPLETED status)
CREATE TABLE orders
(
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id      BIGINT NOT NULL,
    total_amount DECIMAL(12, 2)                                                      NOT NULL,
    status       ENUM ('CREATED','PENDING_SHIPMENT','PENDING_PAYMENT','COMPLETED','CANCELLED') NOT NULL DEFAULT 'CREATED',
    created_at   DATETIME                                                                     DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME                                                                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at   DATETIME                                                                     DEFAULT NULL,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users (id)
);

-- ORDER ITEMS
CREATE TABLE order_items
(
    order_id   BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity   INT   DEFAULT 1         NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id) REFERENCES orders (id),
    CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id) REFERENCES products (id)
);

-- PAYMENTS (UPDATED with advanced fields)
CREATE TABLE payments
(
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT,
    amount          DECIMAL(12, 2)                          NOT NULL,
    payment_method  VARCHAR(100)                            NOT NULL,
    status          ENUM ('PENDING','SUCCESS','FAILED')     NOT NULL DEFAULT 'PENDING',
    paid_at         DATETIME                                         DEFAULT NULL,
    created_at      DATETIME                                         DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      DATETIME                                         DEFAULT NULL,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders (id),
    INDEX idx_payment_method (payment_method),
    INDEX idx_payment_status (status),
    INDEX idx_payment_created (created_at)
);

-- SHIPMENTS (UPDATED with advanced fields, renamed from SHIPPINGS)
CREATE TABLE shipments
(
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id             BIGINT,
    carrier_name         VARCHAR(100)                               NOT NULL,
    tracking_number      VARCHAR(100)                                        DEFAULT NULL,
    delivery_address     VARCHAR(255),
    city                 VARCHAR(100),
    postal_code          VARCHAR(50),
    country              VARCHAR(100),
    shipping_cost        DECIMAL(12, 2)                                     DEFAULT 0,
    status               ENUM ('PROCESSING','SHIPPED','IN_TRANSIT','DELIVERED','LOST','DAMAGED','CANCELLED') NOT NULL DEFAULT 'PROCESSING',
    shipped_at           DATETIME                                           DEFAULT NULL,
    expected_delivery_date DATETIME                                          DEFAULT NULL,
    delivered_at         DATETIME                                           DEFAULT NULL,
    notes                VARCHAR(255)                                       DEFAULT NULL,
    created_at           DATETIME                                           DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME                                           DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at           DATETIME                                           DEFAULT NULL,
    CONSTRAINT fk_shipment_order FOREIGN KEY (order_id) REFERENCES orders (id),
    INDEX idx_carrier (carrier_name),
    INDEX idx_status (status),
    INDEX idx_shipped_at (shipped_at)
);





-- ============================
-- SAMPLE DATA
-- ============================

-- USERS
INSERT INTO users (name, role , email, password)
VALUES ('Admin User', 'ADMIN','admin@example.com','admin123'),
       ('John Doe', 'CUSTOMER' ,'john@example.com', 'password123'),
       ('Jane Smith', 'STAFF','jane@example.com', 'password456'),
       ('Bob Johnson', 'STAFF','bob@example.com', 'password789'),
       ('Alice Brown', 'CUSTOMER','alice@example.com', 'password999');

-- CATEGORIES
INSERT INTO categories (name, description)
VALUES ('Plants', 'Various kinds of plants'),
       ('Fish', 'Aquarium fish'),
       ('Accessories', 'Decorations and accessories');

-- PRODUCTS
INSERT INTO products (name, description, price, stock_quantity, category_id)
VALUES ('Aloe Vera', 'Fresh Aloe Vera plant', 100000, 50, 1),
       ('Peace Lily', 'Indoor plant, air purifier', 150000, 30, 1),
       ('Goldfish', 'Small freshwater fish', 50000, 100, 2),
       ('Betta Fish', 'Colorful fighting fish', 80000, 40, 2),
       ('Aquarium Rocks', 'Decorative stones for aquarium', 20000, 200, 3),
       ('Spider Plant', 'Easy to grow plant', 75000, 60, 1),
       ('Tetra Fish', 'Small colorful fish', 35000, 150, 2);

-- ORDERS (with dates across multiple months in 2024)
INSERT INTO orders (user_id, total_amount, status, created_at)
VALUES
-- January 2024
(2, 200000, 'COMPLETED', '2024-01-15'),
(3, 150000, 'COMPLETED', '2024-01-20'),
-- April 2024
(4, 180000, 'COMPLETED', '2024-04-10'),
(5, 220000, 'COMPLETED', '2024-04-25'),
-- July 2024
(2, 195000, 'COMPLETED', '2024-07-08'),
(3, 310000, 'COMPLETED', '2024-07-22'),
-- October 2024
(4, 250000, 'COMPLETED', '2024-10-05'),
(5, 165000, 'COMPLETED', '2024-10-18'),
-- Current month (November/December 2024)
(2, 95000, 'COMPLETED', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 220000, 'COMPLETED', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 155000, 'CREATED', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- ORDER ITEMS (Fixed NULL values and additional items)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
-- Order 1 (Jan)
(1, 1, 2, 100000),
-- Order 2 (Jan)
(2, 3, 2, 50000),
(2, 5, 1, 30000),
-- Order 3 (Apr)
(3, 1, 1, 100000),
(3, 2, 1, 150000),
-- Order 4 (Apr)
(4, 4, 2, 80000),
(4, 7, 1, 35000),
-- Order 5 (Jul)
(5, 6, 1, 75000),
(5, 3, 2.5, 50000),
-- Order 6 (Jul)
(6, 2, 2, 150000),
(6, 4, 1, 80000),
-- Order 7 (Oct)
(7, 1, 2, 100000),
(7, 7, 1, 35000),
-- Order 8 (Oct)
(8, 5, 2, 20000),
(8, 6, 1, 75000),
-- Order 9 (Nov/Dec - Recent)
(9, 1, 1, 75000),
(9, 3, 1, 20000),
-- Order 10 (Nov/Dec - Recent)
(10, 2, 1, 150000),
(10, 4, 0.5, 40000),
-- Order 11 (Pending - not enough items)
(11, 1, 1, 100000);

-- PAYMENTS (with dates matching orders and various payment methods/statuses)
INSERT INTO payments (order_id, amount, payment_method, status, paid_at, created_at)
VALUES
-- January 2024
(1, 200000, 'CREDIT_CARD', 'SUCCESS', '2024-01-15', '2024-01-15'),
(2, 150000, 'BANK_TRANSFER', 'SUCCESS', '2024-01-20', '2024-01-20'),
-- April 2024
(3, 180000, 'E_WALLET', 'SUCCESS', '2024-04-10', '2024-04-10'),
(4, 220000, 'CREDIT_CARD', 'SUCCESS', '2024-04-25', '2024-04-25'),
-- July 2024
(5, 195000, 'BANK_TRANSFER', 'SUCCESS', '2024-07-08', '2024-07-08'),
(6, 310000, 'E_WALLET', 'SUCCESS', '2024-07-22', '2024-07-22'),
-- October 2024
(7, 250000, 'CREDIT_CARD', 'SUCCESS', '2024-10-05', '2024-10-05'),
(8, 165000, 'CASH', 'SUCCESS', '2024-10-18', '2024-10-18'),
-- Recent (Current month)
(9, 95000, 'CREDIT_CARD', 'SUCCESS', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(10, 220000, 'BANK_TRANSFER', 'SUCCESS', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- Failed payment
(11, 155000, 'CREDIT_CARD', 'FAILED', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
-- Additional failed payment for analytics
(1, 200000, 'E_WALLET', 'FAILED', NULL, '2024-01-14');

-- SHIPMENTS (with dates matching orders, various carriers, and statuses)
INSERT INTO shipments (order_id, carrier_name, tracking_number, delivery_address, city, postal_code, country, shipping_cost, status, shipped_at, expected_delivery_date, delivered_at, created_at)
VALUES
-- January shipments
(1, 'GRAB', 'GRAB001', '123 Green St', 'Hanoi', '100000', 'Vietnam', 25000, 'DELIVERED', '2024-01-16', '2024-01-18', '2024-01-17', '2024-01-15'),
(2, 'GIAO_HANG_NHANH', 'GHN002', '456 Blue Rd', 'Ho Chi Minh City', '700000', 'Vietnam', 30000, 'DELIVERED', '2024-01-21', '2024-01-23', '2024-01-22', '2024-01-20'),
-- April shipments
(3, 'VIETTEL_POST', 'VTP003', '789 Red Ave', 'Da Nang', '550000', 'Vietnam', 28000, 'DELIVERED', '2024-04-11', '2024-04-13', '2024-04-13', '2024-04-10'),
(4, 'GRAB', 'GRAB004', '321 Yellow Ln', 'Hanoi', '100001', 'Vietnam', 32000, 'DELIVERED', '2024-04-26', '2024-04-28', '2024-04-28', '2024-04-25'),
-- July shipments
(5, 'GIAO_HANG_NHANH', 'GHN005', '654 Purple Dr', 'Ho Chi Minh City', '700001', 'Vietnam', 25000, 'DELIVERED', '2024-07-09', '2024-07-11', '2024-07-10', '2024-07-08'),
(6, 'VIETTEL_POST', 'VTP006', '987 Orange Ct', 'Hanoi', '100002', 'Vietnam', 29000, 'DELIVERED', '2024-07-23', '2024-07-25', '2024-07-24', '2024-07-22'),
-- October shipments
(7, 'GRAB', 'GRAB007', '654 Pink Dr', 'Hanoi', '100003', 'Vietnam', 26000, 'DELIVERED', '2024-10-06', '2024-10-08', '2024-10-08', '2024-10-05'),
(8, 'GIAO_HANG_NHANH', 'GHN008', '789 Blue Ave', 'Ho Chi Minh City', '700002', 'Vietnam', 31000, 'DELIVERED', '2024-10-19', '2024-10-21', '2024-10-20', '2024-10-18'),
-- Recent shipments (current month)
(9, 'GRAB', 'GRAB009', '123 Brown St', 'Hanoi', '100004', 'Vietnam', 27000, 'DELIVERED', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 0 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(10, 'VIETTEL_POST', 'VTP010', '456 Green Ln', 'Ho Chi Minh City', '700003', 'Vietnam', 30000, 'IN_TRANSIT', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- Pending order without shipment (will be created later or not)
(11, 'GRAB', 'GRAB011', '789 Red St', 'Da Nang', '550001', 'Vietnam', 28000, 'PROCESSING', NULL, DATE_ADD(NOW(), INTERVAL 3 DAY), NULL, DATE_SUB(NOW(), INTERVAL 1 DAY));




