-- ============================================================
--  ASSIGNMENT 02 — Joins
--  Database : BikeStores
-- ============================================================


-- ============================================================
--  Question 1
--  Retrieve the product_name, list_price, and category_name
--  for every product.
--  Use production.products and production.categories.
--  Sort the results by product_name ascending.
-- ============================================================

-- Write your query below:

select product.product_name,product.list_price,category_name from production.products product INNER JOIN production.categories category
ON product.category_id=category.category_id ORDER BY product.product_name


-- ============================================================
--  Question 2
--  Show the customer full name (as full_name), order_id,
--  and order_date for all customers who have placed an order.
--  Use sales.customers and sales.orders.
--  Sort by order_date descending.
-- ============================================================

-- Write your query below:
select customer.first_name + ' ' + customer.last_name AS "Customer_Name",orders.order_id,order_date from sales.orders orders INNER JOIN sales.customers customer ON orders.customer_id=customer.customer_id
ORDER BY orders.order_date desc


-- ============================================================
--  Question 3
--  Retrieve product_name, list_price, category_name, and
--  brand_name for every product.
--  Use production.products, production.categories,
--  and production.brands.
--  Sort by brand_name then product_name (both ascending).
-- ============================================================

-- Write your query below:

select product.product_name,product.list_price,category.category_name,brand.brand_name from production.products product INNER JOIN production.categories category
ON product.category_id=category.category_id INNER JOIN production.brands brand on product.brand_id=brand.brand_id
ORDER BY brand.brand_name,product.product_name

-- ============================================================
--  Question 4
--  List all products along with their order_id and item_id.
--  Make sure products that have NEVER been ordered also appear
--  in the result (those rows will have NULL for order_id
--  and item_id).
--  Use production.products and sales.order_items.
--  Sort by order_id ascending.
-- ============================================================

-- Write your query below:

select product.product_id,orderitem.order_id,orderitem.item_id  from production.products product 
left JOIN sales.order_items orderitem 
ON product.product_id=orderitem.product_id
ORDER BY orderitem.order_id

-- ============================================================
--  Question 5
--  Using your answer from Question 4 as a base, filter the
--  results to show ONLY the products that have never been
--  ordered.
--  Display only product_id and product_name.
-- ============================================================

-- Write your query below:
select product.product_id,orderitem.order_id,orderitem.item_id  from production.products product 
left JOIN sales.order_items orderitem 
ON product.product_id=orderitem.product_id
where orderitem.order_id is NULL
ORDER BY orderitem.order_id

-- ============================================================
--  Question 6
--  Show all stores along with any orders placed at each store.
--  Display store_name, store_id (from stores), order_id,
--  and order_date.
--  Every store must appear in the result, even if it has
--  no orders yet.
--  Use sales.orders and sales.stores.
-- ============================================================
-- Write your query below:
select store.store_name,store.store_id,orders.order_id,orders.order_date from sales.stores store 
left Join sales.orders orders
ON store.store_id=orders.store_id
ORDER BY store.store_name

-- ============================================================
--  Question 7
--  List every staff member alongside their manager's name.
--  Display:
--    • staff full name   (as staff_name)
--    • manager full name (as manager_name)
--  Use only the sales.staffs table.
--  Staff who have no manager should NOT appear in the result.
-- ============================================================

-- Write your query below:

select staff.first_name + ' '+ staff.last_name AS staff_name,manager.first_name + ' '+ manager.last_name AS manager_name  from sales.staffs staff 
LEFT JOIN sales.staffs manager 
on staff.manager_id=manager.staff_id  order by 2


-- ============================================================
--  Question 8
--  Generate every possible combination of store name and
--  brand name.
--  Display store_name and brand_name.
--  Use sales.stores and production.brands.
--  How many total rows do you expect?
--  Write the expected count as a comment next to your query.
-- ============================================================

-- Write your query below:

SELECT     stores.store_name,
    brands.brand_name
FROM sales.stores AS stores
CROSS JOIN production.brands AS brands;

-- ============================================================
--  Question 9
--  Retrieve the customer full name (as full_name), order_id,
--  order_date, product_name, and list_price for every order
--  that has been placed.
--  Use sales.customers, sales.orders, sales.order_items,
--  and production.products.
--  Sort by order_date ascending, then full_name ascending.
-- ============================================================

-- Write your query below:

SELECT customer.first_name + ' ' +customer.last_name AS Full_Name, orders.order_id,orders.order_date,product.product_name,item.list_price  from sales.orders orders 
INNER JOIN  sales.customers customer ON orders.customer_id=customer.customer_id
INNER JOIN sales.order_items item ON orders.order_id=item.order_id
INNER JOIN production.products product ON item.product_id=product.product_id
