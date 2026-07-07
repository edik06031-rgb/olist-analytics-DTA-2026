-- головний датасет
SELECT 
	o.order_id,
    o.order_purchase_t,
    strftime('%Y-%m',o.order_purchase_t) as ym,
    cu.customer_state,
    t.product_category_1 AS category_en,
    oi.price,
    oi.freight_value,
    op.payment_type AS payment_method,
    r.review_score
    
    
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
JOIN olist_customers_dataset cu USING (customer_id)
JOIN olist_products_dataset p USING (product_id)
left JOIN product_category_name_translation t USING (product_category)
LEFT JOIN olist_order_payments_dataset op USING (order_id)
LEFT JOIN olist_order_reviews_dataset r USING (order_id)
WHERE order_status = 'delivered';



- Місячний виторг і кількість замовлень
- Виторг зростає** протягом 2017-2018 зі стабільним трендом (~41.6К приросту щомісяця на
  стабільному періоді 2017-01 → 2018-08, R² ≈ 0.815).
- Листопад — сплеск понад тренд** (Black Friday в Бразилії): найбільше позитивне відхилення
  виторгу від лінії тренду серед усіх календарних місяців.
	
SELECT
	strftime('%Y-%m', o.order_purchase_t) AS ym,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY ym
ORDER BY ym;

-- розвідувальні запити
-- топ 10 категорій за виторгом

1. Health_beaty
2. watches_gifts
3.bad_bath_table
4.sports_leisure
5. computers_accessories
6. furniture_decor
7. hausewares
8.cool_stuff
9. auto
10. toys

	
SELECT
	t.product_category_1 AS category_en,
    round(sum(oi.price), 2) AS revenue

FROM olist_order_items_dataset oi
join olist_orders_dataset o USING (order_id)
JOIN olist_products_dataset p USING(product_id)
LEFT JOIN product_category_name_translation t USING (product_category)
where o.order_status = 'delivered'
GROUP By category_en
ORDER by revenue DESC
LIMIT 10;

-- виторг за штатами (для карти в Tableau)
-- тройка лідерів штати SP,RJ,MG

	
SELECT
	cu.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
JOIN olist_customers_dataset cu USING (customer_id)
WHERE o.order_status = 'delivered'
GROUP BY cu.customer_state
ORDER BY revenue DESC;


--      середня оцінка (review_score) за категоріями

-- середня оцінка по категоріям від 3.49 до 4.45

SELECT
	t.product_category_1 AS category_en,
    round(avg(r.review_score), 2) as avg_score,
    COUNT(*) AS reviews

FROM olist_order_reviews_dataset r 
JOIN olist_order_items_dataset oi USING (order_id)
JOIN olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category)
GROUP BY category_en
HAVING reviews > 50
ORDER BY avg_score DESC;

-- середній час доставки (різниця між датою купівлі і датою доставки); 

-- Північні штати** (Roraima, Amapá, Amazonas, Alagoas, Pará, Maranhão) мають найдовшу доставку
  (22-29 днів проти ~12.6 в середньому) і помітно нижчі оцінки покупців — операційна проблема,
  яку можна виправити логістикою, без зміни асортименту.

SELECT
	round(avg(julianday(order_delivered_6) - julianday(order_purchase_t)), 1) As avg_delivery_days

FROM olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_6 is not NULL;


--  розподіл способів оплати. 
-- ми бачимо що способ оплати кредитною картою наймассовіший
- - 76.9% замовлень оплачено кредитною карткою, 19.9% — boleto (бразильський банківський рахунок).

SELECT
	payment_type,
    COUNT(*) AS n,
    round(sum(payment_value), 2) AS total_value

from olist_order_payments_dataset
GROUP BY payment_type
ORDER BY n DESC;

