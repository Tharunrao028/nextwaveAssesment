
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    phone_number VARCHAR(15),
    mail_id VARCHAR(100),
    billing_address VARCHAR(255)
);

CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100),
    item_rate DECIMAL(10,2)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);
INSERT INTO users VALUES
('21wrcxuy-67erfn', 'John Doe', '9700000001', 'john.doe@example.com', 'XX, Street Y, ABC City'),
('22abcdxy-98ergh', 'Jane Smith', '9700000002', 'jane.smith@example.com', 'YY, Street Z, XYZ City'),
('23pqrsuv-45tyui', 'Robert Brown', '9700000003', 'robert.brown@example.com', 'ZZ, Street A, LMN City');
INSERT INTO bookings VALUES
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn'),
('bk-12gh7-88kl', '2021-10-15 10:20:00', 'rm-a12b-c34d', '22abcdxy-98ergh'),
('bk-77mn8-44op', '2021-11-05 14:10:30', 'rm-x9y8-z7w6', '23pqrsuv-45tyui');
INSERT INTO items VALUES
('itm-a9e8-q8fu', 'Tawa Paratha', 18),
('itm-a07vh-aer8', 'Mix Veg', 89),
('itm-w978-23u4', 'Paneer Butter Masala', 150),
('itm-zx12-98lk', 'Dal Fry', 120);
INSERT INTO booking_commercials VALUES
('q34r-3q4o8-q34u', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('q3o4-ahf32-o2u4', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1),
('134lr-oyfo8-3qk4', 'bk-12gh7-88kl', 'bl-34qhd-r7h8', '2021-10-15 13:05:37', 'itm-w978-23u4', 2),
('34qj-k3q4h-q34k', 'bk-77mn8-44op', 'bl-77asd-998k', '2021-11-05 15:20:10', 'itm-zx12-98lk', 1.5);



SELECT * FROM users;
SELECT * FROM bookings;
SELECT * FROM items;
SELECT * FROM booking_commercials;




SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) lb
ON b.user_id = lb.user_id
AND b.booking_date = lb.last_booking;


SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;

SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;


WITH monthly_items AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
    FROM monthly_items
)
SELECT month, item_id, total_qty, 'MOST_ORDERED' AS type
FROM ranked
WHERE max_rank = 1

UNION ALL

SELECT month, item_id, total_qty, 'LEAST_ORDERED' AS type
FROM ranked
WHERE min_rank = 1;


WITH monthly_bills AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        b.user_id,
        bc.bill_id,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, b.user_id, bc.bill_id
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS rnk
    FROM monthly_bills
)
SELECT month, user_id, bill_id, bill_amount
FROM ranked
WHERE rnk = 2;