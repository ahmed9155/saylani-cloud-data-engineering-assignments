-- ============================================================
--  ASSIGNMENT 01 — Querying, Sorting & Filtering (Review + New)
--  Database : BikeStores
--  Topics   : SELECT, WHERE, ORDER BY, TOP/OFFSET-FETCH, DISTINCT,
--             AND / OR, IN / NOT IN, BETWEEN, IS NULL, Aliases, LIKE
-- ============================================================


-- ============================================================
--  Question 1 — SELECT, WHERE & AND
--  The operations team wants a roster of active staff members
--  working at store_id = 1.
--  Retrieve the staff_id, first_name, last_name, and email of
--  every staff member where store_id = 1 AND active = 1.
-- ============================================================

-- Write your query below:

select staff_id, first_name, last_name, email  from sales.staffs
where store_id = 1 AND active = 1.




-- ============================================================
--  Question 2 — ORDER BY (Multiple Columns)
--  Retrieve product_id, product_name, category_id, and list_price
--  for all products.
--  Sort the results by category_id ascending, and within the
--  same category sort by list_price descending.
-- ============================================================

-- Write your query below:

select product_id, product_name, category_id,list_price from  production.products ORDER BY category_id ASC,list_price desc


-- ============================================================
--  Question 3 — TOP N & TOP PERCENT
--  a) The logistics team wants to see the 3 most recently placed
--     orders. Return order_id, customer_id, and order_date for
--     the top 3 orders, most recent first.
--  b) Return the top 10 percent of products by list_price
--     (all columns). How many rows does that return? Add the
--     row count as a comment in your answer.
-- ============================================================

-- Part a:

select top(3) order_id, customer_id, order_date  from sales.orders order by order_date desc

-- Part b:
select top 10 percent  * from [production].[products] ORDER BY list_price asc
 -- Row Count is 33


-- ============================================================
--  Question 4 — OFFSET & FETCH (Pagination)
--  Customer support is browsing the customer list alphabetically
--  by last name, 10 customers per page.
--  Write a single query that returns ONLY page 2 (rows 11-20).
-- ============================================================

-- Write your query below:
SELECT *
FROM [sales].[customers]
ORDER BY last_name
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;



-- ============================================================
--  Question 5 — DISTINCT
--  a) The purchasing team wants to know which brands currently
--     have at least one product priced above $1,000.
--     List the distinct brand_id values that qualify.
--  b) List every distinct combination of category_id and
--     model_year that appears in production.products, sorted
--     by category_id then model_year.
-- ============================================================

-- Part a:
select distinct brand_id from [production].[products] where list_price>1000 

-- Part b:
select distinct category_id , model_year  from production.products ORDER BY category_id,model_year




-- ============================================================
--  Question 6 — IN / NOT IN
--  a) Store managers for store_id 1 and 3 want a combined list
--     of every order placed at either store. Show order_id,
--     store_id, and order_date for orders where store_id IN (1, 3).
--  b) A different team wants every order that was NOT placed at
--     store_id 2. Show the same three columns.
-- ============================================================

-- Part a:
select order_ID,store_ID,order_date from sales.orders where store_ID in (1,3)

-- Part b:

select order_ID,store_ID,order_date from sales.orders where store_ID not in (2)


-- ============================================================
--  Question 7 — BETWEEN combined with AND / OR
--  Find every product that meets ALL of the following:
--    - list_price is between $300 and $1,200 (inclusive)
--    - model_year is 2017 OR 2018
--  Show product_name, model_year, and list_price, sorted by
--  list_price ascending.
--  Hint: use parentheses to control the order of evaluation.
-- ============================================================

-- Write your query below:


select * from production.products where list_price between 300 and 1200 and (model_year=2017 OR model_year=2018) 
ORDER BY list_price

-- ============================================================
--  Question 8 — IS NULL / IS NOT NULL
--  HR is reviewing the staff reporting structure.
--  a) List every staff member who has NO manager (the top of
--     the org chart). Show staff_id, first_name, and last_name.
--  b) List every staff member who DOES have a manager on record.
--     Show staff_id, first_name, last_name, and manager_id.
-- ============================================================

-- Part a:

select staff_id, first_name,  last_name from sales.staffs where manager_id is NULL

-- Part b:
select staff_id, first_name,  last_name,manager_id from sales.staffs where manager_id is NOT NULL



-- ============================================================
--  Question 9 — Aliases & LIKE
--  Marketing wants a mailing list of every customer whose email
--  address is hosted on gmail.com.
--  Show the customer's full name as full_name (built from
--  first_name + last_name) and their email, using a table alias
--  for sales.customers. Sort by full_name ascending.
-- ============================================================

-- Write your query below:

select customers.first_name + ' ' + customers.last_name AS Customer_FullName,customers.email  from sales.customers AS customers ORDER BY (customers.first_name + customers.last_name)


-- ============================================================
--  END OF ASSIGNMENT 01
-- ============================================================

