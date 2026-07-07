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
