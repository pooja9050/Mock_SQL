#1045. Customers Who Bought All Products
# Write your MySQL query statement below
SELECT customer_id
FROM customer
GROUP BY customer_id
Having count(DISTINCT product_key)
=(SELECT count(product_key) FROM Product p);


#1070. Product Sales Analysis III
# Write your MySQL query statement below
WITH CTE AS (SELECT product_id, MIN(year) AS 'first_year'
FROM Sales 
GROUP BY product_id)

SELECT s.product_id, s.year AS first_year, s.quantity,s.price
FROM Sales s
Having s.year =(SELECT first_year FROM CTE c
WHERE s.product_id = c.product_id)
ORDER BY product_id;


#1159. Market Analysis II
# Write your MySQL query statement below
With CTE AS (
    SELECT seller_id, item_brand, RANK() OVER(PARTITION BY seller_id 
    ORDER BY order_date) AS rnk
    FROM Orders o JOIN Items t ON o.item_id = t.item_id),
second_order AS(
    SELECT * FROM CTE WHERE rnk=2
)
SELECT u.user_id seller_id,
CASE WHEN u.favorite_brand = so.item_brand THEN 'yes'
ELSE 'no'
END AS 2nd_item_fav_brand
FROM Users u LEFT JOIN second_order so
ON u.user_id = so.seller_id;


#Alternative 
WITH CTE AS (SELECT o.seller_id, o.item_id, i.item_brand FROM
(SELECT seller_id,item_id,ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY order_date) AS rnk 
FROM Orders) o
JOIN Items i 
ON o.item_id = i.item_id
WHERE o.rnk = 2)

SELECT u.user_id AS seller_id,
 IF(c.item_brand = u.favorite_brand, 'yes', 'no') AS 2nd_item_fav_brand
FROM CTE c 
RIGHT JOIN Users u 
ON c.seller_id = u.user_id;


#1194. Tournament Winners. # Write your MySQL query statement below
SELECT group_id, player_id
FROM (
    SELECT p.group_id, p.player_id, RANK() OVER(PARTITION BY p.group_id ORDER BY SUM(
        CASE WHEN p.player_id = m.first_player THEN m.first_score
        ELSE m.second_score
        END
    ) DESC, p.player_id) AS 'rnk' FROM Players p
    JOIN Matches m
    ON p.player_id IN (m.first_player, m.second_player)
    GROUP BY p.group_id, p.player_id) AS intermediate
    WHERE rnk = 1;

#Alternative approach
WITH CTE AS (
    SELECT first_player AS player, first_score AS score 
    FROM Matches
    UNION ALL
    SELECT second_player AS player, second_score AS score 
    FROM Matches
),
ACTE AS (
    SELECT c.player, SUM(c.score) AS score, p.group_id 
    FROM CTE c
    JOIN Players p ON c.player = p.player_id
    GROUP BY c.player
)

SELECT group_id, player_id 
FROM (
    SELECT group_id, player AS player_id, ROW_NUMBER() OVER(PARTITION BY group_id ORDER BY score DESC, player) AS rn 
    FROM ACTE
) a
WHERE a.rn = 1;


#1445. Apples & Oranges
# Write your MySQL query statement below
SELECT sale_date, SUM(CASE WHEN fruit = 'apples' THEN sold_num
WHEN fruit = 'oranges' THEN -1*sold_num 
END) AS diff
FROM Sales
GROUP BY sale_date
ORDER BY sale_date;


#1407. Top Travellers using COALESCE function
# Write your MySQL query statement below
SELECT u.name, COALESE(SUM(r.distance),0) AS travelled_distance
FROM Users u
LEFT JOIN Rides r ON u.id = r.user_id
GROUP BY r.user_id
ODER BY travelled_distance DESC, u.name;
