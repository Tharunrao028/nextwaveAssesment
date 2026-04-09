CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(15)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount DECIMAL(10,2),
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(255),
    amount DECIMAL(10,2),
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);
-- CLINICS
INSERT INTO clinics VALUES
('cnc-0100001','XYZ Clinic','Hyderabad','Telangana','India'),
('cnc-0100002','ABC Clinic','Hyderabad','Telangana','India'),
('cnc-0100003','PQR Clinic','Bangalore','Karnataka','India');

-- CUSTOMERS
INSERT INTO customer VALUES
('u001','John Doe','9700000001'),
('u002','Jane Smith','9700000002'),
('u003','Robert Brown','9700000003');

-- SALES
INSERT INTO clinic_sales VALUES
('ord-001','u001','cnc-0100001',25000,'2021-09-23 12:03:22','online'),
('ord-002','u002','cnc-0100001',15000,'2021-09-25 10:00:00','offline'),
('ord-003','u001','cnc-0100002',20000,'2021-10-10 11:30:00','online'),
('ord-004','u003','cnc-0100003',30000,'2021-10-15 09:45:00','agent');

-- EXPENSES
INSERT INTO expenses VALUES
('exp-001','cnc-0100001','Medicines',5000,'2021-09-23 07:36:48'),
('exp-002','cnc-0100001','Maintenance',3000,'2021-09-25 08:00:00'),
('exp-003','cnc-0100002','Staff Salary',7000,'2021-10-10 09:00:00'),
('exp-004','cnc-0100003','Equipment',10000,'2021-10-15 08:00:00');

SELECT 
    sales_channel,
    SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

WITH revenue AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY month
),
expense_cte AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY month
)
SELECT 
    r.month,
    r.revenue,
    e.expense,
    (r.revenue - e.expense) AS profit,
    CASE 
        WHEN (r.revenue - e.expense) > 0 THEN 'PROFITABLE'
        ELSE 'NOT_PROFITABLE'
    END AS status
FROM revenue r
JOIN expense_cte e ON r.month = e.month;

WITH profit_calc AS (
    SELECT 
        c.city,
        c.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid 
        AND DATE_FORMAT(e.datetime,'%Y-%m') = '2021-09'
    WHERE DATE_FORMAT(cs.datetime,'%Y-%m') = '2021-09'
    GROUP BY c.city, c.cid
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM profit_calc
)
SELECT * FROM ranked WHERE rnk = 1;

WITH profit_calc AS (
    SELECT 
        c.state,
        c.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid 
        AND DATE_FORMAT(e.datetime,'%Y-%m') = '2021-10'
    WHERE DATE_FORMAT(cs.datetime,'%Y-%m') = '2021-10'
    GROUP BY c.state, c.cid
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM profit_calc
)
SELECT * FROM ranked WHERE rnk = 2;