-- FINAL TEST
-- DITA ARTININGTYAS
-- KELOMPOK 12


-- Create raw tables
CREATE TABLE raw_users (
user_id INT,
user_name VARCHAR(100),
country VARCHAR(50)
);
CREATE TABLE raw_posts (
post_id INT,
post_text VARCHAR(500),
post_date DATE,
user_id INT
);
CREATE TABLE raw_likes (
like_id INT,
user_id INT,
post_id INT,
like_date DATE
);
-- Insert sample data
INSERT INTO raw_users
VALUES
(1, 'john_doe', 'Canada'),
(2, 'jane_smith', 'USA'),
(3, 'bob_johnson', 'UK');
INSERT INTO raw_posts
VALUES
(101, 'My first post!', '2020-01-01', 1),
(102, 'Having fun learning SQL', '2020-01-02', 2),
(103, 'Big data is cool', '2020-01-03', 1),
(104, 'Just joined this platform', '2020-01-04', 3),
(105, 'Whats everyone up to today?', '2020-01-05', 2),
(106, 'Data science is the future', '2020-01-06', 1),
(107, 'Practicing my SQL skills', '2020-01-07', 2),
(108, 'Hows the weather where you are?', '2020-01-08', 3),
(109, 'TGI Friday!', '2020-01-09', 1),
(110, 'Any big plans for the weekend?', '2020-01-10', 2);
INSERT INTO raw_likes
VALUES
(1001, 1, 101, '2020-01-01'),
(1002, 3, 101, '2020-01-02'),
(1003, 2, 102, '2020-01-03'),
(1004, 1, 103, '2020-01-04'),
(1005, 3, 104, '2020-01-05'),
(1006, 2, 104, '2020-01-06'),
(1007, 1, 105, '2020-01-07'),
(1008, 2, 106, '2020-01-08'),
(1009, 3, 107, '2020-01-09'),
(1010, 1, 108, '2020-01-10'),
(1011, 2, 109, '2020-01-11'),
(1012, 3, 110, '2020-01-12');


-- 1. Please create dimension tables dim_user , dim_post , and dim_date to store normalized data from the raw tables

CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(255),
    country VARCHAR(255)
);

CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text TEXT,
    user_id INT,
    post_date DATE,
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    date DATE
);



-- 2. Populate the dimension tables by inserting data from the related raw tables

-- Insert data into dim_user
INSERT INTO dim_user (user_id, user_name, country)
SELECT user_id, user_name, country
FROM raw_users;

-- Insert data into dim_post
INSERT INTO dim_post (post_id, post_text, user_id, post_date)
SELECT post_id, post_text, user_id, post_date
FROM raw_posts;


-- 3. Create a fact table called fact_post_performance to store metrics like post views and likes over time

CREATE TABLE fact_post_performance (
    post_id INT,
    date_id INT,
    views INT,
    likes INT,
    FOREIGN KEY (post_id) REFERENCES dim_post(post_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);



-- 4. Populate the fact table by joining and aggregating data from the raw tables

-- Insert data into fact_post_performance
INSERT INTO fact_post_performance (post_id, date_id, views, likes)
SELECT p.post_id, d.date_id, COUNT(DISTINCT v.user_id) AS views, COUNT(DISTINCT l.user_id) AS likes
FROM dim_post p
JOIN dim_date d ON p.post_date = d.date
LEFT JOIN raw_likes l ON p.post_id = l.post_id
LEFT JOIN raw_views v ON p.post_id = v.post_id
GROUP BY p.post_id, d.date_id;



-- 5. Please create a fact_daily_posts table to capture the number of posts per user per day

CREATE TABLE fact_daily_posts (
    user_id INT,
    date_id INT,
    daily_posts INT,
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);


-- 6. Also populate the fact table by joining and aggregating data from the raw tables

-- Insert data into fact_daily_posts
INSERT INTO fact_daily_posts (user_id, date_id, daily_posts)
SELECT p.user_id, d.date_id, COUNT(p.post_id) AS daily_posts
FROM dim_post p
JOIN dim_date d ON p.post_date = d.date
GROUP BY p.user_id, d.date_id;




